//
//  ProductViewController.m
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//


#import <WebKit/WebKit.h>
#import "ProductViewController.h"


#define LARGE_LOGO_SIZE     180.0


const CGFloat PADDING_SIZE = 16.0;
const CGFloat HEADER_LABEL_HEIGHT = 36.0;


@interface ProductViewController ()

@end

@implementation ProductViewController
{
    UIView *_headerContainerView;
    UIImageView *_headerImageView;
    UILabel *_headerLabel;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
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

    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
 
    // Set left navigation button to a back button
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"←"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(performBackNavigation:)];
    [backButton setTitleTextAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:30] }
                              forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = backButton;

    // Set right navigation button to an add button
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return PADDING_SIZE + LARGE_LOGO_SIZE + PADDING_SIZE + HEADER_LABEL_HEIGHT + PADDING_SIZE;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    // Configure the cell...
    cell.textLabel.text = self.products[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (nil == _headerContainerView)
    {
        CGFloat width = CGRectGetWidth(tableView.bounds);
        CGFloat height = CGRectGetHeight(tableView.bounds);
        
        // Create container
        _headerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, height)];
        _headerContainerView.backgroundColor = UIColor.blackColor;

        // Create imageView for displaying the logo
        _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((width - LARGE_LOGO_SIZE) / 2.0, PADDING_SIZE - 1.0,
                                                                         LARGE_LOGO_SIZE, LARGE_LOGO_SIZE)];

        // Create label for displaying company name and stock symbol
        _headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_SIZE - 1.0, (PADDING_SIZE - 1.0) * 2.0 + LARGE_LOGO_SIZE,
                                                                 width - PADDING_SIZE * 2.0, HEADER_LABEL_HEIGHT)];
        _headerLabel.textAlignment = NSTextAlignmentCenter;
        _headerLabel.backgroundColor = [UIColor clearColor];
        _headerLabel.textColor = UIColor.whiteColor;
        _headerLabel.font = [UIFont boldSystemFontOfSize:24];

        // Add imageView and label to container
        [_headerContainerView addSubview:_headerImageView];
        [_headerContainerView addSubview:_headerLabel];
    }

    _headerImageView.image = [UIImage imageNamed:self.title];
    _headerLabel.text = [NSString stringWithFormat:@"%@ (%@)", self.title, self.stockSymbol];

    return _headerContainerView;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.products removeObjectAtIndex:indexPath.row];
        [self.productURLs removeObjectAtIndex:indexPath.row];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath == toIndexPath)
        return;

    NSMutableArray *tempArray = self.products[fromIndexPath.row];
    [self.products removeObjectAtIndex:fromIndexPath.row];
    [self.products insertObject:tempArray atIndex:toIndexPath.row];

    tempArray = self.productURLs[fromIndexPath.row];
    [self.productURLs removeObjectAtIndex:fromIndexPath.row];
    [self.productURLs insertObject:tempArray atIndex:toIndexPath.row];
}


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.

    
    // Pass the selected object to the new view controller.
    self.detailViewController = [[DetailViewController alloc] init];

    self.detailViewController.productURL = self.productURLs[indexPath.row];
    
    // Push the view controller.
    [self.navigationController pushViewController:_detailViewController animated:YES];
}

- (void)performBackNavigation:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

@end
