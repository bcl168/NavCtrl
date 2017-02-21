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
    EntryView *_entryView;
    EntryViewNavigationButtonType _leftButtonType;
    EntryViewNavigationButtonType _rightButtonType;
    NSString *_title;
}

@synthesize delegate;

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

#pragma mark - Overridden Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Overridden method to initialize this controller.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Align the top of the controller to the bottom of navigation bar rather the
    // top of the screen.
    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.title = _title;
    
    if (_rightButtonType)
        self.navigationItem.rightBarButtonItem = [self createNavigationButton:_rightButtonType];
    
    if (_leftButtonType)
        self.navigationItem.leftBarButtonItem = [self createNavigationButton:_leftButtonType];

    // Load entry "form"
    _entryView = [[EntryView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_entryView];
    
    _entryView.textEntry1.delegate = self;
    _entryView.textEntry2.delegate = self;
    _entryView.textEntry3.delegate = self;

    // Get the top most and the bottom most control on the entry form
    CGRect buttonFrame = _entryView.deleteButton.frame;
    CGRect textFieldFrame = _entryView.textEntry1.frame;

    // Calculate and set scrollView's content height
    // Add spacing to the bottom to match that on top
    CGFloat height = buttonFrame.origin.y + buttonFrame.size.height + textFieldFrame.origin.y;
    _entryView.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, height);
    
    // If user request to be notify of deletion then ...
    if (self.deleteNotificationName)
    {
        _entryView.parent = self;
        
        // Enable and show delete button
        _entryView.deleteButton.enabled = YES;
        _entryView.deleteButton.hidden = NO;
        
        // Transfer data to textfields
        _entryView.textEntry1.text = [self.textEntry1 copy];
        _entryView.textEntry2.text = [self.textEntry2 copy];
        _entryView.textEntry3.text = [self.textEntry3 copy];
    }

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
//  Method called when the user touch the cancel or back button or through code to
//  exit this screen.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) exitController:(id)sender
{
    // Unregister for keyboard notification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
    _entryView.scrollView.contentInset = contentInsets;
    
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
    _entryView.scrollView.scrollIndicatorInsets = contentInsets;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method called when the UIKeyboardWillHideNotification is sent.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) keyboardWillBeHidden:(NSNotification*)aNotification
{
    // Reset the padding on the bottom of the content
    _entryView.scrollView.contentInset = UIEdgeInsetsZero;
    
    // Reset the height of the scrollbar
    _entryView.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
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
        errorMsg = [self.delegate saveChangedTextEntry1:_entryView.textEntry1.text
                                         fromTextEntry1:self.textEntry1
                                   andChangedTextEntry2:_entryView.textEntry2.text
                                         fromTextEntry2:self.textEntry2
                                   andChangedTextEntry3:_entryView.textEntry3.text
                                         fromTextEntry3:self.textEntry3];
    else
            errorMsg = [self.delegate saveNewTextEntry1:_entryView.textEntry1.text
                                       andNewTextEntry2:_entryView.textEntry2.text
                                       andNewTextEntry3:_entryView.textEntry3.text];

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
