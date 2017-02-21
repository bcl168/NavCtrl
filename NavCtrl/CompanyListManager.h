//
//  CompanyListManager.h
//  NavCtrl
//
//  Created by bl on 2/7/17.
//  Copyright © 2017 bl. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Company.h"
#import "CompanyListEditor.h"
#import "CompanyListTableViewInterface.h"
#import "DataAccessObject.h"
#import "StockDataFeed.h"


@protocol CompanyListDelegate <NSObject>

@required
- (void) didAddCompany;
- (void) didDeleteCompanyWithDisplayIndex:(NSInteger)index;
- (void) didGetCompanyListError:(NSString *)errorMsg;
- (void) didReadAll;
- (void) didUpdateCompany;
- (void) didUpdateStockPrices;

@end


@interface CompanyListManager : NSObject<DataAccessCompanyDelegate, StockDataFeedDelegate>

@property (nonatomic, strong) id<CompanyListDelegate> delegate;
@property (readonly) NSInteger count;
@property (nonatomic, readonly) CompanyListEditor *editor;
@property (nonatomic, readonly) CompanyListTableViewInterface *tableViewInterface;

- (Company *) getCompany:(NSString *)name;
- (Company *) getCompanyWithDisplayIndex:(NSInteger)index;
- (instancetype) init;
- (BOOL) isStockDataStale;
- (void) readAll;

@end
