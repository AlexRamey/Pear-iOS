//
//  PARGameResultsViewController.h
//  Pear
//
//  Created by Alex Ramey on 10/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PARCommentCard.h"
#import "PARWriteCommentCard.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@class PARButton;

@interface PARGameResultsViewController : UIViewController <CommentCardCallback, WriteCommentCardCallback>
{
    FBSDKProfilePictureView *maleView;
    FBSDKProfilePictureView *femaleView;
    CGFloat yOffset;
}

@property (nonatomic, strong) NSString *coupleObjectID;

@property (nonatomic, strong) NSString *male;
@property (nonatomic, strong) NSString *female;

@property (nonatomic, strong) NSString *maleName;
@property (nonatomic, strong) NSString *femaleName;

@property (nonatomic, strong) NSNumber *downvotes;
@property (nonatomic, strong) NSNumber *upvotes;

@property (nonatomic, weak) IBOutlet UIButton *facebookShare;
@property (nonatomic, weak) IBOutlet UIButton *twitterShare;

@property (nonatomic, weak) IBOutlet UILabel *auxilaryLabel;
@property (nonatomic, weak) IBOutlet UILabel *maleNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *femaleNameLabel;

@property (nonatomic, weak) IBOutlet UIView *maleProfileFillerView;
@property (nonatomic, weak) IBOutlet UIView *femaleProfileFillerView;

@property (nonatomic, weak) IBOutlet UIView *maleShadowView;
@property (nonatomic, weak) IBOutlet UIView *femaleShadowView;

@property (nonatomic, weak) IBOutlet UISwipeGestureRecognizer *leftSwipeRecognizer;
@property (nonatomic, weak) IBOutlet UISwipeGestureRecognizer *rightSwipeRecognizer;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;

@property (nonatomic, strong) NSArray *colors;

@property (nonatomic, strong) NSNumber *userVote;

@end
