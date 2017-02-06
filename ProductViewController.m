//
//  ProductViewController.m
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//


#import "Globals.h"
#import "DataAccessObject.h"
#import "DetailViewController.h"
#import "Product.h"
#import "ProductViewController.h"
#import "UIImage+Resize.h"


#define TABLE_ROW_HEIGHT    76.0
#define PRODUCT_IMAGE_SIZE  (TABLE_ROW_HEIGHT - 12.0)


@interface ProductViewController ()

@end

@implementation ProductViewController
{
    DataAccessObject *_dao;
    UIView *_headerView;
    UIView *_addProductView;
    UITableView *_tableView;
    UITableViewCell *_currentCell;
    NSIndexPath *_indexPathOfCellBeingEdited;
    Product *_currentProduct;
}

#pragma mark - Public Methods

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
    NSString *productName = [textEntry1 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    NSString *productURL = [textEntry2 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    NSString *productImageURL = [textEntry3 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    
    // Check inputs for entry
    if (0 == productName.length)
        return @"Product name missing.";
    else if (0 == productURL.length)
        return @"Product URL missing.";
    else if (0 == productImageURL.length)
        return @"Product image URL missing.";
    
    // Save the new product data
    [_dao addProductWithName:productName
               andProductURL:productURL
          andProductImageURL:productImageURL
                   toCompany:self.companyName];

    return nil;
}

#pragma mark - DAO delegate

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called when user touch the '+' button on the navigation bar or the
//  "+Add Product" button on the no added product screen.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)addProduct
{
    EntryViewController *entryViewController = [[EntryViewController alloc] init];
    [entryViewController setNavigationBarAttributes:@"Add Product"
                           leftNavigationButtonType:EntryViewNavigationBackButton
                          rightNavigationButtonType:EntryViewNavigationSaveButton];
    entryViewController.delegate = self;
    
    [self.navigationController pushViewController:entryViewController animated:YES];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by dao when it successfully added the new product entry.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)didAddProduct:(Product *)newProduct
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       // Add the new product to the company's product list
                       [self.products addObject:newProduct];

                       // If the there is no product screen is on display then ...
                       if (_addProductView)
                       {
                           // remove it from screen ...
                           [_addProductView removeFromSuperview];
                           _addProductView = nil;
                           [_headerView removeFromSuperview];
                           
                           // and replace it with a tableView
                           [self loadProductTableView];
                       }
                       
                       // Request the table refresh itself.
                       [self->_tableView reloadData];
                   });
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by dao when it successfully updated a product entry.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)didUpdateProduct:(Product *)product
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       // Request the table refresh itself.
                       [self->_tableView reloadData];
                   });
}


#pragma mark - Overridden Methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
                                                                                           action:@selector(addProduct)];
    
    // Use the company name as the title
    self.title = self.companyName;

    // Create and initialize a data access object
    _dao = [DataAccessObject sharedInstance];
    _dao.productDelegate = self;

    // Register to be notified when the user press the delete button
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:DELETE_PRODUCT_NOTIFICATION
                                               object:nil];
    
    // If there are products in the list then ...
    if (self.products.count)
        // display them
        [self loadProductTableView];
    // Otherwise, ...
    else
        // display the there are no added product screen.
        [self loadNoAddedProductView];
}

#pragma mark - Table view data source

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method to specify the number of section in the tableView.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method to specify if the current row in the table view can be edited.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
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
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    // Configure the cell...
    Product *product = self.products[indexPath.row];
    
    // Load current cell with the product data
    [self loadCell:cell withProduct:product];
    
    return cell;
}

// Override to support editing the table view.
- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        [_dao deleteProduct:_currentProduct.name fromCompany:self.companyName];
        
        [self.products removeObjectAtIndex:indexPath.row];
        
        // If this is not the last company on the list then ...
        if (self.products.count)
            // show the row deletion
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        // Otherwise, ...
        else
        {
            // Don't bother deleting the last product from screen.
            
            // Instead, remove tableView from screen and ...
            [self unloadProductTableView];
            
            // replace it with the no added product view screen
            [self loadNoAddedProductView];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method to specify the number of rows in the tableView.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) tableView:(UITableView *)tableView
  numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.products count];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method for loading data into the section header.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _headerView;
}


