//
//  PARDataStore.m
//  Pear
//
//  Created by Alex Ramey on 10/12/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARDataStore.h"
#import "FacebookSDK.h"
#import "AppDelegate.h"

@implementation PARDataStore

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
            _coupleObjectsAlreadyVotedOn = [[NSMutableDictionary alloc] init];
        }
        
        _couplesLeftToVoteOn = nil;
        _potentialCouples = nil;
        pushIndex = 0;
    }
    
    return self;
}

-(void)setFriends:(NSArray *)friendsList
{
    _friends = friendsList;
    
    //TODO: Guard against same gender pairings
    
    NSMutableArray *maleFriendIDs = [[NSMutableArray alloc] init];
    NSMutableArray *femaleFriendIDs = [[NSMutableArray alloc] init];
    
    for (NSDictionary<FBGraphUser>* friend in friendsList)
    {
        if ([[friend objectForKey:@"gender"] caseInsensitiveCompare:@"male"] == NSOrderedSame)
        {
            [maleFriendIDs addObject:[friend objectForKey:@"id"]];
        }
        else if ([[friend objectForKey:@"gender"] caseInsensitiveCompare:@"female"] == NSOrderedSame)
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

-(void)nextCoupleWithCompletion:(void (^)(NSError *))completion
{
    if (_couplesLeftToVoteOn && [_couplesLeftToVoteOn count] > 0)
    {
        PFObject *nextVote = [_couplesLeftToVoteOn objectAtIndex:0];
        [_couplesLeftToVoteOn removeObjectAtIndex:0];
        
        NSMutableDictionary *nextCouple = [[nextVote dictionaryWithValuesForKeys:@[@"Downvotes", @"Female", @"FemaleEducation",@"FemaleName", @"Male", @"MaleEducation", @"MaleEducationYear", @"MaleLocation", @"MaleName", @"Upvotes"]] mutableCopy];
        [nextCouple setObject:nextVote.objectId forKey:@"ObjectId"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:nextCouple] forKey:NEXT_COUPLE_TO_VOTE_ON_KEY];
        completion(nil);
    }
    else
    {
        [self fetchCouplesWithCompletion:^(NSError *error) {
            if (error)
            {
                if ([error.domain caseInsensitiveCompare:NO_MORE_COUPLES_DOMAIN] == NSOrderedSame)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:@{@"Error" : NO_MORE_COUPLES_DOMAIN} forKey:NEXT_COUPLE_TO_VOTE_ON_KEY];
                    completion(nil);
                }
                else
                {
                    [[NSUserDefaults standardUserDefaults] setObject:@{@"Error" : NETWORK_ERROR_DOMAIN} forKey:NEXT_COUPLE_TO_VOTE_ON_KEY];
                    completion(error);
                }
            }
            else
            {
                PFObject *nextVote = [_couplesLeftToVoteOn objectAtIndex:0];
                [_couplesLeftToVoteOn removeObjectAtIndex:0];
                
                NSMutableDictionary *nextCouple = [[nextVote dictionaryWithValuesForKeys:@[@"Downvotes", @"Female", @"FemaleEducation",@"FemaleName", @"Male", @"MaleEducation", @"MaleEducationYear", @"MaleLocation", @"MaleName", @"Upvotes"]] mutableCopy];
                [nextCouple setObject:nextVote.objectId forKey:@"ObjectId"];
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:nextCouple] forKey:NEXT_COUPLE_TO_VOTE_ON_KEY];
                completion(nil);
            }
        }];
    }
}

-(void)fetchCouplesWithCompletion:(void (^)(NSError *))completion
{
    _couplesLeftToVoteOn = [[NSMutableArray alloc] init];
    
    [self getExistingCouplesWithCompletion:^(NSError *error) {
        if ([_couplesLeftToVoteOn count] == 0)
        {
            [self createNewCouplesWithCompletion:^(NSError *e) {
                
                if (e)
                {
                    completion(e); //no couples left (only error thrown at this point)
                }
                else
                {
                    [self getExistingCouplesWithCompletion:^(NSError *error2) {
                        //if there is an error with the network request to getExistingCouples
                        completion(error2);
                    }];
                }
            }];
        }
        else
        {
            completion(error); //if there is an error with the network request to getExistingCouples
        }
    }];
}

