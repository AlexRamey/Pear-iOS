//
//  PARCommunityViewController.m
//  Pear
//
//  Created by Alex Ramey on 12/27/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARCommunityViewController.h"
#import "PARCommunityMatchCell.h"
#import "UIColor+Theme.h"
#import "PARDataStore.h"
#import "AppDelegate.h"
#import "PARMatchDetailsViewController.h"

@interface PARCommunityViewController ()

@end

@implementation PARCommunityViewController

static NSString * const reuseIdentifier = @"TopCommunityMatchCell";

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        inProgress = NO;
        
        _topMatchesAllTime = [[NSMutableArray alloc] init];
        _topMatchesPast30Days = [[NSMutableArray alloc] init];
        _allTimeRanks = [[NSMutableArray alloc] init];
        _past30DayRanks = [[NSMutableArray alloc] init];
        _topMatchProfilePicViews = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_topMatchesCollection registerClass:[PARCommunityMatchCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [_topMatchesCollection setBackgroundColor:[UIColor clearColor]];
    
    _segmentedControl.tintColor = [UIColor PARBlue];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSArray *femaleFriendIDs = [[PARDataStore sharedStore] femaleFriendIDs];
    NSArray *maleFriendIDs = [[PARDataStore sharedStore] maleFriendIDs];
    NSArray *myFBID = @[[[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY]];
    
    NSArray *allKnownIDS = [[femaleFriendIDs arrayByAddingObjectsFromArray:maleFriendIDs] arrayByAddingObjectsFromArray:myFBID];
    
    PFQuery *allTimeQuery = [PFQuery queryWithClassName:@"Couples"];
    allTimeQuery.limit = 25;
    [allTimeQuery orderByDescending:@"Score"];
    [allTimeQuery whereKey:@"Male" containedIn:allKnownIDS];
    [allTimeQuery whereKey:@"Female" containedIn:allKnownIDS];
    
    PFQuery *past30DaysQuery = [PFQuery queryWithClassName:@"Couples"];
    past30DaysQuery.limit = 25;
    [past30DaysQuery orderByDescending:@"Score"];
    [past30DaysQuery whereKey:@"Male" containedIn:allKnownIDS];
    [past30DaysQuery whereKey:@"Female" containedIn:allKnownIDS];
    
    double x = [NSDate date].timeIntervalSince1970 - 30*24*60*60;
    //double x = [NSDate date].timeIntervalSince1970 - 1*24*60*60;
    NSDate *thirtyDaysAgo = [NSDate dateWithTimeIntervalSince1970:x];
    
    [past30DaysQuery whereKey:@"createdAt" greaterThan:thirtyDaysAgo];
    
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
                     //sort alphabetically based on maleNames
                     NSString *matchNameOne = [matchOne objectForKey:@"MaleName"];
                     NSString *matchNameTwo = [matchTwo objectForKey:@"MaleName"];
                     
                     return [matchNameOne compare:matchNameTwo];
                 }
             }];
             
             _allTimeRanks[0] = [NSNumber numberWithInt:1];
             
             NSNumber *tempScore = [_topMatchesAllTime[0] objectForKey:@"Score"];
             
             int offset = 1;
             
             for (int i = 1; i < [_topMatchesAllTime count]; i++)
             {
                 PFObject *match = _topMatchesAllTime[i];
                 
                 if ([[match objectForKey:@"Score"] doubleValue] < [tempScore doubleValue])
                 {
                     _allTimeRanks[i] = [NSNumber numberWithInt:[_allTimeRanks[i - 1] intValue] + offset];
                     offset = 1;
                 }
                 else //same score as previous match, therefore same rank
                 {
                     _allTimeRanks[i] = _allTimeRanks[i-1];
                     offset += 1;
                 }
                 
                 tempScore = [match objectForKey:@"Score"];
             }
             
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
                     //sort alphabetically based on maleNames
                     NSString *matchNameOne = [matchOne objectForKey:@"MaleName"];
                     NSString *matchNameTwo = [matchTwo objectForKey:@"MaleName"];
                     
                     return [matchNameOne compare:matchNameTwo];
                 }
                 
             }];
             
             _past30DayRanks[0] = [NSNumber numberWithInt:1];
             
             NSNumber *tempScore = [_topMatchesPast30Days[0] objectForKey:@"Score"];
             
             int offset = 1;
             
             for (int i = 1; i < [_topMatchesPast30Days count]; i++)
             {
                 PFObject *match = _topMatchesPast30Days[i];
                 
                 if ([[match objectForKey:@"Score"] doubleValue] < [tempScore doubleValue])
                 {
                     _past30DayRanks[i] = [NSNumber numberWithInt:[_past30DayRanks[i - 1] intValue] + offset];
                     offset = 1;
                 }
                 else //same score as previous match, therefore same rank
                 {
                     _past30DayRanks[i] = _past30DayRanks[i-1];
                     offset += 1;
                 }
                 
                 tempScore = [match objectForKey:@"Score"];
             }
             
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PARCommunityMatchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    NSArray *dataSource = nil;
    
    int matchRank = -1;
    
    if (_segmentedControl.selectedSegmentIndex == 0)
    {
        dataSource = _topMatchesAllTime;
        matchRank = [_allTimeRanks[indexPath.row] intValue];
    }
    else
    {
        dataSource = _topMatchesPast30Days;
        matchRank = [_past30DayRanks[indexPath.row] intValue];
    }
    
    NSString *femaleID = [dataSource[indexPath.row] objectForKey:@"Female"];
    NSString *femaleName = [dataSource[indexPath.row] objectForKey:@"FemaleName"];
    
    NSString *maleID = [dataSource[indexPath.row] objectForKey:@"Male"];
    NSString *maleName = [dataSource[indexPath.row] objectForKey:@"MaleName"];
    
    [cell setMaleName:maleName femaleName:femaleName matchRank:matchRank];
    
    
    if (![_topMatchProfilePicViews objectForKey:femaleID])
    {
        FBProfilePictureView *profilePic = [[FBProfilePictureView alloc] initWithProfileID:femaleID pictureCropping:FBProfilePictureCroppingSquare];
        [_topMatchProfilePicViews setObject:profilePic forKey:femaleID];
    }
    if (![_topMatchProfilePicViews objectForKey:maleID])
    {
        FBProfilePictureView *profilePic = [[FBProfilePictureView alloc] initWithProfileID:maleID pictureCropping:FBProfilePictureCroppingSquare];
        [_topMatchProfilePicViews setObject:profilePic forKey:maleID];
    }
    
    [cell setMalePicture:[_topMatchProfilePicViews objectForKey:maleID] femalePicture:[_topMatchProfilePicViews objectForKey:femaleID]];
    
    [self createDropShadow:cell];
    
    return cell;
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
    
    NSArray *dataSource = nil;
    
    if (_segmentedControl.selectedSegmentIndex == 0)
    {
        dataSource = _topMatchesAllTime;
    }
    else
    {
        dataSource = _topMatchesPast30Days;
    }
    
    [query whereKey:@"Female" equalTo: [dataSource[indexPath.row] objectForKey:@"Female"]];
    [query whereKey:@"Male" equalTo:[dataSource[indexPath.row] objectForKey:@"Male"]];
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         inProgress = NO;
         
         if (!error && [objects count] > 0)
         {
             couple = [objects firstObject];
             [self performSegueWithIdentifier:@"CommunityToMatchDetails" sender:self];
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to fetch match details." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alert show];
             couple = nil;
             
             [self performSegueWithIdentifier:@"CommunityToMatchDetails" sender:self];
         }
     }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController class] == [PARMatchDetailsViewController class])
    {
        PARMatchDetailsViewController *vc = (PARMatchDetailsViewController *)segue.destinationViewController;
        
        if (couple)
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