#pragma mark - Table view delegate

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method that is called when the user select a row on the tableView.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController *productDetailScreen = [[DetailViewController alloc] init];

    _currentCell = [tableView cellForRowAtIndexPath:indexPath];
    _currentProduct = self.products[indexPath.row];
    productDetailScreen.companyName = self.companyName;
    productDetailScreen.product = _currentProduct;

    // Push the view controller.
    [self.navigationController pushViewController:productDetailScreen animated:YES];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method to return if user can delete current row.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView
            editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{    NSLog(@"editingStyleForRowAtIndexPath");
    return UITableViewCellEditingStyleDelete;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method to return the size of the section header.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _headerView.frame.size.height;
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
//  Method called by notification center when the user press the delete button.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)handleNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:DELETE_PRODUCT_NOTIFICATION])
        [self tableView:_tableView
     commitEditingStyle:UITableViewCellEditingStyleDelete
      forRowAtIndexPath:_indexPathOfCellBeingEdited];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called to load product data into a cell.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)loadCell:(UITableViewCell *)cell withProduct:(Product *)product
{
    cell.textLabel.text = product.name;
    
    // Resize the product image before loading
    UIImage *productImage = [UIImage imageWithData:product.imageData];
    CGSize newSize = CGSizeMake(PRODUCT_IMAGE_SIZE, PRODUCT_IMAGE_SIZE);
    cell.imageView.image = [productImage scaleToSize:newSize];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to create a header containing a company logo, name and stock symbol.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)loadHeaderView
{
    // If already loaded then ...
    if (_headerView)
        // nothing further to do, just exit routine.
        return;

    const CGFloat LOGO_SIZE = 66.0;
    const CGFloat PADDING_SIZE = 11.0;
    const CGFloat HEADER_LABEL_HEIGHT = 33.0;

    CGFloat width = self.view.bounds.size.width;
    CGFloat height = PADDING_SIZE + LOGO_SIZE + PADDING_SIZE + HEADER_LABEL_HEIGHT + PADDING_SIZE;
    
    // Create container
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, height)];
    _headerView.backgroundColor = UIColor.blackColor;
    
    // Create imageView for displaying the logo
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((width - LOGO_SIZE) / 2.0, PADDING_SIZE - 1.0,
                                                                            LOGO_SIZE, LOGO_SIZE)];
    imageView.image = self.logo;
    [_headerView addSubview:imageView];

    // Create label for displaying company name and stock symbol
    UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_SIZE - 1.0, (PADDING_SIZE - 1.0) * 2.0 + LOGO_SIZE,
                                                                      width - PADDING_SIZE * 2.0, HEADER_LABEL_HEIGHT)];
    companyLabel.textAlignment = NSTextAlignmentCenter;
    companyLabel.backgroundColor = [UIColor clearColor];
    companyLabel.textColor = UIColor.whiteColor;
    companyLabel.font = [UIFont boldSystemFontOfSize:16];
    companyLabel.text = [NSString stringWithFormat:@"%@ (%@)", self.title, self.stockSymbol];
    [_headerView addSubview:companyLabel];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to create a screen to display when the user has not associated products with
//  the company.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)loadNoAddedProductView
{
    [self loadHeaderView];
    [self.view addSubview:_headerView];
    
    const CGFloat PADDING_SIZE = 20.0;
    const CGFloat MSG_HEIGHT = 50.0;
    const CGFloat BUTTON_HEIGHT = 30.0;
    const CGFloat BUTTON_WIDTH = 160.0;
    
    CGFloat headerHeight = _headerView.frame.size.height;
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height - headerHeight;
    
    // Create container
    _addProductView = [[UIView alloc] initWithFrame:CGRectMake(0.0, headerHeight - 1.0, width, height)];
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
               action:@selector(addProduct)
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
- (void)loadProductTableView
{
    // Create and initialize a table view for displaying products
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                              style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.allowsSelectionDuringEditing = YES;
    
    // Define an empty UITableView's tableFooterView to hide UITableView Empty Cell
    // Separator Lines
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Load the table into the current ViewController
    [self.view addSubview:_tableView];
    
    // If section header has not been loaded then ...
    if (!_headerView)
        // load it
        [self loadHeaderView];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called when the user hit the back button.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)performBackNavigation:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // Exit current screen
    [self.navigationController popViewControllerAnimated:NO];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to remove the productTableView from the current screen.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)unloadProductTableView
{
    [_tableView removeFromSuperview];
    _tableView = nil;
}

@end