-(void)getExistingCouplesWithCompletion:(void (^)(NSError *))completion
{
    PFQuery *query = [PFQuery queryWithClassName:@"Couples"];
    query.limit = 50;
    [query orderByDescending:@"Upvotes"];
    [query whereKey:@"Male" containedIn:_maleFriendIDs];
    [query whereKey:@"Female" containedIn:_femaleFriendIDs];
    [query whereKey:@"objectId" notContainedIn:[_coupleObjectsAlreadyVotedOn allValues]];
    
    
    //for testing purposes
    /*
    [query whereKey:@"Female" containedIn:@[@"1230104186"]];
    [query whereKey:@"Male" containedIn:@[@"1160804880"]];
    */
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
    if (_potentialCouples)
    {
        [self pushNewCouplesToParseWithCompletion:completion];
        return; //don't generate the list again
    }
    
    _potentialCouples = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [_friends count]; i++)
    {
        NSDictionary* friend1 = [_friends objectAtIndex:i];
        NSString *friend1Gender = [friend1 objectForKey:@"gender"];
        
        if (friend1Gender && ([friend1Gender caseInsensitiveCompare:@"male"] == NSOrderedSame ||
            [friend1Gender caseInsensitiveCompare:@"female"] == NSOrderedSame))
        {
            for (int j = i + 1; j < [_friends count]; j++)
            {
                NSDictionary* friend2 = [_friends objectAtIndex:j];
                NSString *friend2Gender = [friend2 objectForKey:@"gender"];
                if (friend2Gender && ([friend2Gender caseInsensitiveCompare:@"male"] == NSOrderedSame ||
                    [friend2Gender caseInsensitiveCompare:@"female"] == NSOrderedSame) && [friend1Gender caseInsensitiveCompare:friend2Gender] != NSOrderedSame) //viable new couple
                {
                    //make friend1 refer to the male
                    NSDictionary *localMalePtr = friend1;
                    NSDictionary *localFemalePtr = friend2;
                    
                    if ([friend1Gender caseInsensitiveCompare:@"male"] != NSOrderedSame)
                    {
                        localMalePtr = friend2;
                        localFemalePtr = friend1;
                    }
                    
                    //get edu info: school id and year for male and female
                    NSString *maleSchoolID = nil;
                    NSNumber *maleSchoolYear = nil;
                    NSString *femaleSchoolID = nil;
                    NSNumber *femaleSchoolYear = nil;
                    
                    NSArray *maleEducation = [localMalePtr objectForKey:@"education"];
                    NSDictionary *maleEdu = nil;
                    if (maleEducation && [maleEducation count] > 0)
                    {
                        maleEdu = [maleEducation objectAtIndex:[maleEducation count] - 1];
                    }
                    
                    if (maleEdu)
                    {
                        NSDictionary *school = [maleEdu objectForKey:@"school"];
                        if ([school objectForKey:@"id"])
                        {
                            maleSchoolID = [school objectForKey:@"id"];
                        }
                        
                        NSDictionary *year = [maleEdu objectForKey:@"year"];
                        if ([year objectForKey:@"name"])
                        {
                            maleSchoolYear = [NSNumber numberWithInt:[[year objectForKey:@"name"] intValue]];
                        }
                        
                    }
                    
                    NSDictionary *femaleEdu = nil;
                    NSArray *femaleEducation = [localFemalePtr objectForKey:@"education"];
                    if (femaleEducation && [femaleEducation count] > 0)
                    {
                        femaleEdu = [femaleEducation objectAtIndex:[femaleEducation count] - 1];
                    }
                    
                    if (femaleEdu)
                    {
                        NSDictionary *school = [femaleEdu objectForKey:@"school"];
                        if ([school objectForKey:@"id"])
                        {
                            femaleSchoolID = [school objectForKey:@"id"];
                        }
                        
                        NSDictionary *year = [femaleEdu objectForKey:@"year"];
                        if ([year objectForKey:@"name"])
                        {
                            femaleSchoolYear = [NSNumber numberWithInt:[[year objectForKey:@"name"] intValue]];
                        }
                    }
                    
                    //create new couple dictionary with fields necessary to create PFObject<Couple> in Parse
                    
                    NSMutableDictionary *newCouple = [[NSMutableDictionary alloc] init];
                    [newCouple setObject:[localMalePtr objectForKey:@"id"] forKey:@"Male"];
                    [newCouple setObject:[localFemalePtr objectForKey:@"id"] forKey:@"Female"];
                    [newCouple setObject:[localMalePtr objectForKey:@"name"] forKey:@"MaleName"];
                    [newCouple setObject:[localFemalePtr objectForKey:@"name"] forKey:@"FemaleName"];
                    
                    if (maleSchoolID)
                    {
                        [newCouple setObject:maleSchoolID forKey:@"MaleEducation"];
                    }
                    if (maleSchoolYear)
                    {
                        [newCouple setObject:maleSchoolYear forKey:@"MaleEducationYear"];
                    }
                    if (femaleSchoolID)
                    {
                        [newCouple setObject:femaleSchoolID forKey:@"FemaleEducation"];
                    }
                    if (femaleSchoolYear)
                    {
                        [newCouple setObject:femaleSchoolYear forKey:@"FemaleEducationYear"];
                    }
                    
                    //figure out if it's one we've already voted on . . .
                    NSString *key = [[localMalePtr objectForKey:@"id"] stringByAppendingString:[localFemalePtr objectForKey:@"id"]];
                    
                    if (![_coupleObjectsAlreadyVotedOn objectForKey:key]) //if it's a new couple
                    {
                        [_potentialCouples addObject:newCouple];
                    }
                }
            }
        }
    }
    
    //scramble the array of _potentialCouples for now; potentially rank them in the future
    NSUInteger count = [_potentialCouples count];
    for (NSUInteger i = 0; i < count; ++i)
    {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform(remainingCount);
        [_potentialCouples exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
    
    [self pushNewCouplesToParseWithCompletion:completion];
}

-(void)pushNewCouplesToParseWithCompletion:(void (^)(NSError *))completion
{
    if (pushIndex == [_potentialCouples count]) //we've pushed all the couples up already
    {
        NSError *noMoreCouplesError = [[NSError alloc] initWithDomain:NO_MORE_COUPLES_DOMAIN code:000 userInfo:nil];
        completion(noMoreCouplesError);
    }
    
    __block int uploadCounter = 0;
    __block int callbackCounter = 0;
    //push up next 10 if 10 remain
    int i = 0;
    while (i < 10 && pushIndex < [_potentialCouples count])
    {
        NSDictionary *potentialCouple = [_potentialCouples objectAtIndex:pushIndex];
        PFObject *couple = [PFObject objectWithClassName:@"Couples"];
        couple[@"Male"] = [potentialCouple objectForKey:@"Male"];
        couple[@"Female"] = [potentialCouple objectForKey:@"Female"];
        couple[@"MaleName"] = [potentialCouple objectForKey:@"MaleName"];
        couple[@"FemaleName"] = [potentialCouple objectForKey:@"FemaleName"];
        
        if ([potentialCouple objectForKey:@"MaleEducationYear"])
        {
            couple[@"MaleEducationYear"] = [potentialCouple objectForKey:@"MaleEducationYear"];
        }
        if ([potentialCouple objectForKey:@"FemaleEducationYear"])
        {
            couple[@"FemaleEducationYear"] = [potentialCouple objectForKey:@"FemaleEducationYear"];
        }
        if ([potentialCouple objectForKey:@"MaleEducation"])
        {
            couple[@"MaleEducation"] = [potentialCouple objectForKey:@"MaleEducation"];
        }
        if ([potentialCouple objectForKey:@"FemaleEducation"])
        {
            couple[@"FemaleEducation"] = [potentialCouple objectForKey:@"FemaleEducation"];
        }
        
        uploadCounter++;
        
        [couple saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (++callbackCounter == uploadCounter)
            {
                completion(nil);
            }
            if (error)
            {
                NSLog(@"PARSE PUSH ERROR");
            }
        }];
        
        pushIndex++;
        i++;
    }
}

-(void)addCoupleToCouplesAlreadyVotedOnList:(NSDictionary *)coupleInfo
{
    NSString *maleID = [coupleInfo objectForKey:@"Male"];
    NSString *femaleID = [coupleInfo objectForKey:@"Female"];
    NSString *key = [maleID stringByAppendingString:femaleID];
    
    [_coupleObjectsAlreadyVotedOn setObject:[coupleInfo objectForKey:@"ObjectId"] forKey:key];
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
