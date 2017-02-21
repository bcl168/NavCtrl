//
//  ProductViewController.m
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//


#import "Globals.h"
#import "DetailViewController.h"
#import "EntryViewController.h"
#import "ProductViewController.h"
#import "ProductListManager.h"


@implementation ProductViewController
{
    UIView *_addProductView;
    NSInteger _currentRow;
    CGFloat _headerHeight;
    ProductListManager *_productListMgr;
    UITableView *_tableView;
}

#pragma mark - Overridden Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Overriden method to perform initialization
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Align the top of the controller to the bottom of navigation bar rather the
    // top of the screen.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // Add a back button on the left side of the navigation bar
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"←"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(performBackNavigation:)];
    [backButton setTitleTextAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:BACK_BUTTON_FONT_SIZE] }
                              forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = backButton;

    // Add an add button on the right side of the navigation bar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(displayAddProduct)];
    
    // Use the company name as the title
    self.title = self.company.name;

    // Register to be notified when the user press the delete button
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:DELETE_PRODUCT_NOTIFICATION
                                               object:nil];

    const CGFloat LOGO_SIZE = 66.0;
    const CGFloat PADDING_SIZE = 11.0;
    const CGFloat HEADER_LABEL_HEIGHT = 33.0;
    
    CGFloat width = self.view.bounds.size.width;
    _headerHeight = PADDING_SIZE + LOGO_SIZE + PADDING_SIZE + HEADER_LABEL_HEIGHT + PADDING_SIZE;
    
    // Create container
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, _headerHeight)];
    headerView.backgroundColor = UIColor.blackColor;
    
    // Create imageView for displaying the logo
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((width - LOGO_SIZE) / 2.0, PADDING_SIZE - 1.0,
                                                                           LOGO_SIZE, LOGO_SIZE)];
    imageView.image = [UIImage imageWithData:self.company.logoData];
    [headerView addSubview:imageView];
    
    // Create label for displaying company name and stock symbol
    UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_SIZE - 1.0, (PADDING_SIZE - 1.0) * 2.0 + LOGO_SIZE,
                                                                      width - PADDING_SIZE * 2.0, HEADER_LABEL_HEIGHT)];
    companyLabel.textAlignment = NSTextAlignmentCenter;
    companyLabel.backgroundColor = [UIColor clearColor];
    companyLabel.textColor = UIColor.whiteColor;
    companyLabel.font = [UIFont boldSystemFontOfSize:16];
    companyLabel.text = [NSString stringWithFormat:@"%@ (%@)", self.title, self.company.stockSymbol];
    [headerView addSubview:companyLabel];

    // display container
    [self.view addSubview:headerView];

    // Initialize product list
    _productListMgr = [[ProductListManager alloc] initWithCompany:self.company];
    _productListMgr.delegate = self;

    // If there are products in the list then ...
    if (_productListMgr.count)
        // display them
        [self displayProductTableView];
    // Otherwise, ...
    else
        // display the there are no added product screen.
        [self displayNoAddedProductView];
}

