//
//  PARCommentCard.m
//  Pear
//
//  Created by Alex Ramey on 10/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARCommentCard.h"
#import "FacebookSDK.h"

@implementation PARCommentCard

-(id)initWithFacebookID:(NSString *)fbID name:(NSString *)name comment:(NSString *)comment
{
    // Initialization code
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"PARCommentCard"
                                                         owner:self
                                                       options:nil];
    
    self = [nibContents objectAtIndex:0];
    
    FBProfilePictureView *commenterPic = [[FBProfilePictureView alloc] initWithProfileID:fbID pictureCropping:FBProfilePictureCroppingSquare];
    
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
    _commentLabel.text = comment;
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
