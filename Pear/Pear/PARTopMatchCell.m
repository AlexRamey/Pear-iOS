//
//  PARTopMatchCell.m
//  Pear
//
//  Created by Alex Ramey on 12/27/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARTopMatchCell.h"

@implementation PARTopMatchCell

-(id)initWithFrame:(CGRect)frame
{
    
    // Initialization code
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"PARTopMatchCell"
                                                         owner:self
                                                       options:nil];
    
    self = [nibContents objectAtIndex:0];
    
    if (self)
    {
        self.frame = frame;
    }
    
    return self;
}

-(void)setMatchName:(NSString *)matchName matchRank:(int)rank
{
    UILabel *matchNameLabel = nil;
    UILabel *matchRankLabel = nil;
    
    for (int i = 0; i < [[self subviews] count]; i++)
    {
        if ([[[self subviews] objectAtIndex:i] class] == [UILabel class])
        {
            UIView *view = [[self subviews] objectAtIndex:i];
            
            if (view.frame.origin.y == 0)
            {
                matchRankLabel = (UILabel *)view;
            }
            else
            {
                matchNameLabel = (UILabel *)view;
            }
        }
    }
    
    if (matchNameLabel)
    {
        matchNameLabel.text = matchName;
    }
    if (matchRankLabel)
    {
        matchRankLabel.text = [NSString stringWithFormat:@"#%d", rank];
    }
}

-(void)setPicture:(FBSDKProfilePictureView *)profilePic
{
    // Remove old picture if one exists
    
    for (int i = 0; i < [[self subviews] count]; i++)
    {
        if ([[[self subviews] objectAtIndex:i] class] == [FBSDKProfilePictureView class])
        {
            [[[self subviews] objectAtIndex:i] removeFromSuperview];
        }
    }
    
    // Add the new one
    
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
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
