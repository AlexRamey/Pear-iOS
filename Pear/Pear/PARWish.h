//
//  PARWish.h
//  Pear
//
//  Created by Alex Ramey on 12/18/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PARWish : NSObject

@property (nonatomic, strong) NSString *wishName;
@property (nonatomic, strong) NSString *facebookID;

-(id)initWithName:(NSString *)name facebookID:(NSString *)facebookID;

@end
