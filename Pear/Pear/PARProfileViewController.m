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
        
        _topMatchesAllTime = [[NSMutableArray alloc] init];
        _topMatchesPast30Days = [[NSMutableArray alloc] init];
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
    PFQuery *allTimeQuery = [PFQuery queryWithClassName:@"Couples"];
    allTimeQuery.limit = 10;
    [allTimeQuery orderByDescending:@"Score"];
    
    PFQuery *past30DaysQuery = [PFQuery queryWithClassName:@"Couples"];
    past30DaysQuery.limit = 10;
    [past30DaysQuery orderByDescending:@"Score"];
    
    //double x = [NSDate date].timeIntervalSince1970 - 30*24*60*60;
    double x = [NSDate date].timeIntervalSince1970 - 1*24*60*60;
    NSDate *thirtyDaysAgo = [NSDate dateWithTimeIntervalSince1970:x];
    
    [past30DaysQuery whereKey:@"createdAt" greaterThan:thirtyDaysAgo];
    
    NSString *userGender = [[NSUserDefaults standardUserDefaults] objectForKey:USER_GENDER_KEY];
    
    if ([userGender caseInsensitiveCompare:@"male"] == NSOrderedSame)
    {
        [allTimeQuery whereKey:@"Male" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY]];
        [past30DaysQuery whereKey:@"Male" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY]];
    }
    else
    {
        [allTimeQuery whereKey:@"Female" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY]];
        [past30DaysQuery whereKey:@"Female" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY]];
    }
    
    [allTimeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             _topMatchesAllTime = [objects mutableCopy];
             
             [_topMatchesAllTime sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                 PFObject *matchOne = (PFObject *)obj1;
                 PFObject *matchTwo = (PFObject *)obj2;
                 
                 int scoreOne = [[matchOne objectForKey:@"Score"] intValue];
                 int scoreTwo = [[matchTwo objectForKey:@"Score"] intValue];
                 
                 if (scoreOne > scoreTwo)
                 {
                     return NSOrderedAscending;
                 }
                 else if (scoreTwo > scoreOne)
                 {
                     return NSOrderedDescending;
                 }
                 else
                 {
                     NSString *matchNameOne = nil;
                     NSString *matchNameTwo = nil;
                     
                     NSString *userGenderValue = [[NSUserDefaults standardUserDefaults] objectForKey:USER_GENDER_KEY];
                     
                     if ([userGenderValue caseInsensitiveCompare:@"male"] == NSOrderedSame)
                     {
                         matchNameOne = [matchOne objectForKey:@"FemaleName"];
                         matchNameTwo = [matchTwo objectForKey:@"FemaleName"];
                     }
                     else
                     {
                         matchNameOne = [matchOne objectForKey:@"MaleName"];
                         matchNameTwo = [matchTwo objectForKey:@"MaleName"];
                     }
                     
                     return [matchNameOne compare:matchNameTwo];
                 }
             }];
             
             if (_segmentedControl.selectedSegmentIndex == 0)
             {
                 [_topMatchesCollection reloadData];
             }
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to fetch your all-time top matches." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alert show];
         }
     }];
    
    [past30DaysQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             _topMatchesPast30Days = [objects mutableCopy];
             
             [_topMatchesPast30Days sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                 
                 PFObject *matchOne = (PFObject *)obj1;
                 PFObject *matchTwo = (PFObject *)obj2;
                 
                 int scoreOne = [[matchOne objectForKey:@"Score"] intValue];
                 int scoreTwo = [[matchTwo objectForKey:@"Score"] intValue];
                 
                 if (scoreOne > scoreTwo)
                 {
                     return NSOrderedAscending;
                 }
                 else if (scoreTwo > scoreOne)
                 {
                     return NSOrderedDescending;
                 }
                 else
                 {
                     NSString *matchNameOne = nil;
                     NSString *matchNameTwo = nil;
                     
                     NSString *userGenderValue = [[NSUserDefaults standardUserDefaults] objectForKey:USER_GENDER_KEY];
                     
                     if ([userGenderValue caseInsensitiveCompare:@"male"] == NSOrderedSame)
                     {
                         matchNameOne = [matchOne objectForKey:@"FemaleName"];
                         matchNameTwo = [matchTwo objectForKey:@"FemaleName"];
                     }
                     else
                     {
                         matchNameOne = [matchOne objectForKey:@"MaleName"];
                         matchNameTwo = [matchTwo objectForKey:@"MaleName"];
                     }
                     
                     return [matchNameOne compare:matchNameTwo];
                 }
                 
             }];
             
             if (_segmentedControl.selectedSegmentIndex == 1)
             {
                 [_topMatchesCollection reloadData];
             }
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to fetch your top matches made in the past 30 days." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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

-(IBAction)selectionMade:(id)sender
{
    [_topMatchesCollection reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_segmentedControl.selectedSegmentIndex == 0)
    {
        return [_topMatchesAllTime count];
    }
    else
    {
        return [_topMatchesPast30Days count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PARTopMatchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    NSString *userGender = [[NSUserDefaults standardUserDefaults] objectForKey:USER_GENDER_KEY];
    NSString *matchID = nil;
    NSString *matchName = nil;
    
    NSArray *dataSource = nil;
    
    if (_segmentedControl.selectedSegmentIndex == 0)
    {
        dataSource = _topMatchesAllTime;
    }
    else
    {
        dataSource = _topMatchesPast30Days;
    }
    
    if ([userGender caseInsensitiveCompare:@"male"] == NSOrderedSame)
    {
        matchID = [dataSource[indexPath.row] objectForKey:@"Female"];
        matchName = [dataSource[indexPath.row] objectForKey:@"FemaleName"];
    }
    else
    {
        matchID = [dataSource[indexPath.row] objectForKey:@"Male"];
        matchName = [dataSource[indexPath.row] objectForKey:@"MaleName"];
    }
    
    [cell setMatchName:matchName matchRank:(int)indexPath.row + 1];
    
    if (![_topMatchProfilePicViews objectForKey:matchID])
    {
        FBProfilePictureView *profilePic = [[FBProfilePictureView alloc] initWithProfileID:matchID pictureCropping:FBProfilePictureCroppingSquare];
        [_topMatchProfilePicViews setObject:profilePic forKey:matchID];
    }
    
    [cell setPicture:_topMatchProfilePicViews[matchID]];
    
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
