//
//  DataAccess.m
//  NavCtrl
//
//  Created by bl on 1/10/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import "Globals.h"
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
+ (DataAccessObject *) sharedInstance
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
- (void) addCompanyWithName:(NSString *)name
             andStockSymbol:(NSString *)stockSymbol
                 andLogoURL:(NSString *)logoURL
{
    // Get the display index for the new company
    NSInteger index = _companies.count;
    
    // If limit exceeded then ...
    if (index >= MAX_COMPANIES)
    {
        // Format an error message
        NSString *errorMsg = [NSString stringWithFormat:@"Exceeding limit of %d companies.", MAX_COMPANIES];
        
        // Notify delegate of error
        [self.companyDelegate didGetDAOError:errorMsg];
    }
    else
    {
        // Load the field values into a company record
        Company *newCompany = [[Company alloc] initWithName:name
                                             andStockSymbol:stockSymbol
                                              andStockPrice:nil
                                                 andLogoURL:logoURL];
        
        // Append the company to the "database"
        [_companies addObject:newCompany];

        // Download the company logo from the internet in the background
        dispatch_async(dispatch_get_global_queue(0,0),
                       ^{
                           NSURL *url = [NSURL URLWithString:logoURL];
                           newCompany.logoData = [[NSData alloc] initWithContentsOfURL:url];
                           
                           // Notify delegate that the company was added
                           dispatch_async(dispatch_get_main_queue(),
                                          ^{
                                              [self.companyDelegate didInsertCompany:[newCompany copy]
                                                                    withDisplayIndex:index];
                                          });
                       });
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to add a new product.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) addProductWithName:(NSString *)name
              andProductURL:(NSString *)productURL
         andProductImageURL:(NSString *)productImageURL
                  toCompany:(NSString *)companyName;
{
    // Get the company record
    Company *company = [self findCompany:companyName];
    
    // If not found then exit routine.
    if (nil == company)
        return;
    
    // Load the field values into a product record
    Product *newProduct = [[Product alloc] initWithName:name
                                                 andURL:productURL
                                            andImageURL:productImageURL];

    // Append to the company's product list
    [company.products addObject:newProduct];

    // Download the product image from the internet in the background
    dispatch_async(dispatch_get_global_queue(0,0),
                   ^{
                       NSURL *url = [NSURL URLWithString:productImageURL];
                       newProduct.imageData = [[NSData alloc] initWithContentsOfURL:url];
                       
                       // Notify delegate that the product was added
                       dispatch_async(dispatch_get_main_queue(),
                                      ^{
                                          [self.productDelegate didAddProduct:[newProduct copy]];
                                      });
                   });
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to delete the record of a company using the display index as a key.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) deleteCompanyWithDisplayIndex:(NSInteger)index
{
    // If index is valid then ...
    if (index < _companies.count)
    {
        // Delete the company record
        [_companies removeObjectAtIndex:index];
        
        // Notify delegate that the company was deleted
        [self.companyDelegate didDeleteCompanyWithDisplayIndex:index];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to delete a product from a company's product list.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) deleteProduct:(NSString *)productName
           fromCompany:(NSString *)companyName
{
    // Get the company record
    Company *company = [self findCompany:companyName];
    
    // If not found then exit routine.
    if (nil == company)
        return;
    
    // Search for the product in the company product list
    NSInteger index = [self findProduct:productName
                                     in:company.products];
    
    // If not found then exit routine
    if (-1 == index)
        return;
    
    // Remove the product from the list
    [company.products removeObjectAtIndex:index];
    
    // Notify delegate that the product was deleted
    [self.productDelegate didDeleteProduct:productName];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to delete a product from a company's product list.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) deleteProductWithDisplayIndex:(NSInteger)index
                           fromCompany:(NSString *)name
{
    // Get the company record
    Company *company = [self findCompany:name];
    
    // If not found then exit routine.
    if (nil == company)
        return;
    
    // Remove the product from the list
    [company.products removeObjectAtIndex:index];
    
    // Notify delegate that the product was deleted
    [self.productDelegate didDeleteProductWithDisplayIndex:index];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to return the number of company records in the "database".
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) getCompanyCount
{
    return _companies.count;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to return the record of a company using the name as a key.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (Company *) getCompanyWithName:(NSString *)name
{
    // Search for the company record
    Company *company = [self findCompany:name];
    
    // If found then return a copy otherwise return nil to indicate company not found.
    return (company)? [company copy] : nil;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to insert a company record with a display index.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) insertCompany:(Company *)company
      withDisplayIndex:(NSInteger)index
{
    // Insert the company
    [_companies insertObject:[company copy] atIndex:index];

    // Notify delegate of the insertion
    [self.companyDelegate didInsertCompany:company
                          withDisplayIndex:index];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to return all the companies.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) readAll
{
    NSMutableArray *copyOfCompanies = [[NSMutableArray alloc] initWithArray:_companies copyItems:YES];
    
    // Notify delegate that all companies have been read
    [self.companyDelegate didReadAll:copyOfCompanies];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to change the display order of a company.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) updateCompanyDisplayIndexFrom:(NSInteger)currentIndex
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
        
        // Notify delegate of the display order change
        [self.companyDelegate didUpdateCompanyDisplayIndexFrom:currentIndex
                                                            to:newIndex];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to change the content of the company record.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) updateCompanyWithName:(NSString *)currentName
                            to:(NSString *)newName
               withStockSymbol:(NSString *)stockSymbol
                    andLogoURL:(NSString *)logoURL
{
    // Get the company record
    Company *company = [self findCompany:currentName];

    // If not found then exit routine.
    if (nil == company)
        return;
    
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
        
        // download the new logo in the background
        dispatch_async(dispatch_get_global_queue(0,0),
                       ^{
                           NSURL *url = [NSURL URLWithString:logoURL];
                           company.logoData = [[NSData alloc] initWithContentsOfURL:url];
                           
                           // Notify delegate of the company update
                           dispatch_async(dispatch_get_main_queue(),
                                          ^{
                                              [self.companyDelegate didUpdateCompany:[company copy]
                                                                            withName:currentName];
                                          });
                       });
    }
    else
        // Notify delegate of the company update
        [self.companyDelegate didUpdateCompany:[company copy]
                                      withName:currentName];
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
    BOOL dataChanged;

    // Search for the company record
    Company *company = [self findCompany:companyName];
    
    // If not found then exit routine.
    if (nil == company)
        return;
    
    NSInteger index = [self findProduct:currentName
                                     in:company.products];

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
        // Copy the new image url into the product record
        product.imageURL = [productImageURL copy];
    
        // Download the product image from the internet in the background
        dispatch_async(dispatch_get_global_queue(0,0),
                       ^{
                           NSURL *url = [NSURL URLWithString:productImageURL];
                           product.imageData = [[NSData alloc] initWithContentsOfURL:url];

                           // Notify delegate of the product update
                           dispatch_async(dispatch_get_main_queue(),
                                          ^{
                                              [self.productDelegate didUpdateProduct:[product copy]
                                                                            withName:currentName];
                                          });
                       });
    }
    else if (dataChanged)
        [self.productDelegate didUpdateProduct:[product copy]
                                      withName:currentName];
}

#pragma mark - Private Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to linearly search the _companies array for a company.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (Company *) findCompany:(NSString *)name
{
    for (NSInteger i = 0; i < _companies.count; ++i)
        if ([((Company *) _companies[i]).name isEqualToString:name])
            return _companies[i];
    
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to linearly search the products array for a product.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) findProduct:(NSString *)name
                       in:(NSMutableArray *)products
{
    for (NSInteger i = 0; i < products.count; ++i)
        if ([((Product *) products[i]).name isEqualToString:name])
            return i;
    
    return -1;
}

@end
