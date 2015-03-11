//
//  PARWishStatsController.m
//  Pear
//
//  Created by Alex Ramey on 12/19/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARWishStatsController.h"
#import "Parse.h"
#import "AppDelegate.h"
#import "UIColor+Theme.h"
#import "PARNewCommentCard.h"

@interface PARWishStatsController ()

@end

@implementation PARWishStatsController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        //custom initialization
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_removeFromWishlist drawWithPrimaryColor:[UIColor PARRed] secondaryColor:[UIColor PARRed]];
    
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
    
    maleView.profileID = _male;
    femaleView.profileID = _female;
    
    _maleNameLabel.text = _maleName;
    _femaleNameLabel.text = _femaleName;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:USER_GENDER_KEY] caseInsensitiveCompare:@"male"] == NSOrderedSame)
    {
        _auxilaryLabel.text = [NSString stringWithFormat:@"%d out of %d people think you and %@ would make a good couple.", [_upvotes intValue], [_upvotes intValue] + [_downvotes intValue], _femaleName];
    }
    else
    {
        _auxilaryLabel.text = [NSString stringWithFormat:@"%d out of %d people think %@ and you would make a good couple.", [_upvotes intValue], [_upvotes intValue] + [_downvotes intValue], _maleName];
    }
    
    [self loadComments];
}

-(void)loadComments
{
    yOffset = 0.0;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Comments"];
    query.limit = 50;
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"MaleID" equalTo:_male];
    [query whereKey:@"FemaleID" equalTo:_female];
    
    /* 
     //testing purposes
     [query whereKey:@"MaleID" equalTo:@"589608147"];
     [query whereKey:@"FemaleID" equalTo:@"1537906103"];
     */
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        UIScrollView *strongScrollView = _scrollView;
        if (strongScrollView && !error)
        {
            CGSize phoneScreenSize = [UIScreen mainScreen].bounds.size;
            [strongScrollView setContentSize:CGSizeMake(phoneScreenSize.width, 0.0)];
            float initialsDimension = (strongScrollView.frame.size.height - 16.0) / 3.0;
            
            float offset = 0.0;
            int index = 0;
            
            for (PFObject *comment in objects)
            {
                PARNewCommentCard *commentCard = [[PARNewCommentCard alloc] initWithFrame:CGRectMake(0.0, offset, phoneScreenSize.width, initialsDimension) atIndex:index withAuthorName:comment[@"AuthorName"] commentText:comment[@"Text"]];
                
                [self createDropShadow:commentCard];
                
                [strongScrollView addSubview:commentCard];
                
                offset += initialsDimension + 8.0;
                
                [strongScrollView setContentSize:CGSizeMake(strongScrollView.contentSize.width, offset)];
                
                index++;
            }
            
            if ([objects count] > 0)
            {
                [strongScrollView setContentSize:CGSizeMake(strongScrollView.contentSize.width, strongScrollView.contentSize.height - 8.0)];
            }
            
        }
        if (strongScrollView && [objects count] == 0) //if error and objects == nil, this will also be true b/c objects count will return 0
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, (strongScrollView.frame.size.height / 2.0) - 15.0, [UIScreen mainScreen].bounds.size.width, 30.0)];
            label.textAlignment = NSTextAlignmentCenter;
            UIFont *font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:16.0];
            [label setFont:font];
            [label setText:@"No Comments"];
            [strongScrollView addSubview:label];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Remove From Wishlist Button

-(IBAction)removeFromWishlist:(id)sender
{
    NSMutableDictionary *wishlist = [[[NSUserDefaults standardUserDefaults] objectForKey:WISHLIST_DEFAULTS_KEY] mutableCopy];
    [wishlist removeObjectForKey:_selectedWishID];
    [[NSUserDefaults standardUserDefaults] setObject:wishlist forKey:WISHLIST_DEFAULTS_KEY];
    [self.navigationController popViewControllerAnimated:YES];
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
