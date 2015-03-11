//
//  PARNewCommentCard.h
//  Pear
//
//  Created by Alex Ramey on 3/11/15.
//  Copyright (c) 2015 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PARNewCommentCard : UIView

- (id)initWithFrame:(CGRect)frame atIndex:(int)index withAuthorName:(NSString *)authorName commentText:(NSString *)commentText;

@end
