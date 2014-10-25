//
//  PARLoginViewController.m
//  Pear
//
//  Created by Alex Ramey on 10/12/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARLoginViewController.h"
#import "PARDataStore.h"
#import "AppDelegate.h"

@interface PARLoginViewController ()

@end

@implementation PARLoginViewController

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

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
    
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions: @[@"public_profile", @"email"]];
    loginView
    
    loginView.delegate = self;
    
    // Align the button in the center horizontally, and near the bottom vertically
    loginView.frame = CGRectMake(self.view.center.x - (loginView.frame.size.width / 2), self.view.bounds.size.height * .80, loginView.frame.size.width, loginView.frame.size.height);
    [self.view addSubview:loginView];
    
    self.view.backgroundColor = UIColorFromRGB(0x00cc66);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FBLoginViewDelegate methods

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    //Login View has fetched user info
    [[NSUserDefaults standardUserDefaults] setObject:user.objectID forKey:USER_FB_ID_KEY];
}

-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    //button view is now in logged-in state
    //FBRequest *friendsRequest = [FBRequest requestForGraphPath:@"me/friends?fields=name,gender,education,location"];
    FBRequest *request = [FBRequest requestWithGraphPath:@"/me/friends"
                                              parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"20", @"limit", nil]
                                              HTTPMethod:@"GET"];
    //[request overrideVersionPartWith:@"v1.0"];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Sucess! Include your code to handle the results here
            NSLog(@"***** user friends with params: %@", result);
        } else {
            // An error occurred, we need to handle the error
        }
    }];
    [FBSettings enablePlatformCompatibility: YES];
    FBRequest *friendsRequest = [FBRequest requestForGraphPath:@"/me/friends"];
    //[friendsRequest overrideVersionPartWith:@"v1.0"];
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"Result: %@", result);
        NSArray *friends = [result objectForKey:@"data"];
        [PARDataStore sharedStore].friends = friends;
        
        [[PARDataStore sharedStore] nextCoupleWithCompletion:^(NSError *error) {
            if (error)
            {
                //network error occurred . . .
            }
            [self performSegueWithIdentifier:@"LoginToTab" sender:self];
        }];
        
    }];
}

-(void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    //button view is no in logged-out state
}

// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
