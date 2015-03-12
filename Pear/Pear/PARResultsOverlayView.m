//
//  PARResultsOverlayView.m
//  Pear
//
//  Created by Alex Ramey on 3/10/15.
//  Copyright (c) 2015 Pear. All rights reserved.
//

#import "PARResultsOverlayView.h"
#import "UIColor+Theme.h"
#import "PARGameViewController.h"
#import "AppDelegate.h"
#import "PARDataStore.h"
#import "PARNewCommentCard.h"
#import "FacebookSDK.h"

@interface PARResultsOverlayView () <UIAlertViewDelegate>
{
    CGSize phoneScreenSize;
}

//Top Half
@property (nonatomic, strong) UIView *topBackground;
@property (nonatomic, strong) UIImageView *maleImage;
@property (nonatomic, strong) UILabel *maleName;
@property (nonatomic, strong) UIImageView *femaleImage;
@property (nonatomic, strong) UILabel *femaleName;
@property (nonatomic, strong) UILabel *percentApproval;
@property (nonatomic, strong) UILabel *cleverQuote;

//Bottom Half
@property (nonatomic, strong) UIView *bottomBackground;
@property (nonatomic, strong) UIScrollView *comments;
@property (nonatomic, strong) UIImageView *watermarkBackground;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIButton *dismissResults;

//Gesture Recognizer
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeRecognizer;

//Data Properties
@property (nonatomic, strong) NSMutableArray *commentCards;

@end

@implementation PARResultsOverlayView

#define IS_IPHONE_4 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480) < DBL_EPSILON )

