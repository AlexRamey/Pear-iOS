//
//  PARCommentCard.m
//  Pear
//
//  Created by Alex Ramey on 10/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARCommentCard.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation PARCommentCard

-(id)initWithFacebookID:(NSString *)fbID name:(NSString *)name comment:(NSString *)comment authorLiked:(NSNumber *)authorLiked offset: (CGFloat)offset callback:(id<CommentCardCallback>) callback
{
    // Initialization code
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"PARCommentCard"
                                                         owner:self
                                                       options:nil];
    
    self = [nibContents objectAtIndex:0];
    
    FBSDKProfilePictureView *commenterPic = [FBSDKProfilePictureView new];
    commenterPic.profileID = fbID;
    commenterPic.pictureMode = FBSDKProfilePictureModeSquare;
    
    [_profilePictureFillerView addSubview:commenterPic];
    
    [commenterPic setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_profilePictureFillerView addConstraints:[NSLayoutConstraint
                                            constraintsWithVisualFormat:@"H:|-0-[commenterPic]-0-|"
                                            options:NSLayoutFormatDirectionLeadingToTrailing
                                            metrics:nil
                                            views:NSDictionaryOfVariableBindings(commenterPic)]];
    [_profilePictureFillerView addConstraints:[NSLayoutConstraint
                                            constraintsWithVisualFormat:@"V:|-0-[commenterPic]-0-|"
                                            options:NSLayoutFormatDirectionLeadingToTrailing
                                            metrics:nil
                                            views:NSDictionaryOfVariableBindings(commenterPic)]];
    
    _nameLabel.text = name;
    _commentLabel.text = [comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [_commentLabel sizeToFit];
    [_scrollView setContentSize:CGSizeMake(_commentLabel.frame.size.width, _commentLabel.frame.size.width + 2 * _commentLabel.frame.origin.y)];
    
    self.frame = CGRectMake(0,offset,[[UIScreen mainScreen] bounds].size.width, 80.0);
    
    if ([authorLiked intValue] == 1)
    {
        [_imageView setImage:[UIImage imageNamed:@"upVote"]];
    }
    else
    {
        [_imageView setImage:[UIImage imageNamed:@"downVote"]];
    }
    
    [self createDropShadow:self];
    
    [callback commentCardCreatedWithHeight:self.frame.size.height];
    
    return self;
}

-(void)createDropShadow:(UIView *)view
{
    [view setNeedsLayout];
    [view layoutIfNeeded];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    view.layer.shadowOpacity = 0.5f;
    view.layer.shadowPath = shadowPath.CGPath;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
