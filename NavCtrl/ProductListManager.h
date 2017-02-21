//
//  ProductListManager.h
//  NavCtrl
//
//  Created by bl on 2/17/17.
//  Copyright © 2017 bl. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Company.h"
#import "DataAccessObject.h"
#import "Product.h"
#import "ProductListEditor.h"
#import "ProductListTableViewInterface.h"


@protocol ProductListDelegate <NSObject>

@required
- (void) didAddProduct;
- (void) didDeleteProduct;
- (void) didDeleteProductWithDisplayIndex:(NSInteger)index;
- (void) didUpdateProduct;

@end


@interface ProductListManager : NSObject<DataAccessProductDelegate>

@property (nonatomic, readonly) NSString *companyName;
@property (readonly) NSInteger count;
@property (nonatomic, retain) id<ProductListDelegate> delegate;
@property (nonatomic, readonly) ProductListEditor *editor;
@property (nonatomic, readonly) ProductListTableViewInterface *tableViewInterface;

- (Product *) getProductWithDisplayIndex:(NSInteger)index;
- (instancetype) init __attribute__((unavailable("init not available")));
- (instancetype) initWithCompany:(Company *)company NS_DESIGNATED_INITIALIZER;

@end