- (id)initForGivenScreenSize:(CGSize)screenSize voteType:(VoteType)voteType
{
    //Programmatic View Layout, My Favorite . . .
    
    phoneScreenSize = screenSize;
    
    if (voteType == PARPositiveVote) //start below screen
    {
        self = [super initWithFrame:CGRectMake(.05 * screenSize.width, screenSize.height, .9 * screenSize.width, .83 * screenSize.height)];
    }
    else if (voteType == PARNegativeVote) //start on top of screen
    {
        self = [super initWithFrame:CGRectMake(.05 * screenSize.width, (-1) * screenSize.height + .17 * screenSize.height, .9 * screenSize.width, .83 * screenSize.height)];
    }
    else
    {
        //no previous vote . . .
        self = [super initWithFrame:CGRectMake(.05 * screenSize.width, screenSize.height, .9 * screenSize.width, .83 * screenSize.height)];
    }
    
    //Top Half
    
    _topBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, .39 * screenSize.height)];
    
    if (voteType == PARNegativeVote)
    {
        [_topBackground setBackgroundColor:[UIColor PARResultsRed]];
    }
    else if (voteType == PARPositiveVote)
    {
        [_topBackground setBackgroundColor:[UIColor PARResultsGreen]];
    }
    else
    {
        [_topBackground setBackgroundColor:[UIColor PARResultNeutral]];
    }
    
    _maleImage = [[UIImageView alloc] initWithFrame:CGRectMake(.05 * screenSize.width, .05 * screenSize.height, .125 * screenSize.height, .125 * screenSize.height)];
    [_maleImage.layer setCornerRadius:_maleImage.frame.size.width / 2];
    [_maleImage.layer setMasksToBounds:YES];
    
    _maleName = [[UILabel alloc] initWithFrame:CGRectMake(.05 * screenSize.width, .05 * screenSize.height + .125 * screenSize.height + 8, .125 * screenSize.height, 14.0)];
    _maleName.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:12.0];
    _maleName.textColor = [UIColor PARWhite];
    _maleName.textAlignment = NSTextAlignmentCenter;
    [_maleName setMinimumScaleFactor:.75];
    [_maleName setAdjustsFontSizeToFitWidth:YES];
    
    _femaleImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - .125 * screenSize.height - .05 * screenSize.width, .05 * screenSize.height, .125 * screenSize.height, .125 * screenSize.height)];
    [_femaleImage.layer setCornerRadius:_femaleImage.frame.size.width / 2];
    [_femaleImage.layer setMasksToBounds:YES];
    
    _femaleName = [[UILabel alloc] initWithFrame:CGRectMake(_femaleImage.frame.origin.x, .05 * screenSize.height + .125 * screenSize.height + 8, .125 * screenSize.height, 14.0)];
    _femaleName.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:12.0];
    _femaleName.textColor = [UIColor PARWhite];
    _femaleName.textAlignment = NSTextAlignmentCenter;
    [_femaleName setMinimumScaleFactor:.75];
    [_femaleName setAdjustsFontSizeToFitWidth:YES];
    
    NSMutableAttributedString *percentText = [[NSMutableAttributedString alloc] initWithString:@"100%"];
    [percentText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Superclarendon-Bold" size:52.0] range:NSMakeRange(0, percentText.length - 1)];
    [percentText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Superclarendon-Bold" size:18.0] range:NSMakeRange(percentText.length - 1, 1)];
    [percentText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, percentText.length)];
    
    _percentApproval = [[UILabel alloc] init];
    [_percentApproval setTextAlignment:NSTextAlignmentCenter];
    _percentApproval.attributedText = percentText;
    [_percentApproval sizeToFit];
    
    if (IS_IPHONE_4)
    {
        _percentApproval.center = CGPointMake(self.frame.size.width / 2.0, _maleName.frame.origin.y + _maleName.frame.size.height + _percentApproval.frame.size.height / 3.0);
    }
    else
    {
        _percentApproval.center = CGPointMake(self.frame.size.width / 2.0, _maleName.frame.origin.y + _maleName.frame.size.height + _percentApproval.frame.size.height / 2.0);
    }
    
    if (IS_IPHONE_4)
    {
        _cleverQuote = [[UILabel alloc] initWithFrame:CGRectMake(0.0, _percentApproval.frame.origin.y + _percentApproval.frame.size.height - 8.0, self.frame.size.width, 34.0)];
    }
    else
    {
        _cleverQuote = [[UILabel alloc] initWithFrame:CGRectMake(0.0, _percentApproval.frame.origin.y + _percentApproval.frame.size.height, self.frame.size.width, 34.0)];
    }
    
    [_cleverQuote setTextAlignment:NSTextAlignmentCenter];
    [_cleverQuote setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:14]];
    [_cleverQuote setTextColor:[UIColor whiteColor]];
    [_cleverQuote setMinimumScaleFactor:.75];
    [_cleverQuote setAdjustsFontSizeToFitWidth:YES];
    [_cleverQuote setNumberOfLines:2];
    
    [_topBackground addSubview:_maleImage];
    [_topBackground addSubview:_femaleImage];
    [_topBackground addSubview:_maleName];
    [_topBackground addSubview:_femaleName];
    [_topBackground addSubview:_percentApproval];
    [_topBackground addSubview:_cleverQuote];
    
    [self addSubview:_topBackground];
    
    //Bottom Half
    _bottomBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0, _topBackground.frame.size.height, self.frame.size.width, .44 * screenSize.height)];
    _bottomBackground.backgroundColor = [UIColor whiteColor];
    
    _comments = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, .345 * screenSize.height)];
    [_comments setBackgroundColor:[UIColor clearColor]];
    [_comments setPagingEnabled:YES];
    [_comments setShowsVerticalScrollIndicator:YES];
    
    _watermarkBackground = [[UIImageView alloc] initWithFrame:_comments.frame];
    [_watermarkBackground setContentMode:UIViewContentModeScaleAspectFit];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.center = _comments.center;
    _activityIndicator.hidesWhenStopped = YES;
    
    UIView *buttonsBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, .345 * screenSize.height, self.frame.size.width, .095 * screenSize.height)];
    
    //left container
    UIView *leftContainer = [[UIView alloc] initWithFrame:CGRectMake(8.0, 8.0, buttonsBar.frame.size.height - 16.0, buttonsBar.frame.size.height - 16.0)];
    leftContainer.backgroundColor = [UIColor clearColor];
    
    _leftBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, buttonsBar.frame.size.height - 16.0, buttonsBar.frame.size.height - 16.0)];
    [_leftBarButton.layer setCornerRadius:_leftBarButton.frame.size.width / 2.0];
    [_leftBarButton.layer setMasksToBounds:YES];
    
    [leftContainer addSubview:_leftBarButton];
    leftContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    leftContainer.layer.shadowOffset = CGSizeMake(2,3);
    leftContainer.layer.shadowOpacity = 0.5;
    leftContainer.layer.shadowRadius = 2.0;
    leftContainer.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:leftContainer.bounds cornerRadius:leftContainer.frame.size.width/2.0].CGPath;
    
    //middle container
    UIView *middleContainer = [[UIView alloc] initWithFrame:CGRectMake((buttonsBar.frame.size.width - (buttonsBar.frame.size.height - 16.0)) / 2.0, 8.0, buttonsBar.frame.size.height - 16.0, buttonsBar.frame.size.height - 16.0)];
    middleContainer.backgroundColor = [UIColor clearColor];
    
    _middleBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, buttonsBar.frame.size.height - 16.0, buttonsBar.frame.size.height - 16.0)];
    [_middleBarButton.layer setCornerRadius:_middleBarButton.frame.size.width / 2.0];
    [_middleBarButton.layer setMasksToBounds:YES];
    
    [middleContainer addSubview:_middleBarButton];
    middleContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    middleContainer.layer.shadowOffset = CGSizeMake(2,3);
    middleContainer.layer.shadowOpacity = 0.5;
    middleContainer.layer.shadowRadius = 2.0;
    middleContainer.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:middleContainer.bounds cornerRadius:middleContainer.frame.size.width/2.0].CGPath;
    
    //right container
    UIView *dismissContainer = [[UIView alloc] initWithFrame:CGRectMake(buttonsBar.frame.size.width - (buttonsBar.frame.size.height - 16.0) - 8.0, 8.0, buttonsBar.frame.size.height - 16.0, buttonsBar.frame.size.height - 16.0)];
    dismissContainer.backgroundColor = [UIColor clearColor];
    
    _dismissResults = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, buttonsBar.frame.size.height - 16.0, buttonsBar.frame.size.height - 16.0)];
    
    if (voteType == PARNoVote)
    {
        [_dismissResults setImage:[UIImage imageNamed:@"closeButton"] forState:UIControlStateNormal];
    }
    else
    {
        [_dismissResults setImage:[UIImage imageNamed:@"nextCouple"] forState:UIControlStateNormal];
    }
    
    [_dismissResults.layer setCornerRadius:_dismissResults.frame.size.width / 2.0];
    [_dismissResults.layer setMasksToBounds:YES];
    
    [dismissContainer addSubview:_dismissResults];
    dismissContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    dismissContainer.layer.shadowOffset = CGSizeMake(2,3);
    dismissContainer.layer.shadowOpacity = 0.5;
    dismissContainer.layer.shadowRadius = 2.0;
    dismissContainer.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:dismissContainer.bounds cornerRadius:dismissContainer.frame.size.width/2.0].CGPath;
    
    [buttonsBar addSubview:leftContainer];
    [buttonsBar addSubview:middleContainer];
    [buttonsBar addSubview:dismissContainer];
    
    [_bottomBackground addSubview:_watermarkBackground];
    [_bottomBackground addSubview:_comments];
    [_bottomBackground addSubview:_activityIndicator];
    [_bottomBackground addSubview:buttonsBar];
    
    [self addSubview:_bottomBackground];
    
    //Gesture Recognizer
    _leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] init];
    [_leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:_leftSwipeRecognizer];
    
    //Initialize Data Properties
    _commentCards = [NSMutableArray new];
    
    return self;
}

