//
//  PARWriteCommentCard.m
//  Pear
//
//  Created by Alex Ramey on 10/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARWriteCommentCard.h"
#import "PARDataStore.h"
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
    
    self.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width, 80.0);
    
    [self createDropShadow:self];
    
    return self;
}

-(void)createDropShadow:(UIView *)view
{
    [view setNeedsLayout];
    [view layoutIfNeeded];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    view.layer.shadowOpacity = 0.5f;
    view.layer.shadowPath = shadowPath.CGPath;
}

-(void)setAuthorLiked:(NSNumber *)authorLiked
{
    _authorLiked = authorLiked;
    if ([authorLiked intValue] == 1)
    {
        [_imageView setImage:[UIImage imageNamed:@"upVote"]];
    }
    else
    {
        [_imageView setImage:[UIImage imageNamed:@"downVote"]];
    }
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        if ([textView.text caseInsensitiveCompare:@"express yo'self"] != NSOrderedSame)
        {
            PFObject *userObject = [[PARDataStore sharedStore] userObject];
            NSDictionary *userData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA_KEY];
            NSString *userName = userData[@"name"];
            
            PFObject *comment = [PFObject objectWithClassName:@"Comments"];
            comment[@"coupleObjectID"] = _coupleObjectID;
            comment[@"Text"] = textView.text;
            comment[@"AuthorFBID"] = [[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY];;
            comment[@"AuthorObjectID"] = userObject.objectId;
            comment[@"AuthorName"] = userName;
            comment[@"authorLiked"] = _authorLiked;
            comment[@"coupleMaleName"] = _coupleMaleName;
            comment[@"coupleFemaleName"] = _coupleFemaleName;
            
            [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    [_callback commentWasPushed];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to save comment." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }
        
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
