//
//  CompanyViewController.m
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//


#import "CompanyViewController.h"
#import "ProductViewController.h"


@interface CompanyViewController ()

@end

@implementation CompanyViewController
{
    NSMutableArray *_companies;
    NSMutableArray *_stockSymbols;
    NSMutableArray *_stockPrices;
    NSMutableArray *_productsMatrix;
    NSMutableArray *_productURLsMatrix;
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
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
 
    // Add edit button on the left
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.title = @"Stock Tracker";
    
    _companies = [[NSMutableArray alloc] init];
    [_companies addObject:@"Apple"];
    [_companies addObject:@"Google"];
    [_companies addObject:@"Twitter"];
    [_companies addObject:@"Tesla"];
    
    _stockSymbols = [[NSMutableArray alloc] init];
    [_stockSymbols addObject:@"APPL"];
    [_stockSymbols addObject:@"GOOG"];
    [_stockSymbols addObject:@"TWTR"];
    [_stockSymbols addObject:@"TSLA"];
    
    _stockPrices = [[NSMutableArray alloc] init];
    [_stockPrices addObject:@"$96.60"];
    [_stockPrices addObject:@"$708.01"];
    [_stockPrices addObject:@"$16.93"];
    [_stockPrices addObject:@"$175.33"];
    
    _productsMatrix = [[NSMutableArray alloc] init];
    
    NSMutableArray *products = [[NSMutableArray alloc] init];
    [products addObject:@"MacBook Pro"];
    [products addObject:@"iPhone"];
    [products addObject:@"iPad"];
    [products addObject:@"Watch"];
    [_productsMatrix addObject:products];

    products = [[NSMutableArray alloc] init];
    [products addObject:@"Pixel"];
    [products addObject:@"Chromecast"];
    [products addObject:@"Nexus"];
    [_productsMatrix addObject:products];

    products = [[NSMutableArray alloc] init];
    [_productsMatrix addObject:products];
    
    products = [[NSMutableArray alloc] init];
    [products addObject:@"Model S"];
    [products addObject:@"Model X"];
    [products addObject:@"Model 3"];
    [_productsMatrix addObject:products];

    _productURLsMatrix = [[NSMutableArray alloc] init];
    
    NSMutableArray *URLs = [[NSMutableArray alloc] init];
    [URLs addObject:@"https://www.apple.com/macbook-pro/"];
    [URLs addObject:@"https://www.apple.com/iphone/"];
    [URLs addObject:@"https://www.apple.com/ipad/"];
    [URLs addObject:@"https://www.apple.com/watch/"];
    [_productURLsMatrix addObject:URLs];
    
    URLs = [[NSMutableArray alloc] init];
    [URLs addObject:@"https://madeby.google.com/phone/"];
    [URLs addObject:@"https://chromecast.com/chromecast/"];
    [URLs addObject:@"https://www.google.com/nexus/"];
    [_productURLsMatrix addObject:URLs];

    URLs = [[NSMutableArray alloc] init];
    [_productURLsMatrix addObject:URLs];
    
    URLs = [[NSMutableArray alloc] init];
    [URLs addObject:@"https://www.tesla.com/models"];
    [URLs addObject:@"https://www.tesla.com/modelx"];
    [URLs addObject:@"https://www.tesla.com/model3"];
    [_productURLsMatrix addObject:URLs];
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
    NSString *companyName = _companies[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:companyName];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", companyName, _stockSymbols[indexPath.row]];
    cell.detailTextLabel.text = _stockPrices[indexPath.row];
    
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
        [_stockSymbols removeObjectAtIndex:indexPath.row];
        [_stockPrices removeObjectAtIndex:indexPath.row];
        [_productsMatrix removeObjectAtIndex:indexPath.row];
        [_productURLsMatrix removeObjectAtIndex:indexPath.row];
        
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
    
    NSString *tempString = _companies[fromIndexPath.row];
    [_companies removeObjectAtIndex:fromIndexPath.row];
    [_companies insertObject:tempString atIndex:toIndexPath.row];
    
    tempString = _stockSymbols[fromIndexPath.row];
    [_stockSymbols removeObjectAtIndex:fromIndexPath.row];
    [_stockSymbols insertObject:tempString atIndex:toIndexPath.row];
    
    tempString = _stockPrices[fromIndexPath.row];
    [_stockPrices removeObjectAtIndex:fromIndexPath.row];
    [_stockPrices insertObject:tempString atIndex:toIndexPath.row];
    
    NSMutableArray *tempArray = _productsMatrix[fromIndexPath.row];
    [_productsMatrix removeObjectAtIndex:fromIndexPath.row];
    [_productsMatrix insertObject:tempArray atIndex:toIndexPath.row];
    
    tempArray = _productURLsMatrix[fromIndexPath.row];
    [_productURLsMatrix removeObjectAtIndex:fromIndexPath.row];
    [_productURLsMatrix insertObject:tempArray atIndex:toIndexPath.row];
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
    self.productViewController.title = _companies[indexPath.row];
    self.productViewController.stockSymbol = _stockSymbols[indexPath.row];
    self.productViewController.products = _productsMatrix[indexPath.row];
    self.productViewController.productURLs = _productURLsMatrix[indexPath.row];

    [self.navigationController pushViewController:self.productViewController animated:YES];
}

@end
