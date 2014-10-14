//
//  PARWriteCommentCard.m
//  Pear
//
//  Created by Alex Ramey on 10/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARWriteCommentCard.h"
#import "FacebookSDK.h"
#import "Parse.h"

@implementation PARWriteCommentCard

-(id)init
{
    // Initialization code
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"PARWriteCommentCard"
                                                         owner:self
                                                       options:nil];
    
    self = [nibContents objectAtIndex:0];
    
    NSString *userFBID = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_FB_ID"];
    
    FBProfilePictureView *commenterPic = [[FBProfilePictureView alloc] initWithProfileID:userFBID pictureCropping:FBProfilePictureCroppingSquare];
    
    [commenterPic setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_profilePicFillerView addConstraints:[NSLayoutConstraint
                                               constraintsWithVisualFormat:@"H:|-0-[commenterPic]-0-|"
                                               options:NSLayoutFormatDirectionLeadingToTrailing
                                               metrics:nil
                                               views:NSDictionaryOfVariableBindings(commenterPic)]];
    [_profilePicFillerView addConstraints:[NSLayoutConstraint
                                               constraintsWithVisualFormat:@"V:|-0-[commenterPic]-0-|"
                                               options:NSLayoutFormatDirectionLeadingToTrailing
                                               metrics:nil
                                               views:NSDictionaryOfVariableBindings(commenterPic)]];
    
    self.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width);
    
    return self;
}

#pragma mark - UITextViewDelegate Methods

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    //push comment up to parse . . .
    
    [textView resignFirstResponder];
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
