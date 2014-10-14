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

@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSArray *maleFriendIDs;
@property (nonatomic, strong) NSArray *femaleFriendIDs;

@property (nonatomic, strong) NSMutableArray *coupleObjectsAlreadyVotedOn;

@property (nonatomic, strong) NSMutableArray *couplesLeftToVoteOn;

+(PARDataStore *)sharedStore;

-(PFObject *)nextCoupleWithCompletion:(void (^)(NSError *))completion;

-(void)fetchCouplesWithCompletion:(void (^)(NSError *error)) completion;

-(void)addCoupleToCouplesAlreadyVotedOnList:(NSDictionary *)coupleInfo;

-(void)saveCouplesAlreadyVotedOn;

@end
