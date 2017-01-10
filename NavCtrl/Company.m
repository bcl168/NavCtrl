//
//  Company.m
//  NavCtrl
//
//  Created by bl on 1/10/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//

#import "Company.h"

@implementation Company

-(instancetype)initWithName:(NSString *)name andStockSymbol:(NSString *)stockSymbol andStockPrice:(CGFloat)stockPrice
{
    if (self = [super init])
    {
        _name = name;
        _stockSymbol = stockSymbol;
        _stockPrice = stockPrice;
        _products = [[NSMutableArray alloc] init];
    }

    return self;
}

-(instancetype)init
{
    return [self initWithName:nil andStockSymbol:nil andStockPrice:0.0];
}

@end
