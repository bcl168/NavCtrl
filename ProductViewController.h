//
//  ProductViewController.h
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DetailViewController.h"


@interface ProductViewController : UITableViewController

@property (nonatomic, retain) NSString *stockSymbol;
@property (nonatomic, retain) NSMutableArray *products;

@property (nonatomic, retain) DetailViewController *detailViewController;

@end
