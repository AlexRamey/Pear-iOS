//
//  PARGameResultsOverlayView.m
//  Pear
//
//  Created by Alex Ramey on 3/11/15.
//  Copyright (c) 2015 Pear. All rights reserved.
//

#import "PARGameResultsOverlayView.h"

@implementation PARGameResultsOverlayView

-(id)initForGivenScreenSize:(CGSize)screenSize voteType:(VoteType)voteType
{
    self = [super initForGivenScreenSize:screenSize voteType:voteType];
    
    [super.leftBarButton setImage:[UIImage imageNamed:@"addComment"] forState:UIControlStateNormal];
    [super.leftBarButton addTarget:self action:@selector(makeComment:) forControlEvents:UIControlEventTouchUpInside];
    
    [super.middleBarButton setImage:[UIImage imageNamed:@"pearButton"] forState:UIControlStateNormal];
    [super.middleBarButton addTarget:self action:@selector(makePear:) forControlEvents:UIControlEventTouchUpInside];
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
