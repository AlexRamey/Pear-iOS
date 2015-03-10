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

@interface PARResultsOverlayView ()
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
@property (nonatomic, strong) UIButton *dismissResults;

//Gesture Recognizer
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeRecognizer;

@end

@implementation PARResultsOverlayView

- (id)initForGivenScreenSize:(CGSize)screenSize voteType:(BOOL)yesVote
{
    //Programmatic View Layout, My Favorite . . .
    
    phoneScreenSize = screenSize;
    
    if (yesVote) //start below screen
    {
        self = [super initWithFrame:CGRectMake(.05 * screenSize.width, screenSize.height, .9 * screenSize.width, .83 * screenSize.height)];
    }
    else //start on top of screen
    {
        self = [super initWithFrame:CGRectMake(.05 * screenSize.width, (-1) * screenSize.height + .17 * screenSize.height, .9 * screenSize.width, .83 * screenSize.height)];
    }
    
    //Top Half
    
    _topBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, .39 * screenSize.height)];
    
    if (yesVote)
    {
        [_topBackground setBackgroundColor:[UIColor PARResultsGreen]];
    }
    else
    {
        [_topBackground setBackgroundColor:[UIColor PARResultsRed]];
    }
    
    _maleImage = [[UIImageView alloc] initWithFrame:CGRectMake(.05 * screenSize.width, .05 * screenSize.height, .125 * screenSize.height, .125 * screenSize.height)];
    [_maleImage.layer setCornerRadius:_maleImage.frame.size.width / 2];
    [_maleImage.layer setMasksToBounds:YES];
    
    _maleName = [[UILabel alloc] initWithFrame:CGRectMake(.05 * screenSize.width, .05 * screenSize.height + .125 * screenSize.height + 8, .125 * screenSize.height, 14.0)];
    _maleName.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:12.0];
    _maleName.textColor = [UIColor whiteColor];
    _maleName.textAlignment = NSTextAlignmentCenter;
    
    _femaleImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - .125 * screenSize.height - .05 * screenSize.width, .05 * screenSize.height, .125 * screenSize.height, .125 * screenSize.height)];
    [_femaleImage.layer setCornerRadius:_femaleImage.frame.size.width / 2];
    [_femaleImage.layer setMasksToBounds:YES];
    _femaleName.textAlignment = NSTextAlignmentCenter;
    
    _femaleName = [[UILabel alloc] initWithFrame:CGRectMake(_femaleImage.frame.origin.x, .05 * screenSize.height + .125 * screenSize.height + 8, .125 * screenSize.height, 14.0)];
    _femaleName.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:12.0];
    _femaleName.textColor = [UIColor whiteColor];
    
    NSMutableAttributedString *percentText = [[NSMutableAttributedString alloc] initWithString:@"100%"];
    [percentText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Superclarendon-Bold" size:52.0] range:NSMakeRange(0, percentText.length - 1)];
    [percentText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Superclarendon-Bold" size:18.0] range:NSMakeRange(percentText.length - 1, 1)];
    [percentText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, percentText.length)];
    
    _percentApproval = [[UILabel alloc] init];
    [_percentApproval setTextAlignment:NSTextAlignmentCenter];
    _percentApproval.attributedText = percentText;
    [_percentApproval sizeToFit];
    _percentApproval.center = CGPointMake(self.frame.size.width / 2.0, _maleName.frame.origin.y + _maleName.frame.size.height + .02 * screenSize.height + _percentApproval.frame.size.height / 2.0);
    
    _cleverQuote = [[UILabel alloc] init];
    [_cleverQuote setTextAlignment:NSTextAlignmentCenter];
    [_cleverQuote setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:12]];
    [_cleverQuote setTextColor:[UIColor whiteColor]];
    [_cleverQuote setText:@"\"Like pears in a pod.\""];
    [_cleverQuote sizeToFit];
    _cleverQuote.center = CGPointMake(self.frame.size.width / 2.0, _percentApproval.frame.origin.y + _percentApproval.frame.size.height + ((_topBackground.frame.size.height - (_percentApproval.frame.origin.y + _percentApproval.frame.size.height)) / 2.0));
    
    
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
    
    UIView *buttonsBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, .345 * screenSize.height, self.frame.size.width, .095 * screenSize.height)];
    
    
    UIView *addContainer = [[UIView alloc] initWithFrame:CGRectMake(8.0, 8.0, buttonsBar.frame.size.height - 16.0, buttonsBar.frame.size.height - 16.0)];
    addContainer.backgroundColor = [UIColor clearColor];
    
    UIButton *addComment = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, buttonsBar.frame.size.height - 16.0, buttonsBar.frame.size.height - 16.0)];
    [addComment setImage:[UIImage imageNamed:@"addComment"] forState:UIControlStateNormal];
    [addComment addTarget:self action:@selector(makeComment:) forControlEvents:UIControlEventTouchUpInside];
    [addComment.layer setCornerRadius:addComment.frame.size.width / 2.0];
    [addComment.layer setMasksToBounds:YES];
    
    [addContainer addSubview:addComment];
    addContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    addContainer.layer.shadowOffset = CGSizeMake(2,3);
    addContainer.layer.shadowOpacity = 0.5;
    addContainer.layer.shadowRadius = 2.0;
    addContainer.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:addContainer.bounds cornerRadius:addContainer.frame.size.width/2.0].CGPath;
    
    
    UIView *dismissContainer = [[UIView alloc] initWithFrame:CGRectMake(buttonsBar.frame.size.width - (buttonsBar.frame.size.height - 16.0) - 8.0, 8.0, buttonsBar.frame.size.height - 16.0, buttonsBar.frame.size.height - 16.0)];
    addContainer.backgroundColor = [UIColor clearColor];
    
    _dismissResults = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, buttonsBar.frame.size.height - 16.0, buttonsBar.frame.size.height - 16.0)];
    [_dismissResults setImage:[UIImage imageNamed:@"nextCouple"] forState:UIControlStateNormal];
    [_dismissResults.layer setCornerRadius:addComment.frame.size.width / 2.0];
    [_dismissResults.layer setMasksToBounds:YES];
    
    [dismissContainer addSubview:_dismissResults];
    dismissContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    dismissContainer.layer.shadowOffset = CGSizeMake(2,3);
    dismissContainer.layer.shadowOpacity = 0.5;
    dismissContainer.layer.shadowRadius = 2.0;
    dismissContainer.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:dismissContainer.bounds cornerRadius:dismissContainer.frame.size.width/2.0].CGPath;
    
    
    [buttonsBar addSubview:addContainer];
    [buttonsBar addSubview:dismissContainer];
    [_bottomBackground addSubview:_comments];
    [_bottomBackground addSubview:buttonsBar];
    
    [self addSubview:_bottomBackground];
    
    _leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] init];
    [_leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:_leftSwipeRecognizer];
    
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
    if (spaceRange.location != NSNotFound && [maleName length] > spaceRange.location + 1)
    {
        _maleName.text = [maleName substringToIndex:spaceRange.location + 2];
    }
    else
    {
        _maleName.text = maleName;
    }
    
    spaceRange = [femaleName rangeOfString:@" " options:NSBackwardsSearch];
    if (spaceRange.location != NSNotFound && [femaleName length] > spaceRange.location + 1)
    {
        _femaleName.text = [femaleName substringToIndex:spaceRange.location + 2];
    }
    else
    {
        _femaleName.text = femaleName;
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
}

-(void)setCallback:(PARGameViewController *)callback
{
    [_dismissResults addTarget:callback action:@selector(dismissResults:) forControlEvents:UIControlEventTouchUpInside];
    [_leftSwipeRecognizer addTarget:callback action:@selector(dismissResults:)];
}

- (IBAction)makeComment:(id)sender
{
    NSLog(@"Test");
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
