//
//  PARCommentsViewController.m
//  Pear
//
//  Created by Alex Ramey on 1/8/15.
//  Copyright (c) 2015 Pear. All rights reserved.
//

#import "PARCommentsViewController.h"
#import "Parse.h"
#import "AppDelegate.h"
#import "PARTapRecognizer.h"
#import "PARMatchDetailsViewController.h"

@interface PARCommentsViewController ()

@end

@implementation PARCommentsViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        //custom initialization
        _comments = [[NSArray alloc] init];
        inProgress = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFQuery *query = [PFQuery queryWithClassName:@"Comments"];
    query.limit = 100;
    [query whereKey:@"AuthorFBID" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY]];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error)
        {
            _comments = objects;
            [self loadComments];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to load comments" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
}

-(void)loadComments
{
    yOffset = 0.0;
    
    for (PFObject *comment in _comments)
    {
        PARCommentCard *commentCard = [[PARCommentCard alloc] initWithFacebookID:comment[@"AuthorFBID"] name:comment[@"AuthorName"] comment:comment[@"Text"] authorLiked:comment[@"authorLiked"] offset:yOffset callback:self];
        
        PARTapRecognizer *tapRecognizer = [[PARTapRecognizer alloc] initWithTarget:self action:@selector(commentSelected:)];
        tapRecognizer.numberOfTouchesRequired = 1;
        tapRecognizer.numberOfTapsRequired = 1;
        tapRecognizer.coupleObjectID = comment[@"coupleObjectID"];
        [commentCard addGestureRecognizer:tapRecognizer];
        
        [_scrollView addSubview:commentCard];
    }
    
    if ([_comments count] == 0)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, (_scrollView.frame.size.height / 2.0) - 15.0, [UIScreen mainScreen].bounds.size.width, 30.0)];
        label.textAlignment = NSTextAlignmentCenter;
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:16.0];
        [label setFont:font];
        [label setText:@"No Comments"];
        [_scrollView addSubview:label];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)commentSelected:(id)sender
{
    if ([PARTapRecognizer class] == [sender class])
    {
        if (inProgress)
        {
            return;
        }
        
        inProgress = YES;
        
        PARTapRecognizer *tapRecognizer = (PARTapRecognizer *)sender;
        NSString *coupleID = tapRecognizer.coupleObjectID;
        
        PFQuery *query = [PFQuery queryWithClassName:@"Couples"];
        
        [query getObjectInBackgroundWithId:coupleID block:^(PFObject *object, NSError *error){
            
            inProgress = NO;
            
            if (!error)
            {
                couple = object;
                [self performSegueWithIdentifier:@"CommentsToMatchDetails" sender:self];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to fetch match details." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                couple = nil;
                
                [self performSegueWithIdentifier:@"CommentsToMatchDetails" sender:self];
            }
            
            
        }];
        
        
    }
}

#pragma mark - CommentCardCallback method

-(void)commentCardCreatedWithHeight:(CGFloat)height
{
    yOffset += height + 10;
    [_scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, yOffset)];
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
