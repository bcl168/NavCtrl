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
- (NSString *) saveChangedTextEntry1:(NSString *)newTextEntry1
                      fromTextEntry1:(NSString *)originalTextEntry1
                andChangedTextEntry2:(NSString *)newTextEntry2
                      fromTextEntry2:(NSString *)originalTextEntry2
                andChangedTextEntry3:(NSString *)newTextEntry3
                      fromTextEntry3:(NSString *)originalTextEntry3;

- (NSString *) saveNewTextEntry1:(NSString *)textEntry1
                andNewTextEntry2:(NSString *)textEntry2
                andNewTextEntry3:(NSString *)textEntry3;

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
