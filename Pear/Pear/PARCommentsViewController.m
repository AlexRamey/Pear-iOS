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
#import "PARNewCommentCard.h"

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
    //yOffset = 0.0;
    CGSize phoneScreenSize = [UIScreen mainScreen].bounds.size;
    [_scrollView setContentSize:CGSizeMake(phoneScreenSize.width, 0.0)];
    
    float offset = 0.0;
    
    int index = 0;
    
    for (PFObject *comment in _comments)
    {
        //PARCommentCard *commentCard = [[PARCommentCard alloc] initWithFacebookID:comment[@"AuthorFBID"] name:comment[@"AuthorName"] comment:comment[@"Text"] authorLiked:comment[@"authorLiked"] offset:yOffset callback:self];
        
        PARNewCommentCard *commentCard = [[PARNewCommentCard alloc] initWithFrame:CGRectMake(0.0, offset, phoneScreenSize.width, .115 *  phoneScreenSize.height) atIndex:index withAuthorName:comment[@"AuthorName"] commentText:comment[@"Text"]];
        
        [self createDropShadow:commentCard];
        
        PARTapRecognizer *tapRecognizer = [[PARTapRecognizer alloc] initWithTarget:self action:@selector(commentSelected:)];
        tapRecognizer.numberOfTouchesRequired = 1;
        tapRecognizer.numberOfTapsRequired = 1;
        tapRecognizer.male = comment[@"MaleID"];
        tapRecognizer.female = comment[@"FemaleID"];
        [commentCard addGestureRecognizer:tapRecognizer];
        
        [_scrollView addSubview:commentCard];
        
        offset += .115 * phoneScreenSize.height + 8.0;
        
        [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, offset)];
        
         index++;
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
    else
    {
        [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, _scrollView.contentSize.height - 8.0)];
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
        
        if (tapRecognizer.male && tapRecognizer.female)
        {
            PFQuery *query = [PFQuery queryWithClassName:@"Couples"];
            
            [query whereKey:@"Male" equalTo:tapRecognizer.male];
            [query whereKey:@"Female" equalTo:tapRecognizer.female];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                inProgress = NO;
                
                if (!error && [objects count] > 0)
                {
                    couple = [objects objectAtIndex:0];
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
        else //no result will be found . . .
        {
            inProgress = NO;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to fetch match details." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            couple = nil;
            
            [self performSegueWithIdentifier:@"CommentsToMatchDetails" sender:self];
        }
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
