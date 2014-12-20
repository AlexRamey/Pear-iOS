//
//  PARWishlistController.h
//  Pear
//
//  Created by Alex Ramey on 12/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse.h"

@interface PARWishlistController : UICollectionViewController <UICollectionViewDelegateFlowLayout>
{
    PFObject *couple;
    BOOL inProgress;
}

@property (nonatomic, strong) NSDictionary *wishList;
@property (nonatomic, strong) NSArray *sortedKeys;

@end
