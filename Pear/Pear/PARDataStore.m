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
        _coupleObjectsAlreadyVotedOn = [[NSMutableDictionary alloc] init];
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
    
    NSMutableArray *maleFriendNames = [[NSMutableArray alloc] init];
    NSMutableArray *femaleFriendNames = [[NSMutableArray alloc] init];
    
    for (NSDictionary<FBGraphUser>* friend in friendsList)
    {
        if ([[friend objectForKey:@"gender"] caseInsensitiveCompare:@"male"] == NSOrderedSame)
        {
            [maleFriendIDs addObject:[friend objectForKey:@"id"]];
            [maleFriendNames addObject:[friend objectForKey:@"name"]];
        }
        else if ([[friend objectForKey:@"gender"] caseInsensitiveCompare:@"female"] == NSOrderedSame)
        {
            [femaleFriendIDs addObject:[friend objectForKey:@"id" ]];
            [femaleFriendNames addObject:[friend objectForKey:@"name"]];
        }
        else
        {
            //do nothing, effectively discarding people who don't have a gender field
        }
    }
    
    _maleFriendIDs = maleFriendIDs;
    _femaleFriendIDs = femaleFriendIDs;
    _maleFriendNames = maleFriendNames;
    _femaleFriendNames = femaleFriendNames;
}

-(void)pullCouplesAlreadyVotedOnWithCompletion:(void (^)(NSError *))completion
{
    _couplesLiked = [[NSMutableArray alloc] init];
    _couplesDisliked = [[NSMutableArray alloc] init];
    
    int limit = 500;
    __block int likeBatchCounter = 0;
    __block int dislikeBatchCounter = 0;
    __block int completionCounter = 0;
    
    __block NSError *anyError = nil;
    
    //retain cycle is broken below by nilling out block in recursive base case . . .
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-retain-cycles"
    
    __block void (^couplesLikedBlock)() = [^(){
        PFRelation *couplesLiked = [_userObject relationForKey:@"couplesLiked"];
        PFQuery *couplesLikedQuery = [couplesLiked query];
        couplesLikedQuery.limit = limit;
        couplesLikedQuery.skip = likeBatchCounter++ * limit;
        
        [couplesLikedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error)
            {
                [_couplesLiked addObjectsFromArray:objects];
            }
            else
            {
                anyError = error;
            }
            
            if ([objects count] < limit) //will evaluate true if objects is nil b/c 0 < limit
            {
                if (++completionCounter == 2)
                {
                    [self initializeCoupleObjectsAlreadyVotedOn];
                    completion(anyError);
                }
                couplesLikedBlock = nil;
            }
            else
            {
                couplesLikedBlock();
            }
        }];
            } copy];
    
    #pragma clang diagnostic pop
    
    couplesLikedBlock();
    
    //retain cycle is broken below by nilling out block in recursive base case . . .
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-retain-cycles"
    
    __block void (^couplesDislikedBlock)() = [^(){
        PFRelation *couplesDisliked = [_userObject relationForKey:@"couplesDisliked"];
        PFQuery *couplesDislikedQuery = [couplesDisliked query];
        couplesDislikedQuery.limit = limit;
        couplesDislikedQuery.skip = dislikeBatchCounter++ * limit;
        
        [couplesDislikedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error)
            {
                //NSLog(@"Dislike Relations Batch %d: %@", dislikeBatchCounter - 1, objects);
                [_couplesDisliked addObjectsFromArray:objects];
            }
            else
            {
                anyError = error;
            }
            
            if ([objects count] < limit) //will evaluate true if objects is nil b/c 0 < limit
            {
                if (++completionCounter == 2)
                {
                    [self initializeCoupleObjectsAlreadyVotedOn];
                    completion(anyError);
                }
                couplesDislikedBlock = nil;
            }
            else
            {
                couplesDislikedBlock();
            }
        }];
    } copy];
    
    #pragma clang diagnostic pop
    
    couplesDislikedBlock();
}

