//
//  CompanyListTableViewInterface.h
//  NavCtrl
//
//  Created by bl on 2/13/17.
//  Copyright © 2017 bl. All rights reserved.
//


#import <Foundation/Foundation.h>


@class CompanyListManager;


@interface CompanyListTableViewInterface : NSObject<UITableViewDataSource>

- (instancetype) init __attribute__((unavailable("init not available")));
- (instancetype) initWithList:(CompanyListManager *)companyListMgr NS_DESIGNATED_INITIALIZER;

@end
