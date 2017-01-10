//
//  CompanyViewController.m
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//


#import "CompanyViewController.h"
#import "ProductViewController.h"
#import "Company.h"


@interface CompanyViewController ()

@end

@implementation CompanyViewController
{
    NSMutableArray *_companies;
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

- (void)viewDidLoad
{
    Company *company;
    Product *product;

    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Add edit button on the left
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.title = @"Stock Tracker";
    
    _companies = [[NSMutableArray alloc] init];

    company = [[Company alloc] initWithName:@"Apple" andStockSymbol:@"APPL" andStockPrice:96.6];
    [_companies addObject:company];
    product = [[Product alloc] initWithName:@"MacBook Pro" andURL:@"https://www.apple.com/macbook-pro/"];
    [company.products addObject:product];
    product = [[Product alloc] initWithName:@"iPhone" andURL:@"https://www.apple.com/iphone/"];
    [company.products addObject:product];
    product = [[Product alloc] initWithName:@"iPad" andURL:@"https://www.apple.com/ipad/"];
    [company.products addObject:product];
    product = [[Product alloc] initWithName:@"Watch" andURL:@"https://www.apple.com/watch/"];
    [company.products addObject:product];

    company = [[Company alloc] initWithName:@"Google" andStockSymbol:@"GOOG" andStockPrice:708.01];
    [_companies addObject:company];
    product = [[Product alloc] initWithName:@"Pixel" andURL:@"https://madeby.google.com/phone/"];
    [company.products addObject:product];
    product = [[Product alloc] initWithName:@"Chromecast" andURL:@"https://chromecast.com/chromecast/"];
    [company.products addObject:product];
    product = [[Product alloc] initWithName:@"Nexus" andURL:@"https://www.google.com/nexus/"];
    [company.products addObject:product];

    company = [[Company alloc] initWithName:@"Twitter" andStockSymbol:@"TWTR" andStockPrice:16.93];
    [_companies addObject:company];

    company = [[Company alloc] initWithName:@"Tesla" andStockSymbol:@"TSLA" andStockPrice:175.33];
    [_companies addObject:company];
    product = [[Product alloc] initWithName:@"Model S" andURL:@"https://www.tesla.com/models"];
    [company.products addObject:product];
    product = [[Product alloc] initWithName:@"Model X" andURL:@"https://www.tesla.com/modelx"];
    [company.products addObject:product];
    product = [[Product alloc] initWithName:@"Model 3" andURL:@"https://www.tesla.com/model3"];
    [company.products addObject:product];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_companies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Company *company = _companies[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:company.name];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", company.name, company.stockSymbol];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"$%.2f", company.stockPrice];
    
    return cell;
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
        [_companies removeObjectAtIndex:indexPath.row];
        
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
    
    Company *temp = _companies[fromIndexPath.row];
    [_companies removeObjectAtIndex:fromIndexPath.row];
    [_companies insertObject:temp atIndex:toIndexPath.row];
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
    Company *company = _companies[indexPath.row];
    self.productViewController.title = company.name;
    self.productViewController.stockSymbol = company.stockSymbol;
    self.productViewController.products = company.products;

    [self.navigationController pushViewController:self.productViewController animated:YES];
}

@end
