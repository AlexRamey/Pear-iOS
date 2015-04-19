//
//  AppDelegate.m
//  Pear
//
//  Created by Alex Ramey on 10/12/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "Parse.h"
#import "PARLoginViewController.h"
#import "PARDataStore.h"
#import "PARTheme.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

NSString * const USER_FB_ID_KEY = @"USER_FB_ID_KEY";

NSString * const USER_GENDER_KEY = @"USER_GENDER_KEY";

NSString * const USER_DATA_KEY = @"USER_DATA_KEY";

NSString * const NEXT_COUPLE_TO_VOTE_ON_KEY = @"NEXT_COUPLE_TO_VOTE_ON_KEY";

NSString * const NO_MORE_COUPLES_DOMAIN = @"NO_MORE_COUPLES_DOMAIN";

NSString * const NETWORK_ERROR_DOMAIN = @"NETWORK_ERROR_DOMAIN";

NSString * const WISHLIST_DEFAULTS_KEY = @"WISHLIST_DEFAULTS_KEY";

NSString * const PAR_IS_FIRST_LAUNCH_GAME_KEY = @"PAR_IS_FIRST_LAUNCH_GAME_KEY";

NSString * const PAR_IS_FIRST_LAUNCH_RESULTS_KEY = @"PAR_IS_FIRST_LAUNCH_RESULTS_KEY";

NSString * const PAR_IS_FIRST_LAUNCH_PEAR_KEY = @"PAR_IS_FIRST_LAUNCH_PEAR_KEY";

+(void)initialize
{
    //Register Factory Defaults, which will be created and temporarily stored in the registration
    //domain of NSUserDefaults. In the application domain, if no value has been assigned yet to a
    //specified key, then the application will look in the registration domain. The application domain
    //persists, so once a value has been set, factory defaults will always be ignored
    
    NSDictionary *defaults = @{
                               PAR_IS_FIRST_LAUNCH_GAME_KEY : @YES,
                               PAR_IS_FIRST_LAUNCH_RESULTS_KEY : @YES,
                               PAR_IS_FIRST_LAUNCH_PEAR_KEY : @YES,
                               WISHLIST_DEFAULTS_KEY : @{}
                               };
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    [Parse setApplicationId:@"6p8dKCeTQK9clHUwF5jyQLhG0Rcopat0AnfAzFbO"
                  clientKey:@"Anm9Sq6OsS9u5xjeqkF9FSSPk6dqj9ZoLp05O0na"];
    
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PARLoginViewController *vc = [storyboard instantiateInitialViewController];
    self.window.rootViewController = vc;
    
    [PARTheme setupTheme];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[PARDataStore sharedStore] saveUserWithCompletion:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [PFFacebookUtils unlinkUserInBackground:[PFUser user]];
    [self saveContext];
}

#pragma mark - Facebook Login Process

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.pear.alexramey.Pear" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Pear" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Pear.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
