//
//  StockDataFeed.h
//  NavCtrl
//
//  Created by bl on 2/6/17.
//  Copyright © 2017 bl. All rights reserved.
//


#import <Foundation/Foundation.h>


// According to http://www.jarloo.com/yahoo_finance/ you can only request
// a maximum of 200 quotes at a time
#define MAX_QUOTE   200


@protocol StockDataFeedDelegate <NSObject>

@required
- (void) didGetFeedError:(NSString *)errorMsg;
- (void) didGetStockData:(NSDictionary *)stockSymbolsAndPrices;

@end


@interface StockDataFeed : NSObject

@property (nonatomic, strong) id<StockDataFeedDelegate> delegate;

- (instancetype) init;
- (BOOL) registerStockSymbol:(NSString *)stockSymbol;
- (void) start;
- (void) stop;
- (void) unregisterStockSymbol:(NSString *)stockSymbol;

@end
