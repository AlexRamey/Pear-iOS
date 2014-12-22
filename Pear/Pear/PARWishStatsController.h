//
//  PARWishStatsController.h
//  Pear
//
//  Created by Alex Ramey on 12/19/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PARCommentCard.h"
#import "FacebookSDK.h"
#import "PARButton.h"

@interface PARWishStatsController : UIViewController <CommentCardCallback>
{
    FBProfilePictureView *maleView;
    FBProfilePictureView *femaleView;
    CGFloat yOffset;
}

@property (nonatomic, strong) NSString *selectedWishID;

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

@property (nonatomic, weak) IBOutlet PARButton *removeFromWishlist;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@end
