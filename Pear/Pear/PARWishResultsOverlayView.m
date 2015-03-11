//
//  PARWishResultsOverlayView.m
//  Pear
//
//  Created by Alex Ramey on 3/11/15.
//  Copyright (c) 2015 Pear. All rights reserved.
//

#import "PARWishResultsOverlayView.h"

@implementation PARWishResultsOverlayView

-(id)initForGivenScreenSize:(CGSize)screenSize voteType:(VoteType)voteType
{
    self = [super initForGivenScreenSize:screenSize voteType:voteType];
    
    [super.leftBarButton setImage:[UIImage imageNamed:@"removeWish"] forState:UIControlStateNormal];
    [super.leftBarButton setBackgroundColor:[UIColor whiteColor]];
    
    [super.middleBarButton.superview removeFromSuperview];
    
    return self;
}

- (void)setCallback:(id<OverlayCallback>)callback
{
    [super setCallback:callback];
    
    if ([callback respondsToSelector:@selector(removeWish:)])
    {
        [super.leftBarButton addTarget:callback action:@selector(removeWish:) forControlEvents:UIControlEventTouchUpInside];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
