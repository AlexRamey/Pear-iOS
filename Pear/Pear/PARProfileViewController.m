//
//  PARStatsViewController.m
//  Pear
//
//  Created by Alex Ramey on 12/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//
//NOTE: EVERYTHING THAT SAYS 30 Days Ago is Really 10 days ago due to line annotated below
#import "PARProfileViewController.h"
#import "UIColor+Theme.h"
#import "AppDelegate.h"
#import "PARTopMatchCell.h"
#import "PARProfileCollectionViewFlowLayout.h"
#import "PARMatchDetailsViewController.h"
#import "PARDataStore.h"

@interface PARProfileViewController ()

@end

@implementation PARProfileViewController

#define IS_IPHONE_4 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480) < DBL_EPSILON )

static NSString * const reuseIdentifier = @"TopMatchCell";

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        //custom initialization
        UIButton *aboutButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [aboutButton addTarget:self action:@selector(aboutSelected:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *aboutBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aboutButton];
        
        if (IS_IPHONE_4)
        {
            UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(facebookLogout:)];
            self.navigationItem.leftBarButtonItem = logout;
        }
        
        self.navigationItem.rightBarButtonItem = aboutBarButtonItem;
        
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
        _allTimeRanks = [[NSMutableArray alloc] init];
        _past30DayRanks = [[NSMutableArray alloc] init];
        _topMatchProfilePicViews = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_logoutBtn drawWithPrimaryColor:[UIColor PARBlue] secondaryColor:[UIColor PARBlue]];
    [_recentCommentsBtn drawWithPrimaryColor:[UIColor PARBlue] secondaryColor:[UIColor PARBlue]];
    [_recentCommentsBtn addTarget:self action:@selector(viewComments:) forControlEvents:UIControlEventTouchUpInside];
    
    [_topMatchesCollection registerClass:[PARTopMatchCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [_topMatchesCollection setBackgroundColor:[UIColor clearColor]];
    
    _segmentedControl.tintColor = [UIColor PARBlue];
    
    _profileCard.backgroundColor = [UIColor whiteColor];
    
    
    FBProfilePictureView *userProfilePicture = [[FBProfilePictureView alloc] initWithProfileID:[[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY]  pictureCropping:FBProfilePictureCroppingSquare];
    
    [_profilePicFillerView addSubview:userProfilePicture];
    
    [userProfilePicture setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_profilePicFillerView addConstraints:[NSLayoutConstraint
                                            constraintsWithVisualFormat:@"H:|-0-[userProfilePicture]-0-|"
                                            options:NSLayoutFormatDirectionLeadingToTrailing
                                            metrics:nil
                                            views:NSDictionaryOfVariableBindings(userProfilePicture)]];
    [_profilePicFillerView addConstraints:[NSLayoutConstraint
                                            constraintsWithVisualFormat:@"V:|-0-[userProfilePicture]-0-|"
                                            options:NSLayoutFormatDirectionLeadingToTrailing
                                            metrics:nil
                                            views:NSDictionaryOfVariableBindings(userProfilePicture)]];
}

-(void)viewWillAppear:(BOOL)animated
{
    PFQuery *allTimeQuery = [PFQuery queryWithClassName:@"Couples"];
    allTimeQuery.limit = 10;
    [allTimeQuery orderByDescending:@"Score"];
    
    PFQuery *past30DaysQuery = [PFQuery queryWithClassName:@"Couples"];
    past30DaysQuery.limit = 10;
    [past30DaysQuery orderByDescending:@"Score"];
    
    //NOTE: EVERYTHING THAT SAYS 30 Days Ago is Really 10 days ago due to following line
    double x = [NSDate date].timeIntervalSince1970 - 10*24*60*60;
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
             
             _allTimeRanks[0] = [NSNumber numberWithInt:1];
             
             
             NSNumber *tempScore = nil;
             
             if ([_topMatchesAllTime count] != 0)
             {
                 tempScore = [_topMatchesAllTime[0] objectForKey:@"Score"];
             }
             
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
             
             _past30DayRanks[0] = [NSNumber numberWithInt:1];
             
             NSNumber *tempScore = nil;
             
             if ([_topMatchesPast30Days count] != 0)
             {
                 tempScore = [_topMatchesPast30Days[0] objectForKey:@"Score"];
             }
             
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
    
    //update wishlist score
    
    _wishlistSwag.text = @"";
    
    PFQuery *query = [PFUser query];
    
    [query whereKey:@"WishlistFBIDs" containsAllObjectsInArray:@[[[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY]]];
    
    query.limit = 1000;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            NSUInteger wishesCount = [objects count];
            
            NSString *userName = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA_KEY] objectForKey:@"first_name"];
            
            NSString *oppositeGender = nil;
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:USER_GENDER_KEY] caseInsensitiveCompare:@"male"] == NSOrderedSame)
            {
                oppositeGender = @"girl";
            }
            else
            {
                oppositeGender = @"guy";
            }
            
            if (wishesCount != 1)
            {
                oppositeGender = [oppositeGender stringByAppendingString:@"s"];
            }
            
            UIFont *boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
            
            NSString *swagScoreText = [NSString stringWithFormat:@"%@, you are on the wishlist of %lu %@", userName, (unsigned long)wishesCount, oppositeGender];
            
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:swagScoreText];
            
            NSUInteger loc = [userName length] + 29;
            
            NSUInteger endLoc = [swagScoreText rangeOfString:@" " options:NSLiteralSearch range:NSMakeRange(loc, 5)].location;
            
            
            
            [attributedText setAttributes:@{
                                            NSFontAttributeName:boldFont
                                            }
                                    range:NSMakeRange(loc, endLoc - loc)];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.5 animations:^{
                    _wishlistSwag.attributedText = attributedText;
                }];
            });
        }
        else
        {
            //NSLog(@"ERROR: %@", error);
        }
    }];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self createDropShadow:_profileCard];
    
    if (IS_IPHONE_4)
    {
        [_logoutBtn removeFromSuperview];
        _cardHeight.constant = 120.0;
        _collectionViewBottomConstraint.constant = 0.0;
        
        [_wishlistSwag setNumberOfLines:2];
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)selectionMade:(id)sender
{
    [_topMatchesCollection reloadData];
}