- (void)loadImagesForMale:(NSString *)maleID female:(NSString *)femaleID
{
    //load images
    
    NSURL *malePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=100&height=100", maleID]];
    
    NSURLRequest *malePictureRequest = [NSURLRequest requestWithURL:malePictureURL];
    
    [NSURLConnection sendAsynchronousRequest:malePictureRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                _maleImage.image = [UIImage imageWithData:data];
            });
        }
    }];
    
    NSURL *femalePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=100&height=100", femaleID]];
    
    NSURLRequest *femalePictureRequest = [NSURLRequest requestWithURL:femalePictureURL];
    
    [NSURLConnection sendAsynchronousRequest:femalePictureRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                _femaleImage.image = [UIImage imageWithData:data];
            });
        }
    }];
}

- (void)setMaleNameText:(NSString *)maleName femaleNameText:(NSString *)femaleName
{
    NSRange spaceRange = [maleName rangeOfString:@" " options:NSBackwardsSearch];
    NSRange firstSpaceRange = [maleName rangeOfString:@" "];
    if (spaceRange.location != NSNotFound && [maleName length] > spaceRange.location + 1)
    {
        _maleName.text = [[[maleName substringToIndex:firstSpaceRange.location] stringByAppendingString:[maleName substringWithRange:NSMakeRange(spaceRange.location, 2)]] stringByAppendingString:@"."];
    }
    else
    {
        _maleName.text = maleName;
    }
    
    spaceRange = [femaleName rangeOfString:@" " options:NSBackwardsSearch];
    firstSpaceRange = [femaleName rangeOfString:@" "];
    if (spaceRange.location != NSNotFound && [femaleName length] > spaceRange.location + 1)
    {
        _femaleName.text = [[[femaleName substringToIndex:firstSpaceRange.location] stringByAppendingString:[femaleName substringWithRange:NSMakeRange(spaceRange.location, 2)]] stringByAppendingString:@"."];
    }
    else
    {
        _femaleName.text = femaleName;
    }
}

