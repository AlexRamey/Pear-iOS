//
//  PARMatchDetailsViewController.h
//  Pear
//
//  Created by Alex Ramey on 1/7/15.
//  Copyright (c) 2015 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PARCommentCard.h"
#import "FacebookSDK.h"

@interface PARMatchDetailsViewController : UIViewController <CommentCardCallback>
{
    FBProfilePictureView *maleView;
    FBProfilePictureView *femaleView;
    CGFloat yOffset;
}

@property (nonatomic, strong) NSString *selectedCoupleID;

@property (nonatomic, strong) NSString *male;
@property (nonatomic, strong) NSString *female;

@property (nonatomic, strong) NSString *maleName;
@property (nonatomic, strong) NSString *femaleName;

@property (nonatomic, strong) NSNumber *downvotes;
@property (nonatomic, strong) NSNumber *upvotes;

@property (nonatomic, weak) IBOutlet UILabel *auxilaryLabel;
@property (nonatomic, weak) IBOutlet UILabel *maleNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *femaleNameLabel;

@property (nonatomic, weak) IBOutlet UIView *maleProfileFillerView;
@property (nonatomic, weak) IBOutlet UIView *femaleProfileFillerView;

@property (nonatomic, weak) IBOutlet UIView *maleShadowView;
@property (nonatomic, weak) IBOutlet UIView *femaleShadowView;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end
