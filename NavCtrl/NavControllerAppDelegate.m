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

@synthesize persistentContainer = _persistentContainer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Initialize persistance container
    NSPersistentContainer *pc = self.persistentContainer;
//    [self resetDataStore];

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

#pragma mark - Core Data stack

- (NSPersistentContainer *) persistentContainer
{
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self)
    {
        if (_persistentContainer == nil)
        {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Model"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error)
             {
                 if (error != nil)
                 {
                     // Replace this implementation with code to handle the error appropriately.
                     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                     
                     /*
                      Typical reasons for an error here include:
                      * The parent directory does not exist, cannot be created, or disallows writing.
                      * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                      * The device is out of space.
                      * The store could not be migrated to the current model version.
                      Check the error message to determine what the actual problem was.
                      */
                     NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                     abort();
                 }
             }];
        }
    }
    
    return _persistentContainer;
}

- (void) resetDataStore
{
    NSManagedObjectContext *managedObjectContext = _persistentContainer.viewContext;
    
    [managedObjectContext reset];

    NSPersistentStoreCoordinator *persistentStoreCoordinator = [managedObjectContext persistentStoreCoordinator];
    
    NSArray *stores = [persistentStoreCoordinator persistentStores];
    
    if (stores)
    {
        NSError *error;
        
        for (NSPersistentStore *currentStore in stores)
        {
            NSURL *storeUrl = currentStore.URL;
        
            // If successfully remove store files then ...
            if ([persistentStoreCoordinator removePersistentStore:currentStore
                                                            error:&error])
            {
                // delete those store files
                if (![[NSFileManager defaultManager] removeItemAtPath:storeUrl.path
                                                                error:&error])
                    NSLog(@"Error removing file of persistent store: %@", [error localizedDescription]);
            }
            else
                NSLog(@"Error removing persistent store: %@", [error localizedDescription]);
        }
        
        [persistentStoreCoordinator release];
        persistentStoreCoordinator = nil;

        // now recreate persistent store
        persistentStoreCoordinator = [managedObjectContext persistentStoreCoordinator];
    }
    else
        NSLog(@"\nresetDatastore. Could not find the persistent store");
}

@end
