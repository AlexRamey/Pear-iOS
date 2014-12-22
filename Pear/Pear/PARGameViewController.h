//
//  PARPearGameViewController.h
//  Pear
//
//  Created by Alex Ramey on 10/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse.h"
#import "FacebookSDK.h"

@interface PARGameViewController : UIViewController
{
    FBProfilePictureView *maleView;
    FBProfilePictureView *femaleView;
    NSString *maleId;
    NSString *femaleId;
    NSString *mName;
    NSString *fName;
    NSString *objectId;
    int downVotes;
    int upVotes;
    int retryCounter;
    int userVote;
}

@property (nonatomic, weak) IBOutlet UIView *maleProfileFillerView;
@property (nonatomic, weak) IBOutlet UIView *femaleProfileFillerView;

@property (nonatomic, weak) IBOutlet UILabel *maleName;
@property (nonatomic, weak) IBOutlet UILabel *femaleName;

@property (nonatomic, weak) IBOutlet UIButton *upVote;
@property (nonatomic, weak) IBOutlet UIButton *downVote;

@property (nonatomic, weak) IBOutlet UISwipeGestureRecognizer *upSwipeRecognizer;
@property (nonatomic, weak) IBOutlet UISwipeGestureRecognizer *downSwipeRecognizer;

@end
