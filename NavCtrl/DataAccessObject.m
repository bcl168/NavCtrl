//
//  DataAccess.m
//  NavCtrl
//
//  Created by bl on 1/10/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import "DataAccessObject.h"


static NSMutableArray *_companies;


@implementation DataAccessObject

@synthesize companyDelegate;
@synthesize productDelegate;

#pragma mark - Public Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method implements the singleton pattern for this class.
//
//////////////////////////////////////////////////////////////////////////////////////////
+ (DataAccessObject *)sharedInstance
{
    static DataAccessObject *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate,
                  ^{
                      _sharedInstance = [[DataAccessObject alloc] init];
                      _companies = [[NSMutableArray alloc] init];
                  });
    
    return _sharedInstance;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to add a new company.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)addCompanyWithName:(NSString *)name
            andStockSymbol:(NSString *)stockSymbol
                andLogoURL:(NSString *)logoURL
{
    Company *newCompany = [[Company alloc] initWithName:name
                                         andStockSymbol:stockSymbol
                                          andStockPrice:0.0
                                             andLogoURL:logoURL];
    
    if (logoURL)
        dispatch_async(dispatch_get_global_queue(0,0),
                       ^{
                           NSURL *url = [NSURL URLWithString:logoURL];
                           newCompany.logoData = [[NSData alloc] initWithContentsOfURL:url];
                           [self.companyDelegate didAddCompany];
                       });
    
    [_companies addObject:newCompany];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to add a new product.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)addProductWithName:(NSString *)name
             andProductURL:(NSString *)productURL
        andProductImageURL:(NSString *)productImageURL
                 toCompany:(NSString *)companyName;
{
    // Search for the company record
    NSInteger index = [self findCompany:companyName];
    
    // If not found then exit routine.
    if (-1 == index)
        return;
    
    // Get the company record
    Company *company = _companies[index];
    
    Product *newProduct = [[Product alloc] initWithName:name
                                                 andURL:productURL
                                            andImageURL:productImageURL];

    if (productImageURL)
        dispatch_async(dispatch_get_global_queue(0,0),
                       ^{
                           NSURL *url = [NSURL URLWithString:productImageURL];
                           newProduct.imageData = [[NSData alloc] initWithContentsOfURL:url];
                           [self.productDelegate didAddProduct:newProduct];
                       });

    [company.products addObject:newProduct];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to delete the record of a company using the display index as a key.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)deleteCompanyWithDisplayIndex:(NSInteger)index
{
    // If index is valid then ...
    if (index < _companies.count)
    {
        // remove the company record
        [_companies removeObjectAtIndex:index];
        
        [self.companyDelegate didDeleteCompanyWithDisplayIndex:index];
    }

}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to delete a product from a company's product list.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)deleteProduct:(NSString *)productName
          fromCompany:(NSString *)companyName
{
    // Search for the company record
    NSInteger index = [self findCompany:companyName];
    
    // If not found then exit routine.
    if (-1 == index)
        return;
    
    // Get the company record
    Company *company = _companies[index];
    
    // Get company product list
    NSMutableArray *products = company.products;

    // Search for the product in the company product list
    index = [self findProduct:productName
                           in:products];
    
    // If not found then exit routine
    if (-1 == index)
        return;
    
    // Remove the product from the list
    [products removeObjectAtIndex:index];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to return the number of company records in the "database".
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)getCompanyCount
{
    return _companies.count;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to return the record of a company using the display index as the key.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (Company *)getCompanyWithDisplayIndex:(NSInteger)index
{
    // If index is valid then ...
    if (index < _companies.count)
        // return the company record
        return [_companies[index] copy];
    // Otherwise, ...
    else
        // return no company
        return nil;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to return the record of a company using the name as a key.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (Company *)getCompanyWithName:(NSString *)name
{
    // Search for the company record
    NSInteger index = [self findCompany:name];
    
    // If not found then exit routine.
    if (-1 == index)
        return nil;
    
    // return the company record
    return [_companies[index] copy];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//   Method to insert a company record with a display index.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)insertCompany:(Company *)company withDisplayIndex:(NSInteger)index
{
    [_companies insertObject:company atIndex:index];
    [self.companyDelegate didAddCompany];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to change the display order of a company.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)updateCompanyDisplayIndexFrom:(NSInteger)currentIndex
                                   to:(NSInteger)newIndex
{
    // If both indexes are valid then ...
    if (currentIndex < _companies.count && newIndex <= _companies.count)
    {
        Company *temp = _companies[currentIndex];
        
        // Delete the company record in the current slot
        [_companies removeObjectAtIndex:currentIndex];
        
        // Insert the company record in the new slot
        [_companies insertObject:temp atIndex:newIndex];
        
        [self.companyDelegate didUpdateCompanyDisplayIndexFrom:currentIndex
                                                            to:newIndex];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to change the content of the company record.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)updateCompanyWithName:(NSString *)currentName
                           to:(NSString *)newName
              withStockSymbol:(NSString *)stockSymbol
                   andLogoURL:(NSString *)logoURL
{
    // Search for the company record
    NSInteger index = [self findCompany:currentName];
    
    // If not found then exit routine.
    if (-1 == index)
        return;
    
    // Get the company record
    Company *company = _companies[index];
    
    // If the name has changed then ...
    if (![company.name isEqualToString:newName])
        // copy the new name into the company record
        company.name = [newName copy];

    // If the stock symbol has changed then ...
    if (![company.stockSymbol isEqualToString:stockSymbol])
        // copy the new stock symbol into the company record
        company.stockSymbol = [stockSymbol copy];

    // If the logo url has changed then ...
    if (![company.logoURL isEqualToString:logoURL])
    {
        // copy the new logo URL into the company record
        company.logoURL = [logoURL copy];
        
        // download the new logo
        dispatch_async(dispatch_get_global_queue(0,0),
                       ^{
                           NSURL *url = [NSURL URLWithString:logoURL];
                           company.logoData = [[NSData alloc] initWithContentsOfURL:url];
                           [self.companyDelegate didUpdateCompany:[company copy]];
                       });
    }
    else
        [self.companyDelegate didUpdateCompany:[company copy]];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to change the content of a product record for a company.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) updateProductWithName:(NSString *)currentName
                            to:(NSString *)newName
                 andProductURL:(NSString *)productURL
            andProductImageURL:(NSString *)productImageURL
                     inCompany:(NSString *)companyName;
{
    Boolean dataChanged;

    // Search for the company record
    NSInteger index = [self findCompany:companyName];
    
    // If not found then exit routine.
    if (-1 == index)
        return;
    
    // Get the company record
    Company *company = _companies[index];
    
    index = [self findProduct:currentName in:company.products];

    // If not found then exit routine.
    if (-1 == index)
        return;
    
    Product *product = company.products[index];

    // If the name has changed then ...
    if (![product.name isEqualToString:newName])
    {
        // copy the new name into the product record
        product.name = [newName copy];
        
        dataChanged = YES;
    }

    // If the url has changed then ...
    if (![product.url isEqualToString:productURL])
    {
        // copy the new url into the product record
        product.url = [productURL copy];
        
        dataChanged = YES;
    }
    
    // If the image url has changed then ...
    if (![product.imageURL isEqualToString:productImageURL])
    {
        // copy the new image url into the product record
        product.imageURL = [productImageURL copy];
    
        // download the new image
        dispatch_async(dispatch_get_global_queue(0,0),
                       ^{
                           NSURL *url = [NSURL URLWithString:productImageURL];
                           product.imageData = [[NSData alloc] initWithContentsOfURL:url];
                           [self.productDelegate didUpdateProduct:[product copy]];
                       });
    }
    else if (dataChanged)
        [self.productDelegate didUpdateProduct:[product copy]];
}

#pragma mark - Private Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to linearly search the companies array for a company.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)findCompany:(NSString *)name
{
    for (NSInteger i = 0; i < _companies.count; ++i)
        if ([((Company *) _companies[i]).name isEqualToString:name])
            return i;
    
    return -1;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to linearly search the products array for a product.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)findProduct:(NSString *)name
                      in:(NSMutableArray *)products
{
    for (NSInteger i = 0; i < products.count; ++i)
        if ([((Product *) products[i]).name isEqualToString:name])
            return i;
    
    return -1;
}

@end
