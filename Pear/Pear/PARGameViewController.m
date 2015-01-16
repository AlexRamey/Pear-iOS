//
//  PARPearGameViewController.m
//  Pear
//
//  Created by Alex Ramey on 10/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARGameViewController.h"
#import "PARGameResultsViewController.h"
#import "PARDataStore.h"
#import "AppDelegate.h"
#import "FacebookSDK.h"
#import "AppDelegate.h"
#import "UIColor+Theme.h"

@interface PARGameViewController ()

@end

@implementation PARGameViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        retryCounter = 0;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    self.view.backgroundColor = [UIColor whiteColor];
    
    maleView = [[FBProfilePictureView alloc] init];
    femaleView = [[FBProfilePictureView alloc] init];
    
    [_maleProfileFillerView addSubview:maleView];
    [_femaleProfileFillerView addSubview:femaleView];
    
    [maleView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_maleProfileFillerView addConstraints:[NSLayoutConstraint
                                            constraintsWithVisualFormat:@"H:|-0-[maleView]-0-|"
                                            options:NSLayoutFormatDirectionLeadingToTrailing
                                            metrics:nil
                                            views:NSDictionaryOfVariableBindings(maleView)]];
    [_maleProfileFillerView addConstraints:[NSLayoutConstraint
                                            constraintsWithVisualFormat:@"V:|-0-[maleView]-0-|"
                                            options:NSLayoutFormatDirectionLeadingToTrailing
                                            metrics:nil
                                            views:NSDictionaryOfVariableBindings(maleView)]];
    
    [femaleView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_femaleProfileFillerView addConstraints:[NSLayoutConstraint
                                            constraintsWithVisualFormat:@"H:|-0-[femaleView]-0-|"
                                            options:NSLayoutFormatDirectionLeadingToTrailing
                                            metrics:nil
                                            views:NSDictionaryOfVariableBindings(femaleView)]];
    [_femaleProfileFillerView addConstraints:[NSLayoutConstraint
                                            constraintsWithVisualFormat:@"V:|-0-[femaleView]-0-|"
                                            options:NSLayoutFormatDirectionLeadingToTrailing
                                            metrics:nil
                                            views:NSDictionaryOfVariableBindings(femaleView)]];
    
    [_upSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [_downSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self createDropShadow:_maleShadowView];
    [self createDropShadow:_femaleShadowView];
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
    [self.view sendSubviewToBack:view];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Reset UI
    NSArray *subviews = [maleView subviews];
    for (int i = 0; i < [subviews count]; i++)
    {
        if ([[subviews objectAtIndex:i] class] == [UIImageView class])
        {
            UIImageView *maleProfileImageView = (UIImageView *)[subviews objectAtIndex:i];
            maleProfileImageView.image = nil;
        }
    }
    subviews = [femaleView subviews];
    for (int i = 0; i < [subviews count]; i++)
    {
        if ([[subviews objectAtIndex:i] class] == [UIImageView class])
        {
            UIImageView *femaleProfileImageView = (UIImageView *)[subviews objectAtIndex:i];
            femaleProfileImageView.image = nil;
        }
    }
    
    maleView.profileID = nil;
    femaleView.profileID = nil;
    
    _maleName.text = @"";
    _femaleName.text = @"";
    
    
    //Get Next Couple
    NSDictionary *coupleToVoteOn = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:NEXT_COUPLE_TO_VOTE_ON_KEY]];
    
    NSString *error = [coupleToVoteOn objectForKey:@"Error"];
    
    if (error)
    {
        //disable UI
        _upSwipeRecognizer.enabled = NO;
        _downSwipeRecognizer.enabled = NO;
        _upVote.enabled = NO;
        _downVote.enabled = NO;
        
        if ([error caseInsensitiveCompare:NO_MORE_COUPLES_DOMAIN] == NSOrderedSame)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No More Couples" message:@"You've voted on all possible couples." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        else // error --> NETWORK_ERROR_DOMAIN --> Try again (once)
        {
            if (retryCounter++ == 0)
            {
                //NSLog(@"Retry Initiated!");
                [[PARDataStore sharedStore] nextCoupleWithCompletion:^(NSError *error) {
                    [self viewWillAppear:animated];
                }];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Networking Problems. Try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }
        return;
    }
    
    retryCounter = 0;
    _upSwipeRecognizer.enabled = YES;
    _downSwipeRecognizer.enabled = YES;
    _upVote.enabled = YES;
    _downVote.enabled = YES;
    
    objectId = [coupleToVoteOn objectForKey:@"ObjectId"];
    
    maleId = [coupleToVoteOn objectForKey:@"Male"];
    femaleId = [coupleToVoteOn objectForKey:@"Female"];
    mName = [coupleToVoteOn objectForKey:@"MaleName"];
    fName = [coupleToVoteOn objectForKey:@"FemaleName"];
     
    if ([[coupleToVoteOn objectForKey:@"Upvotes"] isKindOfClass:[NSNumber class]])
    {
        upVotes = [[coupleToVoteOn objectForKey:@"Upvotes"] intValue];
    }
    else
    {
        upVotes = 0;
    }
    
    if ([[coupleToVoteOn objectForKey:@"Downvotes"] isKindOfClass:[NSNumber class]])
    {
        downVotes = [[coupleToVoteOn objectForKey:@"Downvotes"] intValue];
    }
    else
    {
        downVotes = 0;
    }
    
    maleView.profileID = maleId;
    femaleView.profileID = femaleId;
    
    _maleName.text = mName;
    _femaleName.text = fName;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSNumber *firstLaunch = [[NSUserDefaults standardUserDefaults] objectForKey:PAR_IS_FIRST_LAUNCH_GAME_KEY];
    
    if ([firstLaunch boolValue])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:PAR_IS_FIRST_LAUNCH_GAME_KEY];
        
        UIAlertView *hint = [[UIAlertView alloc] initWithTitle:@"HINT" message:@"Use the buttons or swipe up or down to cast your vote!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [hint show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)voteCast:(id)sender
{
    UIButton *voteBtn = nil;
    UISwipeGestureRecognizer *gestureRecognizer = nil;
    
    if ([sender class] == [UIButton class])
    {
        voteBtn = (UIButton *)sender;
    }
    else
    {
        gestureRecognizer = (UISwipeGestureRecognizer *)sender;
    }
    
    _upSwipeRecognizer.enabled = NO;
    _downSwipeRecognizer.enabled = NO;
    _upVote.enabled = NO;
    _downVote.enabled = NO;
    
    void (^nextCoupleBlock)(NSError *) = ^void(NSError *e){
        //Load the next couple
        PARDataStore *sharedStore = [PARDataStore sharedStore];
        [sharedStore nextCoupleWithCompletion:^(NSError *e) {
            //puts the next couple into the defaults . . .
            
            //if (e) it means network error
            //either way (network or no more couples), error will be stored in Defaults and caught by this view controller when it tries to load the next couple in viewWillAppear
            [self performSegueWithIdentifier:@"GameToResults" sender:self];
        }];
    };
    
    PFQuery *query = [PFQuery queryWithClassName:@"Couples"];
    PARDataStore *sharedStore = [PARDataStore sharedStore];
    NSDictionary *coupleJustVotedOn = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:NEXT_COUPLE_TO_VOTE_ON_KEY]];
    
    if ((voteBtn && voteBtn.frame.origin.x == _downVote.frame.origin.x) || (gestureRecognizer && gestureRecognizer.direction == UISwipeGestureRecognizerDirectionDown))
    {
        // downvote behavior
        userVote = -1;
        
        [UIView animateWithDuration:0.5 animations:^{
            self.view.backgroundColor = [UIColor PARDarkRed];
        }];
        [UIView animateWithDuration:0.5 animations:^{
            self.view.backgroundColor = [UIColor whiteColor];
        }];
        
        [query getObjectInBackgroundWithId:objectId block:^(PFObject *couple, NSError *error) {
            if (!error)
            {
                if ([couple[@"Downvotes"] isKindOfClass:[NSNumber class]])
                {
                    [couple incrementKey:@"Downvotes"];
                }
                else
                {
                    couple[@"Downvotes"] = [NSNumber numberWithInt:1];
                }
                
                if (![couple[@"Upvotes"] isKindOfClass:[NSNumber class]])
                {
                    couple[@"Upvotes"] = [NSNumber numberWithInt:0];
                }
                
                upVotes = [couple[@"Upvotes"] intValue];
                downVotes = [couple[@"Downvotes"] intValue];
                
                double uVotes = [couple[@"Upvotes"] doubleValue];
                double dVotes = [couple[@"Downvotes"] doubleValue];
                couple[@"Score"] = [self computeScoreFromUpvotes:uVotes andDownvotes:dVotes];
                
                [couple saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    //notify store
                    [sharedStore saveCoupleVote:coupleJustVotedOn withStatus:NO completion:nextCoupleBlock];
                }];
            }
            else //user vote is lost
            {
                //notify store
                [sharedStore saveCoupleVote:coupleJustVotedOn withStatus:NO completion:nextCoupleBlock];
            }
        }];
    }
    else
    {
        //upvote behavior
        userVote = 1;
        
        [UIView animateWithDuration:0.5 animations:^{
            self.view.backgroundColor = [UIColor PARGreen];
        }];
        [UIView animateWithDuration:0.5 animations:^{
            self.view.backgroundColor = [UIColor whiteColor];
        }];
        
         
        [query getObjectInBackgroundWithId:objectId block:^(PFObject *couple, NSError *error) {
            if (!error)
            {
                if ([couple[@"Upvotes"] isKindOfClass:[NSNumber class]])
                {
                    [couple incrementKey:@"Upvotes"];
                }
                else
                {
                    couple[@"Upvotes"] = [NSNumber numberWithInt:1];
                }
                
                if (![couple[@"Downvotes"] isKindOfClass:[NSNumber class]])
                {
                    couple[@"Downvotes"] = [NSNumber numberWithInt:0];
                }
                
                upVotes = [couple[@"Upvotes"] intValue];
                downVotes = [couple[@"Downvotes"] intValue];
                
                double uVotes = [couple[@"Upvotes"] doubleValue];
                double dVotes = [couple[@"Downvotes"] doubleValue];
                couple[@"Score"] = [self computeScoreFromUpvotes:uVotes andDownvotes:dVotes];
                
                [couple saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    //notify store
                    [sharedStore saveCoupleVote:coupleJustVotedOn withStatus:YES completion:nextCoupleBlock];
                }];
            }
            else //user vote is lost
            {
                //notify store
                [sharedStore saveCoupleVote:coupleJustVotedOn withStatus:YES completion:nextCoupleBlock];
            }
            
        }];
    }
}

-(NSNumber *)computeScoreFromUpvotes:(double)uVotes andDownvotes:(double)dVotes
{
    if (dVotes == 0)
    {
        dVotes = 1.0;
    }
    
    double score = pow(uVotes, 7/3) / pow(dVotes, 2);
    
    return [NSNumber numberWithDouble:score];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PARGameResultsViewController *vc = (PARGameResultsViewController *)segue.destinationViewController;
    
    [vc setMale:maleId];
    [vc setMaleName:mName];
    
    [vc setFemale:femaleId];
    [vc setFemaleName:fName];
    
    [vc setCoupleObjectID:objectId];
    
    [vc setUpvotes:[NSNumber numberWithInt:upVotes]];
    [vc setDownvotes:[NSNumber numberWithInt:downVotes]];
    
    [vc setUserVote:[NSNumber numberWithInt:userVote]];
}

@end
