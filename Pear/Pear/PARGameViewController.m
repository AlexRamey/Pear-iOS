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

@interface PARGameViewController ()

@end

@implementation PARGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    NSLog(@"VIEW DID LOAD");
    
    maleView = [[FBProfilePictureView alloc] init];
    femaleView = [[FBProfilePictureView alloc] init];
    
    maleView.profileID = @"1557246102";
    femaleView.profileID = @"1557246102";
    
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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //get the next couple from the store . . .
    
    NSDictionary *coupleToVoteOn = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:NEXT_COUPLE_TO_VOTE_ON_KEY]];
    
    objectId = [coupleToVoteOn objectForKey:@"ObjectId"];
    maleId = [coupleToVoteOn objectForKey:@"Male"];
    femaleId = [coupleToVoteOn objectForKey:@"Female"];
    maleName = [coupleToVoteOn objectForKey:@"MaleName"];
    femaleName = [coupleToVoteOn objectForKey:@"FemaleName"];
    
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
    
    _maleName.text = maleName;
    _femaleName.text = femaleName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)voteCast:(id)sender
{
    UIButton *voteBtn =  (UIButton *)sender;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Couples"];
    
    if (voteBtn.frame.origin.x == _downVote.frame.origin.x)
    {
        // downvote behavior
        downVotes++;
        
        [query getObjectInBackgroundWithId:objectId block:^(PFObject *couple, NSError *error) {
            
            // Now let's update it with some new data. In this case, only cheatMode and score
            // will get sent to the cloud. playerName hasn't changed.
            [couple incrementKey:@"Downvotes"];
            [couple saveInBackground];
            
        }];
    }
    else
    {
        //upvote behavior
        upVotes++;
        
        [query getObjectInBackgroundWithId:objectId block:^(PFObject *couple, NSError *error) {
            
            // Now let's update it with some new data. In this case, only cheatMode and score
            // will get sent to the cloud. playerName hasn't changed.
            [couple incrementKey:@"Upvotes"];
            [couple saveInBackground];
            
        }];
    }
    
    //tell store couple you voted on
    PARDataStore *sharedStore = [PARDataStore sharedStore];
    [sharedStore addCoupleToCouplesAlreadyVotedOnList:[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:NEXT_COUPLE_TO_VOTE_ON_KEY]]];
    
    //Load the next couple
    [sharedStore nextCoupleWithCompletion:^(NSError *e) {
        //TODO: ADD Error Handling . . .
        
        [self performSegueWithIdentifier:@"GameToResults" sender:self];
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PARGameResultsViewController *vc = (PARGameResultsViewController *)segue.destinationViewController;
    
    [vc setMale:maleId];
    [vc setMaleName:maleName];
    
    [vc setFemale:femaleId];
    [vc setFemaleName:femaleName];
    
    [vc setUpvotes:[NSNumber numberWithInt:upVotes]];
    [vc setDownvotes:[NSNumber numberWithInt:downVotes]];
    
    
}

@end
