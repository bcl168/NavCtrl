//
//  CompanyListEditor.m
//  NavCtrl
//
//  Created by bl on 2/13/17.
//  Copyright © 2017 bl. All rights reserved.
//


#import "CompanyListManager.h"


@implementation CompanyListEditor
{
    CompanyListManager *_companyListMgr;
    DataAccessObject *_dao;
    NSUndoManager *_undoManager;
}

#pragma mark - Public Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method for adding a company.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) addCompanyWithName:companyName
             andStockSymbol:stockSymbol
                 andLogoURL:logoURL
{
    [_dao addCompanyWithName:companyName
              andStockSymbol:stockSymbol
                  andLogoURL:logoURL];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method for deleting a company with undo feature.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) deleteCompanyWithDisplayIndex:(NSInteger)index
{
    Company *company = [_companyListMgr getCompanyWithDisplayIndex:index];

    // Save the opposite to the undo stack
    [[_undoManager prepareWithInvocationTarget:self] insertCompany:company
                                                  withDisplayIndex:index];
    
    // Initiate a request to DAO to delete a company
    [_dao deleteCompanyWithDisplayIndex:index];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method to perform an initialization.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithList:(CompanyListManager *)companyListMgr
{
    if (self = [super init])
    {
        _companyListMgr = companyListMgr;
        _dao = [DataAccessObject sharedInstance];
        _undoManager = [[NSUndoManager alloc] init];
    }
    
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called to redo the last change.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) redo
{
    [_undoManager redo];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called to remove all entries in the undo/redo stack.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) reset
{
    [_undoManager removeAllActions];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method is called to undo the last change.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) undo
{
    [_undoManager undo];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Methods for updating a company's display index with undo feature.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) updateCompanyDisplayIndexFrom:(NSInteger)fromIndex
                                    to:(NSInteger)toIndex
{
    // Save the opposite to the undo stack
    [[_undoManager prepareWithInvocationTarget:self] updateCompanyDisplayIndexFrom:toIndex
                                                                                to:fromIndex];
    
    // Initiate a request to DAO to update the company
    [_dao updateCompanyDisplayIndexFrom:fromIndex
                                     to:toIndex];
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Methods for updating a company's record with undo feature.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) updateCompanyFrom:(Company *)originalCompany
                        to:(Company *)newCompany
{
    // Save the change to the undo stack
    [[_undoManager prepareWithInvocationTarget:self] updateCompanyFrom:newCompany
                                                                    to:originalCompany];
    
    // Initiate a request to DAO to update the company
    [_dao updateCompanyWithName:originalCompany.name
                             to:newCompany.name
                withStockSymbol:newCompany.stockSymbol
                     andLogoURL:newCompany.logoURL];
}

#pragma mark - EntryViewController Delegate Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by EntryViewController when the user wants to save a
//  company with new values.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSString *) saveChangedTextEntry1:(NSString *)newTextEntry1
                      fromTextEntry1:(NSString *)originalTextEntry1
                andChangedTextEntry2:(NSString *)newTextEntry2
                      fromTextEntry2:(NSString *)originalTextEntry2
                andChangedTextEntry3:(NSString *)newTextEntry3
                      fromTextEntry3:(NSString *)originalTextEntry3
{
    // Trim leading and trailing spaces from all inputs
    NSCharacterSet *allWhitespaceCharacters = [NSCharacterSet whitespaceCharacterSet];
    NSString *companyName = [newTextEntry1 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    NSString *stockSymbol = [newTextEntry2 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    NSString *logoURL = [newTextEntry3 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    
    // Check inputs for entry
    if (0 == companyName.length)
        return @"Company name missing.";
    else if (0 == stockSymbol.length)
        return @"Stock symbol missing.";
    else if (0 == logoURL.length)
        return @"URL for logo missing.";
    
    // If one of the input has changed then ...
    if (![originalTextEntry1 isEqualToString:companyName] ||
        ![originalTextEntry2 isEqualToString:stockSymbol] ||
        ![originalTextEntry3 isEqualToString:logoURL])
    {
        Company *newCompany = [[Company alloc] initWithName:companyName
                                             andStockSymbol:stockSymbol
                                              andStockPrice:@""
                                                 andLogoURL:logoURL];
        
        [self updateCompanyFrom:[_companyListMgr getCompany:originalTextEntry1]
                             to:newCompany];
    }
    
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Delegate method called by EntryViewController when the user wants to save a new
//  company entry.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (NSString *) saveNewTextEntry1:(NSString *)textEntry1
                andNewTextEntry2:(NSString *)textEntry2
                andNewTextEntry3:(NSString *)textEntry3
{
    // Trim leading and trailing spaces from all inputs
    NSCharacterSet *allWhitespaceCharacters = [NSCharacterSet whitespaceCharacterSet];
    NSString *companyName = [textEntry1 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    NSString *stockSymbol = [textEntry2 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    NSString *logoURL = [textEntry3 stringByTrimmingCharactersInSet:allWhitespaceCharacters];
    
    // Check inputs for entry
    if (0 == companyName.length)
        return @"Company name missing.";
    else if (0 == stockSymbol.length)
        return @"Stock symbol missing.";
    else if (0 == logoURL.length)
        return @"URL for logo missing.";
    
    // Save the new company data
    [self addCompanyWithName:companyName
              andStockSymbol:stockSymbol
                  andLogoURL:logoURL];
    
    // Return no error found.
    return nil;
}

#pragma mark - Private Methods

//////////////////////////////////////////////////////////////////////////////////////////
//
//  Method for inserting a company with undo feature.
//
//////////////////////////////////////////////////////////////////////////////////////////
- (void) insertCompany:(Company *)company
      withDisplayIndex:(NSInteger)index
{
    // Save the opposite to the undo stack
    [[_undoManager prepareWithInvocationTarget:self] deleteCompanyWithDisplayIndex:index];
    
    // Initiate a request to DAO to insert a company
    [_dao insertCompany:company withDisplayIndex:index];
}

@end
