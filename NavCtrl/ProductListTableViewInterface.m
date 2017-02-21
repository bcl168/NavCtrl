//
//  ProductListTableViewInterface.m
//  NavCtrl
//
//  Created by bl on 2/17/17.
//  Copyright © 2017 bl. All rights reserved.
//


#import "Globals.h"
#import "ProductListManager.h"
#import "UIImage+Resize.h"


#define PRODUCT_IMAGE_SIZE  (TABLE_ROW_HEIGHT - 12.0)


@implementation ProductListTableViewInterface
{
    ProductListManager *_productListMgr;
}

#pragma mark - Public Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to perform an initialization.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithList:(ProductListManager *)productListMgr
{
    if (self = [super init])
        _productListMgr = productListMgr;
    
    return self;
}

#pragma mark - Table View Data Source Methods

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
- (UITableViewCell *) tableView:(UITableView *)tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    
    // Get the product record for the current row ...
    Product *product = [_productListMgr getProductWithDisplayIndex:indexPath.row];
    
    // Load current cell with the product data
    cell.textLabel.text = product.name;
        
    // Resize the product image before loading
    UIImage *productImage = [UIImage imageWithData:product.imageData];
    CGSize newSize = CGSizeMake(PRODUCT_IMAGE_SIZE, PRODUCT_IMAGE_SIZE);
    cell.imageView.image = [productImage scaleToSize:newSize];
    
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
    if (editingStyle == UITableViewCellEditingStyleDelete)
        // Delete the row from the data source
        [_productListMgr.editor deleteProductWithDisplayIndex:indexPath.row
                                                  fromCompany:_productListMgr.companyName];
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
    return _productListMgr.count;
}

@end
