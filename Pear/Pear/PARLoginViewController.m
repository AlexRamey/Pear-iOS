//
//  PARLoginViewController.m
//  Pear
//
//  Created by Alex Ramey on 10/12/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARLoginViewController.h"
#import "PARDataStore.h"
#import "PFFacebookUtils.h"
#import "AppDelegate.h"
#import "UIColor+Theme.h"

@interface PARLoginViewController ()

@end

@implementation PARLoginViewController

#define IS_IPHONE_4 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480) < DBL_EPSILON )

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define IS_IPHONE_6 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )667 ) < DBL_EPSILON )

#define IS_IPHONE_6PLUS ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )736 ) < DBL_EPSILON )

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        //custom initialization
        [FBSettings enablePlatformCompatibility: YES];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_activityIndicator setHidesWhenStopped:YES];
        
        _loginBtn = [[PARButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 150.0, 30.0)];
        [_loginBtn setTitle:@"Login" forState:UIControlStateNormal];
        [_loginBtn addTarget:self action:@selector(loginButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor PARBlue];
}

-(void)viewDidLayoutSubviews
{
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.view.frame];
    BOOL success = NO;
    
    if (IS_IPHONE_4)
    {
        [backgroundImage setImage:[UIImage imageNamed:@"pear4background.png"]];
        success = YES;
    }
    else if (IS_IPHONE_5)
    {
        [backgroundImage setImage:[UIImage imageNamed:@"pear5background.png"]];
        success = YES;
    }
    else if (IS_IPHONE_6)
    {
        [backgroundImage setImage:[UIImage imageNamed:@"pear6background.png"]];
        success = YES;
    }
    else if (IS_IPHONE_6PLUS)
    {
        [backgroundImage setImage:[UIImage imageNamed:@"pear6plusbackground.png"]];
        success = YES;
    }
    
    CGFloat activityIndicatorDimension = 50.0;
    
    if (success)
    {
        [self.view addSubview:backgroundImage];
        [self.view sendSubviewToBack:backgroundImage];
        [_loginBtn drawWithPrimaryColor:[UIColor PARBlue] secondaryColor:[UIColor PARBlue]];
        
        _loginBtn.frame = CGRectMake((self.view.frame.size.width - _loginBtn.frame.size.width)/ 2.0, 3*(self.view.frame.size.height/4.0) - (_loginBtn.frame.size.height / 2.0), _loginBtn.frame.size.width, _loginBtn.frame.size.height);
        
        _activityIndicator.frame = CGRectMake((self.view.frame.size.width - activityIndicatorDimension)/ 2.0, (self.view.frame.size.height/4.0), activityIndicatorDimension, activityIndicatorDimension);
        
        [_thePearGameLabel removeFromSuperview];
        [_pearLogo removeFromSuperview];
    }
    else
    {
        [_loginBtn drawWithPrimaryColor:[UIColor PAROrange] secondaryColor:[UIColor PARDarkOrange]];
        _loginBtn.frame = CGRectMake((self.view.frame.size.width - _loginBtn.frame.size.width)/ 2.0, 3*(self.view.frame.size.height/4.0) - (_loginBtn.frame.size.height / 2.0), _loginBtn.frame.size.width, _loginBtn.frame.size.height);
        _activityIndicator.frame = CGRectMake((self.view.frame.size.width - activityIndicatorDimension)/ 2.0, (self.view.frame.size.height/2.0) - (activityIndicatorDimension / 2.0), activityIndicatorDimension, activityIndicatorDimension);
    }
    
    [self.view addSubview:_loginBtn];
    [self.view addSubview:_activityIndicator];
}

