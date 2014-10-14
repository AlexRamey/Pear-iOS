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

@interface PARGameResultsViewController ()

@end

@implementation PARGameResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Add write comment card to top of scroll view
    PARWriteCommentCard *writeCard = [[PARWriteCommentCard alloc] init];
    [_scrollView addSubview:writeCard];
    
    //populate scrollView with PARCommentCards. . .
    yOffset = writeCard.frame.size.height + 10;
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)nextCouple:(id)sender
{
    //Tell the game controller to load a new couple
    PARGameViewController *gameVC = (PARGameViewController *)[self presentingViewController];
    [gameVC dismissViewControllerAnimated:YES completion:nil];
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
