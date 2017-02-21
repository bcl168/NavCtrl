//
//  DetailViewController.h
//  NavCtrl
//
//  Created by bl on 1/9/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "ProductListManager.h"


@interface DetailViewController : UIViewController

@property (nonatomic, retain) ProductListManager *productListMgr;
@property (nonatomic, retain) Product *product;

@end

