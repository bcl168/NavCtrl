//
//  StockDataFeed.m
//  NavCtrl
//
//  Created by bl on 2/6/17.
//  Copyright © 2017 bl. All rights reserved.
//


#import "StockDataFeed.h"

@interface StockDataFeed()
@property (nonatomic, retain) NSURLSession *session;
@end

@implementation StockDataFeed
{
    NSTimer *_feedTimer;
//    NSURLSession *_session;
    NSMutableArray *_stockSymbols;
    NSString *_URLCache;
}

#pragma mark - Public Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to perform a standard initialization.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) init
{
    if (self = [super init])
    {
        _stockSymbols = [[NSMutableArray alloc] init];

        NSURLSessionConfiguration *defaultConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:defaultConfiguration
                                                 delegate:nil
                                            delegateQueue:nil];
    }
    
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to add a stock symbol to a list of stocks to retrieve data for.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) registerStockSymbol:(NSString *)stockSymbol
{
    // If at max capacity then ...
    if (_stockSymbols.count >= MAX_QUOTE)
        // return failure
        return NO;
    
    // Search list for stockSymbol
    // If found then ...
    if (-1 != [self findStockSymbol:stockSymbol])
        // return failure, because it is a duplicate
        return NO;
    
    // Append stockSymbol to list
    [_stockSymbols addObject:[stockSymbol copy]];
    
    // Flush the cache since the list has changed
    _URLCache = nil;

    // Return success
    return YES;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to start the stock data feed going.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) start
{
    [self getStockPrices];

    // Set interval for 60 seconds
    const NSTimeInterval feedInterval = 60.0;
    
    // If in the main thread then ...
    if ([NSThread isMainThread])
        // Schedule the stock data feed
        _feedTimer = [NSTimer scheduledTimerWithTimeInterval:feedInterval
                                                      target:self
                                                    selector:@selector(getStockPrices)
                                                    userInfo:nil
                                                     repeats:YES];
    // Otherwise, ...
    else
        // Request the stock data feed be scheduled with the main thread
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           _feedTimer = [NSTimer scheduledTimerWithTimeInterval:feedInterval
                                                                         target:self
                                                                       selector:@selector(getStockPrices)
                                                                       userInfo:nil
                                                                        repeats:YES];
                       });
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to stop the stock data feed.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) stop
{
    // If in the main thread then ...
    if ([NSThread isMainThread])
        // stop the timer
        [_feedTimer invalidate];
    // Otherwise, ...
    else
        // Request the timer be stopped in the main thread
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [_feedTimer invalidate];
                       });
}


//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to remove a stock symbol from the list of stocks to retrieve data for.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) unregisterStockSymbol:(NSString *)stockSymbol
{
    // Search list for stockSymbol
    int index = [self findStockSymbol:stockSymbol];
    
    // If found then ...
    if (-1 != index)
    {
        // Remove stockSymbol from list
        [_stockSymbols removeObjectAtIndex:index];
        
        // Flush the cache since the list has changed
        _URLCache = nil;
    }
}

