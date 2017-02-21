//
//  ProductListEditor.m
//  NavCtrl
//
//  Created by bl on 2/17/17.
//  Copyright © 2017 bl. All rights reserved.
//


#import "ProductListManager.h"


@implementation ProductListEditor
{
    DataAccessObject *_dao;
    ProductListManager *_productListMgr;
}

#pragma mark - Public Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method for initiating a product deletion.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) deleteProductWithDisplayIndex:(NSInteger)index
                           fromCompany:(NSString *)name
{
    [_dao deleteProductWithDisplayIndex:index
                            fromCompany:name];
    
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to perform an initialization.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithList:(ProductListManager *)productListMgr
{
    if (self = [super init])
    {
        _productListMgr = productListMgr;
        _dao = [DataAccessObject sharedInstance];
    }
    
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method for initiating a product modification.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) updateProductWithName:(NSString *)currentName
                            to:(NSString *)newName
                 andProductURL:(NSString *)productURL
            andProductImageURL:(NSString *)productImageURL
                     inCompany:(NSString *)companyName
{
    [_dao updateProductWithName:currentName
                             to:newName
                  andProductURL:productURL
             andProductImageURL:productImageURL
                      inCompany:companyName];
}

#pragma mark - Private Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by EntryViewController when the user wants to save an updated
//  product entry.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSString *) saveChangedTextEntry1:(NSString *)newTextEntry1
                      fromTextEntry1:(NSString *)originalTextEntry1
                andChangedTextEntry2:(NSString *)newTextEntry2
                      fromTextEntry2:(NSString *)originalTextEntry2
                andChangedTextEntry3:(NSString *)newTextEntry3
                      fromTextEntry3:(NSString *)originalTextEntry3
{
    // Trim leading and trailing spaces from all inputs
    NSCharacterSet *allWhitespaceCharacters = [NSCharacterSet whitespaceCharacterSet];
    NSString *productName = [newTextEntry1 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    NSString *productURL = [newTextEntry2 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    NSString *productImageURL = [newTextEntry3 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    
    // Check inputs for entry
    if (0 == productName.length)
        return @"Product name missing.";
    else if (0 == productURL.length)
        return @"Product URL missing.";
    else if (0 == productImageURL.length)
        return @"Product image URL missing.";

    // If one of the input has changed then ...
    if (![originalTextEntry1 isEqualToString:productName] ||
        ![originalTextEntry2 isEqualToString:productURL] ||
        ![originalTextEntry3 isEqualToString:productImageURL])
        // Save the update product data
        [_dao updateProductWithName:originalTextEntry1
                                 to:productName
                      andProductURL:productURL
                 andProductImageURL:productImageURL
                          inCompany:_productListMgr.companyName];

    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by EntryViewController when the user wants to save a new
//  product entry.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSString *) saveNewTextEntry1:(NSString *)textEntry1
                andNewTextEntry2:(NSString *)textEntry2
                andNewTextEntry3:(NSString *)textEntry3
{
    // Trim leading and trailing spaces from all inputs
    NSCharacterSet *allWhitespaceCharacters = [NSCharacterSet whitespaceCharacterSet];
    NSString *productName = [textEntry1 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    NSString *productURL = [textEntry2 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    NSString *productImageURL = [textEntry3 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    
    // Check inputs for entry
    if (0 == productName.length)
        return @"Product name missing.";
    else if (0 == productURL.length)
        return @"Product URL missing.";
    else if (0 == productImageURL.length)
        return @"Product image URL missing.";
    
    // Save the new product data
    [_dao addProductWithName:productName
               andProductURL:productURL
          andProductImageURL:productImageURL
                   toCompany:_productListMgr.companyName];
    
    return nil;
}

@end