#pragma mark - ProductListManager Delegate Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by ProductListManager when it successfully added a new product
//  entry.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didAddProduct
{
    // If the there is no product screen is on display then ...
    if (_addProductView)
    {
        // remove it from screen ...
        [_addProductView removeFromSuperview];
        _addProductView = nil;
        
        // and replace it with a tableView
        [self displayProductTableView];
    }
    
    // Request the table refresh itself.
    [self->_tableView reloadData];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by ProductListManager when it successfully deleted a product
//  entry.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didDeleteProduct
{
    // If this is not the last product on the list then ...
    if (_productListMgr.count)
        // Request the table refresh itself.
        [self->_tableView reloadData];
    // Otherwise, ...
    else
        // switch the view
        [self switchView];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by ProductListManager when it successfully deleted a product
//  entry.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didDeleteProductWithDisplayIndex:(NSInteger)index
{
    // If this is not the last product on the list then ...
    if (_productListMgr.count)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
                                                    inSection:0];
        
        // show the row deletion
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    // Otherwise, ...
    else
        // switch the view
        [self switchView];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by ProductListManager when it successfully updated a product
//  entry.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) didUpdateProduct
{
    // Request the table refresh itself.
    [self->_tableView reloadData];
}

#pragma mark - Table View Delegate Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method that is called when the user select a row on the tableView.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentRow = indexPath.row;
    
    // Initialize the DetailViewController
    DetailViewController *productDetailScreen = [[DetailViewController alloc] init];
    productDetailScreen.productListMgr = _productListMgr;
    productDetailScreen.product = [_productListMgr getProductWithDisplayIndex:indexPath.row];

    // Display the DetailViewController.
    [self.navigationController pushViewController:productDetailScreen animated:YES];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method to return if user can delete current row.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView
            editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method to return the size of the section header.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
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
//  Method is called when user touch the '+' button on the navigation bar or the
//  "+Add Product" button on the no added product screen.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) displayAddProduct
{
    EntryViewController *entryViewController = [[EntryViewController alloc] init];
    [entryViewController setNavigationBarAttributes:@"Add Product"
                           leftNavigationButtonType:EntryViewNavigationBackButton
                          rightNavigationButtonType:EntryViewNavigationSaveButton];
    entryViewController.delegate = _productListMgr.editor;
    
    [self.navigationController pushViewController:entryViewController animated:YES];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to create a screen to display when the user has not associated products with
//  the company.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) displayNoAddedProductView
{
    const CGFloat PADDING_SIZE = 20.0;
    const CGFloat MSG_HEIGHT = 50.0;
    const CGFloat BUTTON_HEIGHT = 30.0;
    const CGFloat BUTTON_WIDTH = 160.0;
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height - _headerHeight;
    
    // Create container
    _addProductView = [[UIView alloc] initWithFrame:CGRectMake(0.0, _headerHeight - 1.0, width, height)];
    _addProductView.backgroundColor = UIColor.whiteColor;
    
    // Create label for displaying a message
    UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_SIZE - 1.0, PADDING_SIZE * 2.0 - 1.0,
                                                             width - PADDING_SIZE * 2.0, MSG_HEIGHT)];
    msg.textAlignment = NSTextAlignmentCenter;
    msg.font = [UIFont boldSystemFontOfSize:16];
    msg.numberOfLines = 0;
    msg.textColor = UIColor.darkGrayColor;
    msg.text = @"Add a few of this company's products to track.";
    [_addProductView addSubview:msg];
    
    // Create a button for adding products
    height = MSG_HEIGHT + PADDING_SIZE * 3.0;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake((width - BUTTON_WIDTH) / 2.0, height - 1.0, BUTTON_WIDTH, BUTTON_HEIGHT);
    [button setTitle:@"+Add Product" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button addTarget:self
               action:@selector(displayAddProduct)
     forControlEvents:UIControlEventTouchUpInside];
    [_addProductView addSubview:button];
    
    [self.view addSubview:_addProductView];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called when a product table view needs to be loaded into the current
//  ViewController.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) displayProductTableView
{
    CGFloat height = self.view.bounds.size.height - _headerHeight;
    
    // Create and initialize a table view for displaying products
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, _headerHeight - 1.0, self.view.bounds.size.width, height)
                                              style:UITableViewStylePlain];
    _tableView.dataSource = _productListMgr.tableViewInterface;
    _tableView.delegate = self;
    _tableView.allowsSelectionDuringEditing = YES;
    
    // Define an empty UITableView's tableFooterView to hide UITableView Empty Cell
    // Separator Lines
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Load the table into the current ViewController
    [self.view addSubview:_tableView];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method called by notification center when the user press the delete button.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) handleNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:DELETE_PRODUCT_NOTIFICATION])
        [_productListMgr.editor deleteProductWithDisplayIndex:_currentRow
                                                  fromCompany:_productListMgr.companyName];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called when the user hit the back button.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) performBackNavigation:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // Exit current screen
    [self.navigationController popViewControllerAnimated:NO];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called to reset the display.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) switchView
{
    // remove the table view from the screen ...
    [_tableView removeFromSuperview];
    _tableView = nil;

    // and replace it with a no added product screen
    [self displayNoAddedProductView];
}
 
@end