#pragma mark - Private Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to perform a linear search of the _stockSymbols array for a stock symbol.
//  Return index of stockSymbol in _stockSymbols if found. Otherwise, return -1.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (int) findStockSymbol:(NSString *)stockSymbol
{
    for (int i = 0; i < _stockSymbols.count; ++i)
        if ([stockSymbol isEqualToString:(NSString *)_stockSymbols[i]])
            return i;
    
    return -1;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to access stock prices from Yahoo's REST-compliant Web service.
//
//  Documentation can be found at http://www.jarloo.com/yahoo_finance/
//
//  Note: The following settings are required in info.plist
//        Added a Key called "App Transport Security Settings" as a Dictionary.
//        Added a Subkey called "Allows Arbitrary Loads" as Boolean and set its value to YES.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) getStockPrices
{
    // If the stock symbol list is empty then ...
    if (0 == _stockSymbols.count)
        // there is nothing to do, just exit
        return;
    
    // If the URL cache is empty then ...
    if (nil == _URLCache)
    {
        // Create and format url for requesting stock prices from Yahoo

        // Initialize url string with Yahoo's url and the first stock symbol
        NSMutableString *URLString = [NSMutableString stringWithFormat:@"https://finance.yahoo.com/d/quotes.csv?s=%@", _stockSymbols[0]];
        
        // Append any remaining stock symbols
        for (int i = 1; i < _stockSymbols.count; ++i)
            [URLString appendFormat:@"+%@", _stockSymbols[i]];
        
        // Append request for the following type of data
        //   s = symbol
        //   a = asking price
        [URLString appendString:@"&f=sa"];
        
        // Convert to NSString and save to cache
        // Note: When _URLCache was declared as NSMutableString, the code kept getting
        //       EXC_BAD_ACCESS on the second call to getStockPrices. It seems that
        //       that the string was not being retained despite ARC not being turned
        //       on.
        _URLCache = [URLString copy];
    }
    
    NSURL *url = [NSURL URLWithString:_URLCache];
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:url
                                         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
                                      NSString *errorMsg;
                                      
                                      // If there was a connectivity issues then
                                      if (error)
                                          // format an error message
                                          errorMsg = [NSString stringWithFormat:@"%@", error.localizedDescription];
                                      
                                      // If did not receive a HTTP response then
                                      else if (![response isKindOfClass:[NSHTTPURLResponse class]])
                                          // format an error message
                                          errorMsg = @"Invalid response from server.";
                                      
                                      else
                                      {
                                          // Extract the status code from the HTTP response
                                          NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                                          
                                          // If the HTTP GET was successful then ...
                                          if (statusCode == 200)
                                          {
                                              // Parse the returned csv
                                              NSString *content = [[NSString alloc] initWithBytes:[data bytes]
                                                                                           length:[data length]
                                                                                         encoding:NSUTF8StringEncoding];

                                              // Break up the csv into an array of rows
                                              NSArray *rows = [content componentsSeparatedByString:@"\n"];
                                              [content release];
                                              
                                              // Initialize the dictionary
                                              NSMutableDictionary *stockSymbolsAndPrices = [[NSMutableDictionary alloc] init];

                                              // Iterate through the rows ...
                                              for (NSString *row in rows)
                                              {
                                                  // Break up the row into an array of dataItems
                                                  NSArray* dataItems = [row componentsSeparatedByString:@","];
                                                  
                                                  NSString *stockSymbol = (NSString *) dataItems[0];
                                                  
                                                  // The last row of the csv will contain an empty stock symbol, ie just ""
                                                  // If not at last row then ...
                                                  if (stockSymbol.length > 2)
                                                  {
                                                      // Remove enclosing double quote from stock symbol
                                                      NSString *key = [stockSymbol substringWithRange: NSMakeRange(1, stockSymbol.length - 2)];
                                                      
                                                      // If the stock symbol is still registered then ...
                                                      if (-1 != [self findStockSymbol:key])
                                                          // transfer data into the dictionary
                                                          stockSymbolsAndPrices[key] = dataItems[1];
                                                  }
                                              }
                                              
                                              // Notify delegate that a new set prices are available
                                              dispatch_async(dispatch_get_main_queue(),
                                                             ^{
                                                                 [self.delegate didGetStockData:stockSymbolsAndPrices];
                                                                 [stockSymbolsAndPrices release];
                                                             });
                                              return;
                                          }
                                          // otherwise, ...
                                          else
                                              // format an error message about HTTP GET failure.
                                              errorMsg = [NSString stringWithFormat:@"HTTP GET status code: %ld", statusCode];
                                      }
                                      
                                      // Notify delegate that an error occurred
                                      dispatch_async(dispatch_get_main_queue(),
                                                     ^{
                                                         [self.delegate didGetFeedError:errorMsg];
                                                     });
                                      
                                      return;
                                  }];
    
    [task resume];
}

@end
