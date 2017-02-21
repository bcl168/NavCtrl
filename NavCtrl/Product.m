//
//  Product.m
//  NavCtrl
//
//  Created by bl on 1/10/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import "Product.h"


@implementation Product

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method that implements the designated initializer.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithName:(NSString *)name
                       andURL:(NSString *)url
                  andImageURL:(NSString *)imageURL
{
    if (self = [super init])
    {
        _name = [name copy];
        _url = [url copy];
        _imageURL = [imageURL copy];
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
                       andURL:nil
                  andImageURL:nil];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Protocol method to help with deep copying.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (id) copyWithZone:(NSZone *)zone
{
    Product *copy = [[Product allocWithZone:zone] initWithName:_name
                                                        andURL:_url
                                                   andImageURL:_imageURL];
    copy.imageData = [_imageData copy];
    return copy;
}

@end
