//
//  PARWishlistController.m
//  Pear
//
//  Created by Alex Ramey on 12/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARWishlistController.h"
#import "PARWishlistCell.h"
#import "AppDelegate.h"
#import "PARWishStatsController.h"

@interface PARWishlistController ()

@end

@implementation PARWishlistController

static NSString * const reuseIdentifier = @"WishlistCell";

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        //custom initialization
        inProgress = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[PARWishlistCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _wishList = [[NSUserDefaults standardUserDefaults] objectForKey:WISHLIST_DEFAULTS_KEY];
    
    if (!_wishList)
    {
        _wishList = [[NSDictionary alloc] init];
    }
    
    _sortedKeys = [[_wishList allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *id1 = (NSString *)obj1;
        NSString *id2 = (NSString *)obj2;
        
        return [[_wishList objectForKey:id1] caseInsensitiveCompare:[_wishList objectForKey:id2]];
    }];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createDropShadow:(UIView *)view
{
    [view setNeedsLayout];
    [view layoutIfNeeded];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    view.layer.shadowOpacity = 0.5f;
    view.layer.shadowPath = shadowPath.CGPath;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_wishList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PARWishlistCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    [cell loadProfilePictureForFBID:[_sortedKeys objectAtIndex:indexPath.row] andWishName:[_wishList objectForKey:[_sortedKeys objectAtIndex:indexPath.row]]];
    
    [self createDropShadow:cell];
    
    return cell;
}

#pragma mark <UICollectionViewDelegateFlowLayout>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float dimension = ([UIScreen mainScreen].bounds.size.width - 31) / 2.0;
    
    return CGSizeMake(dimension, dimension);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20.0, 10.0, 20.0, 10.0);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 15.0;
}

#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (inProgress)
    {
        return;
    }
    
    inProgress = YES;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Couples"];
    query.limit = 1;
    
    NSString *userGender = [[NSUserDefaults standardUserDefaults] objectForKey:USER_GENDER_KEY];
    selectedWishID = [_sortedKeys objectAtIndex:indexPath.row];
    
    if ([userGender caseInsensitiveCompare:@"male"] == NSOrderedSame)
    {
        [query whereKey:@"Male" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY]];
        [query whereKey:@"Female" equalTo:selectedWishID];
    }
    else
    {
        [query whereKey:@"Female" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY]];
        [query whereKey:@"Male" equalTo:selectedWishID];
    }
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        inProgress = NO;
        
        if (!error && [objects count] > 0)
        {
            couple = [objects firstObject];
            [self performSegueWithIdentifier:@"WishlistToWishDetail" sender:self];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to fetch details." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            couple = nil;
            
            [self performSegueWithIdentifier:@"WishlistToWishDetail" sender:self];
        }
    }];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController class] == [PARWishStatsController class])
    {
        PARWishStatsController *vc = (PARWishStatsController *)segue.destinationViewController;
        [vc setSelectedWishID:selectedWishID];
        
        if (couple) //fetch succeeded
        {
            [vc setSelectedCoupleID:couple.objectId];
            
            [vc setMale:couple[@"Male"]];
            [vc setMaleName:couple[@"MaleName"]];
            
            [vc setFemale:couple[@"Female"]];
            [vc setFemaleName:couple[@"FemaleName"]];
            
            if ([couple[@"Upvotes"] isKindOfClass:[NSNumber class]])
            {
                [vc setUpvotes: couple[@"Upvotes"]];
            }
            else
            {
                [vc setUpvotes:[NSNumber numberWithInt:0]];
            }
            if ([couple[@"Downvotes"] isKindOfClass:[NSNumber class]])
            {
                [vc setDownvotes: couple[@"Downvotes"]];
            }
            else
            {
                [vc setDownvotes: [NSNumber numberWithInt:0]];
            }
        }
        else
        {
            [vc setSelectedCoupleID:@""];
            
            [vc setMale:nil];
            [vc setMaleName:@""];
            
            [vc setFemale:nil];
            [vc setFemaleName:@""];
            
            [vc setUpvotes: [NSNumber numberWithInt:0]];
            [vc setDownvotes: [NSNumber numberWithInt:0]];
        }
    }
}

@end
