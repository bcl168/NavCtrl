//
//  DetailViewController.m
//  NavCtrl
//
//  Created by bl on 1/9/17.
//  Copyright © 2017 bl. All rights reserved.
//


#import "Globals.h"
#import "DetailViewController.h"


@implementation DetailViewController
{
    WKWebView *_webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Align the top of the controller to the bottom of navigation bar rather the
    // top of the screen.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title = @"Product Link";
    
    // Add a back button on the left side of the navigation bar
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"←"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(performBackNavigation:)];
    [backButton setTitleTextAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:30] }
                              forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = backButton;

    // Add an edit button on the right side of the navigation bar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(gotoEditScreen)];

    // Create a webView
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    [self.view addSubview:_webView];
    
    // Load the web page for the product
    NSURL *url = [NSURL URLWithString:self.product.url];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by EntryViewController when the user wants to do a save.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSString *) saveChangedTextEntry1:(NSString *)newTextEntry1
                      fromTextEntry1:(NSString *)originalTextEntry1
                andChangedTextEntry2:(NSString *)newTextEntry2
                      fromTextEntry2:(NSString *)originalTextEntry2
                andChangedTextEntry3:(NSString *)newTextEntry3
                      fromTextEntry3:(NSString *)originalTextEntry3;
{
    // Trim leading and trailing spaces from all inputs
    NSCharacterSet *allWhitespaceCharacters = [NSCharacterSet whitespaceCharacterSet];
    NSString *productName = [newTextEntry1 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    NSString *productURL = [newTextEntry2 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    NSString *productImageURL = [newTextEntry3 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    BOOL productURLChanged;
    
    // Check inputs for entry
    if (0 == productName.length)
        return @"Product name missing.";
    else if (0 == productURL.length)
        return @"Product URL missing.";
    else if (0 == productImageURL.length)
        return @"Product image URL missing.";

    productURLChanged = ![originalTextEntry2 isEqualToString:productURL];

    // If one of the input has changed then ...
    if (![originalTextEntry1 isEqualToString:productName] ||
        ![originalTextEntry3 isEqualToString:productImageURL] ||
        productURLChanged)
    {
        DataAccessObject *dao = [DataAccessObject sharedInstance];
        
        // Save the changes
        [dao updateProductWithName:self.product.name
                                to:productName
                     andProductURL:productURL
                andProductImageURL:productImageURL
                         inCompany:self.productListMgr.companyName];
        
        // If url changed then ...
        if (productURLChanged)
        {
            // Download the new web page
            NSURL *url = [NSURL URLWithString:productURL];
            [_webView loadRequest:[NSURLRequest requestWithURL:url]];
        }
    }

    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called when user hits the edit button on the navigation bar.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) gotoEditScreen
{
    // Create and initialize entry screen
    EntryViewController *entryViewController = [[EntryViewController alloc] init];
    [entryViewController setNavigationBarAttributes:@"Edit Product"
                           leftNavigationButtonType:EntryViewNavigationCancelButton
                          rightNavigationButtonType:EntryViewNavigationSaveButton];
    [entryViewController setTextFieldLabel1:@"Product Name:"
                         andTextFieldLabel2:@"Product URL:"
                         andTextFieldLabel3:@"Image URL:"];
    entryViewController.delegate = self.productListMgr.editor;
    entryViewController.destinationControllerForDelete = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    entryViewController.deleteNotificationName = DELETE_PRODUCT_NOTIFICATION;
    
    // Load current values into the text fields
    entryViewController.textEntry1 = self.product.name;
    entryViewController.textEntry2 = self.product.url;
    entryViewController.textEntry3 = self.product.imageURL;
    
    // Go to the entry screen
    [self.navigationController pushViewController:entryViewController animated:YES];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called when user hits the back button on the navigation bar.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void)performBackNavigation:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

@end
