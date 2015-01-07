//
//  PARProfileCollectionViewFlowLayout.m
//  Pear
//
//  Created by Alex Ramey on 1/7/15.
//  Copyright (c) 2015 Pear. All rights reserved.
//

#import "PARProfileCollectionViewFlowLayout.h"

@implementation PARProfileCollectionViewFlowLayout

-(void)prepareLayout
{
    CGFloat itemWidth = (self.collectionView.frame.size.width - 15) / 2.0;
    CGFloat itemHeight = itemWidth;
    self.itemSize = CGSizeMake(itemWidth, itemHeight);
    self.minimumLineSpacing = 15;
    float horizontalInset = self.collectionView.center.x - (itemWidth / 2.0);
    float verticalInset = (self.collectionView.bounds.size.height - itemHeight) / 2.0;
    self.sectionInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
                                 withScrollingVelocity:(CGPoint)velocity
{
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat cvHalfWidth = (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    CGFloat horizontalCenter = proposedContentOffset.x + cvHalfWidth;
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x,
                                   0.0,
                                   self.collectionView.bounds.size.width,
                                   self.collectionView.bounds.size.height);
    
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes* layoutAttributes in array)
    {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment))
        {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    
    CGPoint p = CGPointMake(
                            MIN(self.collectionView.contentSize.width - self.collectionView.frame.size.width,
                                MAX(0, proposedContentOffset.x + offsetAdjustment)),
                            proposedContentOffset.y);
    
    return p;
}

@end
