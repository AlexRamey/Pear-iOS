//
//  PARStatsViewController.m
//  Pear
//
//  Created by Alex Ramey on 12/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARProfileViewController.h"
#import "UIColor+Theme.h"
#import "Parse.h"
#import "AppDelegate.h"
#import "PARTopMatchCell.h"

@interface PARProfileViewController ()

@end

@implementation PARProfileViewController

static NSString * const reuseIdentifier = @"TopMatchCell";

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        //custom initialization
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:USER_GENDER_KEY] caseInsensitiveCompare:@"male"] == NSOrderedSame)
        {
            self.navigationController.tabBarItem.image = [UIImage imageNamed:@"profileTabMale"];
        }
        else
        {
            self.navigationController.tabBarItem.image = [UIImage imageNamed:@"profileTabFemale"];
        }
        self.navigationController.tabBarItem.title = @"Profile";
        
        inProgress = NO;
        
        _topMatches = [[NSArray alloc] init];
        _topMatchProfilePicViews = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_logoutBtn drawWithPrimaryColor:[UIColor PARBlue] secondaryColor:[UIColor PARBlue]];
    
    [_topMatchesCollection registerClass:[PARTopMatchCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [_topMatchesCollection setBackgroundColor:[UIColor clearColor]];
}

-(void)viewWillAppear:(BOOL)animated
{
    PFQuery *query = [PFQuery queryWithClassName:@"Couples"];
    query.limit = 5;
    
    NSString *userGender = [[NSUserDefaults standardUserDefaults] objectForKey:USER_GENDER_KEY];
    
    if ([userGender caseInsensitiveCompare:@"male"] == NSOrderedSame)
    {
        [query whereKey:@"Male" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY]];
    }
    else
    {
        [query whereKey:@"Female" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY]];
    }
    
    [query orderByDescending:@"Score"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             _topMatches = objects;
             [_topMatchesCollection reloadData];
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to fetch top matches." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alert show];
         }
     }];
}

-(void)createDropShadow:(UIView *)view
{
    [view setNeedsLayout];
    [view layoutIfNeeded];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
    view.layer.shadowOpacity = 0.5f;
    view.layer.shadowPath = shadowPath.CGPath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_topMatches count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PARTopMatchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    NSString *userGender = [[NSUserDefaults standardUserDefaults] objectForKey:USER_GENDER_KEY];
    NSString *matchID = nil;
    NSString *matchName = nil;
    
    if ([userGender caseInsensitiveCompare:@"male"] == NSOrderedSame)
    {
        matchID = [_topMatches[indexPath.row] objectForKey:@"Female"];
        matchName = [_topMatches[indexPath.row] objectForKey:@"FemaleName"];
    }
    else
    {
        matchID = [_topMatches[indexPath.row] objectForKey:@"Male"];
        matchName = [_topMatches[indexPath.row] objectForKey:@"MaleName"];
    }
    
    [cell setMatchName:matchName matchRank:(int)indexPath.row + 1];
    
    NSString *key = [NSString stringWithFormat:@"TMPic%d", (int)indexPath.row];
    if (![_topMatchProfilePicViews objectForKey:key])
    {
        FBProfilePictureView *profilePic = [[FBProfilePictureView alloc] initWithProfileID:matchID pictureCropping:FBProfilePictureCroppingSquare];
        [_topMatchProfilePicViews setObject:profilePic forKey:key];
    }
    
    [cell setPicture:_topMatchProfilePicViews[key]];
    
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
    return UIEdgeInsetsMake(5.0, 10.0, 5.0, 10.0);
}

#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (inProgress)
    {
        return;
    }
    
    inProgress = YES;
    inProgress = NO;
    /*
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
     */
    
}

#pragma mark - FBLogout
-(IBAction)facebookLogout:(id)sender
{
    [PFUser logOut]; // Log out
    
    [self.parentViewController.parentViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
