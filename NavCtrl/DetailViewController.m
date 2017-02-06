//
//  DetailViewController.m
//  NavCtrl
//
//  Created by bl on 1/9/17.
//  Copyright © 2017 Aditya Narayan. All rights reserved.
//


#import "Globals.h"
#import "DataAccessObject.h"
#import "DetailViewController.h"


@interface DetailViewController ()

@end

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    Boolean productURLChanged;
    
    // Check inputs for entry
    if (0 == productName.length)
        return @"Product name missing.";
    else if (0 == productURL.length)
        return @"Product URL missing.";
    else if (0 == productImageURL.length)
        return @"Product image URL missing.";

    productURLChanged = ![self.product.url isEqualToString:productURL];

    // If one of the input has changed then ...
    if (![self.product.name isEqualToString:productName] ||
        ![self.product.imageURL isEqualToString:productImageURL] ||
        productURLChanged)
    {
        DataAccessObject *dao = [DataAccessObject sharedInstance];
        
        // Save the changes
        [dao updateProductWithName:self.product.name
                                to:productName
                     andProductURL:productURL
                andProductImageURL:productImageURL
                         inCompany:self.companyName];
        
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
    // Create and initialize entrhy screen
    EntryViewController *entryViewController = [[EntryViewController alloc] init];
    [entryViewController setNavigationBarAttributes:@"Edit Product"
                           leftNavigationButtonType:EntryViewNavigationCancelButton
                          rightNavigationButtonType:EntryViewNavigationSaveButton];
    entryViewController.delegate = self;
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
