//
//  PARGameResultsViewController.m
//  Pear
//
//  Created by Alex Ramey on 10/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARGameResultsViewController.h"
#import "PARGameViewController.h"
#import "AppDelegate.h"
#import <Social/Social.h>
#import "PARButton.h"
#import "UIColor+Theme.h"

@interface PARGameResultsViewController ()

@end

@implementation PARGameResultsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [_rightSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapRecognizer];
    
    maleView = [[FBProfilePictureView alloc] init];
    femaleView = [[FBProfilePictureView alloc] init];
    
    maleView.profileID = nil;
    femaleView.profileID = nil;
    
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

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self createDropShadow:_maleShadowView];
    [self createDropShadow:_femaleShadowView];
    
    //message couple formula
    
    double upVotes = [_upvotes doubleValue];
    double downVotes = [_downvotes doubleValue];
    
    if (downVotes == 0)
    {
        downVotes = 1.0;
    }
    
    if ((pow(upVotes, 7/3) / pow(downVotes, 2) > 1 && upVotes + downVotes > 3))
    {
        _scrollViewBottomConstraint.constant = 48.0;
        
        PARButton *msgButton = [[PARButton alloc] initWithFrame:CGRectMake(self.view.center.x - 75, self.view.frame.size.height - 45.0, 150.0, 40.0)];
        [msgButton drawWithPrimaryColor:[UIColor PARBlue] secondaryColor:[UIColor PARBlue]];
        [msgButton setTitle:@"Message Couple" forState:UIControlStateNormal];
        [msgButton addTarget:self action:@selector(messageCouple:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:msgButton];
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
    [self.view sendSubviewToBack:view];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
    
    maleView.profileID = _male;
    femaleView.profileID = _female;
    
    if ([_userVote intValue] == 1)
    {
        self.view.backgroundColor = [UIColor PARGreen];
    }
    else
    {
        self.view.backgroundColor = [UIColor PARDarkRed];
    }
    
    _maleNameLabel.text = _maleName;
    _femaleNameLabel.text = _femaleName;
    
    _auxilaryLabel.text = [NSString stringWithFormat:@"%d out of %d people think %@ and %@ would make a good couple.", [_upvotes intValue], [_upvotes intValue] + [_downvotes intValue], _maleName, _femaleName];
    
    [self loadComments];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSNumber *firstLaunch = [[NSUserDefaults standardUserDefaults] objectForKey:PAR_IS_FIRST_LAUNCH_KEY];
    
    if ([firstLaunch boolValue])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:PAR_IS_FIRST_LAUNCH_KEY];
        
        UIAlertView *hint = [[UIAlertView alloc] initWithTitle:@"HINT" message:@"Side swipe to escape this screen" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [hint show];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification  object:nil];
}

