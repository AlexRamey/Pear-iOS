//
//  AppDelegate.h
//  Pear
//
//  Created by Alex Ramey on 10/12/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

extern NSString * const USER_FB_ID_KEY;

extern NSString * const USER_GENDER_KEY;

extern NSString * const NEXT_COUPLE_TO_VOTE_ON_KEY;

extern NSString * const NO_MORE_COUPLES_DOMAIN;

extern NSString * const NETWORK_ERROR_DOMAIN;

extern NSString * const GAME_RESULTS_PICTURE_ORIGIN_Y_KEY;

extern NSString * const WISHLIST_DEFAULTS_KEY;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

