//
//  PARResultsOverlayView.h
//  Pear
//
//  Created by Alex Ramey on 3/10/15.
//  Copyright (c) 2015 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PARGameViewController;
@protocol OverlayCallback;

typedef NS_ENUM(NSInteger, VoteType) {
    PARNoVote,
    PARPositiveVote,
    PARNegativeVote
};

@interface PARResultsOverlayView : UIView

//Buttons
@property (nonatomic, strong) UIButton *leftBarButton;
@property (nonatomic, strong) UIButton *middleBarButton;

//Data
@property (nonatomic, strong) NSString *maleID;
@property (nonatomic, strong) NSString *femaleID;
@property (nonatomic, strong) UIImage *maleProfileImage;
@property (nonatomic, strong) UIImage *femaleProfileImage;
@property (nonatomic, strong) NSString *maleNameText;
@property (nonatomic, strong) NSString *femaleNameText;
@property (nonatomic, strong) NSString *coupleObjectID;
@property (nonatomic, strong) NSNumber *authorLiked;

- (id)initForGivenScreenSize:(CGSize)screenSize voteType:(VoteType)voteType;

- (void)loadImagesForMale:(NSString *)maleID female:(NSString *)femaleID;

- (void)setMaleNameText:(NSString *)maleName femaleNameText:(NSString *)femaleName;

- (void)setQuoteTextForUpvotes:(int)upvotes downvotes:(int)downvotes;

- (void)flyInAnimatingUpToPercent:(CGFloat)percent;

- (void)setCallback:(id<OverlayCallback>)callback;

-(IBAction)makeComment:(id)sender;

-(IBAction)makePear:(id)sender;

@end

@protocol OverlayCallback <NSObject>

-(IBAction)dismissOverlay:(id)sender;

@optional

-(IBAction)removeWish:(id)sender;

@end