-(void)initializeCoupleObjectsAlreadyVotedOn
{
    for (PFObject *couple in _couplesLiked)
    {
        NSString *key = [couple[@"Male"] stringByAppendingString:couple[@"Female"]];
        NSString *priorSavedCoupleID = [_coupleObjectsAlreadyVotedOn objectForKey:key];
        
        if (priorSavedCoupleID && [priorSavedCoupleID caseInsensitiveCompare:couple.objectId] != NSOrderedSame) //already pulled a couple with same male/female
        {
            PFQuery *query = [PFQuery queryWithClassName:@"Couples"];
            [query getObjectInBackgroundWithId:priorSavedCoupleID block:^(PFObject *object, NSError *error) {
                if (!error)
                {
                    PFObject *priorSavedCouple = object;
                    
                    //Merge
                    int priorSavedUpvotes, priorSavedDownvotes, incomingUpvotes, incomingDownvotes = 0;
                    
                    if ([priorSavedCouple[@"Upvotes"] isKindOfClass:[NSNumber class]])
                    {
                        priorSavedUpvotes = [priorSavedCouple[@"Upvotes"] intValue];
                    }
                    if ([priorSavedCouple[@"Downvotes"] isKindOfClass:[NSNumber class]])
                    {
                        priorSavedDownvotes = [priorSavedCouple[@"Downvotes"] intValue];
                    }
                    if ([couple[@"Upvotes"] isKindOfClass:[NSNumber class]])
                    {
                        incomingUpvotes = [couple[@"Upvotes"] intValue];
                    }
                    if ([couple[@"Downvotes"] isKindOfClass:[NSNumber class]])
                    {
                        incomingDownvotes = [couple[@"Downvotes"] intValue];
                    }
                    
                    priorSavedCouple[@"Upvotes"] = [NSNumber numberWithInt:priorSavedUpvotes + incomingUpvotes];
                    priorSavedCouple[@"Downvotes"] = [NSNumber numberWithInt:priorSavedDownvotes + incomingDownvotes];
                    
                    double uVotes = [priorSavedCouple[@"Upvotes"] doubleValue];
                    double dVotes = [priorSavedCouple[@"Downvotes"] doubleValue];
                    priorSavedCouple[@"Score"] = [self computeScoreFromUpvotes:uVotes andDownvotes:dVotes];
                    
                    //save the updated priorSavedCouple
                    [priorSavedCouple saveInBackground];
                    
                    //delete incoming couple now that we've added its votes to the existing couple
                    [couple deleteInBackground];
                }
            }];
        }
        else
        {
            [_coupleObjectsAlreadyVotedOn setObject:couple.objectId forKey:key];
        }
    }
    
    for (PFObject *couple in _couplesDisliked)
    {
        NSString *key = [couple[@"Male"] stringByAppendingString:couple[@"Female"]];
        NSString *priorSavedCoupleID = [_coupleObjectsAlreadyVotedOn objectForKey:key];
        
        if (priorSavedCoupleID && [priorSavedCoupleID caseInsensitiveCompare:couple.objectId] != NSOrderedSame)
            //already pulled a couple with same male/female, but make sure it's not
            //the same couple before deleting! (in case we voted twice for some multiplatform
            //race condition reason)
        {
            PFQuery *query = [PFQuery queryWithClassName:@"Couples"];
            [query getObjectInBackgroundWithId:priorSavedCoupleID block:^(PFObject *object, NSError *error) {
                if (!error)
                {
                    PFObject *priorSavedCouple = object;
                    
                    //Merge
                    int priorSavedUpvotes, priorSavedDownvotes, incomingUpvotes, incomingDownvotes = 0;
                    
                    if ([priorSavedCouple[@"Upvotes"] isKindOfClass:[NSNumber class]])
                    {
                        priorSavedUpvotes = [priorSavedCouple[@"Upvotes"] intValue];
                    }
                    if ([priorSavedCouple[@"Downvotes"] isKindOfClass:[NSNumber class]])
                    {
                        priorSavedDownvotes = [priorSavedCouple[@"Downvotes"] intValue];
                    }
                    if ([couple[@"Upvotes"] isKindOfClass:[NSNumber class]])
                    {
                        incomingUpvotes = [couple[@"Upvotes"] intValue];
                    }
                    if ([couple[@"Downvotes"] isKindOfClass:[NSNumber class]])
                    {
                        incomingDownvotes = [couple[@"Downvotes"] intValue];
                    }
                    
                    priorSavedCouple[@"Upvotes"] = [NSNumber numberWithInt:priorSavedUpvotes + incomingUpvotes];
                    priorSavedCouple[@"Downvotes"] = [NSNumber numberWithInt:priorSavedDownvotes + incomingDownvotes];
                    
                    double uVotes = [priorSavedCouple[@"Upvotes"] doubleValue];
                    double dVotes = [priorSavedCouple[@"Downvotes"] doubleValue];
                    priorSavedCouple[@"Score"] = [self computeScoreFromUpvotes:uVotes andDownvotes:dVotes];
                    
                    //save the updated priorSavedCouple
                    [priorSavedCouple saveInBackground];
                    
                    //delete incoming couple now that we've added its votes to the existing couple
                    [couple deleteInBackground];
                }
            }];
        }
        else
        {
            [_coupleObjectsAlreadyVotedOn setObject:couple.objectId forKey:key];
        }
    }
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
                    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:@{@"Error" : NO_MORE_COUPLES_DOMAIN}] forKey:NEXT_COUPLE_TO_VOTE_ON_KEY];
                    completion(nil);
                }
                else
                {
                    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:@{@"Error" : NETWORK_ERROR_DOMAIN}] forKey:NEXT_COUPLE_TO_VOTE_ON_KEY];
                    completion(error);
                }
            }
            else
            {
                //maybe we pushed them to parse but Parse wasn't fast enough to immediately give them back to us . . .
                if ([_couplesLeftToVoteOn count] > 0)
                {
                    PFObject *nextVote = [_couplesLeftToVoteOn objectAtIndex:0];
                    [_couplesLeftToVoteOn removeObjectAtIndex:0];
                    
                    NSMutableDictionary *nextCouple = [[nextVote dictionaryWithValuesForKeys:@[@"Downvotes", @"Female", @"FemaleEducation",@"FemaleEducationYear", @"FemaleLocation", @"FemaleName", @"Male", @"MaleEducation", @"MaleEducationYear", @"MaleLocation", @"MaleName", @"NumberOfComments", @"Score", @"Upvotes"]] mutableCopy];
                    [nextCouple setObject:nextVote.objectId forKey:@"ObjectId"];
                    [nextCouple setObject:nextVote.createdAt forKey:@"createdAt"];
                    [nextCouple setObject:nextVote.updatedAt forKey:@"updatedAt"];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:nextCouple] forKey:NEXT_COUPLE_TO_VOTE_ON_KEY];
                    completion(nil);
                }
                else
                {
                    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:@{@"Error" : NETWORK_ERROR_DOMAIN}] forKey:NEXT_COUPLE_TO_VOTE_ON_KEY];
                    completion(error);
                }
            }
        }];
    }
}

