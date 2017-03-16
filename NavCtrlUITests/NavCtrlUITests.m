//
//  NavCtrlUITests.m
//  NavCtrlUITests
//
//  Created by bl on 3/7/17.
//  Copyright © 2017 Aditya Narayan. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface NavCtrlUITests : XCTestCase

@end

@implementation NavCtrlUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


//  Note: Auto-Correction and Check Spelling must be turned off in the simulator
//        Settings > General > Keyboards
- (void)testAddingData
{
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.

    XCUIApplication *app = [[XCUIApplication alloc] init];

    [app.buttons[@"+Add Company"] tap];
    
    XCUIElement *textEntry0TextField = app.textFields[@"Text Entry 0"];
    [textEntry0TextField tap];
    [textEntry0TextField typeText:@"Apple Inc."];
    
    XCUIElement *textEntry1TextField = app.textFields[@"Text Entry 1"];
    [textEntry1TextField tap];
    [textEntry1TextField typeText:@"AAPL"];
    [textEntry1TextField swipeUp];
    
    XCUIElement *textEntry2TextField = app.textFields[@"Text Entry 2"];
    [textEntry2TextField tap];
    [textEntry2TextField typeText:@"https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Apple_Store_logo.svg/240px-Apple_Store_logo.svg.png"];
    
    XCUIElement *saveButton = app.navigationBars[@"New Company"].buttons[@"Save"];
    [saveButton tap];
    
    XCUIElement *stockTrackerNavigationBar = app.navigationBars[@"Stock Tracker"];
    XCUIElement *addButton = stockTrackerNavigationBar.buttons[@"Add"];
    [addButton tap];
    [textEntry0TextField tap];
    [textEntry0TextField typeText:@"Microsoft Corporation"];
    [textEntry1TextField tap];
    [textEntry1TextField typeText:@"MSFT"];
    [textEntry1TextField swipeUp];
    [textEntry2TextField tap];
    [textEntry2TextField typeText:@"https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Microsoft_logo.svg/240px-Microsoft_logo.svg.png"];
    [saveButton tap];

    [addButton tap];
    [textEntry0TextField tap];
    [textEntry0TextField typeText:@"Tesla Motors, Inc."];
    [textEntry1TextField tap];
    [textEntry1TextField typeText:@"TSLA"];
    [textEntry1TextField swipeUp];
    [textEntry2TextField tap];
    [textEntry2TextField typeText:@"https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Tesla_Motors.svg/279px-Tesla_Motors.svg.png"];
    [saveButton tap];
    
    [addButton tap];
    [textEntry0TextField tap];
    [textEntry0TextField typeText:@"Alphabet, Inc"];
    [textEntry1TextField tap];
    [textEntry1TextField typeText:@"GOOG"];
    [textEntry1TextField swipeUp];
    [textEntry2TextField tap];
    [textEntry2TextField typeText:@"https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Alphabet_Inc_Logo_2015.svg/320px-Alphabet_Inc_Logo_2015.svg.png"];
    [saveButton tap];
    
    [addButton tap];
    [textEntry0TextField tap];
    [textEntry0TextField typeText:@"Amazon.com, Inc"];
    [textEntry1TextField tap];
    [textEntry1TextField typeText:@"AMZN"];
    [textEntry1TextField swipeUp];
    [textEntry2TextField tap];
    [textEntry2TextField typeText:@"https://s3.amazonaws.com/BURC_Pages/downloads/a_com_logo_cldb.png"];
    [saveButton tap];
    
    XCUIElementQuery *tablesQuery = app.tables;
    [tablesQuery.staticTexts[@"Apple Inc. (AAPL)"] tap];
    
    XCUIElement *addProductButton = app.buttons[@"+Add Product"];
    [addProductButton tap];
    [textEntry0TextField tap];
    [textEntry0TextField typeText:@"MacBook Pro"];
    [textEntry1TextField tap];
    [textEntry1TextField typeText:@"https://www.apple.com/macbook-pro/"];
    [textEntry1TextField swipeUp];
    [textEntry2TextField tap];
    [textEntry2TextField typeText:@"https://store.storeimages.cdn-apple.com/4974/as-images.apple.com/is/image/AppleInc/aos/published/images/m/bp/mbp15touch/gray/mbp15touch-gray-select-201610?wid=452&hei=420&fmt=jpeg"];
    
    XCUIElement *saveButton2 = app.navigationBars[@"Add Product"].buttons[@"Save"];
    [saveButton2 tap];
    
    XCUIElement *addButton2 = app.navigationBars[@"Apple Inc."].buttons[@"Add"];
    [addButton2 tap];
    [textEntry0TextField tap];
    [textEntry0TextField typeText:@"iPad Mini 2"];
    [textEntry1TextField tap];
    [textEntry1TextField typeText:@"http://www.apple.com/shop/buy-ipad/ipad-mini-2"];
    [textEntry1TextField swipeUp];
    [textEntry2TextField tap];
    [textEntry2TextField typeText:@"https://store.storeimages.cdn-apple.com/4974/as-images.apple.com/is/image/AppleInc/aos/published/images/i/pa/ipad/mini/ipad-mini-retina-step1-white-2013_GEO_US?wid=150&hei=195&fmt=png-alpha&qlt=95&.v=1482192572282"];
    [saveButton2 tap];
    
    [addButton2 tap];
    [textEntry0TextField tap];
    [textEntry0TextField typeText:@"iPhone SE"];
    [textEntry1TextField tap];
    [textEntry1TextField typeText:@"http://www.apple.com/iphone-se/"];
    [textEntry1TextField swipeUp];
    [textEntry2TextField tap];
    [textEntry2TextField typeText:@"https://www.att.com/catalog/en/skus/images/apple-iphone%20se%2016gb-silver-450x350.png"];
    [saveButton2 tap];

    [addButton2 tap];
    [textEntry0TextField tap];
    [textEntry0TextField typeText:@"Watch"];
    [textEntry1TextField tap];
    [textEntry1TextField typeText:@"http://www.apple.com/watch/"];
    [textEntry1TextField swipeUp];
    [textEntry2TextField tap];
    [textEntry2TextField typeText:@"http://cdn2.itpro.co.uk/sites/itpro/files/styles/insert_main_image/public/2016/09/2up-stainless-black-sport-black-select.jpg?itok=27hGrOwj"];
    [saveButton2 tap];
    
    [[[XCUIApplication alloc] init].navigationBars[@"Apple Inc."].buttons[@"←"] tap];

    [tablesQuery.staticTexts[@"Microsoft Corporation (MSFT)"] tap];
    [addProductButton tap];
    [textEntry0TextField tap];
    [textEntry0TextField typeText:@"Xbox One S"];
    [textEntry1TextField tap];
    [textEntry1TextField typeText:@"http://www.xbox.com/en-US/xbox-one-s?xr=shellnav"];
    [textEntry1TextField swipeUp];
    [textEntry2TextField tap];
    [textEntry2TextField typeText:@"http://compass.xbox.com/assets/8f/e7/8fe72bc8-a7aa-4ac0-ad56-ae3aca7316fe.jpg?n=Xbox_Console_MeetOneS_Desktop_ImageModule_img1_New.jpg"];
    [saveButton2 tap];
    
    XCUIElement *addButton3 = app.navigationBars[@"Microsoft Corporation"].buttons[@"Add"];
    [addButton3 tap];
    [textEntry0TextField tap];
    [textEntry0TextField typeText:@"Universal Foldable Keyboard"];
    [textEntry1TextField tap];
    [textEntry1TextField typeText:@"https://www.microsoft.com/accessories/en-us/products/keyboards/universal-foldable-keyboard/gu5-00001"];
    [textEntry1TextField swipeUp];
    [textEntry2TextField tap];
    [textEntry2TextField typeText:@"https://compass-ssl.microsoft.com/assets/2d/5d/2d5dde0a-bac2-42c6-bf82-9bc28a34c520.jpg?n=mk_UFK_blk_otherviews01.jpg"];
    [saveButton2 tap];
    
    [addButton3 tap];
    [textEntry0TextField tap];
    [textEntry0TextField typeText:@"Surface Pro 4"];
    [textEntry1TextField tap];
    [textEntry1TextField typeText:@"https://www.microsoft.com/en-us/surface/devices/surface-pro-4/overview"];
    [textEntry1TextField swipeUp];
    [textEntry2TextField tap];
    [textEntry2TextField typeText:@"https://c.s-microsoft.com/en-us/CMSImages/SurfacePro4_Home_1_Hero_V1.png?version=ebeb052d-229b-8f25-d598-210cf0f918a2"];
    [saveButton2 tap];
    
    [addButton3 tap];
    [textEntry0TextField tap];
    [textEntry0TextField typeText:@"Lumia 950"];
    [textEntry1TextField tap];
    [textEntry1TextField typeText:@"https://www.microsoft.com/en-us/mobile/phone/lumia950/"];
    [textEntry1TextField swipeUp];
    [textEntry2TextField tap];
    [textEntry2TextField typeText:@"https://compass-ssl.microsoft.com/assets/f2/2f/f22f364c-2bef-43ac-a420-1343b72cd437.jpg?n=hero-desktop.jpg"];
    [saveButton2 tap];
    
    [[[XCUIApplication alloc] init].navigationBars[@"Microsoft Corporation"].buttons[@"←"] tap];
    
}

@end