- (void)setQuoteTextForUpvotes:(int)upvotes downvotes:(int)downvotes
{
    if (upvotes + downvotes > 6)
    {
        NSArray *quotes = nil;
        float percent = (1.0 * upvotes) / (upvotes + downvotes);
        
        if (percent <= .17)
        {
            quotes = @[
                       @"Probability of happening: fetch.",
                       @"<3…people approve.",
                       @"The odds: 3720:1",
                       @"The tribe has spoken."
                       ];
            
            _cleverQuote.text = quotes[arc4random_uniform(4)];
        }
        else if (percent <= .34)
        {
            quotes = @[
                       @"Meh.",
                       @"It's raining downvotes!",
                       @"k.",
                       @"Haters...",
                       @"The odds are NEVER in our favor.",
                       @"Level: Taylor Swift + guy from Black Space."
                       ];
            _cleverQuote.text = quotes[arc4random_uniform(6)];
        }
        else if (percent <= .65)
        {
            quotes = @[
                       @"Jury's still out.",
                       @":K",
                       @"If social approval were grades, we'd have a messed up academic system.",
                       @"Not bad. Not great...",
                       @"Level: YA protagonist and secondary love interest.",
                       @"Steal our quotes for YikYak. It's ok. What can we do?"
                       ];
            _cleverQuote.text = quotes[arc4random_uniform(6)];
        }
        else if (percent <= .83)
        {
            quotes = @[
                       @";)",
                       @"Not bad.",
                       @"A solid pearing.",
                       @":D",
                       @"Level: Cleopatra + Julius Caesar."
                       ];
            
            _cleverQuote.text = quotes[arc4random_uniform(5)];
        }
        else if (percent <=.95)
        {
            quotes = @[
                       @"Like pears in a pod.",
                       @"<3",
                       @"These two...",
                       @"Votes don't lie.",
                       @"Level: Romeo + Juliet",
                       @"Level: Cyrano + Roxane",
                       @"Level: Cleopatra + Marc Antony"
                       ];
            
            _cleverQuote.text = quotes[arc4random_uniform(7)];
        }
        else
        {
            quotes = @[
                       @"A pearfect match!",
                       @"A match without pearallel.",
                       @"Together, forever, always... because we said so.",
                       @"Most likely already dating.",
                       @"Level: Gollum and the One Ring.",
                       @"Level: peanut butter and Nutella.",
                       @"Level: George Washington + Freedom",
                       @"Level: Hunter Anjou + Alexis Forelle."
                       ];
            
            _cleverQuote.text = quotes[arc4random_uniform(8)];
        }
    }
    else
    {
        _cleverQuote.text = @"";
    }
}

- (void)flyInAnimatingUpToPercent:(CGFloat)percent
{
    NSMutableAttributedString *percentText = [[NSMutableAttributedString alloc] initWithString:@"0%"];
    [percentText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Superclarendon-Bold" size:52.0] range:NSMakeRange(0, percentText.length - 1)];
    [percentText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Superclarendon-Bold" size:18.0] range:NSMakeRange(percentText.length - 1, 1)];
    [percentText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, percentText.length)];
    [_percentApproval setAttributedText:percentText];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.frame = CGRectMake(.05 * phoneScreenSize.width, .06 * phoneScreenSize.height, .9 * phoneScreenSize.width, .83 * phoneScreenSize.height);
    } completion:^(BOOL finished) {
        [self animateUpToPercent:percent];
    }];
}

