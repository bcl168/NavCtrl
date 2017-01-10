//
//  DetailViewController.m
//  NavCtrl
//
//  Created by bl on 1/9/17.
//  Copyright © 2017 Aditya Narayan. All rights reserved.
//


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
    
    self.title = @"Product Link";
    
    // Set left navigation button to a back button
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"←" style:UIBarButtonItemStylePlain target:self action:@selector(performBackNavigation:)];
    [backButton setTitleTextAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:30] } forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = backButton;

    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    NSURL *url = [NSURL URLWithString:self.productURL];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:_webView];
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

- (void)performBackNavigation:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}


@end
