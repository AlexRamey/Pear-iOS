//
//  PARCommunityMatchCell.h
//  Pear
//
//  Created by Alex Ramey on 1/8/15.
//  Copyright (c) 2015 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookSDK.h"
#import "PARButton.h"

@interface PARCommunityMatchCell : UICollectionViewCell
{
    UILabel *rank;
    UIView *malePictureFiller;
    UILabel *maleName;
    UIView *femalePictureFiller;
    UILabel *femaleName;
}

@property (nonatomic, strong) NSString *coupleObjectID;

-(void)setMaleName:(NSString *)maleName femaleName:(NSString *)femaleName matchRank:(int)rank;

-(void)setMalePicture:(FBProfilePictureView *)malePicture femalePicture:(FBProfilePictureView *)femalePicture;

@end