-(void)loadComments
{
    for (UIView *subview in _scrollView.subviews)
    {
        [subview removeFromSuperview];
    }
    
    //Add write comment card to top of scroll view
    PARWriteCommentCard *writeCard = [[PARWriteCommentCard alloc] init];
    [writeCard setCoupleObjectID:_coupleObjectID];
    [writeCard setCoupleFemaleName:_femaleName];
    [writeCard setCoupleMaleName:_maleName];
    [writeCard setCallback:self];
    [writeCard setAuthorLiked:_userVote];
    [_scrollView addSubview:writeCard];
    yOffset = writeCard.frame.size.height + 10;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Comments"];
    query.limit = 50;
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"coupleObjectID" equalTo:_coupleObjectID];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        UIScrollView *strongScrollView = _scrollView;
        if (strongScrollView && !error)
        {
            for (PFObject *comment in objects)
            {
                PARCommentCard *commentCard = [[PARCommentCard alloc] initWithFacebookID:comment[@"AuthorFBID"] name:comment[@"AuthorName"] comment:comment[@"Text"] authorLiked:comment[@"authorLiked"] offset:yOffset callback:self];
                
                [_scrollView addSubview:commentCard];
            }
        }
    }];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGFloat kbHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    [_scrollView setNeedsLayout];
    [_scrollView layoutIfNeeded];
    
    CGFloat offset = 0.0;
    
    CGFloat effectiveScreenHeight = [UIScreen mainScreen].bounds.size.height - kbHeight;
    
    if (effectiveScreenHeight < _scrollView.frame.origin.y + 80 + 10)
    {
        offset = effectiveScreenHeight - (_scrollView.frame.origin.y + 80 + 10);
    }
    
    [UIView animateWithDuration:.5 animations:^{
        self.view.frame = CGRectMake(0.0, offset, self.view.frame.size.width, self.view.frame.size.height);
    }];
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if (self.view.frame.origin.y != 0.0)
    {
        [UIView animateWithDuration:.5 animations:^{
            self.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)nextCouple:(id)sender
{
    [self.view endEditing:YES];
    
    PARGameViewController *gameVC = (PARGameViewController *)[self presentingViewController];
    [gameVC dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)viewTapped:(id)sender
{
    //end editing in case user is typing a commment and taps outside to be done
    [self.view endEditing:YES];
}

-(IBAction)facebookShare:(id)sender
{
    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:@"http://thepeargame.parseapp.com/"];
    
    NSString *name = @"The Pear Game";
    NSString *caption = [[_maleName stringByAppendingString:@" + "] stringByAppendingString:_femaleName];
    NSString *description = @"Give your opinion on couples made up of your Facebook friends. See who your friends think you should be with.";
    NSString *picture = @"http://thepeargame.parseapp.com/img/pear%20icon%201024x1024.png";
    NSURL *pictureURL = [NSURL URLWithString:picture];
    NSString *link =  @"http://thepeargame.parseapp.com/";
    
    // If the Facebook app is installed and we can present the share dialog
    
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:params.link name:name caption:caption description:description picture:pictureURL clientState:nil
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              //NSLog(@"Error publishing story: %@", error.description);
                                              
                                              if ([FBErrorUtility shouldNotifyUserForError:error])
                                              {
                                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[FBErrorUtility userMessageForError:error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                                  [alert show];
                                              }
                                              
                                          } else {
                                              // Success
                                              //NSLog(@"result %@", results);
                                          }
                                      }];
    } else {
        // Put together the dialog parameters
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       name, @"name",
                                       caption, @"caption",
                                       description, @"description",
                                       link, @"link",
                                       picture, @"picture",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          //NSLog(@"Error publishing story: %@", error.description);
                                                          if ([FBErrorUtility shouldNotifyUserForError:error])
                                                          {
                                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[FBErrorUtility userMessageForError:error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                                              [alert show];
                                                          }
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              //NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  //NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  //NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  //NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

-(IBAction)twitterShare:(id)sender
{
    //twitter share
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *initialText = [[[_maleName stringByAppendingString:@" + "] stringByAppendingString:_femaleName] stringByAppendingString:@"The Pear Game! Give your opinion on couples made up of your Facebook friends. See who your friends think you should be with. http://thepeargame.parseapp.com/"];
        [tweetSheet setInitialText:initialText];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"User must be logged into Twitter in the device settings to Tweet." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(IBAction)messageCouple:(id)sender
{
    // Check if the Facebook app is installed and we can present
    // the message dialog
    NSString *name = @"The Pear Game";
    NSString *caption = [[_maleName stringByAppendingString:@" + "] stringByAppendingString:_femaleName];
    NSString *description = @"Give your opinion on couples made up of your Facebook friends. See who your friends think you should be with.";
    NSString *picture = @"http://thepeargame.parseapp.com/img/pear%20icon%201024x1024.png";
    NSString *link =  @"http://thepeargame.parseapp.com/";
    
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:link];
    params.name = name;
    params.caption = caption;
    params.picture = [NSURL URLWithString:picture];
    params.linkDescription = description;
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentMessageDialogWithParams:params]) {
        // Enable button or other UI to initiate launch of the Message Dialog
        // Present message dialog
        [FBDialogs presentMessageDialogWithLink:[NSURL URLWithString:link] name:name caption:caption description:description picture:[NSURL URLWithString:picture] clientState:nil
                                        handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                            if(error) {
                                                // An error occurred, we need to handle the error
                                                // See: https://developers.facebook.com/docs/ios/errors
                                                //NSLog(@"Error messaging link: %@", error);
                                                if ([FBErrorUtility shouldNotifyUserForError:error])
                                                {
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[FBErrorUtility userMessageForError:error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                                    [alert show];
                                                }
                                            } else {
                                                // Success
                                                //NSLog(@"result %@", results);
                                            }
                                        }];
    }  else {
        // Disable button or other UI for Message Dialog
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"User must have native Facebook Messenger app installed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - CommentViewCallback protocol methods

-(void)commentCardCreatedWithHeight:(CGFloat)height
{
    yOffset += height + 10;
    [_scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, yOffset)];
}

#pragma mark - WriteCommentCardCallback protocol methods

-(void)commentWasPushed
{
    [self loadComments];
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
