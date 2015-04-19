//
//  PARLoginViewController.h
//  Pear
//
//  Created by Alex Ramey on 10/12/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PARButton.h"

@interface PARLoginViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView *thePearGameLabel;
@property (nonatomic, weak) IBOutlet UIView *pearLogo;
@property (nonatomic, strong) PARButton *loginBtn;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end
