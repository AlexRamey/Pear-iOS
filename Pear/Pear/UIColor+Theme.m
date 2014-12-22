//
//  UIColor+Theme.m
//  Pear
//
//  Created by Alex Ramey on 12/22/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "UIColor+Theme.h"

@implementation UIColor (Theme)

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

+(UIColor *)PARGreen
{
    return UIColorFromRGB(0x3abb2a);
}

+(UIColor *)PAROrange
{
    return UIColorFromRGB(0xf5662c);
}

+(UIColor *)PARBrown
{
    return UIColorFromRGB(0x774803);
}

+(UIColor *)PARBlue
{
    return UIColorFromRGB(0x3c5a99);
}

+(UIColor *)PARRed
{
    return UIColorFromRGB(0xe93a31);
}

@end