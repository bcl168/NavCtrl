//
//  CompanyListEditor.h
//  NavCtrl
//
//  Created by bl on 2/13/17.
//  Copyright © 2017 bl. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "EntryViewController.h"


@class CompanyListManager;


@interface CompanyListEditor : NSObject<EntryViewDelegate>

- (instancetype) init __attribute__((unavailable("init not available")));
- (instancetype) initWithList:(CompanyListManager *)companyListMgr NS_DESIGNATED_INITIALIZER;

- (void) redo;
- (void) reset;
- (void) undo;

- (void) addCompanyWithName:companyName
             andStockSymbol:stockSymbol
                 andLogoURL:logoURL;
- (void) deleteCompanyWithDisplayIndex:(NSInteger)index;
- (void) updateCompanyDisplayIndexFrom:(NSInteger)fromIndex
                                    to:(NSInteger)toIndex;
- (void) updateCompanyFrom:(Company *)originalCompany
                        to:(Company *)newCompany;
@end
