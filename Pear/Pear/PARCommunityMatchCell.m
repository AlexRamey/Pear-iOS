//
//  PARCommunityMatchCell.m
//  Pear
//
//  Created by Alex Ramey on 1/8/15.
//  Copyright (c) 2015 Pear. All rights reserved.
//

#import "PARCommunityMatchCell.h"
#import "UIColor+Theme.h"

@implementation PARCommunityMatchCell

-(id)initWithFrame:(CGRect)frame
{
    //Same calculations made by Flow Layout
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat cardWidth = screenWidth - 20.0;
    
    CGFloat profilePictureDimension = (cardWidth - 30.0) / 2.0;
    
    CGFloat cardHeight = 10.0 + profilePictureDimension + 13.0 + 10 + 20 + 10;
    
    self = [super initWithFrame:CGRectMake(0, 0, cardWidth, cardHeight)];
    
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        //Rank Label
        rank = [[UILabel alloc] initWithFrame:CGRectMake((cardWidth - 150)/2.0, 10 + profilePictureDimension + 16.0 + 10, 150, 20.0)];
        rank.backgroundColor = [UIColor clearColor];
        rank.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        rank.minimumScaleFactor = .75;
        rank.textAlignment = NSTextAlignmentCenter;
        rank.text = @"";
        
        //Male Picture Filler
        malePictureFiller = [[UIView alloc] initWithFrame:CGRectMake(10, 10, profilePictureDimension, profilePictureDimension)];
        
        //Female Picture Filler
        femalePictureFiller = [[UIView alloc] initWithFrame:CGRectMake(10 + profilePictureDimension + 10, 10, profilePictureDimension, profilePictureDimension)];
        
        //Male Name Label
        maleName = [[UILabel alloc] initWithFrame:CGRectMake(10, 10 + profilePictureDimension, profilePictureDimension, 16)];
        maleName.backgroundColor = [UIColor clearColor];
        maleName.textAlignment = NSTextAlignmentCenter;
        maleName.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        maleName.minimumScaleFactor = .75;
        maleName.text = @"";
        
        //Female Name Label
        femaleName = [[UILabel alloc] initWithFrame:CGRectMake(10 + profilePictureDimension + 10, 10 + profilePictureDimension, profilePictureDimension, 16)];
        femaleName.backgroundColor = [UIColor clearColor];
        femaleName.textAlignment = NSTextAlignmentCenter;
        femaleName.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        femaleName.minimumScaleFactor = .75;
        femaleName.text = @"";
        
        [self addSubview:malePictureFiller];
        [self addSubview:femalePictureFiller];
        [self addSubview:maleName];
        [self addSubview:femaleName];
        [self addSubview:detailsButton];
        [self addSubview:rank];
    }
    
    return self;
}

-(void)setMaleName:(NSString *)maleNameText femaleName:(NSString *)femaleNameText matchRank:(int)rankNumber
{
    maleName.text = maleNameText;
    femaleName.text = femaleNameText;
    rank.text = [NSString stringWithFormat:@"Rank: #%d", rankNumber];
}

-(void)setMalePicture:(FBProfilePictureView *)malePicture femalePicture:(FBProfilePictureView *)femalePicture
{
    //Remove old pictures
    for (UIView *view in malePictureFiller.subviews)
    {
        [view removeFromSuperview];
    }
    for (UIView *view in femalePictureFiller.subviews)
    {
        [view removeFromSuperview];
    }
    
    if ([malePicture superview]) //this malePicture already belongs to a view hierarchy
    {
        NSData *archivedViewData = [NSKeyedArchiver archivedDataWithRootObject:malePicture];
        UIView *clone = [NSKeyedUnarchiver unarchiveObjectWithData:archivedViewData];
        clone.frame = CGRectMake(0, 0, malePictureFiller.frame.size.width, malePictureFiller.frame.size.height);
        [malePictureFiller addSubview:clone];
    }
    else
    {
        malePicture.frame = CGRectMake(0, 0, malePictureFiller.frame.size.width, malePictureFiller.frame.size.height);
        [malePictureFiller addSubview:malePicture];
    }
    
    if ([femalePicture superview]) //this femalePicture already belongs to a view hierarchy
    {
        FBProfilePictureView *copyPic = [femalePicture copy];
        copyPic.frame = CGRectMake(0, 0, femalePictureFiller.frame.size.width, femalePictureFiller.frame.size.height);
        [femalePictureFiller addSubview:copyPic];
    }
    else
    {
        NSData *archivedViewData = [NSKeyedArchiver archivedDataWithRootObject:femalePicture];
        UIView *clone = [NSKeyedUnarchiver unarchiveObjectWithData:archivedViewData];
        clone.frame = CGRectMake(0, 0, femalePictureFiller.frame.size.width, femalePictureFiller.frame.size.height);
        [femalePictureFiller addSubview:clone];
    }
    
    
}

@end
