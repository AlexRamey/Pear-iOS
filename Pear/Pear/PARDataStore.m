//
//  PARDataStore.m
//  Pear
//
//  Created by Alex Ramey on 10/12/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARDataStore.h"
#import "FacebookSDK.h"

@implementation PARDataStore

static NSString * const COUPLE_IDS_ALREADY_VOTED_ON_KEY = @"COUPLE_IDS_ALREADY_VOTED_ON_KEY";
static NSString * const COUPLE_OBJECTS_ALREADY_VOTED_ON_KEY = @"COUPLE_OBJECTS_ALREADY_VOTED_ON_KEY";

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
        _coupleObjectsAlreadyVotedOn = [[NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathForKey:COUPLE_OBJECTS_ALREADY_VOTED_ON_KEY]] mutableCopy];
        
        if (!_coupleObjectsAlreadyVotedOn)
        {
            _coupleObjectsAlreadyVotedOn = [[NSMutableArray alloc] init];
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

-(PFObject *)nextCoupleWithCompletion:(void (^)(NSError *))completion
{
    return nil;
}

-(void)fetchCouplesWithCompletion:(void (^)(NSError *))completion
{
    _couplesLeftToVoteOn = [[NSMutableArray alloc] init];
    
    [self getExistingCouplesWithCompletion:^(NSError *error) {
        if ([_couplesLeftToVoteOn count] == 0)
        {
            [self createNewCouplesWithCompletion:^(NSError *e) {
                if ([_couplesLeftToVoteOn count] == 0)
                {
                    NSError *noMoreCouplesError = [[NSError alloc] initWithDomain:@"NO_MORE_COUPLES_DOMAIN" code:000 userInfo:nil];
                    completion(noMoreCouplesError);
                }
                else
                {
                    completion(e);
                }
            }];
        }
        else
        {
            completion(error);
        }
    }];
}

-(void)getExistingCouplesWithCompletion:(void (^)(NSError *))completion
{
    NSMutableArray *coupleIDsAlreadyVotedOn = [[NSMutableArray alloc] init];
    
    for (NSDictionary *couple in _coupleObjectsAlreadyVotedOn)
    {
        [coupleIDsAlreadyVotedOn addObject:[couple objectForKey:@"coupleObjectID"]];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Couples"];
    query.limit = 50;
    [query orderByDescending:@"Upvotes"];
    [query whereKey:@"Male" containedIn:_maleFriendIDs];
    [query whereKey:@"Female" containedIn:_femaleFriendIDs];
    [query whereKey:@"objectId" notContainedIn:coupleIDsAlreadyVotedOn];
    [query whereKey:@"Female" containedIn:@[@"100000460843014"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *couple in objects)
        {
            [_couplesLeftToVoteOn addObject:couple];
        }
        completion(error);
    }];
}

-(void)createNewCouplesWithCompletion:(void (^)(NSError *))completion
{
    //do nothing
    completion(nil);
    
    //TODO: Use Core Data To Store Couples to boost Performance
    /*
    //create list of all possible couples
    NSMutableArray *allPossibleCouples = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [_friends count]; i++)
    {
        NSDictionary* friend1 = [_friends objectAtIndex:i];
        NSString *friend1Gender = [friend1 objectForKey:@"gender"];
        
        if ([friend1Gender caseInsensitiveCompare:@"male"] == NSOrderedSame ||
            [friend1Gender caseInsensitiveCompare:@"female"] == NSOrderedSame)
        {
            for (int j = i + 1; j < [_friends count]; j++)
            {
                NSDictionary* friend2 = [_friends objectAtIndex:j];
                NSString *friend2Gender = [friend2 objectForKey:@"gender"];
                if (([friend2Gender caseInsensitiveCompare:@"male"] == NSOrderedSame ||
                    [friend2Gender caseInsensitiveCompare:@"female"] == NSOrderedSame) && [friend1Gender caseInsensitiveCompare:friend2Gender] != NSOrderedSame) //viable new couple
                {
                    //make friend1 refer to the male
                    
                    if ([friend1Gender caseInsensitiveCompare:@"male"] != NSOrderedSame)
                    {
                        NSDictionary *temp = friend1;
                        friend1 = friend2;
                        friend2 = temp;
                    }
                    
                    //NSDictionary *newCouple =
                }
            }
        }
    }
    */
}

-(void)addCoupleToCouplesAlreadyVotedOnList:(NSDictionary *)coupleInfo
{
    [_coupleObjectsAlreadyVotedOn addObject:coupleInfo];
}

-(void)saveCouplesAlreadyVotedOn
{
    [NSKeyedArchiver archiveRootObject:_coupleObjectsAlreadyVotedOn toFile:[self filePathForKey:COUPLE_OBJECTS_ALREADY_VOTED_ON_KEY]];
}

-(NSString *)filePathForKey:(NSString *)key
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:key];
}

@end
