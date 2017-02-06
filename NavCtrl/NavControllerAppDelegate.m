//
//  NavControllerAppDelegate.m
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//

#import "NavControllerAppDelegate.h"
#import "CompanyViewController.h"

@implementation NavControllerAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Set the color of the title to white for all navigation bar
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          UIColor.whiteColor, NSForegroundColorAttributeName, nil]];
    
    // Set the background color to greenish for all navigation bar
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed: (float) 0x7E / 255.0
                                                                  green: (float) 0xB2 / 255.0
                                                                   blue: (float) 0x38 / 255.0
                                                                  alpha: 1.0]];
    
    // Set the foreground color to white for all navigation bar
    [[UINavigationBar appearance] setTintColor:UIColor.whiteColor];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    
    // Create the start up ViewController
    UIViewController *rootController = [[CompanyViewController alloc] init];

    // Embed the start up ViewController into a navigation controller
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:rootController];

    // Create and initialize the window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = UIColor.purpleColor;
    
    // Set the navigation controller as the root controller of the window
    [self.window setRootViewController:self.navigationController];
    
    // Make the window visible and active
    [self.window makeKeyAndVisible];
    
    [rootController release];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
