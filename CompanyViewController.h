//
//  CompanyViewController.h
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DataAccessObject.h"
#import "EntryViewController.h"



@interface CompanyViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, DataAccessCompanyDelegate, EntryViewDelegate>

- (void)addCompany;
- (NSString *)saveTextEntry1:(NSString *)textEntry1
               andTextEntry2:(NSString *)textEntry2
               andTextEntry3:(NSString *)textEntry3;

@end
