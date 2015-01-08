//
//  PARCommunityCollectionViewFlowLayout.m
//  Pear
//
//  Created by Alex Ramey on 1/8/15.
//  Copyright (c) 2015 Pear. All rights reserved.
//

#import "PARCommunityCollectionViewFlowLayout.h"

@implementation PARCommunityCollectionViewFlowLayout

-(void)prepareLayout
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat cardWidth = screenWidth - 20.0;
    
    CGFloat profilePictureDimension = (cardWidth - 30.0) / 2.0;
    
    CGFloat cardHeight = 10.0 + profilePictureDimension + 13.0 + 10 + 20 + 10;
    
    self.itemSize = CGSizeMake(cardWidth, cardHeight);
    self.minimumLineSpacing = 10;
    self.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
}

@end
