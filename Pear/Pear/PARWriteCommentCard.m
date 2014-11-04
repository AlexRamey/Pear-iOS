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
#import "AppDelegate.h"

@implementation PARWriteCommentCard

-(id)init
{
    // Initialization code
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"PARWriteCommentCard"
                                                         owner:self
                                                       options:nil];
    
    self = [nibContents objectAtIndex:0];
    
    NSString *userFBID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY];
    
    FBProfilePictureView *commenterPic = [[FBProfilePictureView alloc] initWithProfileID:userFBID pictureCropping:FBProfilePictureCroppingSquare];
    
    [_profilePicFillerView addSubview:commenterPic];
    
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
    
    [_commentArea setDelegate:self];
    
    self.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width, 60.0);
    
    return self;
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        //push comment up to parse . . .
        //refresh view . . .
        NSLog(@"Push Comment Up");
        
        return NO;
    }
    
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    float offset = [[[NSUserDefaults standardUserDefaults] objectForKey:@"GAME_RESULTS_PICTURE_ORIGIN_Y_KEY"] floatValue];
    
    //move view up
    self.superview.superview.frame = CGRectMake(self.superview.superview.frame.origin.x, self.superview.superview.frame.origin.y - offset + 10, self.superview.superview.frame.size.width, self.superview.superview.frame.size.height);
    
    if ([textView.text caseInsensitiveCompare:@"express yo'self"] == NSOrderedSame)
    {
        textView.text = @""; //clear placeholder text if necessary
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    float offset = [[[NSUserDefaults standardUserDefaults] objectForKey:@"GAME_RESULTS_PICTURE_ORIGIN_Y_KEY"] floatValue];
    
    //move view back down
    self.superview.superview.frame = CGRectMake(self.superview.superview.frame.origin.x, self.superview.superview.frame.origin.y + offset - 10, self.superview.superview.frame.size.width, self.superview.superview.frame.size.height);
    
    if ([textView.text caseInsensitiveCompare:@""] == NSOrderedSame)
    {
        textView.text = @"express yo'self";
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
