//
//  ProductListEditor.h
//  NavCtrl
//
//  Created by bl on 2/17/17.
//  Copyright © 2017 bl. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "EntryViewController.h"


@class ProductListManager;


@interface ProductListEditor : NSObject<EntryViewDelegate>

- (void) deleteProductWithDisplayIndex:(NSInteger)index
                           fromCompany:(NSString *)name;

- (instancetype) init __attribute__((unavailable("init not available")));

- (instancetype) initWithList:(ProductListManager *)productListMgr NS_DESIGNATED_INITIALIZER;

- (void) updateProductWithName:(NSString *)currentName
                            to:(NSString *)newName
                 andProductURL:(NSString *)productURL
            andProductImageURL:(NSString *)productImageURL
                     inCompany:(NSString *)companyName;

@end
