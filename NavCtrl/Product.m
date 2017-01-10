//
//  Product.m
//  NavCtrl
//
//  Created by bl on 1/10/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import "Product.h"


@implementation Product

-(instancetype)initWithName:(NSString *)name andURL:(NSString *)url
{
    if (self = [super init])
    {
        _name = name;
        _url = url;
    }
    
    return self;
}

-(instancetype)init
{
    return [self initWithName:nil andURL:nil];
}

@end
