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

@interface PARGameViewController ()

@end

@implementation PARGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    [self.view.layer insertSublayer:gradient atIndex:0];
    
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    
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
        if ([error caseInsensitiveCompare:NO_MORE_COUPLES_DOMAIN] == NSOrderedSame)
        {
            
        }
        else // error --> NETWORK_ERROR_DOMAIN
        {
            
        }
        return;
    }
    
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
    
    PFQuery *query = [PFQuery queryWithClassName:@"Couples"];
    
    if ((voteBtn && voteBtn.frame.origin.x == _downVote.frame.origin.x) || (gestureRecognizer && gestureRecognizer.direction == UISwipeGestureRecognizerDirectionDown))
    {
        // downvote behavior
        downVotes++;
        
        [UIView animateWithDuration:.5f animations:^{
            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor redColor] CGColor], nil];
        } completion:^(BOOL finished) {
            [query getObjectInBackgroundWithId:objectId block:^(PFObject *couple, NSError *error) {
                [couple incrementKey:@"Downvotes"];
                [couple saveInBackground];
            }];
        }];
    }
    else
    {
        //upvote behavior
        upVotes++;
        
        [UIView animateWithDuration:.5f animations:^{
            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor greenColor] CGColor], nil];
        } completion:^(BOOL finished) {
            [query getObjectInBackgroundWithId:objectId block:^(PFObject *couple, NSError *error) {
                [couple incrementKey:@"Upvotes"];
                [couple saveInBackground];
                
            }];
        }];
    }
    
    //tell store couple you voted on
    PARDataStore *sharedStore = [PARDataStore sharedStore];
    [sharedStore addCoupleToCouplesAlreadyVotedOnList:[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:NEXT_COUPLE_TO_VOTE_ON_KEY]]];
    
    //Load the next couple
    [sharedStore nextCoupleWithCompletion:^(NSError *e) {
        //puts the next couple into the defaults . . .
        
        //if (e) it means network error
        //either way (network or no more couples), error will be stored in Defaults and caught by this view controller when it tries to load the next couple in viewWillAppear
        
        [self performSegueWithIdentifier:@"GameToResults" sender:self];
    }];
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
    
    [vc setUpvotes:[NSNumber numberWithInt:upVotes]];
    [vc setDownvotes:[NSNumber numberWithInt:downVotes]];
    
    [vc setColors:gradient.colors];
}

@end
