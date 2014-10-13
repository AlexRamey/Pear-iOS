//
//  PARWriteCommentCard.h
//  Pear
//
//  Created by Alex Ramey on 10/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PARWriteCommentCard : UIView <UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *profilePicFillerView;

@property (nonatomic, strong) IBOutlet UITextView *commentArea;

@end
