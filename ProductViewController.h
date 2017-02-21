//
//  ProductViewController.h
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ProductListManager.h"


@interface ProductViewController : UIViewController<UITableViewDelegate, ProductListDelegate>

@property (nonatomic, retain) Company *company;

@end
