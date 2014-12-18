//
//  PARWish.m
//  Pear
//
//  Created by Alex Ramey on 12/18/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARWish.h"

@implementation PARWish

-(id)initWithName:(NSString *)name facebookID:(NSString *)facebookID
{
    self = [super init];
    
    if (self)
    {
        _wishName = name;
        _facebookID = facebookID;
    }
    
    return self;
}

@end
