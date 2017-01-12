//
//  DataAccess.h
//  NavCtrl
//
//  Created by bl on 1/10/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface DataAccessObject : NSObject

+ (DataAccessObject *)sharedInstance;
- (void)getCompanies:(void (^)(NSMutableArray *))completion;

@end
