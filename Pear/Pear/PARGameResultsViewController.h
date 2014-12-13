//
//  PARGameResultsViewController.h
//  Pear
//
//  Created by Alex Ramey on 10/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PARCommentCard.h"
#import "FacebookSDK.h"

@interface PARGameResultsViewController : UIViewController <CommentCardCallback>
{
    FBProfilePictureView *maleView;
    FBProfilePictureView *femaleView;
    CGFloat yOffset;
    CAGradientLayer *gradient;
}

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

@property (nonatomic, weak) IBOutlet UISwipeGestureRecognizer *leftSwipeRecognizer;
@property (nonatomic, weak) IBOutlet UISwipeGestureRecognizer *rightSwipeRecognizer;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NSArray *colors;

@end
