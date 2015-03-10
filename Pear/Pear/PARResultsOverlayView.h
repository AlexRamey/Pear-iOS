//
//  PARResultsOverlayView.h
//  Pear
//
//  Created by Alex Ramey on 3/10/15.
//  Copyright (c) 2015 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PARGameViewController;
@interface PARResultsOverlayView : UIView

- (id)initForGivenScreenSize:(CGSize)screenSize voteType:(BOOL)yesVote;

- (void)loadImagesForMale:(NSString *)maleID female:(NSString *)femaleID;

- (void)setMaleNameText:(NSString *)maleName femaleNameText:(NSString *)femaleName;

- (void)flyInAnimatingUpToPercent:(CGFloat)percent;

- (void)setCallback:(PARGameViewController *)callback;

@end
