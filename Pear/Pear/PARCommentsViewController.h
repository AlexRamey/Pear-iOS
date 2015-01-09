//
//  PARCommentsViewController.h
//  Pear
//
//  Created by Alex Ramey on 1/8/15.
//  Copyright (c) 2015 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PARCommentCard.h"
#import "Parse.h"

@interface PARCommentsViewController : UIViewController <CommentCardCallback>
{
    PFObject *couple;
    BOOL inProgress;
    CGFloat yOffset;
}

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NSArray *comments;

@end
