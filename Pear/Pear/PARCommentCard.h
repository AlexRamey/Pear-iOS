//
//  PARCommentCard.h
//  Pear
//
//  Created by Alex Ramey on 10/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentCardCallback;

@interface PARCommentCard : UIView

-(id)initWithFacebookID:(NSString *)fbID name:(NSString *)name comment:(NSString *)comment callback:(id<CommentCardCallback>) callback;

@property (nonatomic, strong) IBOutlet UIView *profilePictureFillerView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *commentLabel;

@end

@protocol CommentCardCallback <NSObject>

-(void)commentCardCreatedWithHeight:(CGFloat)height;

@end


