//
//  CompanyListManager.m
//  NavCtrl
//
//  Created by bl on 2/7/17.
//  Copyright © 2017 bl. All rights reserved.
//


#import "CompanyListManager.h"


@implementation CompanyListManager
{
    NSMutableArray *_companies;
    CompanyListEditor *_companyListEditor;
    CompanyListTableViewInterface *_companyListTableViewInterface;
    BOOL _isStockDataStale;
    NSString *_lastErrorMsg;
    StockDataFeed *_stockDataFeed;
}

#pragma mark - Properties

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Getter method for count property.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) count
{
    return (nil == _companies)? 0 : _companies.count;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Getter method to return a CompanyListEditor.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (CompanyListEditor *) editor
{
    return _companyListEditor;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Getter method to return a CompanyListTableViewInterface.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (CompanyListTableViewInterface *) tableViewInterface
{
    return _companyListTableViewInterface;
}

#pragma mark - Public Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to linearly search the companies array for a company.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (Company *) getCompany:(NSString *)name
{
    for (NSInteger i = 0; i < _companies.count; ++i)
        if ([((Company *) _companies[i]).name isEqualToString:name])
            return [(Company *) _companies[i] copy];
    
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to retrieve a company at location specified by argument index.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (Company *) getCompanyWithDisplayIndex:(NSInteger)index
{
    return _companies[index];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to perform a standard initialization.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) init
{
    if (self = [super init])
    {
        _companyListEditor = [[CompanyListEditor alloc] initWithList:self];
        _companyListTableViewInterface = [[CompanyListTableViewInterface alloc] initWithList:self];

        DataAccessObject *dao = [DataAccessObject sharedInstance];
        dao.companyDelegate = self;
        
        _stockDataFeed = [[StockDataFeed alloc] init];
        _stockDataFeed.delegate = self;
    }
    
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method return YES, if stock data hasn't been updated recently. Otherwise, return NO.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) isStockDataStale
{
    return _isStockDataStale;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to initiate a load of all the company from the DAO.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) readAll
{
    DataAccessObject *dao = [DataAccessObject sharedInstance];

    [dao readAll];
}

#pragma mark - DAO Delegate Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by DAO when a company has been deleted.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didDeleteCompanyWithDisplayIndex:(NSInteger)index
{
    Company *company = (Company *) _companies[index];
    
    // Unregister the company's stock symbol first
    [_stockDataFeed unregisterStockSymbol:company.stockSymbol];
    
    // If this is the last company on the list then ...
    if (1 == _companies.count)
        // stop the real-time price feed
        [_stockDataFeed stop];
    
    // Delete the company from _companies to match the dao
    [_companies removeObjectAtIndex:index];
    
    // Propagate the notification to the next delegate
    [self.delegate didDeleteCompanyWithDisplayIndex:index];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by DAO when an error occurred.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didGetDAOError:(NSString *)errorMsg
{
    [self.delegate didGetCompanyListError:errorMsg];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by DAO when a company has been added.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didInsertCompany:(Company *)company
         withDisplayIndex:(NSInteger)index;
{
    // Insert the company at the desired position
    [_companies insertObject:company atIndex:index];

    // Register the stock symbol of the new company
    [_stockDataFeed registerStockSymbol:company.stockSymbol];
    
    // If this is the first company on the list then ...
    if (1 == _companies.count)
        // start the feed for real-time price updates
        [_stockDataFeed start];

    // Propagate the notification to the next delegate
    [self.delegate didAddCompany];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by DAO when all the companies have been read in.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didReadAll:(NSMutableArray *)companiesFromDAO
{
    // Save the returned data
    _companies = companiesFromDAO;

    // If there is data from the DAO then ...
    if (_companies.count)
    {
        // Register all the stock symbols in the list
        for (int i = 0; i < _companies.count; ++i)
            [_stockDataFeed registerStockSymbol:((Company *) _companies[i]).stockSymbol];
        
        // Start feed for real-time price updates
        [_stockDataFeed start];
    }
    
    // Propagate the notification to the next delegate
    [self.delegate didReadAll];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by DAO when the display order of a company has changed.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didUpdateCompanyDisplayIndexFrom:(NSInteger)currentIndex
                                       to:(NSInteger)newIndex
{
    Company *temp = _companies[currentIndex];
    
    // Delete the company record in the current slot
    [_companies removeObjectAtIndex:currentIndex];
    
    // Insert the company record in the new slot
    [_companies insertObject:temp atIndex:newIndex];
    
    // Propagate the notification to the next delegate
    [self.delegate didUpdateCompany];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by DAO when the content of a company has changed.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didUpdateCompany:(Company *)company
                 withName:(NSString *)oldName
{
    NSInteger index = [self findDisplayIndexForCompany:oldName];
    
    // Get the current stock symbol for the company
    NSString *stockSymbol = ((Company *)_companies[index]).stockSymbol;
    
    // If it has changed then ...
    if (![stockSymbol isEqualToString:company.stockSymbol])
    {
        // Remove the stock symbol from the data feed.
        [_stockDataFeed unregisterStockSymbol:stockSymbol];
        
        // Add the new stock symbol to the data feed.
        [_stockDataFeed registerStockSymbol:company.stockSymbol];
    }

    // Transfer the new values over
    Company *current = _companies[index];
    current.name = company.name;
    current.stockSymbol = company.stockSymbol;
    current.logoURL = company.logoURL;
    current.logoData = company.logoData;
    
    // Propagate the notification to the next delegate
    [self.delegate didUpdateCompany];
}

#pragma mark - StockDataFeed Delegate Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by StockDataFeed when an error occurred during the retrieval
//  of stock prices.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didGetFeedError:(NSString *)errorMsg
{
    BOOL sameMsg = NO;

    // Failed to get data from feed. All the stock data is now stale.
    _isStockDataStale = YES;
    
    // If there was an error message previously then ...
    if (_lastErrorMsg)
        // Determine if we are getting the same error
        sameMsg = [errorMsg isEqualToString:_lastErrorMsg];
    
    // Save the current error message
    _lastErrorMsg = [errorMsg copy];
    
    // If the error is not same as before then ...
    if (!sameMsg)
    {
        // Propagate the error message
        [self.delegate didGetCompanyListError:errorMsg];
        
        // Trigger display of stale data
        [self.delegate didUpdateStockPrices];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by StockDataFeed when all the stock prices have been
//  retrieved.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didGetStockData:(NSDictionary *)stockSymbolsAndPrices
{
    // Just received stock data, it is no longer stale.
    _isStockDataStale = NO;

    // Clear any previous error
    _lastErrorMsg = nil;
    
    // Loop through the list of stock symbols
    for (NSString *key in stockSymbolsAndPrices)
        // Loop through the list of companies.
        for (Company *company in _companies)
            // If the stock symbol match then ...
            if ([company.stockSymbol isEqualToString:key])
            {
                // save the stock price
                company.stockPrice = (NSString *)stockSymbolsAndPrices[key];
                
                break;
            }
    
    // Propagate the notification to the next delegate
    [self.delegate didUpdateStockPrices];
}

#pragma mark - Private Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to linearly search the _companies for a company. If found then returns its
//  display index. Otherwise, returns -1.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) findDisplayIndexForCompany:(NSString *)name
{
    for (NSInteger i = 0; i < _companies.count; ++i)
        if ([((Company *) _companies[i]).name isEqualToString:name])
            return i;
    
    return -1;
}

@end
