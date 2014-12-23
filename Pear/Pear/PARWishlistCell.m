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
    
    // Initialization code
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"PARWishlistCell"
                                                         owner:self
                                                       options:nil];
    
    self = [nibContents objectAtIndex:0];
    
    if (self)
    {
        self.frame = frame;
        
        // Initialization code
        FBProfilePictureView *profilePic = [[FBProfilePictureView alloc] initWithProfileID:nil pictureCropping:FBProfilePictureCroppingSquare];
        
        [self addSubview:profilePic];
        [self sendSubviewToBack:profilePic];
        
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
        
        [self createDropShadow:self];
    }
    
    return self;
}

-(void)createDropShadow:(UIView *)view
{
    [view setNeedsLayout];
    [view layoutIfNeeded];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    view.layer.shadowOpacity = 0.5f;
    view.layer.shadowPath = shadowPath.CGPath;
}

-(void)loadProfilePictureForFBID:(NSString *)facebookID andWishName:(NSString *)wishName
{
    FBProfilePictureView *pic = nil;
    UILabel *wishNameLabel = nil;
    
    for (int i = 0; i < [[self subviews] count]; i++)
    {
        if ([[[self subviews] objectAtIndex:i] class] == [FBProfilePictureView class])
        {
            pic = [[self subviews] objectAtIndex:i];
        }
        else if ([[[self subviews] objectAtIndex:i] class] == [UILabel class])
        {
            wishNameLabel = [[self subviews] objectAtIndex:i];
        }
    }
    
    if (pic)
    {
        [pic setProfileID:nil]; //so it will show silouhette while loading
        [pic setProfileID:facebookID];
    }
    
    if (wishNameLabel)
    {
        wishNameLabel.text = wishName;
    }
}

@end
