//
//  Company.h
//  NavCtrl
//
//  Created by bl on 1/10/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Product.h"


@interface Company : NSObject<NSCopying>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *stockSymbol;
@property (nonatomic) CGFloat stockPrice;
@property (nonatomic, retain) NSMutableArray *products;

-(instancetype)initWithName:(NSString *)name andStockSymbol:(NSString *)stockSymbol andStockPrice:(CGFloat)stockPrice  NS_DESIGNATED_INITIALIZER;
-(instancetype)init;

@end
