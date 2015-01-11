//
//  PARTabBarController.m
//  Pear
//
//  Created by Alex Ramey on 1/11/15.
//  Copyright (c) 2015 Pear. All rights reserved.
//

#import "PARTabBarController.h"

@implementation PARTabBarController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        codeIndex = 0;
        //0-1 10 times
        //0-2 5 times
        //0-3 5 times
        
        secretCode = @[@0, @1, @0, @1, @0, @1, @0, @1, @0, @1, @0, @1, @0, @1, @0, @1, @0, @1, @0, @1, @0, @2, @0, @2, @0, @2, @0, @2, @0, @2, @0, @3, @0, @3, @0, @3, @0, @3, @0, @3];
        self.delegate = self;
    }
    
    return self;
}

#pragma mark -UITabBarControllerDelegate methods

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.selectedIndex == [secretCode[codeIndex] intValue])
    {
        codeIndex++;
    }
    else
    {
        codeIndex = 0;
    }
    
    if (codeIndex == [secretCode count])
    {
        codeIndex = 0;
        UIAlertView *secret = [[UIAlertView alloc] initWithTitle:@"Easter Egg" message:@"Alex Ramey made this app." delegate:nil cancelButtonTitle:@"Roll Tide" otherButtonTitles: nil];
        [secret show];
    }
}

@end
