//
//  PARDataStore.h
//  Pear
//
//  Created by Alex Ramey on 10/12/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse.h"

@interface PARDataStore : NSObject
{
    int pushIndex;
}

@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSArray *maleFriendIDs;
@property (nonatomic, strong) NSArray *femaleFriendIDs;
@property (nonatomic, strong) NSArray *maleFriendNames;
@property (nonatomic, strong) NSArray *femaleFriendNames;

@property (nonatomic, strong) NSMutableDictionary *coupleObjectsAlreadyVotedOn;

@property (nonatomic, strong) NSMutableArray *couplesLeftToVoteOn;

@property (nonatomic, strong) NSMutableArray *potentialCouples;

@property (nonatomic, strong) PFObject *userObject;

+(PARDataStore *)sharedStore;

-(void)nextCoupleWithCompletion:(void (^)(NSError *))completion;

-(void)fetchCouplesWithCompletion:(void (^)(NSError *error)) completion;

-(void)addCoupleToCouplesAlreadyVotedOnList:(NSDictionary *)coupleInfo;

-(void)saveCouplesAlreadyVotedOn;

-(void)saveWishlist;

-(void)removePotentialCoupleWithMaleID:(NSString *)maleID femaleID:(NSString *)femaleID;

@end
