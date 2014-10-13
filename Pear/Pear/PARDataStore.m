//
//  PARDataStore.m
//  Pear
//
//  Created by Alex Ramey on 10/12/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARDataStore.h"
#import "FacebookSDK.h"
#import "Parse.h"

@implementation PARDataStore

static NSString * const COUPLES_ALREADY_VOTED_ON_KEY = @"COUPLES_ALREADY_VOTED_ON_KEY";

+(PARDataStore *)sharedStore
{
    static PARDataStore *sharedStore = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedStore = [[PARDataStore alloc] init];
    });
    
    return sharedStore;
}

-(id)init
{
    self = [super init];
    
    if (self)
    {
        //custom initialization
        _coupleIDsAlreadyVotedOn = [[NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathForKey:COUPLES_ALREADY_VOTED_ON_KEY]] mutableCopy];
        
        if (!_coupleIDsAlreadyVotedOn)
        {
            _coupleIDsAlreadyVotedOn = [[NSMutableArray alloc] init];
        }
    }
    
    return self;
}

-(void)setFriends:(NSArray *)friendsList
{
    _friends = friendsList;
    
    NSMutableArray *maleFriendIDs = [[NSMutableArray alloc] init];
    NSMutableArray *femaleFriendIDs = [[NSMutableArray alloc] init];
    
    for (NSDictionary<FBGraphUser>* friend in friendsList)
    {
        if ([[friend objectForKey:@"gender"] caseInsensitiveCompare:@"male"] == NSOrderedSame)
        {
            [maleFriendIDs addObject:[friend objectForKey:@"id"]];
        }
        else if ([[friend objectForKey:@"gender"] caseInsensitiveCompare:@"male"] == NSOrderedSame)
        {
            [femaleFriendIDs addObject:[friend objectForKey:@"id" ]];
        }
        else
        {
            //do nothing, effectively discarding people who don't have a gender field
        }
    }
    
    _maleFriendIDs = maleFriendIDs;
    _femaleFriendIDs = femaleFriendIDs;
}

-(void)getAllExistingCouplesWithCompletion:(void (^)(NSError *))completion
{
    PFQuery *query = [PFQuery queryWithClassName:@"Couples"];
    [query orderByDescending:@"Upvotes"];
    [query whereKey:@"Male" containedIn:_maleFriendIDs];
    [query whereKey:@"Female" containedIn:_femaleFriendIDs];
    [query whereKey:@"objectId" notContainedIn:_coupleIDsAlreadyVotedOn];
    [query whereKey:@"Female" containedIn:@[@"100000460843014"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Done! %d", [objects count]);
        NSLog(@"Result: %@", objects);
        for (PFObject *couple in objects)
        {
            [_existingCouplesLeftToVoteOn addObject:couple];
        }
        
    }];
}

-(void)addCoupleIDToCouplesAlreadyVotedOnList:(NSString *)coupleID
{
    [_coupleIDsAlreadyVotedOn addObject:coupleID];
}

-(void)saveCouplesAlreadyVotedOn
{
    [NSKeyedArchiver archiveRootObject:_coupleIDsAlreadyVotedOn toFile:[self filePathForKey:COUPLES_ALREADY_VOTED_ON_KEY]];
}

-(NSString *)filePathForKey:(NSString *)key
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:key];
}

@end
