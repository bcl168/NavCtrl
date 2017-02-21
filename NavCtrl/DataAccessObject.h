//
//  DataAccessObject.h
//  NavCtrl
//
//  Created by bl on 1/10/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Company.h"


@protocol DataAccessCompanyDelegate <NSObject>

@required
- (void) didDeleteCompanyWithDisplayIndex:(NSInteger)index;

- (void) didGetDAOError:(NSString *)errorMsg;

- (void) didInsertCompany:(Company *)company
         withDisplayIndex:(NSInteger)index;

- (void) didReadAll:(NSMutableArray *)companiesFromDAO;

- (void) didUpdateCompany:(Company *)company
                 withName:(NSString *)oldName;

- (void) didUpdateCompanyDisplayIndexFrom:(NSInteger)currentIndex
                                       to:(NSInteger)newIndex;

@end


@protocol DataAccessProductDelegate <NSObject>

@required
- (void) didAddProduct:(Product *)product;

- (void) didDeleteProduct:(NSString *)productName;

- (void) didDeleteProductWithDisplayIndex:(NSInteger)index;

- (void) didUpdateProduct:(Product *)product
                 withName:(NSString *)oldName;

@end


@interface DataAccessObject : NSObject

@property (nonatomic, strong) id <DataAccessCompanyDelegate> companyDelegate;
@property (nonatomic, strong) id <DataAccessProductDelegate> productDelegate;

+ (DataAccessObject *)sharedInstance;

- (void)readAll;

- (void) addCompanyWithName:(NSString *)name
             andStockSymbol:(NSString *)stockSymbol
                 andLogoURL:(NSString *)logoURL;

- (void) addProductWithName:(NSString *)name
              andProductURL:(NSString *)productURL
         andProductImageURL:(NSString *)productImageURL
                  toCompany:(NSString *)companyName;

- (void) deleteCompanyWithDisplayIndex:(NSInteger)index;

- (void) deleteProduct:(NSString *)productName
           fromCompany:(NSString *)companyName;

- (void) deleteProductWithDisplayIndex:(NSInteger)index
                           fromCompany:(NSString *)name;

- (NSInteger) getCompanyCount;

- (Company *) getCompanyWithName:(NSString *)name;

- (void) insertCompany:(Company *)company
      withDisplayIndex:(NSInteger)index;

- (void) updateCompanyDisplayIndexFrom:(NSInteger)currentIndex
                                    to:(NSInteger)newIndex;

- (void) updateCompanyWithName:(NSString *)currentName
                            to:(NSString *)newName
               withStockSymbol:(NSString *)stockSymbol
                    andLogoURL:(NSString *)logoURL;

- (void) updateProductWithName:(NSString *)currentName
                            to:(NSString *)newName
                 andProductURL:(NSString *)productURL
            andProductImageURL:(NSString *)productImageURL
                     inCompany:(NSString *)companyName;

@end
