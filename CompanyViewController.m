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
#define TABLE_ROW_HEIGHT    76.0
#define LOGO_SIZE           (TABLE_ROW_HEIGHT - 12.0)


@interface CompanyViewController ()

@end

@implementation CompanyViewController
{
    DataAccessObject *_dao;
    UIView *_noAddedCompanyView;
    UITableView *_tableView;
    NSUndoManager *_undoManager;
    NSIndexPath *_indexPathOfCellBeingEdited;
    Company *_companyBeingEdited;
    Boolean _tableViewNeedsToBeReloaded;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called when user touch the '+' button on the navigation bar or the
//  "+Add Company" button on the _noAddedCompanyView.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)addCompany
{
    // Create and initialize screen for adding a new company record.
    EntryViewController *entryViewController = [[EntryViewController alloc] init];
    [entryViewController setNavigationBarAttributes:@"New Company"
                           leftNavigationButtonType:EntryViewNavigationCancelButton
                          rightNavigationButtonType:EntryViewNavigationSaveButton];
    entryViewController.delegate = self;
    
    // Display the screen
    [self.navigationController pushViewController:entryViewController animated:YES];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by dao when it successfully added the new company entry.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)didAddCompany
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       // If the there is no company screen is on display then ...
                       if (_noAddedCompanyView)
                       {
                           // remove it from screen ...
                           [_noAddedCompanyView removeFromSuperview];
                           _noAddedCompanyView = nil;
                           
                           // and replace it with a tableView
                           [self loadCompanyTableView];
                       }
                       
                       // Request the table refresh itself.
                       [self->_tableView reloadData];
                   });
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate methods called by dao when it successfully deleted a company entry.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)didDeleteCompanyWithDisplayIndex:(NSInteger)index
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       // If this is not the last company on the list then ...
                       if ([_dao getCompanyCount])
                       {
                           NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
                                                                       inSection:0];
                           
                           // show the row deletion
                           [_tableView deleteRowsAtIndexPaths:@[indexPath]
                                             withRowAnimation:UITableViewRowAnimationFade];
                       }
                       // Otherwise, ...
                       else
                           [self resetOnLastDeletion];
                   });
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by dao when it successfully updated a company entry.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)didUpdateCompany:(Company *)company
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       // Request the table reload itself
                       [_tableView reloadData];
                   });
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by dao when it successfully updated a company entry.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)didUpdateCompanyDisplayIndexFrom:(NSInteger)currentIndex
                                      to:(NSInteger)newIndex
{
    if (_tableViewNeedsToBeReloaded)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           // Request the table reload itself
                           [_tableView reloadData];
                       });
        
        _tableViewNeedsToBeReloaded = NO;
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method called by notification center when the user press the delete button.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)handleNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:DELETE_COMPANY_NOTIFICATION])
    {
        [self tableView:_tableView
     commitEditingStyle:UITableViewCellEditingStyleDelete
      forRowAtIndexPath:_indexPathOfCellBeingEdited];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by EntryViewController when the user wants to do a save.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)saveTextEntry1:(NSString *)textEntry1
               andTextEntry2:(NSString *)textEntry2
               andTextEntry3:(NSString *)textEntry3
{
    // Trim leading and trailing spaces from all inputs
    NSCharacterSet *allWhitespaceCharacters = [NSCharacterSet whitespaceCharacterSet];
    NSString *companyName = [textEntry1 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    NSString *stockSymbol = [textEntry2 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    NSString *logoURL = [textEntry3 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    
    // Check inputs for entry
    if (0 == companyName.length)
        return @"Company name missing.";
    else if (0 == stockSymbol.length)
        return @"Stock symbol missing.";
    else if (0 == logoURL.length)
        return @"URL for logo missing.";

    // If in edit mode then ...
    if (_tableView.editing)
    {
        // If one of the input has changed then ...
        if (![_companyBeingEdited.name isEqualToString:companyName] ||
            ![_companyBeingEdited.stockSymbol isEqualToString:stockSymbol] ||
            ![_companyBeingEdited.logoURL isEqualToString:logoURL])
        {
            Company *newCompany = [[Company alloc] initWithName:companyName
                                                 andStockSymbol:stockSymbol
                                                  andStockPrice:0.0
                                                     andLogoURL:logoURL];
            
            [self updateCompanyWithUndoFrom:[_companyBeingEdited copy]
                                         to:newCompany];
        }
    }
    // Otherwise, ...
    else
        // Save the new company data
        [_dao addCompanyWithName:companyName
                  andStockSymbol:stockSymbol
                      andLogoURL:logoURL];

    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called when user touch the 'Edit' or 'Done' button on the navigation bar
//  and when the last row is deleted in the tableView.
//
//////////////////////////////////////////////////////////////////////////////////////////
-(void)toggleEditingMode
{
    // Toggle editing state
    [_tableView setEditing:!_tableView.editing animated:YES];

    // If in editing mode then ...
    if (_tableView.editing)
    {
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
                                                                       action:@selector(redo)];
            UIBarButtonItem *button2 = [[UIBarButtonItem alloc] initWithTitle:@"Undo"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(undo)];
            NSArray *buttons = [NSArray arrayWithObjects: flexibleSpace, button1, flexibleSpace, button2, flexibleSpace, nil];
            [self setToolbarItems:buttons animated:YES];
        }
    }
    // Otherwise, ...
    else
    {
        _indexPathOfCellBeingEdited = nil;
        _companyBeingEdited = nil;

        // Clear undo stack
        [_undoManager removeAllActions];
        
        // reset button back to 'Edit'
        self.navigationItem.leftBarButtonItem.title = @"Edit";
        
        // hide the toolbar on the bottom of the screen
        [self.navigationController setToolbarHidden:YES];
    }
}

#pragma mark - Overridden Methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
                                                                                           action:@selector(addCompany)];
    
    // Set screen title
    self.title = @"Stock Tracker";
    
    _undoManager = [[NSUndoManager alloc] init];
    
    // Create and initialize a data access object
    _dao = [DataAccessObject sharedInstance];
    _dao.companyDelegate = self;
    
    // If there are companies in the dao then ...
    if ([_dao getCompanyCount])
        // display them
        [self loadCompanyTableView];
    // Otherwise, ...
    else
        // display a there are no company screen
        [self loadNoAddedCompanyView];
}

