//
//  DataAccess.m
//  NavCtrl
//
//  Created by bl on 1/10/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import "DataAccessObject.h"
#import "Company.h"


static NSMutableArray *_companies;


@implementation DataAccessObject


//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method implements the singleton pattern for this class.
//
//////////////////////////////////////////////////////////////////////////////////////////
+ (DataAccessObject *)sharedInstance
{
    static DataAccessObject *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{ _sharedInstance = [[DataAccessObject alloc] init]; });
    
    return _sharedInstance;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to "retrieve" all the companies and return them to the caller through the
//  completion handler.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)getCompanies:(void (^)(NSMutableArray *))completion
{
    if (completion)
    {
        Company *company;
        Product *product;
        
        _companies = [[NSMutableArray alloc] init];
        
        company = [[Company alloc] initWithName:@"Apple" andStockSymbol:@"APPL" andStockPrice:96.6];
        [_companies addObject:company];
        product = [[Product alloc] initWithName:@"MacBook Pro" andURL:@"https://www.apple.com/macbook-pro/"];
        [company.products addObject:product];
        product = [[Product alloc] initWithName:@"iPhone" andURL:@"https://www.apple.com/iphone/"];
        [company.products addObject:product];
        product = [[Product alloc] initWithName:@"iPad" andURL:@"https://www.apple.com/ipad/"];
        [company.products addObject:product];
        product = [[Product alloc] initWithName:@"Watch" andURL:@"https://www.apple.com/watch/"];
        [company.products addObject:product];
        
        company = [[Company alloc] initWithName:@"Google" andStockSymbol:@"GOOG" andStockPrice:708.01];
        [_companies addObject:company];
        product = [[Product alloc] initWithName:@"Pixel" andURL:@"https://madeby.google.com/phone/"];
        [company.products addObject:product];
        product = [[Product alloc] initWithName:@"Chromecast" andURL:@"https://chromecast.com/chromecast/"];
        [company.products addObject:product];
        product = [[Product alloc] initWithName:@"Nexus" andURL:@"https://www.google.com/nexus/"];
        [company.products addObject:product];
        
        company = [[Company alloc] initWithName:@"Twitter" andStockSymbol:@"TWTR" andStockPrice:16.93];
        [_companies addObject:company];
        
        company = [[Company alloc] initWithName:@"Tesla" andStockSymbol:@"TSLA" andStockPrice:175.33];
        [_companies addObject:company];
        product = [[Product alloc] initWithName:@"Model S" andURL:@"https://www.tesla.com/models"];
        [company.products addObject:product];
        product = [[Product alloc] initWithName:@"Model X" andURL:@"https://www.tesla.com/modelx"];
        [company.products addObject:product];
        product = [[Product alloc] initWithName:@"Model 3" andURL:@"https://www.tesla.com/model3"];
        [company.products addObject:product];

        completion([_companies mutableCopy]);
    }
}

@end
