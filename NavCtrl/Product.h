//
//  Product.h
//  NavCtrl
//
//  Created by bl on 1/10/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface Product : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *url;

-(instancetype)initWithName:(NSString *)name andURL:(NSString *)url NS_DESIGNATED_INITIALIZER;
-(instancetype)init;

@end