#pragma mark - Table view data source

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method that return if the specified row can move or not.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method to specify the number of section in the tableView.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method to specify the number of rows in the tableView.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [_dao getCompanyCount];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method to specify if the current row is editable.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method for loading data into current row of the tableView.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    
    // Get the company record
    Company *company = [_dao getCompanyWithDisplayIndex:indexPath.row];
    
    // Load current cell with the company data
    [self loadCell:cell withCompany:company];

    return cell;
}

// Override to support editing the table view.
- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Company *company = [_dao getCompanyWithDisplayIndex:indexPath.row];
        
        [self deleteCompanyWithUndo:(Company *)company withIndexPath:indexPath];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

// Override to support rearranging the table view.
- (void) tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
       toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath == toIndexPath)
        return;

    // Save the change to the undo stack
    [[_undoManager prepareWithInvocationTarget:self] updateCompanyDisplayIndexWithUndoFrom:toIndexPath
                                                                               toIndexPath:fromIndexPath];

    _tableViewNeedsToBeReloaded = NO;
    
    // Make the change
    [_dao updateCompanyDisplayIndexFrom:fromIndexPath.row to:toIndexPath.row];
}

#pragma mark - Table view delegate

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method that is called when the user select a row on the tableView.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If in edit mode then ...
    if (self->_tableView.editing)
    {
        _indexPathOfCellBeingEdited = indexPath;
        
        EntryViewController *entryViewController = [[EntryViewController alloc] init];
        entryViewController.hidesBottomBarWhenPushed = YES;
        [entryViewController setNavigationBarAttributes:@"Edit Company"
                                    leftNavigationButtonType:EntryViewNavigationCancelButton
                                   rightNavigationButtonType:EntryViewNavigationSaveButton];
        entryViewController.delegate = self;
        entryViewController.deleteNotificationName = DELETE_COMPANY_NOTIFICATION;

        // Get the company record
        _companyBeingEdited = [_dao getCompanyWithDisplayIndex:indexPath.row];

        entryViewController.textEntry1 = _companyBeingEdited.name;
        entryViewController.textEntry2 = _companyBeingEdited.stockSymbol;
        entryViewController.textEntry3 = _companyBeingEdited.logoURL;
        
        [self.navigationController pushViewController:entryViewController animated:YES];
    }
    else
    {
        // Get the company record
        Company *company = [_dao getCompanyWithDisplayIndex:indexPath.row];
        
        ProductViewController *productViewController = [[ProductViewController alloc] init];
        productViewController.companyName = company.name;
        productViewController.stockSymbol = company.stockSymbol;
        productViewController.logo = [UIImage imageWithData:company.logoData];
        productViewController.products = company.products;

        [self.navigationController pushViewController:productViewController animated:YES];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method to return the size of the section header.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // Return 0, there is no need to display a section header in this screen.
    return 0.0;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method to return the size of each row in points (not pixel).
//
//////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLE_ROW_HEIGHT;
}


