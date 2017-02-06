//
//  EntryViewController.h
//  NavCtrl
//
//  Created by bl on 1/13/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "EntryView.h"


typedef enum
{
    EntryViewNavigationNoButton = 0,
    EntryViewNavigationAddButton,
    EntryViewNavigationBackButton,
    EntryViewNavigationCancelButton,
    EntryViewNavigationDoneButton,
    EntryViewNavigationEditButton,
    EntryViewNavigationSaveButton
}
EntryViewNavigationButtonType;


@protocol EntryViewDelegate <NSObject>

@required
- (NSString *)saveTextEntry1:(NSString *)textEntry1
               andTextEntry2:(NSString *)textEntry2
               andTextEntry3:(NSString *)textEntry3;

@end


@interface EntryViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, strong) id<EntryViewDelegate> delegate;
@property (nonatomic, retain) UIViewController *destinationControllerForDelete;
@property (nonatomic, retain) NSString *deleteNotificationName;
@property (nonatomic, retain) NSString *textEntry1;
@property (nonatomic, retain) NSString *textEntry2;
@property (nonatomic, retain) NSString *textEntry3;

- (void)setNavigationBarAttributes:(NSString *)title
          leftNavigationButtonType:(EntryViewNavigationButtonType)leftButtontype
         rightNavigationButtonType:(EntryViewNavigationButtonType)rightButtonType;


@end
