//
//  PARWriteCommentCard.h
//  Pear
//
//  Created by Alex Ramey on 10/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WriteCommentCardCallback;

@interface PARWriteCommentCard : UIView <UITextViewDelegate>

@property (nonatomic, weak) id<WriteCommentCardCallback> callback;

@property (nonatomic, strong) IBOutlet UIView *profilePicFillerView;
@property (nonatomic, strong) IBOutlet UITextView *commentArea;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) NSString *coupleObjectID;
@property (nonatomic, strong) NSString *coupleMaleName;
@property (nonatomic, strong) NSString *coupleFemaleName;
@property (nonatomic, strong) NSString *coupleMaleID;
@property (nonatomic, strong) NSString *coupleFemaleID;

@property (nonatomic, strong) NSNumber *authorLiked;

@end

@protocol WriteCommentCardCallback <NSObject>

-(void)commentWasPushed;

@end