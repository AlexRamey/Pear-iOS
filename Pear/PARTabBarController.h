//
//  PARTabBarController.h
//  Pear
//
//  Created by Alex Ramey on 1/11/15.
//  Copyright (c) 2015 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PARTabBarController : UITabBarController <UITabBarControllerDelegate>
{
    NSArray *secretCode;
    int codeIndex;
}

@end