-(void)fetchCouplesWithCompletion:(void (^)(NSError *))completion
{
    _couplesLeftToVoteOn = [[NSMutableArray alloc] init];
    
    [self getExistingCouplesWithCompletion:^(NSError *error) {
        if ([_couplesLeftToVoteOn count] == 0 && !error)
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
                        
                        if ([[maleEdu objectForKey:@"year"] isKindOfClass:[NSDictionary class]])
                        {
                            NSDictionary *year = [maleEdu objectForKey:@"year"];
                            if ([year objectForKey:@"name"])
                            {
                                maleSchoolYear = [NSNumber numberWithInt:[[year objectForKey:@"name"] intValue]];
                            }
                        }
                        else if ([maleEdu objectForKey:@"year"])
                        {
                            NSString *mYear = [maleEdu objectForKey:@"year"];
                            maleSchoolYear = [NSNumber numberWithInt:[mYear intValue]];
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
                        
                        if ([[femaleEdu objectForKey:@"year"] isKindOfClass:[NSDictionary class]])
                        {
                            NSDictionary *year = [femaleEdu objectForKey:@"year"];
                            if ([year objectForKey:@"name"])
                            {
                                femaleSchoolYear = [NSNumber numberWithInt:[[year objectForKey:@"name"] intValue]];
                            }
                        }
                        else if ([femaleEdu objectForKey:@"year"])
                        {
                            NSString *fYear = [femaleEdu objectForKey:@"year"];
                            femaleSchoolYear = [NSNumber numberWithInt:[fYear intValue]];
                        }
                    }
                    
                    NSDictionary *maleLocationInfo = [localMalePtr objectForKey:@"location"];
                    NSString *maleLocation = nil;
                    if (maleLocationInfo)
                    {
                        maleLocation = [maleLocationInfo objectForKey:@"id"];
                    }
                    
                    NSDictionary *femaleLocationInfo = [localFemalePtr objectForKey:@"location"];
                    NSString *femaleLocation = nil;
                    if (femaleLocationInfo)
                    {
                        femaleLocation = [femaleLocationInfo objectForKey:@"id"];
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
                    if (maleLocation)
                    {
                        [newCouple setObject:maleLocation forKey:@"MaleLocation"];
                    }
                    if (femaleLocation)
                    {
                        [newCouple setObject:femaleLocation forKey:@"FemaleLocation"];
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
    
    // SMART COUPLES
    
    [_potentialCouples sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {
        int smartScoreOne = 0;
        
        NSDictionary *coupleOne = (NSDictionary *)obj1;
        
        if (coupleOne[@"FemaleEducation"] && coupleOne[@"MaleEducation"] && ([coupleOne[@"FemaleEducation"] caseInsensitiveCompare:coupleOne[@"MaleEducation"]] == NSOrderedSame))
        {
            smartScoreOne++;
        }
        if (coupleOne[@"FemaleEducationYear"] && coupleOne[@"MaleEducationYear"] && abs([coupleOne[@"FemaleEducationYear"] intValue] - [coupleOne[@"MaleEducationYear"] intValue]) < 7)
        {
            smartScoreOne++;
        }
        if (coupleOne[@"FemaleLocation"] && coupleOne[@"MaleLocation"] && ([coupleOne[@"FemaleLocation"] caseInsensitiveCompare:coupleOne[@"MaleLocation"]] == NSOrderedSame))
        {
            smartScoreOne++;
        }
        
        int smartScoreTwo = 0;
        
        NSDictionary *coupleTwo = (NSDictionary *)obj2;
        
        if (coupleTwo[@"FemaleEducation"] && coupleTwo[@"MaleEducation"] && ([coupleTwo[@"FemaleEducation"] caseInsensitiveCompare:coupleTwo[@"MaleEducation"]] == NSOrderedSame))
        {
            smartScoreTwo++;
        }
        if (coupleTwo[@"FemaleEducationYear"] && coupleTwo[@"MaleEducationYear"] && abs([coupleTwo[@"FemaleEducationYear"] intValue] - [coupleTwo[@"MaleEducationYear"] intValue]) < 7)
        {
            smartScoreTwo++;
        }
        if (coupleTwo[@"FemaleLocation"] && coupleTwo[@"MaleLocation"] && ([coupleTwo[@"FemaleLocation"] caseInsensitiveCompare:coupleTwo[@"MaleLocation"]] == NSOrderedSame))
        {
            smartScoreTwo++;
        }
        
        [coupleOne setValue:[NSNumber numberWithInt:smartScoreOne] forKey:@"Score"];
        [coupleTwo setValue:[NSNumber numberWithInt:smartScoreTwo] forKey:@"Score"];
        
        if (smartScoreOne > smartScoreTwo)
        {
            return NSOrderedAscending;
        }
        else if (smartScoreTwo > smartScoreOne)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];
    
    int lastThreeIndex = -1;
    int lastTwoIndex = -1;
    int lastOneIndex = -1;
    
    int checkNumber = 1;
    int count = (int)[_potentialCouples count];
    for (int i = count - 1; i > -1; i--)
    {
        int score = [[[_potentialCouples objectAtIndex:i] objectForKey:@"Score"] intValue];
        
        if (score == checkNumber)
        {
            if (checkNumber == 1)
            {
                lastOneIndex = i;
                checkNumber++;
            }
            else if (checkNumber == 2)
            {
                lastTwoIndex = i;
                checkNumber++;
            }
            else
            {
                lastThreeIndex = i;
                break;
            }
        }
    }
    
    for (int i = 0; i < count; i++)
    {
        int score = [[[_potentialCouples objectAtIndex:i] objectForKey:@"Score"] intValue];
        int remainingCount;
        if (score == 3)
        {
            //Pretend last three is the end of array
            remainingCount = lastThreeIndex + 1 - i;
        }
        else if (score == 2)
        {
            //Pretend last two is the end of the array
            remainingCount = lastTwoIndex + 1 - i;
        }
        else if (score == 1)
        {
            //Pretend the last 1 is the end of the array
            remainingCount = lastOneIndex + 1 - i;
        }
        else
        {
            //Scramble remaining couples
            remainingCount = count - i;
        }
        
        int exchangeIndex = i + arc4random_uniform(remainingCount);
        [_potentialCouples exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
    
    // END SMART COUPLES
    
    [self pushNewCouplesToParseWithCompletion:completion];
}

-(void)pushNewCouplesToParseWithCompletion:(void (^)(NSError *))completion
{
    if (pushIndex == [_potentialCouples count]) //we've pushed all the couples up already
    {
        NSError *noMoreCouplesError = [[NSError alloc] initWithDomain:NO_MORE_COUPLES_DOMAIN code:000 userInfo:nil];
        completion(noMoreCouplesError);
        return;
    }
    
    NSMutableArray *validPushCoupleOffsets = [[NSMutableArray alloc] init];
    
    NSUInteger maxOffset = [_potentialCouples count] - pushIndex - 1;
    
    __block int validPushCounter = 0;
    __block int pushIndexOffset = 0;
    
    __weak PARDataStore *weakSelf = self;
    
    //retain cycle is broken below by nilling out block in recursive base case . . .
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-retain-cycles"

    __block void (^block)() = [^(){
        PARDataStore *strongSelf = weakSelf;
        
        if (strongSelf)
        {
            [strongSelf executeQueryWithOffset:pushIndexOffset++ completion:^(BOOL exists, int offset) {
                if (exists == NO)
                {
                    [validPushCoupleOffsets addObject:[NSNumber numberWithInt:offset]];
                    //NSLog(@"Successful Offset: %d", offset);
                    validPushCounter++;
                }
                if (validPushCounter == 3 || pushIndexOffset > maxOffset) //we're done
                {
                    if (validPushCounter == 0)
                    {
                        NSError *noMoreCouplesError = [[NSError alloc] initWithDomain:NO_MORE_COUPLES_DOMAIN code:000 userInfo:nil];
                        completion(noMoreCouplesError);
                    }
                    else
                    {
                        [strongSelf executeUploadsWithOffsets:validPushCoupleOffsets completion:completion];
                    }
                    block = nil;
                }
                else
                {
                    block();
                }
            }];
        }
        else
        {
            NSError *e = [[NSError alloc] init];
            completion(e);
            
            block = nil; //breaks the retain cycle
        }
        
    } copy];
    
    #pragma clang diagnostic pop
    
    block();
}

-(void)executeQueryWithOffset:(int)offset completion:(void (^)(BOOL, int))completion
{
    if ([_potentialCouples count] > pushIndex + offset)
    {
        NSDictionary *potentialCouple = [_potentialCouples objectAtIndex:pushIndex + offset];
        PFQuery *query = [PFQuery queryWithClassName:@"Couples"];
        query.limit = 5;
        [query whereKey:@"Male" containedIn:@[[potentialCouple objectForKey:@"Male"]]];
        [query whereKey:@"Female" containedIn:@[[potentialCouple objectForKey:@"Female"]]];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) //consider pushIndex--
            {
                completion(YES, offset); //assume the worst (couple exists)
            }
            else if ([objects count] > 0)
            {
                completion(YES, offset); //couple exists
            }
            else
            {
                completion(NO, offset); //couple does not exist
            }
        }];
    }
    else
    {
        completion(YES, offset); //report the worst (couple exists); out of bounds will be caught by completion()
    }
}

-(void)executeUploadsWithOffsets:(NSArray *)offsets completion:(void (^)(NSError *))completion
{
    __block int uploadCounter = 0;
    __block int callbackCounter = 0;
    __block BOOL oneSuccess = NO;
    
    for (int i = 0; i < [offsets count]; i++)
    {
        NSDictionary *potentialCouple = [_potentialCouples objectAtIndex:pushIndex + [[offsets objectAtIndex:i] intValue]];
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
        if ([potentialCouple objectForKey:@"MaleLocation"])
        {
            couple[@"MaleLocation"] = [potentialCouple objectForKey:@"MaleLocation"];
        }
        if ([potentialCouple objectForKey:@"FemaleLocation"])
        {
            couple[@"FemaleLocation"] = [potentialCouple objectForKey:@"FemaleLocation"];
        }
        
        couple[@"Upvotes"] = [NSNumber numberWithInt:0];
        couple[@"Downvotes"] = [NSNumber numberWithInt:0];
        couple[@"Score"] = [NSNumber numberWithInt:0];
        couple[@"NumberOfComments"] = [NSNumber numberWithInt:0];
        
        uploadCounter++;
        
        [couple saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded)
            {
                oneSuccess = YES;
                //NSLog(@"One Success");
            }
            
            if (++callbackCounter == uploadCounter)
            {
                //update pushIndex
                pushIndex = pushIndex + [[offsets lastObject] intValue] + 1;
                
                if (oneSuccess)
                {
                    completion(nil);
                }
                else
                {
                    NSError *networkError = [[NSError alloc] initWithDomain:NETWORK_ERROR_DOMAIN code:000 userInfo:nil];
                    completion(networkError);
                }
                
            }
        }];
    }
}

-(void)saveCoupleVote:(NSDictionary *)coupleInfo withStatus:(BOOL)wasLiked completion:(void (^)(NSError *))completion
{
    PFObject *couple = [PFObject objectWithoutDataWithClassName:@"Couples" objectId:[coupleInfo objectForKey:@"ObjectId"]];
    
    NSString *maleID = [coupleInfo objectForKey:@"Male"];
    NSString *femaleID = [coupleInfo objectForKey:@"Female"];
    NSString *key = [maleID stringByAppendingString:femaleID];
    NSString *priorSavedCoupleID = [_coupleObjectsAlreadyVotedOn objectForKey:key];
    
    //shouldn't be possible for IDs to be the same but add extra check just in case so we don't permanently delete a couple
    if (priorSavedCoupleID && [[coupleInfo objectForKey:@"ObjectId"] caseInsensitiveCompare:priorSavedCoupleID] != NSOrderedSame)
    {
        //We already voted on this same male and female pair (just voted on a duplicate)
        //Merge
        PFQuery *query = [PFQuery queryWithClassName:@"Couples"];
        [query getObjectInBackgroundWithId:priorSavedCoupleID block:^(PFObject *object, NSError *error) {
            if (!error)
            {
                PFObject *priorSavedCouple = object;
                
                //Merge
                int priorSavedUpvotes, priorSavedDownvotes, incomingUpvotes, incomingDownvotes = 0;
                
                if ([priorSavedCouple[@"Upvotes"] isKindOfClass:[NSNumber class]])
                {
                    priorSavedUpvotes = [priorSavedCouple[@"Upvotes"] intValue];
                }
                if ([priorSavedCouple[@"Downvotes"] isKindOfClass:[NSNumber class]])
                {
                    priorSavedDownvotes = [priorSavedCouple[@"Downvotes"] intValue];
                }
                if ([coupleInfo[@"Upvotes"] isKindOfClass:[NSNumber class]])
                {
                    incomingUpvotes = [coupleInfo[@"Upvotes"] intValue];
                }
                if ([coupleInfo[@"Downvotes"] isKindOfClass:[NSNumber class]])
                {
                    incomingDownvotes = [coupleInfo[@"Downvotes"] intValue];
                }
                
                if (wasLiked) //take away the vote that was just made since this user already voted . . .
                {
                    incomingUpvotes -= 1;
                }
                else
                {
                    incomingDownvotes -= 1;
                }
                
                priorSavedCouple[@"Upvotes"] = [NSNumber numberWithInt:priorSavedUpvotes + incomingUpvotes];
                priorSavedCouple[@"Downvotes"] = [NSNumber numberWithInt:priorSavedDownvotes + incomingDownvotes];
                
                double uVotes = [priorSavedCouple[@"Upvotes"] doubleValue];
                double dVotes = [priorSavedCouple[@"Downvotes"] doubleValue];
                priorSavedCouple[@"Score"] = [self computeScoreFromUpvotes:uVotes andDownvotes:dVotes];
                
                //save the updated priorSavedCouple
                [priorSavedCouple saveInBackground];
                
                //delete incoming couple now that we've added its votes to the existing couple
                [couple deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *deleteError) {
                    completion(deleteError);
                }];
            }
            else
            {
                completion(error);
            }
        }];
        return;
    }
    
    //The couple is not a duplicate of one that we already voted on
    PFRelation *relation = nil;
    
    if (wasLiked)
    {
        [_couplesLiked addObject:couple];
        relation = [_userObject relationForKey:@"couplesLiked"];
    }
    else
    {
        [_couplesDisliked addObject:couple];
        relation = [_userObject relationForKey:@"couplesDisliked"];
    }
    
    [relation addObject:couple];
    
    [_coupleObjectsAlreadyVotedOn setObject:[coupleInfo objectForKey:@"ObjectId"] forKey:key];
    completion(nil);
}

-(NSNumber *)computeScoreFromUpvotes:(double)uVotes andDownvotes:(double)dVotes
{
    if (dVotes == 0)
    {
        dVotes = 1.0;
    }
    
    double score = pow(uVotes, 7/3) / pow(dVotes, 2);
    
    return [NSNumber numberWithDouble:score];
}

-(void)saveUserWithCompletion:(void (^)(void))completion
{
    if (_userObject)
    {
        [_userObject setObject:[[NSUserDefaults standardUserDefaults] objectForKey:WISHLIST_DEFAULTS_KEY] forKey:@"Wishlist"];
        [_userObject setObject:[[[NSUserDefaults standardUserDefaults] objectForKey:WISHLIST_DEFAULTS_KEY] allKeys] forKey:@"WishlistFBIDs"];
        if (!completion)
        {
            [_userObject saveInBackground];
        }
        else
        {
            [_userObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
            {
                completion();
            }];
        }
    }
}

-(NSString *)filePathForKey:(NSString *)key
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:key];
}

@end
