//
//  EntryViewController.m
//  NavCtrl
//
//  Created by bl on 1/13/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import "Globals.h"
#import "EntryViewController.h"


@implementation EntryViewController
{
    EntryViewNavigationButtonType _leftButtonType;
    EntryViewNavigationButtonType _rightButtonType;
    NSArray *_labelText;
    UIScrollView *_scrollView;
    NSMutableArray *_textFields;
    NSString *_title;
}

#pragma mark - Public Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to configure the navigation bar.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) setNavigationBarAttributes:(NSString *)title
          leftNavigationButtonType:(EntryViewNavigationButtonType)leftButtontype
         rightNavigationButtonType:(EntryViewNavigationButtonType)rightButtonType
{
    _title = title;
    _leftButtonType = leftButtontype;
    _rightButtonType = rightButtonType;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to configure the label of the 3 text field.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) setTextFieldLabel1:(NSString *)label1
         andTextFieldLabel2:(NSString *)label2
         andTextFieldLabel3:(NSString *)label3
{
    _labelText = [[NSArray alloc] initWithObjects:label1, label2, label3, nil];
}

#pragma mark - Overridden Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Overridden method to initialize this controller.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) viewDidLoad
{
    const CGFloat PADDING_SIZE = 30.0;
    const CGFloat LABEL_HEIGHT = 31.0;
    const CGFloat TEXTFIELD_HEIGHT = 40.0;
    const CGFloat SEPARATION_SIZE = 4.0;
    const CGFloat BUTTON_WIDTH = 100.0;
    const CGFloat BUTTON_HEIGHT = 40.0;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Align the top of the controller to the bottom of navigation bar rather the
    // top of the screen.
    self.edgesForExtendedLayout = UIRectEdgeNone;

    // Configure the navigation bar
    self.title = _title;
    if (_rightButtonType)
        self.navigationItem.rightBarButtonItem = [self createNavigationButton:_rightButtonType];
    if (_leftButtonType)
        self.navigationItem.leftBarButtonItem = [self createNavigationButton:_leftButtonType];

    // Create a scrollView to be the container for our controls
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.backgroundColor = UIColor.whiteColor;
    
    CGFloat controlWidth = self.view.bounds.size.width - 2 * PADDING_SIZE;
    CGFloat y = 3 * PADDING_SIZE;

    _textFields = [[NSMutableArray alloc] init];

    for (int i = 0; i < 3; ++i)
    {
        // Create a label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_SIZE, y, controlWidth, LABEL_HEIGHT)];
        label.text = _labelText[i];
        label.textColor = UIColor.lightGrayColor;
        // Add the label to the scroll view
        [_scrollView addSubview:label];
        [label release];
        
        // Calculate position for the next control
        y += LABEL_HEIGHT + SEPARATION_SIZE;

        // Create a text field
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(PADDING_SIZE, y, controlWidth, TEXTFIELD_HEIGHT)];
        textField.delegate = self;
        [_textFields addObject:textField];
        // Create a border on the bottom of the text field
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0.0, TEXTFIELD_HEIGHT - 2.0, controlWidth, 2.0);
        bottomBorder.backgroundColor = UIColor.lightGrayColor.CGColor;
        [textField.layer addSublayer:bottomBorder];
        // Set accessibility so UI testing can access the text field
        textField.accessibilityLabel = [NSString stringWithFormat:@"Text Entry %d", i];
        textField.isAccessibilityElement = YES;
        // Add the text field to the scroll view
        [_scrollView addSubview:textField];
        [textField release];
        
        // Calculate position for the next control
        y += TEXTFIELD_HEIGHT + SEPARATION_SIZE;
    }

    // Add the scrollView to viewController
    [self.view addSubview:_scrollView];

    // If user request to be notify of deletion then ...
    if (self.deleteNotificationName)
    {
        y += PADDING_SIZE;
        
        // Create a delete button
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - BUTTON_WIDTH) / 2.0, y,
                                                                      BUTTON_WIDTH, BUTTON_HEIGHT)];
        [button setTitle:@"Delete" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:24.0];
        // Set the target, action and event for the button
        [button addTarget:self
                   action:@selector(deleteButtonTouched:)
         forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:button];
        [button release];

        // Transfer data to textfields
        ((UITextField *)_textFields[0]).text = [self.textEntry1 copy];
        ((UITextField *)_textFields[1]).text = [self.textEntry2 copy];
        ((UITextField *)_textFields[2]).text = [self.textEntry3 copy];
        
        y += BUTTON_HEIGHT;
    }

    y += 3 * PADDING_SIZE;
    _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, y);

    // Register for keyboard notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - Private Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method for creating navigation buttons.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (UIBarButtonItem *) createNavigationButton:(EntryViewNavigationButtonType)buttonType
{
    switch (buttonType)
    {
        case EntryViewNavigationBackButton:
        {
            UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"←"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(exitController:)];
            [button setTitleTextAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:BACK_BUTTON_FONT_SIZE] }
                                  forState:UIControlStateNormal];
            return button;
        }
            
        case EntryViewNavigationCancelButton:
            return [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(exitController:)];

        case EntryViewNavigationSaveButton:
            return [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(saveButtonTouched:)];
            
        case EntryViewNavigationNoButton:
        case EntryViewNavigationAddButton:
        case EntryViewNavigationDoneButton:
        case EntryViewNavigationEditButton:
            // Implement in the future as needed.
            return nil;
            
        default:
            NSAssert(buttonType, @"Unexpected type");
            return nil;
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called when the user touches the delete button.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) deleteButtonTouched:(UIButton *)sender
{
    // Notify who ever is interested, the user wants to delete the current entry
    [[NSNotificationCenter defaultCenter] postNotificationName:self.deleteNotificationName
                                                        object:self];
    
    if (self.destinationControllerForDelete)
        [self.navigationController popToViewController:self.destinationControllerForDelete
                                              animated:NO];
    else
        // Return to the previous controller
        [self.navigationController popViewControllerAnimated:NO];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method called when the user touch the cancel or back button or through code to
//  exit this screen.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) exitController:(id)sender
{
    // Unregister for keyboard notification
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // Clean up
    [_labelText release];
    [_scrollView release];
    [_textFields release];
    if (_rightButtonType)
        [self.navigationItem.rightBarButtonItem release];
    if (_leftButtonType)
        [self.navigationItem.leftBarButtonItem release];

    // Return to the previous controller
    [self.navigationController popViewControllerAnimated:NO];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method called when the UIKeyboardDidShowNotification is sent.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) keyboardWasShown:(NSNotification*)notification
{
    // Get keyboard height
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    
    // Increase the padding on the bottom of the content to match the height of the
    // keyboard, so the bottom of the content can scroll above the keyboard.
    _scrollView.contentInset = contentInsets;
    
    // Shrink the scrollbar by the height of the keyboard so it won't be partially
    // hidden by the keyboard. Add 2.0 so there will a small gap between the bottom
    // of the scrollbar and the top of the keyboard.
    //
    // Note: In iOS 10.12.2, there is a bug. The scrollbar did not compensate for
    //       edgesForExtendedLayout = UIRectEdgeNone. That is, the height did
    //       not subtract the height of the status bar and the height of navigation bar.
    //       So "subtract" them until the bug is fixed.
    contentInsets.bottom += ([UIApplication sharedApplication].statusBarFrame.size.height +
                             self.navigationController.navigationBar.frame.size.height + 2.0);
    _scrollView.scrollIndicatorInsets = contentInsets;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method called when the UIKeyboardWillHideNotification is sent.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) keyboardWillBeHidden:(NSNotification*)aNotification
{
    // Reset the padding on the bottom of the content
    _scrollView.contentInset = UIEdgeInsetsZero;
    
    // Reset the height of the scrollbar
    _scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method called when the user touch the save button.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) saveButtonTouched:(id)sender
{
    NSString *errorMsg;

    if (self.textEntry1.length)
        errorMsg = [self.delegate saveChangedTextEntry1:((UITextField *)_textFields[0]).text
                                         fromTextEntry1:self.textEntry1
                                   andChangedTextEntry2:((UITextField *)_textFields[1]).text
                                         fromTextEntry2:self.textEntry2
                                   andChangedTextEntry3:((UITextField *)_textFields[2]).text
                                         fromTextEntry3:self.textEntry3];
    else
        errorMsg = [self.delegate saveNewTextEntry1:((UITextField *)_textFields[0]).text
                                   andNewTextEntry2:((UITextField *)_textFields[1]).text
                                   andNewTextEntry3:((UITextField *)_textFields[2]).text];

    // If there is an error message then ...
    if (errorMsg)
    {
        // Initialize the controller for displaying the message
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:errorMsg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        // Create an OK button and add it to the controller
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okButton];
        
        // Display the alert controller
        [self presentViewController:alert animated:YES completion:nil];
    }
    // Otherwise, ...
    else
        // Just exit
        [self exitController:sender];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method called when user touches the return key on the keyboard.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

@end
