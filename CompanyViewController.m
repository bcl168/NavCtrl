//
//  CompanyViewController.m
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//


#import "Globals.h"
#import "CompanyViewController.h"
#import "ProductViewController.h"
#import "UIImage+Resize.h"


#define DELETE_COMPANY_NOTIFICATION   @"DeleteCompany"


@implementation CompanyViewController
{
    CompanyListManager *_companyListMgr;
    NSInteger _currentSelectedRow;
    UIView *_noAddedCompanyView;
    UITableView *_tableView;
}

#pragma mark - Overridden Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Overridden method to initialize this ViewController.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Align the top of the controller to the bottom of navigation bar rather the
    // top of the screen.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // Add an edit button on the left side of the navigation bar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(toggleEditingMode)];
    
    // Add an add button on the right side of the navigation bar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(displayEntryViewController)];
    
    // Set screen title
    self.title = @"Stock Tracker";
    
    // Get the list of companies
    _companyListMgr = [[CompanyListManager alloc] init];
    _companyListMgr.delegate = self;
    [_companyListMgr readAll];
}

#pragma mark - CompanyListManager Delegate Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by CompanyListManager when all the companies have been read
//  in.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didReadAll
{
    // If there are companies then ...
    if (_companyListMgr.count)
        // display them
        [self displayCompanyTableView];
    // Otherwise, ...
    else
        // display a there are no company screen
        [self displayNoAddedCompanyView];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by CompanyListManager when it successfully added a new
//  company.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)didAddCompany
{
    // If the no added company screen is on display then ...
    if (_noAddedCompanyView)
    {
       // remove it from screen ...
       [_noAddedCompanyView removeFromSuperview];
       _noAddedCompanyView = nil;
       
       // and replace it with a tableView
       [self displayCompanyTableView];
    }

    // Request the table refresh itself.
    [self->_tableView reloadData];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate methods called by CompanyListManager when it successfully deleted a company.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)didDeleteCompanyWithDisplayIndex:(NSInteger)index
{
    // If this is not the last company on the list then ...
    if (_companyListMgr.count)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
                                                    inSection:0];
       
        // show the row deletion
        [_tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
    }
    // Otherwise, ...
    else
        // Remove tableView and display noAddCompanyView
        [self resetOnLastDeletion];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate methods called by CompanyListManager when an error occurred while
//  processing a request.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didGetCompanyListError:(NSString *)errorMsg
{
    // Initialize the controller for displaying the message
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@" "
                                                                   message:errorMsg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    // Create an OK button
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    // Add the button to the controller
    [alert addAction:okButton];
    
    // Display the alert controller on the topmost viewController
    UINavigationController *navigationController = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [navigationController.topViewController presentViewController:alert animated:YES completion:nil];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by CompanyListManager when it successfully updated a company
//  entry.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didUpdateCompany
{
    // Request the table reload itself
    [_tableView reloadData];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by CompanyListManager when the stock prices have been updated.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didUpdateStockPrices
{
    // Request the table reload itself
    [_tableView reloadData];
}

#pragma mark - UITableView Delegate Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method that is called when the user select a row on the tableView.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the company record
    Company *company = [_companyListMgr getCompanyWithDisplayIndex:indexPath.row];
    
    // If in edit mode then ...
    if (_tableView.editing)
    {
        _currentSelectedRow = indexPath.row;
        
        // Initialize the entryViewController
        EntryViewController *entryViewController = [[EntryViewController alloc] init];
        entryViewController.hidesBottomBarWhenPushed = YES;
        [entryViewController setNavigationBarAttributes:@"Edit Company"
                               leftNavigationButtonType:EntryViewNavigationCancelButton
                              rightNavigationButtonType:EntryViewNavigationSaveButton];
        [entryViewController setTextFieldLabel1:@"Company Name:"
                             andTextFieldLabel2:@"Stock Symbol:"
                             andTextFieldLabel3:@"Logo URL:"];
        entryViewController.delegate = _companyListMgr.editor;
        entryViewController.deleteNotificationName = DELETE_COMPANY_NOTIFICATION;

        entryViewController.textEntry1 = company.name;
        entryViewController.textEntry2 = company.stockSymbol;
        entryViewController.textEntry3 = company.logoURL;
        
        // Display the entryViewController
        [self.navigationController pushViewController:entryViewController animated:YES];
        
        // Clean up
        [entryViewController release];
    }
    else
    {
        // Initialize the productViewController
        ProductViewController *productViewController = [[ProductViewController alloc] init];
        productViewController.company = company;

        CATransition *transition = [CATransition animation];
        transition.duration = .5;
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromLeft;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        
        // Display the productViewController
        [self.navigationController pushViewController:productViewController animated:NO];
        
        // Clean up
        [productViewController release];
        
        // http://stackoverflow.com/questions/10961926/how-do-i-do-a-fade-no-transition-between-view-controllers
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method to return the size of the section header.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // Return 0, there is no need to display a section header in this screen.
    return 0.0;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method to return the size of each row in points (not pixel).
//
//////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLE_ROW_HEIGHT;
}

#pragma mark - Private Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called when a company table view needs to be loaded into the current
//  ViewController.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) displayCompanyTableView
{
    // Create and initialize a table view for displaying companies
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                              style:UITableViewStylePlain];
    _tableView.dataSource = _companyListMgr.tableViewInterface;
    _tableView.delegate = self;
    _tableView.allowsSelectionDuringEditing = YES;
    
    // Define an empty UITableView's tableFooterView to hide UITableView Empty Cell
    // Separator Lines
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Load the table view into the current ViewController
    [self.view addSubview:_tableView];
    
    // Initiate loading the table with company data
    [_tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:DELETE_COMPANY_NOTIFICATION
                                               object:nil];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called when user touch the '+' button on the navigation bar or the
//  "+Add Company" button on the _noAddedCompanyView.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) displayEntryViewController
{
    // Create and initialize screen for adding a new company record.
    EntryViewController *entryViewController = [[EntryViewController alloc] init];
    [entryViewController setNavigationBarAttributes:@"New Company"
                           leftNavigationButtonType:EntryViewNavigationCancelButton
                          rightNavigationButtonType:EntryViewNavigationSaveButton];
    [entryViewController setTextFieldLabel1:@"Company Name:"
                         andTextFieldLabel2:@"Stock Symbol:"
                         andTextFieldLabel3:@"Logo URL:"];
    entryViewController.delegate = _companyListMgr.editor;
    
    // Display the screen
    [self.navigationController pushViewController:entryViewController animated:YES];
    
    // Clean up
    [entryViewController release];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to create a screen to display when there are no companies in the dao.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) displayNoAddedCompanyView
{
    const CGFloat PADDING_SIZE = 20.0;
    const CGFloat ICON_SIZE = 66.0;
    const CGFloat MSG_HEIGHT = 60.0;
    const CGFloat BUTTON_HEIGHT = 30.0;
    const CGFloat BUTTON_WIDTH = 160.0;

    CGFloat width = self.view.bounds.size.width;
    CGFloat cumlativeHeight = 0.0;

    // Create container
    _noAddedCompanyView = [[UIView alloc] initWithFrame:self.view.bounds];
    _noAddedCompanyView.backgroundColor = UIColor.whiteColor;

    // Create imageView for displaying the logo
    cumlativeHeight = PADDING_SIZE * 2.0;
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((width - ICON_SIZE) / 2.0, cumlativeHeight - 1.0,
                                                                               ICON_SIZE, ICON_SIZE)];
    iconImageView.image = [UIImage imageNamed:@"emptystate-homeView.png"];
    [_noAddedCompanyView addSubview:iconImageView];

    // Create label for displaying a message
    cumlativeHeight += ICON_SIZE + PADDING_SIZE;
    UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_SIZE - 1.0, cumlativeHeight - 1.0,
                                                             width - PADDING_SIZE * 2.0, MSG_HEIGHT)];
    msg.font = [UIFont boldSystemFontOfSize:16];
    msg.numberOfLines = 0;
    msg.textAlignment = NSTextAlignmentCenter;
    msg.textColor = UIColor.darkGrayColor;
    msg.text = @"You currently don't have any companies added";
    [_noAddedCompanyView addSubview:msg];
    
    // Create a button for adding companies
    cumlativeHeight += MSG_HEIGHT + PADDING_SIZE;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake((width - BUTTON_WIDTH) / 2.0, cumlativeHeight - 1.0, BUTTON_WIDTH, BUTTON_HEIGHT);
    [button setTitle:@"+Add Company" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button addTarget:self
               action:@selector(displayEntryViewController)
     forControlEvents:UIControlEventTouchUpInside];
    [_noAddedCompanyView addSubview:button];
    
    // Load it into the current ViewController
    [self.view addSubview:_noAddedCompanyView];
    
    // Clean up
    [iconImageView release];
    [msg release];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method called by notification center when the user press the delete button.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) handleNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:DELETE_COMPANY_NOTIFICATION])
        [_companyListMgr.editor deleteCompanyWithDisplayIndex:_currentSelectedRow];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called when the redo button is touched.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) redoButtonTouched
{
    [_companyListMgr.editor redo];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called to reset screen after deleting the last row in tableView.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) resetOnLastDeletion
{
    // Change editing mode
    [self toggleEditingMode];
    
    // Remove tableView from screen and ...
    [self unloadCompanyTableView];
    
    // replace it with the no added company view screen
    [self displayNoAddedCompanyView];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called when user touch the 'Edit' or 'Done' button on the navigation bar
//  and when the last row is deleted in the tableView.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) toggleEditingMode
{
    // If in editing mode then ...
    if ([self.navigationItem.leftBarButtonItem.title isEqualToString:@"Edit"])
    {
        if (0 == _companyListMgr.count)
            return;

        [_tableView setEditing:YES animated:YES];
        
        // change button to display 'Done'
        self.navigationItem.leftBarButtonItem.title = @"Done";
        
        // display the toolbar on the bottom of the screen
        [self.navigationController setToolbarHidden:NO];
        
        // If the toolbar has not been initialized yet then ...
        if (!self.navigationController.toolbar.items.count)
        {
            // Set the background color to black.
            self.navigationController.toolbar.barStyle = UIBarStyleBlack;
            
            // Set button color to white
            self.navigationController.toolbar.tintColor = UIColor.whiteColor;
            
            // Populate toolbar with a redo and undo button
            UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                           target:nil
                                                                                           action:nil];
            UIBarButtonItem *button1 = [[UIBarButtonItem alloc] initWithTitle:@"Redo"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(redoButtonTouched)];
            UIBarButtonItem *button2 = [[UIBarButtonItem alloc] initWithTitle:@"Undo"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(undoButtonTouched)];
            NSArray *buttons = [NSArray arrayWithObjects: flexibleSpace, button1, flexibleSpace, button2, flexibleSpace, nil];
            [self setToolbarItems:buttons animated:YES];
            
            // Clean up
            [flexibleSpace release];
            [button1 release];
            [button2 release];
        }
    }
    // Otherwise, ...
    else
    {
        [_tableView setEditing:NO animated:YES];

        _currentSelectedRow = -1;

        // Clear undo stack
        [_companyListMgr.editor reset];
        
        // reset button back to 'Edit'
        self.navigationItem.leftBarButtonItem.title = @"Edit";
        
        // hide the toolbar on the bottom of the screen
        [self.navigationController setToolbarHidden:YES];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called when the undo button is touched.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) undoButtonTouched
{
    [_companyListMgr.editor undo];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to remove the companyTableView from the current screen.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)unloadCompanyTableView
{
    [_tableView removeFromSuperview];
    
    [_tableView release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


