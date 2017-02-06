//
//  Product.h
//  NavCtrl
//
//  Created by bl on 1/10/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface Product : NSObject<NSCopying>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain) NSData *imageData;

-(instancetype)initWithName:(NSString *)name
                     andURL:(NSString *)url
                andImageURL:(NSString *)imageURL NS_DESIGNATED_INITIALIZER;
-(instancetype)init;

@end
