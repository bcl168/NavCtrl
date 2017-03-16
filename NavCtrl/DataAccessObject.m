//
//  DataAccess.m
//  NavCtrl
//
//  Created by bl on 1/10/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import <CoreData/CoreData.h>
#import "Globals.h"
#import "DataAccessObject.h"
#import "NavControllerAppDelegate.h"
#import "CDCompany+CoreDataClass.h"
#import "CDProduct+CoreDataClass.h"


static NSInteger _companyCount = 0;
static NSManagedObjectContext *_managedObjectContext;
static NSPersistentContainer *_persistentContainer;


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
                      
                      _persistentContainer = ((NavControllerAppDelegate *)[UIApplication sharedApplication].delegate).persistentContainer;
                      _managedObjectContext = _persistentContainer.viewContext;
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
    NSInteger index = _companyCount;
    
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
        Company *company = [[Company alloc] initWithName:[name copy]
                                          andStockSymbol:[stockSymbol copy]
                                              andLogoURL:[logoURL copy]];
        
        // Download the company logo from the internet in the background
        dispatch_async(dispatch_get_global_queue(0,0),
                       ^{
                           NSError *error = nil;
                           
                           NSURL *url = [NSURL URLWithString:company.logoURL];
                           company.logoData = [[NSData alloc] initWithContentsOfURL:url];

                           // Persist the company in core data
                           CDCompany *moCompany = [NSEntityDescription insertNewObjectForEntityForName:@"CDCompany"
                                                                                inManagedObjectContext:_managedObjectContext];
                           
                           
                           [self company:company toNSManagedObject:moCompany];
                           moCompany.displayIndex = index;

                           // If successful then ...
                           if ([_managedObjectContext save:&error])
                           {
                               // increment counter
                               ++_companyCount;
                               
                               // Notify delegate that the company was sucessfully added
                               dispatch_async(dispatch_get_main_queue(),
                                              ^{
                                                  [self.companyDelegate didInsertCompany:company
                                                                        withDisplayIndex:index];
                                              });
                           }
                           // Otherwise, ...
                           else
                               // Notify delegate of the error
                               dispatch_async(dispatch_get_main_queue(),
                                              ^{
                                                  [self.companyDelegate didGetDAOError:[error localizedDescription]];
                                              });
                           
                           // Clean up
                           [_managedObjectContext reset];
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
    CDCompany *moCompany = [self findCompany:companyName
                              withPrefetch:YES];

    // Load the field values into a product record
    Product *product = [[Product alloc] initWithName:[name copy]
                                              andURL:[productURL copy]
                                         andImageURL:[productImageURL copy]];
    
    // Download the product image from the internet in the background
    dispatch_async(dispatch_get_global_queue(0,0),
                   ^{
                       NSError *error;
                       NSURL *url = [NSURL URLWithString:productImageURL];
                       product.imageData = [[NSData alloc] initWithContentsOfURL:url];

                       // Initialize core data version of the new product
                       CDProduct *moProduct = [NSEntityDescription insertNewObjectForEntityForName:@"CDProduct"
                                                                                             inManagedObjectContext:_managedObjectContext];
                       moProduct.name = product.name;
                       moProduct.url = product.url;
                       moProduct.imageURL = product.imageURL;
                       moProduct.displayIndex = [moCompany.companyToProducts count];
                       moProduct.imageData = product.imageData;

                       moProduct.productToCompany = moCompany;

                       // If successfully persisted the updates then ...
                       if ([_managedObjectContext save:&error])
                           // Notify delegate of the product update
                           dispatch_async(dispatch_get_main_queue(),
                                          ^{
                                              [self.productDelegate didAddProduct:product];
                                          });
                       else
                       {
                           [self showDetailedCoreDataError:error];

                           // Notify delegate of the error
                           dispatch_async(dispatch_get_main_queue(),
                                          ^{
                                              [self.companyDelegate didGetDAOError:[error localizedDescription]];
                                          });
                       }
                   });
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to delete the record of a company using the display index as a key.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) deleteCompanyWithDisplayIndex:(NSInteger)index
{
    NSAssert(index < _companyCount, @"Deleting a company with an invalid index");

    // Initialize request to fetch all companies with displayIndex >= index
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"CDCompany"
                                   inManagedObjectContext:_managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"displayIndex >= %ld", index];
    [request setPredicate:predicate];

    // Execute the request
    NSError *error = nil;
    NSArray *companyManagedObjectArray = [_managedObjectContext executeFetchRequest:request
                                                                              error:&error];

    [request release];

    // If successful then ...
    if (!error)
    {
        // Loop through the company list
        for (CDCompany *moCompany in companyManagedObjectArray)
            // If the display index matches the argument then ...
            if (index == moCompany.displayIndex)
                // delete the company
                [_managedObjectContext deleteObject:moCompany];
            // Otherwise, ...
            else
                // shift the display index down by 1
                --moCompany.displayIndex;

        // If sucessfully saved all changes then ...
        if ([_managedObjectContext save:&error])
        {
            // decrement counter
            --_companyCount;
            
            // Notify delegate that the company was successfully deleted
            [self.companyDelegate didDeleteCompanyWithDisplayIndex:index];
            
            return;
        }
        // Otherwise, ...
        else
            // clear the all the changes from context
            [_managedObjectContext reset];
    }

    // Notify delegate of the error
    [self.companyDelegate didGetDAOError:[error localizedDescription]];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to delete a product from a company's product list.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) deleteProductWithDisplayIndex:(NSInteger)index
                           fromCompany:(NSString *)name
{
    CDProduct *hold;
    NSError *error;

    // Get the company record
    CDCompany *moCompany = [self findCompany:name withPrefetch:YES];
    
    NSAssert(index < moCompany.companyToProducts.count, @"Deleting a product with an invalid index.");

    // Loop through the product list
    for (CDProduct *moProduct in moCompany.companyToProducts)
        // If it matches the argument then ...
        if (moProduct.displayIndex == index)
            // hold on to it temporarily
            hold = moProduct;
        // Otherwise, if the display index is bigger than the argument then ...
        else if (moProduct.displayIndex > index)
            // shift the display index down
            --moProduct.displayIndex;
    
    // Now that the fast enumeration loop has completed, we can delete the product.
    [_managedObjectContext deleteObject:hold];
    
    // Remove it from the company product list
    [moCompany removeCompanyToProducts:[NSSet setWithObject:hold]];
    
    // If successfully persist the deletion then ...
    if ([_managedObjectContext save:&error])
        // Notify delegate that the product was deleted
        [self.productDelegate didDeleteProductWithDisplayIndex:index];
    // Otherwise, ...
    else
        // Notify delegate of the error
        [self.companyDelegate didGetDAOError:[error localizedDescription]];

    // clear memory
    [_managedObjectContext reset];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to return the number of company records in the "database".
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) getCompanyCount
{
    return _companyCount;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to insert a company record with a display index.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) insertCompany:(Company *)company
      withDisplayIndex:(NSInteger)index
{
    CDCompany *moCompany;
    NSError *error = nil;

    NSAssert(index <= _companyCount, @"Inserting a company with an invalid index.");

    // If not appending then ...
    if (index != _companyCount - 1)
    {
        // Initialize request to fetch all companies with displayIndex >= index
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"CDCompany"
                                       inManagedObjectContext:_managedObjectContext]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"displayIndex >= %ld", index];
        [request setPredicate:predicate];
        
        // Execute the request
        NSArray *companyArray = [_managedObjectContext executeFetchRequest:request
                                                                     error:&error];
        
        [request release];

        // If failed then ...
        if (error)
        {
            // Notify delegate of the error
            [self.companyDelegate didGetDAOError:[error localizedDescription]];
            return;
        }
        
        // Loop through the company list
        for (moCompany in companyArray)
            // shift the display index up by 1
            ++moCompany.displayIndex;
    }

    // Initialize a core data version of the company
    moCompany = [NSEntityDescription insertNewObjectForEntityForName:@"CDCompany"
                                              inManagedObjectContext:_managedObjectContext];
    [self company:company toNSManagedObject:moCompany];
    moCompany.displayIndex = index;

    // If successfully persist the new company then ...
    if ([_managedObjectContext save:&error])
    {
        // increment count
        ++_companyCount;
        
        // Notify delegate that the company was inserted
        [self.companyDelegate didInsertCompany:company
                              withDisplayIndex:index];
    }
    // Otherwise, ...
    else
        // Notify delegate of the error
        [self.companyDelegate didGetDAOError:[error localizedDescription]];

    // clear memory
    [_managedObjectContext reset];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to return all the companies.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) readAll
{
    NSError *error = nil;

    // Initialize request to get all the companies, sorted by their displayIndex
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"CDCompany"
                                   inManagedObjectContext:_managedObjectContext]];
    NSMutableArray *sortArray = [NSMutableArray array];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayIndex"
                                                                   ascending:YES];
    [sortArray addObject:sortDescriptor];
    [request setSortDescriptors:sortArray];
    
    // Execute the request
    NSArray *companyArray = [_managedObjectContext executeFetchRequest:request
                                                                 error:&error];
    [sortDescriptor release];
    [request release];

    // if request failed then ...
    if (error)
    {
        // Notify the delegate of the error
        [self.companyDelegate didGetDAOError:[error localizedDescription]];
        return;
    }

    // Initialize array for storing companies from core data
    NSMutableArray *companies = [[NSMutableArray alloc] init];
    
    // Loop through the company list
    for (CDCompany *moCompany in companyArray)
    {
        // Convert the core data version of the company to a company object
        Company *company = [[Company alloc] initWithName:moCompany.name
                                          andStockSymbol:moCompany.stockSymbol
                                              andLogoURL:moCompany.logoURL];
        company.logoData = [moCompany.logoData copy];

        // Get the product list for the company
        NSMutableSet *productSet = [moCompany mutableSetValueForKey:@"companyToProducts"];
        
        // Initialize the company object's product list
        company.products = [[NSMutableArray alloc] initWithCapacity:productSet.count];
        for (NSInteger i = 0; i < productSet.count; ++i)
            [company.products addObject:[NSNull null]];
        
        // Loop through the product list
        for (CDProduct *moProduct in moCompany.companyToProducts)
        {
            // Transfer the field values to a product object
            Product *product = [[Product alloc] initWithName:moProduct.name
                                                      andURL:moProduct.url
                                                 andImageURL:moProduct.imageURL];
            product.imageData = [moProduct.imageData copy];
            
            // Insert the product object into the product list in its displayIndex order
            [company.products replaceObjectAtIndex:moProduct.displayIndex
                                        withObject:product];
        }

        // Append the company object to the list
        [companies addObject:company];
    }
    
    // save the count
    _companyCount = companies.count;
    
    // Notify delegate that all companies have been read
    [self.companyDelegate didReadAll:companies];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to change the display order of a company.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) updateCompanyDisplayIndexFrom:(NSInteger)currentIndex
                                    to:(NSInteger)newIndex
{
    NSInteger delta;
    NSInteger lowerBound;
    NSInteger upperBound;
    NSError *error = nil;
    
    // If increasing display index then ...
    if (currentIndex < newIndex)
    {
        delta = -1;
        lowerBound = currentIndex;
        upperBound = newIndex;
    }
    else
    {
        delta = 1;
        lowerBound = newIndex;
        upperBound = currentIndex;
    }
    
    // Initialize request to fetch all companies in the displayIndex range
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"CDCompany"
                                   inManagedObjectContext:_managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"displayIndex >= %d and displayIndex <= %d", lowerBound, upperBound];
    [request setPredicate:predicate];

    // Execute the request
    NSArray *companies = [_managedObjectContext executeFetchRequest:request
                                                              error:&error];

    [request release];

    // if unable to get the companies then ...
    if (error)
    {
        // Notify the delegate of the error
        [self.companyDelegate didGetDAOError:[error localizedDescription]];
        return;
    }

    // Loop through the company list
    for (CDCompany *moCompany in companies)
        // If it matches then ...
        if (currentIndex == moCompany.displayIndex)
            // change it to the new value
            moCompany.displayIndex = newIndex;
        // Otherwise, ...
        else
            // shift the display index by 1
            moCompany.displayIndex += delta;

    // If successfully persisted the updates then ...
    if ([_managedObjectContext save:&error])
        // Notify delegate of the display order change
        [self.companyDelegate didUpdateCompanyDisplayIndexFrom:currentIndex
                                                            to:newIndex];
    // Otherwise, ...
    else
        // notify delegate of the error
        [self.companyDelegate didGetDAOError:[error localizedDescription]];

    // clear memory
    [_managedObjectContext reset];
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
    NSError *error = nil;

    // Get the company record
    CDCompany *moCompany = [self findCompany:currentName withPrefetch:NO];
    moCompany.name = newName;
    moCompany.stockSymbol = stockSymbol;
    
    Company *company = [[Company alloc] initWithName:newName
                                      andStockSymbol:stockSymbol
                                          andLogoURL:logoURL];

    // If the logo url has changed then ...
    if (![moCompany.logoURL isEqualToString:logoURL])
    {
        // copy the new logo URL into the company record
        moCompany.logoURL = logoURL;
        
        // download the new logo in the background
        dispatch_async(dispatch_get_global_queue(0,0),
                       ^{
                           NSError *error = nil;
                           NSURL *url = [NSURL URLWithString:logoURL];
                           company.logoData = [[NSData alloc] initWithContentsOfURL:url];
                           moCompany.logoData = company.logoData;
                           
                           // If successfully persisted the updates then ...
                           if ([_managedObjectContext save:&error])
                               // Notify delegate of the company update
                               dispatch_async(dispatch_get_main_queue(),
                                              ^{
                                                  [self.companyDelegate didUpdateCompany:company
                                                                                withName:currentName];
                                              });
                           else
                               // Notify delegate of the error
                               dispatch_async(dispatch_get_main_queue(),
                                              ^{
                                                  [self.companyDelegate didGetDAOError:[error localizedDescription]];
                                              });
                       });
        return;
    }
    else
        company.logoData = [moCompany.logoData copy];

    // If successfully persisted the updates then ...
    if ([_managedObjectContext save:&error])
        // notify delegate of the company update
        [self.companyDelegate didUpdateCompany:company
                                      withName:currentName];
    // Otherwise, ...
    else
        // notify delegate of the error
        [self.companyDelegate didGetDAOError:[error localizedDescription]];
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
    NSError *error = nil;

    // Initialize request to fetch a specific product
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"CDProduct"
                                   inManagedObjectContext:_managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", currentName];
    [request setPredicate:predicate];
    
    // Execute the request
    NSArray *productArray = [_managedObjectContext executeFetchRequest:request
                                                                 error:&error];
    CDProduct *moProduct = productArray[0];

    [request release];

    // If the request failed then ...
    if (error)
    {
        // Notify the delegate of the error
        [self.companyDelegate didGetDAOError:[error localizedDescription]];
        return;
    }
    
    Product *product = [[Product alloc] initWithName:[newName copy]
                                              andURL:[productURL copy]
                                         andImageURL:[productImageURL copy]];

    moProduct.name = newName;
    moProduct.url = productURL;
    
    // If the image url has changed then ...
    if (![moProduct.imageURL isEqualToString:productImageURL])
    {
        moProduct.imageURL = productImageURL;

        // Download the product image from the internet in the background
        dispatch_async(dispatch_get_global_queue(0,0),
                       ^{
                           NSError *error;
                           NSURL *url = [NSURL URLWithString:productImageURL];
                           product.imageData = [[NSData alloc] initWithContentsOfURL:url];
                           moProduct.imageData = product.imageData;
                           
                           // If successfully persisted the updates then ...
                           if ([_managedObjectContext save:&error])
                               // Notify delegate of the product update
                               dispatch_async(dispatch_get_main_queue(),
                                              ^{
                                                  [self.productDelegate didUpdateProduct:product
                                                                                withName:currentName];
                                              });
                           else
                               // Notify delegate of the error
                               dispatch_async(dispatch_get_main_queue(),
                                              ^{
                                                  [self.companyDelegate didGetDAOError:[error localizedDescription]];
                                              });
                       });
        return;
    }
    else
        product.imageData = [moProduct.imageData copy];
    
    // If successfully persisted the updates then ...
    if ([_managedObjectContext save:&error])
        // notify delegate of the product update
        [self.productDelegate didUpdateProduct:product
                                      withName:currentName];
    // Otherwise, ...
    else
        // notify delegate of the error
        [self.companyDelegate didGetDAOError:[error localizedDescription]];
}