#pragma mark - Private Wrapper Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Wrapper methods for deleting a company with undo feature.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) deleteCompanyWithUndo:(Company *)company
              withIndexPath:(NSIndexPath *)indexPath
{
    // Save the opposite to the undo stack
    [[_undoManager prepareWithInvocationTarget:self] insertCompanyWithUndo:company
                                                             withIndexPath:indexPath];
    
    // Delete the company from the data source
    [_dao deleteCompanyWithDisplayIndex:indexPath.row];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Wrapper method for inserting a company with undo feature.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) insertCompanyWithUndo:(Company *)company
                 withIndexPath:(NSIndexPath *)indexPath
{
    // Save the opposite to the undo stack
    [[_undoManager prepareWithInvocationTarget:self] deleteCompanyWithUndo:company
                                                             withIndexPath:indexPath];
    
    // Insert the company into the data source
    [_dao insertCompany:company withDisplayIndex:indexPath.row];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Wrapper methods for updating a company's display index with undo feature.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) updateCompanyDisplayIndexWithUndoFrom:(NSIndexPath *)fromIndexPath
                                   toIndexPath:(NSIndexPath *)toIndexPath
{
    // Save the change to the undo stack
    [[_undoManager prepareWithInvocationTarget:self] updateCompanyDisplayIndexWithUndoFrom:toIndexPath
                                                                               toIndexPath:fromIndexPath];
    
    _tableViewNeedsToBeReloaded = YES;
    
    // Make the change
    [_dao updateCompanyDisplayIndexFrom:fromIndexPath.row to:toIndexPath.row];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Wrapper methods for updating a company's record with undo feature.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) updateCompanyWithUndoFrom:(Company *)originalCompany
                                to:(Company *)newCompany
{
    // Save the change to the undo stack
    [[_undoManager prepareWithInvocationTarget:self] updateCompanyWithUndoFrom:newCompany
                                                                            to:originalCompany];
    
    // Save the changes
    [_dao updateCompanyWithName:originalCompany.name
                             to:newCompany.name
                withStockSymbol:newCompany.stockSymbol
                     andLogoURL:newCompany.logoURL];
}


#pragma mark - Private Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called to load company data into a cell.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)loadCell:(UITableViewCell *)cell withCompany:(Company *)company
{
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", company.name, company.stockSymbol];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"$%.2f", company.stockPrice];

    // Resize the logo before loading
    UIImage *logoImage = [UIImage imageWithData:company.logoData];
    CGSize newSize = CGSizeMake(LOGO_SIZE, LOGO_SIZE);
    cell.imageView.image = [logoImage scaleToSize:newSize];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called when a company table view needs to be loaded into the current
//  ViewController.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)loadCompanyTableView
{
    // Create and initialize a table view for displaying companies
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                              style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.allowsSelectionDuringEditing = YES;
    
    // Define an empty UITableView's tableFooterView to hide UITableView Empty Cell
    // Separator Lines
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Load it into the current ViewController
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
//  Method to create a screen to display when there are no companies in the dao.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)loadNoAddedCompanyView
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
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];  // UIButtonTypeCustom??
    button.frame = CGRectMake((width - BUTTON_WIDTH) / 2.0, cumlativeHeight - 1.0, BUTTON_WIDTH, BUTTON_HEIGHT);
    [button setTitle:@"+Add Company" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button addTarget:self
               action:@selector(addCompany)
     forControlEvents:UIControlEventTouchUpInside];
    [_noAddedCompanyView addSubview:button];
    
    // Load it into the current ViewController
    [self.view addSubview:_noAddedCompanyView];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called when the redo button is touched.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) redo
{
    [_undoManager redo];
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
    [self loadNoAddedCompanyView];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to remove the companyTableView from the current screen.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)unloadCompanyTableView
{
    [_tableView removeFromSuperview];
    _tableView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called when the undo button is touched.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) undo
{
    [_undoManager undo];
}

@end