-(IBAction)viewComments:(id)sender
{
    [self performSegueWithIdentifier:@"ProfileToComments" sender:self];
}

-(IBAction)aboutSelected:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *writeReview = [UIAlertAction actionWithTitle:@"Write a Review" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id957882121"];
        [[UIApplication sharedApplication] openURL:url];
    }];
    
    UIAlertAction *privacyPolicy = [UIAlertAction actionWithTitle:@"Privacy Policy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:@"http://thepeargame.com/privacy"];
        [[UIApplication sharedApplication] openURL:url];
    }];
    
    UIAlertAction *termsOfService = [UIAlertAction actionWithTitle:@"Terms of Service" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:@"http://www.thepeargame.com/terms"];
        [[UIApplication sharedApplication] openURL:url];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    [alert addAction:writeReview];
    [alert addAction:privacyPolicy];
    [alert addAction:termsOfService];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
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
    
    [cell setMatchName:matchName matchRank:matchRank];
    
    NSString *matchKey = [NSString stringWithFormat:@"%@%lu", matchID, (long)indexPath.row];
    
    if (![_topMatchProfilePicViews objectForKey:matchKey])
    {
        FBProfilePictureView *profilePic = [[FBProfilePictureView alloc] initWithProfileID:matchID pictureCropping:FBProfilePictureCroppingSquare];
        [_topMatchProfilePicViews setObject:profilePic forKey:matchKey];
    }
    
    [cell setPicture:_topMatchProfilePicViews[matchKey]];
    
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
    
    NSString *userGender = [[NSUserDefaults standardUserDefaults] objectForKey:USER_GENDER_KEY];
    
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
        [query whereKey:@"Male" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY]];
        [query whereKey:@"Female" equalTo: [dataSource[indexPath.row] objectForKey:@"Female"]];
    }
    else
    {
        [query whereKey:@"Female" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY]];
        [query whereKey:@"Male" equalTo:[dataSource[indexPath.row] objectForKey:@"Male"]];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         inProgress = NO;
         
         if (!error && [objects count] > 0)
         {
             couple = [objects firstObject];
             [self performSegueWithIdentifier:@"ProfileToMatchDetails" sender:self];
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to fetch match details." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alert show];
             couple = nil;
             
             [self performSegueWithIdentifier:@"ProfileToMatchDetails" sender:self];
         }
     }];
}

#pragma mark - FBLogout
-(IBAction)facebookLogout:(id)sender
{
    
    [[PARDataStore sharedStore] saveUserWithCompletion:^{
        
        //Logout
        [PFUser logOut];
        
        //Set _userObject to nil
        [PARDataStore sharedStore].userObject = nil;
        
        //Return to Login Screen
        [self.parentViewController.parentViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
