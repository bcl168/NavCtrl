//
//  Company.h
//  NavCtrl
//
//  Created by bl on 1/10/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Product.h"
#import "StockDataFeed.h"


// Redefine MAX_QUOTE for readability
#define MAX_COMPANIES   MAX_QUOTE


@interface Company : NSObject<NSCopying>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *stockSymbol;
@property (nonatomic, retain) NSString *stockPrice;
@property (nonatomic, retain) NSString *logoURL;
@property (nonatomic, retain) NSData *logoData;
@property (nonatomic, retain) NSMutableArray *products;

- (instancetype) init;
- (instancetype) initWithName:(NSString *)name
              andStockSymbol:(NSString *)stockSymbol
                  andLogoURL:(NSString *)logoURL NS_DESIGNATED_INITIALIZER;

@end
