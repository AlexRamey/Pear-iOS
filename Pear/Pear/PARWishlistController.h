//
//  PARWishlistController.h
//  Pear
//
//  Created by Alex Ramey on 12/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PARWishlistController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSDictionary *wishList;
@property (nonatomic, strong) NSArray *sortedKeys;

@end
