//
//  EntryView.h
//  NavCtrl
//
//  Created by bl on 1/13/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface EntryView : UIView

- (id)initWithFrame:(CGRect)frame;

@property (retain, nonatomic) UIViewController *parent;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UITextField *textEntry1;
@property (retain, nonatomic) IBOutlet UITextField *textEntry2;
@property (retain, nonatomic) IBOutlet UITextField *textEntry3;
@property (retain, nonatomic) IBOutlet UIButton *deleteButton;

@end
