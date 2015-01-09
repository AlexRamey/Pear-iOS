//
//  PARTheme.m
//  Pear
//
//  Created by Alex Ramey on 12/22/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARTheme.h"
#import "UIColor+Theme.h"

@implementation PARTheme

+(void)setupTheme
{
    UINavigationBar* t = [UINavigationBar appearance];
    t.barStyle = UIBarStyleDefault;
    
    //Set navigation bar's background color to theme blue and button tints to white
    t.barTintColor = [UIColor PARBlue];
    t.tintColor = [UIColor whiteColor];
    t.translucent = NO;
    
    //Sets navigation bar's title font and configures title shadow
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    t.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor] ,
                              NSShadowAttributeName : shadow,
                              NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:22.0] };
    
    //Configure Status Bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end