- (void)animateUpToPercent:(CGFloat)percent
{
    int roundedPercent = (int)((100 * percent) + 0.5);
    
    CGFloat animationDuration = 2.0 * roundedPercent / 100;
    
    CGFloat magnitudeOfImageMovement = .00165 * phoneScreenSize.width * roundedPercent;
    
    [UIView animateWithDuration:animationDuration animations:^{
        _maleImage.center = CGPointMake(_maleImage.center.x + magnitudeOfImageMovement, _maleImage.center.y);
        _maleName.center = CGPointMake(_maleName.center.x + magnitudeOfImageMovement, _maleName.center.y);
        _femaleImage.center = CGPointMake(_femaleImage.center.x - magnitudeOfImageMovement, _femaleImage.center.y);
        _femaleName.center = CGPointMake(_femaleName.center.x - magnitudeOfImageMovement, _femaleName.center.y);
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (int i = 1; i < roundedPercent + 1; i ++) {
            usleep(animationDuration/roundedPercent * 1000000); // sleep in microseconds
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableAttributedString *percentText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d%@", i, @"%"]];
                [percentText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Superclarendon-Bold" size:52.0] range:NSMakeRange(0, percentText.length - 1)];
                [percentText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Superclarendon-Bold" size:18.0] range:NSMakeRange(percentText.length - 1, 1)];
                [percentText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, percentText.length)];
                _percentApproval.attributedText = percentText;
            });
        }
    });
    
    [self loadComments];
}

-(void)setCallback:(id<OverlayCallback>)callback
{
    [_dismissResults addTarget:callback action:@selector(dismissOverlay:) forControlEvents:UIControlEventTouchUpInside];
    [_leftSwipeRecognizer addTarget:callback action:@selector(dismissOverlay:)];
}

- (void)loadComments
{
    [_comments scrollRectToVisible:CGRectMake(0.0, 0.0, _comments.frame.size.width, _comments.frame.size.height) animated:YES];
    
    [_activityIndicator startAnimating];
    
    for (UIView *view in [_comments subviews])
    {
        [view removeFromSuperview];
    }
    
    [_comments setContentSize:CGSizeMake(_comments.frame.size.width, 0.0)];
    
    [_commentCards removeAllObjects];
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Comments"];
    query.limit = 50;
    [query orderByDescending:@"createdAt"];
    
    [query whereKey:@"MaleID" equalTo:_maleID];
    [query whereKey:@"FemaleID" equalTo:_femaleID];
     
    /* testing purposes
    [query whereKey:@"MaleID" equalTo:@"589608147"];
    [query whereKey:@"FemaleID" equalTo:@"1537906103"];
    */
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            int i = 0;
            CGFloat offset = 0.0;
            for (PFObject *comment in objects)
            {
                PARNewCommentCard *commentCard = [[PARNewCommentCard alloc] initWithFrame:CGRectMake(.9 * phoneScreenSize.width * pow(-1, i), offset, .9 * phoneScreenSize.width, .115 *  phoneScreenSize.height) atIndex:i withAuthorName:comment[@"AuthorName"] commentText:comment[@"Text"]];
                
                [_commentCards addObject:commentCard];
                offset += .115*phoneScreenSize.height;
                i++;
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([_commentCards count] > 0 && [_commentCards count] < 3)
                    {
                        NSArray *watermarkBackgroundImages =
                        @[@"DarkWatermark", @"LightWatermark",
                          @"DarkWatermarkNoFace", @"LightWatermarkNoFace"];
                        NSUInteger r = arc4random_uniform(4);
                        [_watermarkBackground setImage:[UIImage imageNamed:watermarkBackgroundImages[r]]];
                    }
                    else if ([_commentCards count] >= 3)
                    {
                        NSArray *watermarkBackgroundImages =
                        @[@"DarkWatermark", @"LightWatermark",
                          @"DarkWatermarkNoFace", @"LightWatermarkNoFace",
                          @"DarkWatermarkWithText",@"LightWatermarkWithText"];
                        NSUInteger r = arc4random_uniform(6);
                        [_watermarkBackground setImage:[UIImage imageNamed:watermarkBackgroundImages[r]]];
                    }
                    else //0 comments
                    {
                        NSArray *initialBackgroundWatermarks =
                        @[@"DarkWatermark",@"LightWatermark",
                          @"DarkWatermarkNoComments", @"LightWatermarkNoComments",
                          @"DarkWatermarkNoFace", @"LightWatermarkNoFace"];
                        NSUInteger r = arc4random_uniform(6);
                        [_watermarkBackground setImage:[UIImage imageNamed:initialBackgroundWatermarks[r]]];
                    }
                });
                
                for (int j = 0; j < [_commentCards count]; j ++) {
                    if (j!=0)
                    {
                        usleep(.2 * 1000000); // sleep in microseconds
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:.5 animations:^{
                            UIView *card = _commentCards[j];
                            [_comments addSubview:card];
                            card.frame = CGRectMake(0.0, card.frame.origin.y, card.frame.size.width, card.frame.size.height);
                            [_comments setContentSize:CGSizeMake(_comments.frame.size.width, _comments.contentSize.height + .115 * phoneScreenSize.height)];
                        }];
                    });
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    CGFloat bufferspace = (3 - ([_commentCards count] % 3)) * .115 *phoneScreenSize.height;
                    [_comments setContentSize:CGSizeMake(_comments.frame.size.width, _comments.contentSize.height + bufferspace)];
                });
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_activityIndicator stopAnimating];
            
            NSNumber *firstLaunch = [[NSUserDefaults standardUserDefaults] objectForKey:PAR_IS_FIRST_LAUNCH_RESULTS_KEY];
            
            if ([firstLaunch boolValue])
            {
                [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:PAR_IS_FIRST_LAUNCH_RESULTS_KEY];
                
                UIAlertView *hint = [[UIAlertView alloc] initWithTitle:@"HINT" message:@"You may swipe left to dismiss this view." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [hint show];
            }
        });
    }];
}

