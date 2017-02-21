//
//  ProductListTableViewInterface.h
//  NavCtrl
//
//  Created by bl on 2/17/17.
//  Copyright © 2017 bl. All rights reserved.
//


#import <Foundation/Foundation.h>


@class ProductListManager;


@interface ProductListTableViewInterface : NSObject<UITableViewDataSource>

- (instancetype) init __attribute__((unavailable("init not available")));
- (instancetype) initWithList:(ProductListManager *)productListMgr NS_DESIGNATED_INITIALIZER;

@end