#pragma mark - Private Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to get a core data version of company.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (CDCompany *) findCompany:(NSString *)name
               withPrefetch:(BOOL)prefetchEnabled
{
    // Initialize request to fetch the company where name = companyName
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"CDCompany"
                                   inManagedObjectContext:_managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    [request setPredicate:predicate];
    
    if (prefetchEnabled)
        [request setRelationshipKeyPathsForPrefetching:@[@"companyToProducts"]];

    // Execute the request
    NSError *error = nil;
    NSArray *results = [_managedObjectContext executeFetchRequest:request
                                                            error:&error];
    
    [request release];

    if (error)
    {
        // notify delegate of the error
        [self.companyDelegate didGetDAOError:[error localizedDescription]];
        
        return nil;
    }
    else
        return (CDCompany *)results[0];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to transfer the data from a company to a CDCompany.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) company:(Company *)company toNSManagedObject:(CDCompany *)moCompany
{
    moCompany.name = company.name;
    moCompany.stockSymbol = company.stockSymbol;
    moCompany.logoURL = company.logoURL;
    moCompany.logoData = company.logoData;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method, used in development, to show a core data error in detail.
//  The code with minor modifications is from:
//  http://stackoverflow.com/questions/1283960/iphone-core-data-unresolved-error-while-saving/1297157#1297157
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) showDetailedCoreDataError:(NSError *) error
{
    // If Cocoa generated the error...
    if ([[error domain] isEqualToString:@"NSCocoaErrorDomain"])
    {
        NSDictionary *userInfo = [error userInfo];

        // ...check whether there's an NSDetailedErrors array
        if ([userInfo valueForKey:@"NSDetailedErrors"] != nil)
        {
            // ...and loop through the array, if so.
            NSArray *errors = [userInfo valueForKey:@"NSDetailedErrors"];
            for (NSError *anError in errors)
            {
                NSDictionary *subUserInfo = [anError userInfo];
                subUserInfo = [anError userInfo];
                // Granted, this indents the NSValidation keys rather a lot
                // ...but it's a small loss to keep the code more readable.
                NSLog(@"Core Data Save Error\n\n \
                      NSValidationErrorKey\n%@\n\n \
                      NSValidationErrorPredicate\n%@\n\n \
                      NSValidationErrorObject\n%@\n\n \
                      NSLocalizedDescription\n%@",
                      [subUserInfo valueForKey:@"NSValidationErrorKey"],
                      [subUserInfo valueForKey:@"NSValidationErrorPredicate"],
                      [subUserInfo valueForKey:@"NSValidationErrorObject"],
                      [subUserInfo valueForKey:@"NSLocalizedDescription"]);
            }
        }
        // If there was no NSDetailedErrors array, print values directly
        // from the top-level userInfo object. (Hint: all of these keys
        // will have null values when you've got multiple errors sitting
        // behind the NSDetailedErrors key.
        else
            NSLog(@"Core Data Save Error\n\n \
                  NSValidationErrorKey\n%@\n\n \
                  NSValidationErrorPredicate\n%@\n\n \
                  NSValidationErrorObject\n%@\n\n \
                  NSLocalizedDescription\n%@",
                  [userInfo valueForKey:@"NSValidationErrorKey"],
                  [userInfo valueForKey:@"NSValidationErrorPredicate"],
                  [userInfo valueForKey:@"NSValidationErrorObject"],
                  [userInfo valueForKey:@"NSLocalizedDescription"]);
    }
    // Handle mine--or 3rd party-generated--errors
    else
        NSLog(@"Custom Error: %@", [error localizedDescription]);
}

@end
