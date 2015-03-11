//
//  PARStatsViewController.h
//  Pear
//
//  Created by Alex Ramey on 12/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PARButton.h"
#import "FacebookSDK.h"
#import "Parse.h"
#import "PARResultsOverlayView.h"

@interface PARProfileViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, OverlayCallback>
{
    PFObject *couple;
    BOOL inProgress;
}

@property (nonatomic, weak) IBOutlet UIView *profileCard;
@property (nonatomic, weak) IBOutlet UIView *profilePicFillerView;
@property (nonatomic, weak) IBOutlet UILabel *wishlistSwag;

@property (nonatomic, weak) IBOutlet PARButton *logoutBtn;
@property (nonatomic, weak) IBOutlet PARButton *recentCommentsBtn;
@property (nonatomic, weak) IBOutlet UICollectionView *topMatchesCollection;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionViewBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cardHeight;

@property (nonatomic, strong) NSMutableDictionary *topMatchProfilePicViews;
@property (nonatomic, strong) NSMutableArray *topMatchesAllTime;
@property (nonatomic, strong) NSMutableArray *topMatchesPast30Days;
@property (nonatomic, strong) NSMutableArray *allTimeRanks;
@property (nonatomic, strong) NSMutableArray *past30DayRanks;

@end
