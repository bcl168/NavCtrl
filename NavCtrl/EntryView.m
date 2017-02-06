//
//  EntryView.m
//  NavCtrl
//
//  Created by bl on 1/13/17.
//  Copyright © 2017 Bobby Lee. All rights reserved.
//


#import "Globals.h"
#import "EntryView.h"
#import "EntryViewController.h"


@implementation EntryView

- (void)dealloc
{
    [_textEntry1 release];
    [_textEntry2 release];
    [_textEntry3 release];
    [_deleteButton release];
    [_scrollView release];
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called when the user touches the delete button.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)deleteButtonTouched:(UIButton *)sender
{
    EntryViewController *parent = (EntryViewController *) self.parent;

    // Notify who ever is interested, the user wants to delete the current entry
    [[NSNotificationCenter defaultCenter] postNotificationName:parent.deleteNotificationName
                                                        object:self];
    
    if (parent.destinationControllerForDelete)
        [parent.navigationController popToViewController:parent.destinationControllerForDelete
                                                     animated:NO];
    else
        // Return to the previous controller
        [parent.navigationController popViewControllerAnimated:NO];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method for initializing this class.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Load corresponding xib file
        // Note: EntryViewForm.xib was originally named EntryView.xib. It was renamed
        //       because EntryViewController attempted to autoload EntryView.xib during
        //       instantiation resulting in an exception. Autoloading is a feature see
        //       Apple's documentation for instance property nibName.
        UIView *viewInXib = [[[NSBundle mainBundle] loadNibNamed:@"EntryViewForm"
                                                           owner:self
                                                         options:nil] firstObject];
        
        // Add to the view hierarchy
        [self addSubview:viewInXib];
        
        // Initialize the view size
        viewInXib.frame = frame;
    }
    
    return self;
}

@end
