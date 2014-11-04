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

-(id)initWithFacebookID:(NSString *)fbID name:(NSString *)name comment:(NSString *)comment offset: (CGFloat)offset callback:(id<CommentCardCallback>) callback
{
    // Initialization code
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"PARCommentCard"
                                                         owner:self
                                                       options:nil];
    
    self = [nibContents objectAtIndex:0];
    
    FBProfilePictureView *commenterPic = [[FBProfilePictureView alloc] initWithProfileID:fbID pictureCropping:FBProfilePictureCroppingSquare];
    
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
    _commentLabel.text = comment;
    
    [_commentLabel sizeToFit];
    
    self.frame = CGRectMake(0,offset,[[UIScreen mainScreen] bounds].size.width, self.commentLabel.frame.size.height + self.commentLabel.frame.origin.y + 10);
    
    [callback commentCardCreatedWithHeight:self.frame.size.height];
    
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
