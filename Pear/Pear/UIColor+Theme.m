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
    return UIColorFromRGB(0x32CD32);
}

+(UIColor *)PARDarkGreen
{
    return UIColorFromRGB(0x228B22);
    //return UIColorFromRGB(0xc7e5ba);
}

+(UIColor *)PAROrange
{
    return UIColorFromRGB(0xf79f05); //theme orange
}

+(UIColor *)PARDarkOrange
{
    return UIColorFromRGB(0xf5662c); //random orange
}

+(UIColor *)PARBrown
{
    return UIColorFromRGB(0x774803);
}

+(UIColor *)PARBlue
{
    return UIColorFromRGB(0x3c5b99);
}

+(UIColor *)PARRed
{
    return UIColorFromRGB(0xe93a31);
}

+(UIColor *)PARDarkRed
{
    return UIColorFromRGB(0xda2c43);
    //return UIColorFromRGB(0xf5b8ad);
}

@end