-(void)viewWillAppear:(BOOL)animated
{
    _loginBtn.enabled = YES;
    if ([PFUser currentUser] && // Check if user is cached
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) { // Check if user is linked to Facebook
        [_activityIndicator startAnimating];
        [self retrieveUserInfoAndTransition:nil];
        _loginBtn.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonTouchHandler:(id)sender  {
    //disable loginBtn
    _loginBtn.enabled = NO;
    
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[@"public_profile", @"email", @"user_friends", @"friends_location", @"friends_education_history"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        PFUser *newUser = nil;
        
        if (!user) {
            _loginBtn.enabled = YES;
            [_activityIndicator stopAnimating];
            NSString *errorMessage = nil;
            if (!error) {
                //NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                //NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            
            [errorMessage stringByAppendingString:@" Pleae try again."];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            if (user.isNew) {
                //NSLog(@"User with facebook signed up and logged in!");
                newUser = user;
            } else {
                //NSLog(@"User with facebook logged in!");
            }
            
            [self retrieveUserInfoAndTransition:newUser];
        }
    }];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

-(void)retrieveUserInfoAndTransition:(PFUser *)newUser
{
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            NSLog(@"User Data: %@", userData);
            
            [[NSUserDefaults standardUserDefaults] setObject:userData forKey:USER_DATA_KEY];
            
            if (newUser)
            {
                NSArray *education = userData[@"education"];
                if (education)
                {
                    NSDictionary *mostRecent = [education lastObject];
                    if (mostRecent)
                    {
                        NSDictionary *school = mostRecent[@"school"];
                        if (school)
                        {
                            if (school[@"id"])
                            {
                                newUser[@"Education"] = school[@"id"];
                            }
                            if (school[@"name"])
                            {
                                newUser[@"EducationName"] = school[@"name"];
                            }
                        }
                        
                        if ([mostRecent[@"year"] isKindOfClass:[NSDictionary class]])
                        {
                            NSDictionary *year = mostRecent[@"year"];
                            if (year[@"name"])
                            {
                                newUser[@"EducationYear"] = year[@"name"];
                            }
                        }
                        else if (mostRecent[@"year"]) //it's a number
                        {
                            newUser[@"EducationYear"] = mostRecent[@"year"];
                        }
                    }
                }
                
                if (userData[@"name"])
                {
                    newUser[@"Name"] = userData[@"name"];
                }
                
                if (userData[@"gender"])
                {
                    newUser[@"Gender"] = userData[@"gender"];
                }
                
                if (userData[@"email"])
                {
                    newUser[@"email"] = userData[@"email"];
                }
                
                if (userData[@"id"])
                {
                    newUser[@"FBID"] = userData[@"id"];
                }
                
                [newUser saveInBackground];
            }
            
            NSString *facebookID = userData[@"id"];
            [[NSUserDefaults standardUserDefaults] setObject:facebookID forKey:USER_FB_ID_KEY];
            NSString *userGender = userData[@"gender"];
            if (userGender)
            {
                [[NSUserDefaults standardUserDefaults] setObject:userGender forKey:USER_GENDER_KEY];
            }
            else //if no gender is provided, assume male
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"male" forKey:USER_GENDER_KEY];
            }
            
            //Attempt to retrieve wishlist and user object
            //if this fails, then login fails
            
            PFQuery *userQuery = [PFUser query];
            userQuery.limit = 1;
            [userQuery whereKey:@"FBID" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY]];
            [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error && [objects count] > 0)
                {
                    PFObject *userObject = [objects firstObject];
                    [[PARDataStore sharedStore] setUserObject:[PFUser currentUser]];
                    NSDictionary *wishlist = [userObject objectForKey:@"Wishlist"];
                    [[NSUserDefaults standardUserDefaults] setObject:wishlist forKey:WISHLIST_DEFAULTS_KEY];
                    
                    [[PARDataStore sharedStore] pullCouplesAlreadyVotedOnWithCompletion:^(NSError *error)
                     {
                         if (error)
                         {
                             [PFUser logOut];
                             _loginBtn.enabled = YES;
                             [_activityIndicator stopAnimating];
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed." message:@"Please Try Again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                 [alert show];
                             });
                         }
                         else
                         {
                             [self requestFriendsAndTransition];
                         }
                     }];
                }
                else //login fails
                {
                    [PFUser logOut];
                    _loginBtn.enabled = YES;
                    [_activityIndicator stopAnimating];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed." message:@"Please Try Again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
                    });
                }
            }];
        }
        else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                  isEqualToString: @"OAuthException"])
        {
            [PFUser logOut];
            _loginBtn.enabled = YES;
            [_activityIndicator stopAnimating];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed." message:@"Please Try Again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            });
        }
        else
        {
            [PFUser logOut];
            _loginBtn.enabled = YES;
            [_activityIndicator stopAnimating];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed." message:@"Please Try Again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            });
        }
    }];
}

-(void)requestFriendsAndTransition
{
    FBRequest *friendsRequest = [FBRequest requestForGraphPath:@"me/friends?fields=name,gender,education,location"];
    
    FBRequest *permissionsRequest = [FBRequest requestForGraphPath:@"/me/permissions"];
    [permissionsRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        //NSLog(@"PERMISSIONS: %@", result);
        if ([FBErrorUtility shouldNotifyUserForError:error])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[FBErrorUtility userMessageForError:error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }];
    
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if (!error)
        {
            NSArray *friends = [result objectForKey:@"data"];
            //NSLog(@"Friends: %@", friends);
            [PARDataStore sharedStore].friends = friends;
            [[PARDataStore sharedStore] nextCoupleWithCompletion:^(NSError *error) {
                if (error)
                {
                    //If error, it will be stored in defaults and caught by PARGameController in viewWillAppear
                }
                [self performSegueWithIdentifier:@"LoginToTab" sender:self];
                [_activityIndicator stopAnimating];
            }];
        }
        else
        {
            //login fails
            [PFUser logOut];
            _loginBtn.enabled = YES;
            [_activityIndicator stopAnimating];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed." message:@"Please Try Again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            });
        }
    }];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
