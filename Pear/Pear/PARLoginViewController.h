//
//  PARLoginViewController.h
//  Pear
//
//  Created by Alex Ramey on 10/12/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookSDK.h"
#import "PARButton.h"

@interface PARLoginViewController : UIViewController <FBLoginViewDelegate>

@property (nonatomic, weak) IBOutlet PARButton *loginBtn;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
