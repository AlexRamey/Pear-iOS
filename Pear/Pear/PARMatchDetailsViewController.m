//
//  PARMatchDetailsViewController.m
//  Pear
//
//  Created by Alex Ramey on 1/7/15.
//  Copyright (c) 2015 Pear. All rights reserved.
//

#import "PARMatchDetailsViewController.h"
#import "AppDelegate.h"
#import "Parse.h"

@implementation PARMatchDetailsViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        //custom initialization
    }
    
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    maleView = [[FBProfilePictureView alloc] initWithProfileID:_male pictureCropping:FBProfilePictureCroppingSquare];
    femaleView = [[FBProfilePictureView alloc] initWithProfileID:_female pictureCropping:FBProfilePictureCroppingSquare];
    
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
    
    if ([_male caseInsensitiveCompare:[[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY]] == NSOrderedSame)
    {
        _auxilaryLabel.text = [NSString stringWithFormat:@"%d out of %d people think you and %@ would make a good couple.", [_upvotes intValue], [_upvotes intValue] + [_downvotes intValue], _femaleName];
    }
    else if ([_female caseInsensitiveCompare:[[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY]] == NSOrderedSame)
    {
        _auxilaryLabel.text = [NSString stringWithFormat:@"%d out of %d people think %@ and you would make a good couple.", [_upvotes intValue], [_upvotes intValue] + [_downvotes intValue], _maleName];
    }
    else
    {
        _auxilaryLabel.text = [NSString stringWithFormat:@"%d out of %d people think %@ and %@ would make a good couple.", [_upvotes intValue], [_upvotes intValue] + [_downvotes intValue], _maleName, _femaleName];
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
        if (strongScrollView && [objects count] == 0)
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



#pragma mark - CommentCardCallback method

-(void)commentCardCreatedWithHeight:(CGFloat)height
{
    yOffset += height + 10;
    [_scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, yOffset)];
}

@end
