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

@interface PARProfileViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    BOOL inProgress;
}

@property (nonatomic, weak) IBOutlet PARButton *logoutBtn;
@property (nonatomic, weak) IBOutlet UICollectionView *topMatchesCollection;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, strong) NSMutableDictionary *topMatchProfilePicViews;
@property (nonatomic, strong) NSArray *topMatches;

@end
