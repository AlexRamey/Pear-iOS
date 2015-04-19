//
//  PARTopMatchCell.h
//  Pear
//
//  Created by Alex Ramey on 12/27/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface PARTopMatchCell : UICollectionViewCell

-(void)setMatchName:(NSString *)matchName matchRank:(int)rank;

-(void)setPicture:(FBSDKProfilePictureView *)profilePic;

@end