-(IBAction)makePear:(id)sender
{
    NSString *name = @"The Pear Game";
    NSString *pear = [[_maleNameText stringByAppendingString:@" + "] stringByAppendingString:_femaleNameText];
    
    NSString *description = [pear stringByAppendingString:[NSString stringWithFormat:@" @ http://thepeargame.com/webapp/index.html?male=%@&female=%@", _maleID, _femaleID]];
    
    NSMutableArray *recipients = [NSMutableArray new];
    
    NSString *userFBID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY];
    
    if ([userFBID caseInsensitiveCompare:_maleID] != NSOrderedSame)
    {
        [recipients addObject:_maleID];
    }
    
    if ([userFBID caseInsensitiveCompare:_femaleID] != NSOrderedSame)
    {
        [recipients addObject:_femaleID];
    }
    
    NSArray *suggestedFriends = [NSArray arrayWithArray:recipients];
    
    // Create a dictionary of key/value pairs which are the parameters of the dialog
    
    // 1. No additional parameters provided - enables generic Multi-friend selector
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     // 2. Optionally provide a 'to' param to direct the request at a specific user
                                     [suggestedFriends componentsJoinedByString:@","], @"to", // Ali
                                     description, @"data",
                                     nil];
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:description
                                                    title:name
                                               parameters:params
                                                  handler:^(FBWebDialogResult result,
                                                            NSURL *resultURL,
                                                            NSError *error) {
                                                      if (error) {
                                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not send request." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                                          [alert show];
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              //NSLog(@"User canceled request.");
                                                          } else {
                                                              //NSLog(@"Request Sent.");
                                                          }
                                                      }
                                                  }
                                              friendCache:nil];
}

- (IBAction)makeComment:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Comment" message:nil delegate:self cancelButtonTitle:@"Quit" otherButtonTitles:@"Submit", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

#pragma mark - UIAlertViewDelegateMethods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *commentText = [alertView textFieldAtIndex:0].text;
    
    if (buttonIndex == 1 && commentText.length > 0)
    {
        PFObject *userObject = [[PARDataStore sharedStore] userObject];
        NSDictionary *userData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA_KEY];
        NSString *userName = userData[@"name"];
        
        PFObject *comment = [PFObject objectWithClassName:@"Comments"];
        comment[@"coupleObjectID"] = _coupleObjectID;
        comment[@"Text"] = commentText;
        comment[@"AuthorFBID"] = [[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY];;
        comment[@"AuthorObjectID"] = userObject.objectId;
        comment[@"AuthorName"] = userName;
        comment[@"authorLiked"] = _authorLiked;
        comment[@"coupleMaleName"] = _maleNameText;
        comment[@"coupleFemaleName"] = _femaleNameText;
        comment[@"MaleID"] = _maleID;
        comment[@"FemaleID"] = _femaleID;
        comment[@"coupleURL"] = [NSString stringWithFormat:@"http://thepeargame.com/webapp/index.html?male=%@&female=%@", _maleID, _femaleID];
        
        [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                PFQuery *coupleQuery = [PFQuery queryWithClassName:@"Couples"];
                [coupleQuery getObjectInBackgroundWithId:_coupleObjectID block:^(PFObject *object, NSError *error) {
                    if (!error)
                    {
                        [object incrementKey:@"NumberOfComments"];
                        [object saveInBackground];
                    }
                }];
                
                [self loadComments];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to save comment." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];

    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
