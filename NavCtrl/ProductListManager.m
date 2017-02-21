//
//  ProductListManager.m
//  NavCtrl
//
//  Created by bl on 2/17/17.
//  Copyright © 2017 bl. All rights reserved.
//


#import "ProductListManager.h"


@implementation ProductListManager
{
    Company *_company;
    ProductListEditor *_productListEditor;
    ProductListTableViewInterface *_productListTableViewInterface;
}

#pragma mark - Properties

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Getter method for company name property.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSString *) companyName
{
    return _company.name;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Getter method for count property.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) count
{
    return _company.products.count;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Getter method to return a ProductListEditor.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (ProductListEditor *) editor
{
    return _productListEditor;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Getter method to return a ProductListTableViewInterface.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (ProductListTableViewInterface *) tableViewInterface
{
    return _productListTableViewInterface;
}

#pragma mark - Public Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to retrieve a product at location specified by argument index.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (Product *) getProductWithDisplayIndex:(NSInteger)index
{
    return [_company.products[index] copy];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to perform a standard initialization.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithCompany:(Company *)company
{
    if (self = [super init])
    {
        _company = company;
        _productListEditor = [[ProductListEditor alloc] initWithList:self];
        _productListTableViewInterface = [[ProductListTableViewInterface alloc] initWithList:self];

        DataAccessObject *dao = [DataAccessObject sharedInstance];
        dao.productDelegate = self;
    }

    return self;
}

#pragma mark - DAO Delegate Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by DAO when it successfully added the new product entry.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didAddProduct:(Product *)newProduct
{
    // Add the new product to the company's product list
    [_company.products addObject:newProduct];

    // Propagate the notification to the next delegate
    [self.delegate didAddProduct];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by DAO when it successfully deleted a product entry.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didDeleteProduct:(NSString *)productName
{
    // Locate the product in the list
    NSInteger index = [self findProduct:productName];
    
    // If not found then exit
    if (-1 == index)
        return;
    
    // Delete the product record
    [_company.products removeObjectAtIndex:index];

    // Propagate the notification to the next delegate
    [self.delegate didDeleteProduct];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by DAO when it successfully deleted a product entry.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didDeleteProductWithDisplayIndex:(NSInteger)index
{
    // Delete the product record
    [_company.products removeObjectAtIndex:index];
    
    // Propagate the notification to the next delegate
    [self.delegate didDeleteProductWithDisplayIndex:index];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by DAO when it successfully updated a product entry.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didUpdateProduct:(Product *)product
                 withName:(NSString *)oldName
{
    // Locate the product in the list
    NSInteger index = [self findProduct:oldName];
    
    // If not found then exit
    if (-1 == index)
        return;

    // Delete the product record in the current slot
    [_company.products removeObjectAtIndex:index];
    
    // Replace with the updated product record in the same slot
    [_company.products insertObject:product atIndex:index];
    
    // Propagate the notification to the next delegate
    [self.delegate didUpdateProduct];
}

#pragma mark - Private Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to linearly search the company's product list for a product.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) findProduct:(NSString *)name
{
    for (NSInteger i = 0; i < _company.products.count; ++i)
        if ([name isEqualToString:((Product *)_company.products[i]).name])
            return i;
    
    return -1;
}

@end
