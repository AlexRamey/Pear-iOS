//
//  PARPearGameViewController.h
//  Pear
//
//  Created by Alex Ramey on 10/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookSDK.h"

@interface PARGameViewController : UIViewController
{
    FBProfilePictureView *maleView;
    FBProfilePictureView *femaleView;
}

@property (nonatomic, weak) IBOutlet UIView *maleProfileFillerView;
@property (nonatomic, weak) IBOutlet UIView *femaleProfileFillerView;

@property (nonatomic, weak) IBOutlet UILabel *maleName;
@property (nonatomic, weak) IBOutlet UILabel *femaleName;

@property (nonatomic, weak) IBOutlet UIButton *upVote;
@property (nonatomic, weak) IBOutlet UIButton *downVote;

@property (nonatomic, weak) IBOutlet UILabel *auxilaryLabel;

//@property (nonatomic, weak) NSDictionary *

@end
