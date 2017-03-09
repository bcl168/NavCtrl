//
//  Company.m
//  NavCtrl
//
//  Created by bl on 1/10/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import "Company.h"


@implementation Company

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method that implements the designated initializer.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithName:(NSString *)name
               andStockSymbol:(NSString *)stockSymbol
                   andLogoURL:(NSString *)logoURL
{
    if (self = [super init])
    {
        _name = [name copy];
        _stockSymbol = [stockSymbol copy];
        _stockPrice = nil;
        _logoURL = [logoURL copy];
        _products = [[NSMutableArray alloc] init];
    }

    return self;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method that implements the basic initializer.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) init
{
    return [self initWithName:nil
               andStockSymbol:nil
                   andLogoURL:nil];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Protocol method to help with deep copying.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (id) copyWithZone:(NSZone *)zone
{
    Company *copy = [[Company allocWithZone:zone] initWithName:_name
                                                andStockSymbol:_stockSymbol
                                                    andLogoURL:_logoURL];
    
    if (_stockPrice)
        copy.stockPrice = [_stockPrice copy];
    copy.logoData = [_logoData copy];
    copy->_products = [_products mutableCopy];
    return copy;
}

@end
