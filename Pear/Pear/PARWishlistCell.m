//
//  PARWishlistCell.m
//  Pear
//
//  Created by Alex Ramey on 12/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARWishlistCell.h"
#import "FacebookSDK.h"

@implementation PARWishlistCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
        FBProfilePictureView *profilePic = [[FBProfilePictureView alloc] initWithProfileID:nil pictureCropping:FBProfilePictureCroppingSquare];
        
        [self addSubview:profilePic];
        
        [profilePic setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:|-0-[profilePic]-0-|"
                              options:NSLayoutFormatDirectionLeadingToTrailing
                              metrics:nil
                              views:NSDictionaryOfVariableBindings(profilePic)]];
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|-0-[profilePic]-0-|"
                              options:NSLayoutFormatDirectionLeadingToTrailing
                              metrics:nil
                              views:NSDictionaryOfVariableBindings(profilePic)]];
    }
    
    return self;
}


-(void)loadProfilePictureForFBID:(NSString *)facebookID
{
    FBProfilePictureView *pic = [[self subviews] lastObject];
    [pic setProfileID:nil]; //so it will show silouhette while loading
    [pic setProfileID:facebookID];
}

-(void)addLabelWithName:(NSString *)name
{
    //TODO
}

@end
