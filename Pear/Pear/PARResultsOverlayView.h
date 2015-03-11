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

@property (nonatomic, strong) NSString *maleID;
@property (nonatomic, strong) NSString *femaleID;
@property (nonatomic, strong) NSString *maleNameText;
@property (nonatomic, strong) NSString *femaleNameText;
@property (nonatomic, strong) NSString *coupleObjectID;
@property (nonatomic, strong) NSNumber *authorLiked;

- (id)initForGivenScreenSize:(CGSize)screenSize voteType:(BOOL)yesVote;

- (void)loadImagesForMale:(NSString *)maleID female:(NSString *)femaleID;

- (void)setMaleNameText:(NSString *)maleName femaleNameText:(NSString *)femaleName;

- (void)setQuoteTextForPercent:(CGFloat)percent;

- (void)flyInAnimatingUpToPercent:(CGFloat)percent;

- (void)setCallback:(PARGameViewController *)callback;

@end
