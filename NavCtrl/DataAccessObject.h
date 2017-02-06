//
//  DataAccess.h
//  NavCtrl
//
//  Created by bl on 1/10/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Company.h"


@protocol DataAccessCompanyDelegate <NSObject>

@required
- (void) didAddCompany;
- (void) didDeleteCompanyWithDisplayIndex:(NSInteger)index;
- (void) didUpdateCompany:(Company *)company;
- (void) didUpdateCompanyDisplayIndexFrom:(NSInteger)currentIndex
                                       to:(NSInteger)newIndex;

@end


@protocol DataAccessProductDelegate <NSObject>

@required
- (void)didAddProduct:(Product *)product;
- (void)didUpdateProduct:(Product *)product;

@end


@interface DataAccessObject : NSObject

@property (nonatomic, strong) id <DataAccessCompanyDelegate> companyDelegate;
@property (nonatomic, strong) id <DataAccessProductDelegate> productDelegate;

+ (DataAccessObject *)sharedInstance;

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

- (NSInteger) getCompanyCount;

- (Company *) getCompanyWithDisplayIndex:(NSInteger)index;

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
