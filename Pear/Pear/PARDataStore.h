//
//  PARDataStore.h
//  Pear
//
//  Created by Alex Ramey on 10/12/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PARDataStore : NSObject

@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSArray *maleFriendIDs;
@property (nonatomic, strong) NSArray *femaleFriendIDs;

@property (nonatomic, strong) NSMutableArray *coupleIDsAlreadyVotedOn;

@property (nonatomic, strong) NSMutableArray *existingCouplesLeftToVoteOn;

+(PARDataStore *)sharedStore;

-(void)getAllExistingCouplesWithCompletion:(void (^)(NSError *))completion;

-(void)createNewCouplesWithCompletion:(void (^)(NSError *))completion;

-(void)addCoupleIDToCouplesAlreadyVotedOnList:(NSString *)coupleID;

-(void)saveCouplesAlreadyVotedOn;

@end
