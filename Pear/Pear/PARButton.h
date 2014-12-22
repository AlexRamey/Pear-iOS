//
//  PARButton.h
//  Pear
//
//  Created by Alex Ramey on 12/22/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PARButton : UIButton

@property (nonatomic, strong) CAGradientLayer *backgroundLayer, *highlightBackgroundLayer;
@property (nonatomic, strong) CALayer *innerGlow;

@property (nonatomic, strong) UIColor *primaryColor;
@property (nonatomic, strong) UIColor *secondaryColor;

-(void)drawWithPrimaryColor:(UIColor *)primary secondaryColor:(UIColor *)secondary;

@end
