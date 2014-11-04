//
//  PARGameResultsViewController.m
//  Pear
//
//  Created by Alex Ramey on 10/13/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARGameResultsViewController.h"
#import "PARGameViewController.h"
#import "PARCommentCard.h"
#import "PARWriteCommentCard.h"
#import "AppDelegate.h"

@interface PARGameResultsViewController ()

@end

@implementation PARGameResultsViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    gradient.colors = _colors;
    
    maleView = [[FBProfilePictureView alloc] init];
    femaleView = [[FBProfilePictureView alloc] init];
    
    maleView.profileID = _male;
    femaleView.profileID = _female;
    
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
    
    _maleNameLabel.text = _maleName;
    _femaleNameLabel.text = _femaleName;
    
    _auxilaryLabel.text = [NSString stringWithFormat:@"%d out of %d people think %@ and %@ would make a good couple.", [_upvotes intValue], [_upvotes intValue] + [_downvotes intValue], _maleName, _femaleName];
    
    //Add write comment card to top of scroll view
    PARWriteCommentCard *writeCard = [[PARWriteCommentCard alloc] init];
    [_scrollView addSubview:writeCard];
    yOffset = writeCard.frame.size.height + 10;
    
    //populate scrollView with PARCommentCards. . .
    for (int i = 0; i < 5; i++)
    {
        PARCommentCard *commentCard = [[PARCommentCard alloc] initWithFacebookID:[[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY] name:@"Author" comment:@"This is a test comment" offset:yOffset callback:self];
            
        [_scrollView addSubview:commentCard];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    [_leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [_rightSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:_maleProfileFillerView.frame.origin.y] forKey:@"GAME_RESULTS_PICTURE_ORIGIN_Y_KEY"];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)nextCouple:(id)sender
{
    PARGameViewController *gameVC = (PARGameViewController *)[self presentingViewController];
    [gameVC dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)viewTapped:(id)sender
{
    //end editing in case user is typing a commment and taps outside to be done
    [self.view endEditing:YES];
}

#pragma mark - CommentViewCallback protocol methods

-(void)commentCardCreatedWithHeight:(CGFloat)height
{
    yOffset += height + 10;
    [_scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, yOffset)];
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
