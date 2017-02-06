//
//  DetailViewController.h
//  NavCtrl
//
//  Created by bl on 1/9/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "EntryViewController.h"
#import "Product.h"
#import "ProductViewController.h"


@class ProductViewController;


@interface DetailViewController : UIViewController<EntryViewDelegate>

@property (nonatomic, retain) NSString *companyName;
@property (nonatomic, retain) Product *product;

@end

