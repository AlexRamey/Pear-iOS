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

-(void)nextCoupleWithCompletion:(void (^)(NSError *))completion
{
    if (_couplesLeftToVoteOn && [_couplesLeftToVoteOn count] > 0)
    {
        PFObject *nextVote = [_couplesLeftToVoteOn objectAtIndex:0];
        [_couplesLeftToVoteOn removeObjectAtIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:nextVote forKey:NEXT_COUPLE_TO_VOTE_ON_KEY];
        completion(nil);
    }
    else
    {
        [self fetchCouplesWithCompletion:^(NSError *error) {
            if (error)
            {
                if ([error.domain caseInsensitiveCompare:@"NO_MORE_COUPLES_DOMAIN"] == NSOrderedSame)
                {
                    NSLog(@"No More Couples Response");
                    [[NSUserDefaults standardUserDefaults] setObject:@{@"Error" : @"NO_MORE_COUPLES_DOMAIN"} forKey:NEXT_COUPLE_TO_VOTE_ON_KEY];
                    completion(nil);
                }
                else
                {
                    NSLog(@"NETWORK ERROR LOGIN RESPONSE");
                    [[NSUserDefaults standardUserDefaults] setObject:@{@"Error" : @"Network"} forKey:NEXT_COUPLE_TO_VOTE_ON_KEY];
                    completion(error);
                }
            }
            else
            {
                PFObject *nextVote = [_couplesLeftToVoteOn objectAtIndex:0];
                [_couplesLeftToVoteOn removeObjectAtIndex:0];
                [[NSUserDefaults standardUserDefaults] setObject:nextVote forKey:NEXT_COUPLE_TO_VOTE_ON_KEY];
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
    
    /*
    //for testing purposes
    [query whereKey:@"Female" containedIn:@[@"100000460843014"]];
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
                    
                    //get edu info: school id and year for male and female
                    NSString *maleSchoolID = @"";
                    NSString *maleSchoolYear = @"";
                    NSString *femaleSchoolID = @"";
                    NSString *femaleSchoolYear = @"";
                    
                    NSArray *maleEducation = [friend1 objectForKey:@"education"];
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
                            maleSchoolYear = [year objectForKey:@"name"];
                        }
                        
                    }
                    
                    NSDictionary *femaleEdu = nil;
                    NSArray *femaleEducation = [friend2 objectForKey:@"education"];
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
                            femaleSchoolYear = [year objectForKey:@"name"];
                        }
                    }
                    
                    //create new couple dictionary with fields necessary to create PFObject<Couple> in Parse
                    
                    NSDictionary *newCouple = @{
                                                @"Male" : [friend1 objectForKey:@"id"],
                                                @"Female" : [friend2 objectForKey:@"id"],
                                                @"MaleName" : [friend1 objectForKey:@"name"],
                                                @"FemaleName" : [friend2 objectForKey:@"name"],
                                                @"MaleEducationYear" : maleSchoolYear,
                                                @"FemaleEducationYear" : femaleSchoolYear,
                                                @"MaleEducation" : maleSchoolID,
                                                @"FemaleEducation" : femaleSchoolID
                                                };
                    
                    //figure out if it's one we've already voted on . . .
                    NSString *key = [[friend1 objectForKey:@"id"] stringByAppendingString:[friend2 objectForKey:@"id"]];
                    
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
        NSError *noMoreCouplesError = [[NSError alloc] initWithDomain:@"NO_MORE_COUPLES_DOMAIN" code:000 userInfo:nil];
        completion(noMoreCouplesError);
    }
    
    int downloadCounter = 0;
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
        couple[@"MaleEducationYear"] = [potentialCouple objectForKey:@"MaleEducationYear"];
        couple[@"FemaleEducationYear"] = [potentialCouple objectForKey:@"FemaleEducationYear"];
        couple[@"MaleEducation"] = [potentialCouple objectForKey:@"MaleEducation"];
        couple[@"FemaleEducation"] = [potentialCouple objectForKey:@"FemaleEducation"];
        
        downloadCounter++;
        
        [couple saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (++callbackCounter == downloadCounter)
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
    NSString *maleID = [coupleInfo objectForKey:@"Male_ID"];
    NSString *femaleID = [coupleInfo objectForKey:@"Female_ID"];
    NSString *key = [maleID stringByAppendingString:femaleID];
    
    [_coupleObjectsAlreadyVotedOn setObject:[coupleInfo objectForKey:@"Couple_Object_ID"] forKey:key];
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
