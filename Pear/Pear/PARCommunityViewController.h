//
//  PARCommunityViewController.h
//  Pear
//
//  Created by Alex Ramey on 12/27/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse.h"
#import "PARResultsOverlayView.h"

@interface PARCommunityViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, OverlayCallback>
{
    PFObject *couple;
    BOOL inProgress;
}

@property (nonatomic, weak) IBOutlet UICollectionView *topMatchesCollection;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, strong) NSMutableDictionary *topMatchProfilePicViews;
@property (nonatomic, strong) NSMutableArray *topMatchesAllTime;
@property (nonatomic, strong) NSMutableArray *topMatchesPast30Days;
@property (nonatomic, strong) NSMutableArray *allTimeRanks;
@property (nonatomic, strong) NSMutableArray *past30DayRanks;

@end
