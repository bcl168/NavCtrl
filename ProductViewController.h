//
//  ProductViewController.h
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DataAccessObject.h"
#import "EntryViewController.h"


@class DetailViewController;


@interface ProductViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, EntryViewDelegate, DataAccessProductDelegate>

@property (nonatomic, retain) NSString *companyName;
@property (nonatomic, retain) NSString *stockSymbol;
@property (nonatomic, retain) UIImage *logo;
@property (nonatomic, retain) NSMutableArray *products;

- (NSString *)saveTextEntry1:(NSString *)textEntry1
               andTextEntry2:(NSString *)textEntry2
               andTextEntry3:(NSString *)textEntry3;

@end
