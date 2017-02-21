//
//  CompanyListTableViewInterface.m
//  NavCtrl
//
//  Created by bl on 2/13/17.
//  Copyright © 2017 bl. All rights reserved.
//


#import "Globals.h"
#import "CompanyListManager.h"
#import "UIImage+Resize.h"


#define LOGO_SIZE           (TABLE_ROW_HEIGHT - 12.0)


@implementation CompanyListTableViewInterface
{
    CompanyListManager *_companyListMgr;
}

#pragma mark - Public Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to perform an initialization.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithList:(CompanyListManager *)companyListMgr
{
    if (self = [super init])
        _companyListMgr = companyListMgr;
    
    return self;
}

#pragma mark - Table View Data Source Delegate Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method to specify if the current row can move or not.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method to specify the number of section in the tableView.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method to specify the number of rows in the tableView.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) tableView:(UITableView *)tableView
  numberOfRowsInSection:(NSInteger)section
{
    return _companyListMgr.count;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method to specify if the current row is editable.
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
- (UITableViewCell *) tableView:(UITableView *)tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    // Get a recycled table row
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // If none are available then ...
    if (nil == cell)
        // Create a new row
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    
    // Get the company record
    Company *company = [_companyListMgr getCompanyWithDisplayIndex:indexPath.row];
    
    // Load current cell with the company data
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", company.name, company.stockSymbol];
    if (company.stockPrice)
        cell.detailTextLabel.text = [NSString stringWithFormat:@"$%@", company.stockPrice];
    cell.detailTextLabel.textColor = [_companyListMgr isStockDataStale]? UIColor.blueColor : UIColor.redColor;
    
    // Resize the logo before loading
    UIImage *logoImage = [UIImage imageWithData:company.logoData];
    CGSize newSize = CGSizeMake(LOGO_SIZE, LOGO_SIZE);
    cell.imageView.image = [logoImage scaleToSize:newSize];
    
    return cell;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method for supporting editing of the table view.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If user initiated a delete action then ...
    if (editingStyle == UITableViewCellEditingStyleDelete)
        // start the process for deleting the company
        [_companyListMgr.editor deleteCompanyWithDisplayIndex:indexPath.row];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method for supporting rearranging of rows in the table view.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
       toIndexPath:(NSIndexPath *)toIndexPath
{
    // If the user initiated a drag but returned to the original position then ...
    if (fromIndexPath == toIndexPath)
        // there is nothing to do, exit the routine.
        return;
    // Otherwise, ...
    else
        // start the process to move the company to its new position on the list
        [_companyListMgr.editor updateCompanyDisplayIndexFrom:fromIndexPath.row
                                                       to:toIndexPath.row];
}

@end
