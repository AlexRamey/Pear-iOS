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

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        //custom initialization
        [FBSettings enablePlatformCompatibility: YES];
    }
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor PARBlue];
    [_loginBtn drawWithPrimaryColor:[UIColor PAROrange] secondaryColor:[UIColor PAROrange]];
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
    NSArray *permissionsArray = @[@"public_profile", @"email", @"user_friends"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        PFUser *newUser = nil;
        
        if (!user) {
            _loginBtn.enabled = YES;
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                newUser = user;
            } else {
                NSLog(@"User with facebook logged in!");
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
                        
                        NSDictionary *year = mostRecent[@"year"];
                        if (year)
                        {
                            if (year[@"name"])
                            {
                                newUser[@"EducationYear"] = year[@"name"];
                            }
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
                    [[PARDataStore sharedStore] setUserObject:userObject];
                    NSDictionary *wishlist = [userObject objectForKey:@"Wishlist"];
                    [[NSUserDefaults standardUserDefaults] setObject:wishlist forKey:WISHLIST_DEFAULTS_KEY];
                    
                    [[PARDataStore sharedStore] pullCouplesAlreadyVotedOnWithCompletion:^(NSError *error)
                     {
                         if (error)
                         {
                             NSLog(@"Error: %@", error);
                         }
                         [self requestFriendsAndTransition];
                     }];
                }
                else //login fails
                {
                    _loginBtn.enabled = YES;
                    [_activityIndicator stopAnimating];
                }
            }];
        }
        else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                  isEqualToString: @"OAuthException"])
        {
            [PFUser logOut];
            _loginBtn.enabled = YES;
            [_activityIndicator stopAnimating];
        }
        else
        {
            NSLog(@"Some other error: %@", error);
            _loginBtn.enabled = YES;
            [_activityIndicator stopAnimating];
        }
    }];
}

-(void)requestFriendsAndTransition
{
    FBRequest *friendsRequest = [FBRequest requestForGraphPath:@"me/friends?fields=name,gender,education,location"];
    
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSArray *friends = [result objectForKey:@"data"];
        [PARDataStore sharedStore].friends = friends;
        
        [[PARDataStore sharedStore] nextCoupleWithCompletion:^(NSError *error) {
            if (error)
            {
                //TODO: Implement This
                //network error occurred . . .
            }
            [self performSegueWithIdentifier:@"LoginToTab" sender:self];
            [_activityIndicator stopAnimating];
        }];
    }];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
