//
//  PARAddWishController.m
//  Pear
//
//  Created by Alex Ramey on 12/14/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARAddWishController.h"
#import "PARDataStore.h"
#import "PARWish.h"
#import "AppDelegate.h"

@interface PARAddWishController ()

@end

@implementation PARAddWishController

static NSString * const reuseIdentifider = @"CELL";

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        
        NSArray *otherGenderIDs;
        NSArray *otherGenderNames;
        //custom initialization
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:USER_GENDER_KEY] caseInsensitiveCompare:@"female"] == NSOrderedSame)
        {
            otherGenderIDs = [[PARDataStore sharedStore] maleFriendIDs];
            otherGenderNames = [[PARDataStore sharedStore] maleFriendNames];
        }
        else
        {
            otherGenderIDs = [[PARDataStore sharedStore] femaleFriendIDs];
            otherGenderNames = [[PARDataStore sharedStore] femaleFriendNames];
        }
        
        NSMutableArray *potentialWishesMutable = [[NSMutableArray alloc] init];
        for (int i = 0; i < [otherGenderNames count]; i++)
        {
            PARWish *wish = [[PARWish alloc] initWithName:[otherGenderNames objectAtIndex:i] facebookID:[otherGenderIDs objectAtIndex:i]];
            [potentialWishesMutable addObject:wish];
        }
        
        [potentialWishesMutable sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            PARWish *wish1 = (PARWish *)obj1;
            PARWish *wish2 = (PARWish *)obj2;
            
            return [wish1.wishName compare: wish2.wishName];
        }];
        
        _potentialWishes = potentialWishesMutable;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifider];
    [_tableView setEditing:YES];
    [_tableView setAllowsSelectionDuringEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    _wishList = [[[NSUserDefaults standardUserDefaults] objectForKey:WISHLIST_DEFAULTS_KEY] mutableCopy];
    
    if (!_wishList)
    {
        _wishList = [[NSMutableDictionary alloc] init];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PARWish *wish = [_potentialWishes objectAtIndex:indexPath.row];
    
    NSArray *keys = [_wishList allKeys];
    
    for (int i = 0; i < [keys count]; i++)
    {
        if ([[keys objectAtIndex:i] caseInsensitiveCompare:wish.facebookID] == NSOrderedSame)
        {
            NSString *msg = [NSString stringWithFormat:@"%@ is already on your wishlist!", wish.wishName];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done." message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    //1. Query Parse to See if Couple Already Exists, if so we're good
    
    PFQuery *query = [PFQuery queryWithClassName:@"Couples"];
    query.limit = 5;
    
    NSString *userFBID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_FB_ID_KEY];
    NSString *userGender = [[NSUserDefaults standardUserDefaults] objectForKey:USER_GENDER_KEY];
    
    if ([userGender caseInsensitiveCompare:@"male"] == NSOrderedSame)
    {
        [query whereKey:@"Male" containedIn:@[userFBID]];
        [query whereKey:@"Female" containedIn:@[wish.facebookID]];
    }
    else
    {
        [query whereKey:@"Male" containedIn:@[wish.facebookID]];
        [query whereKey:@"Female" containedIn:@[userFBID]];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) //Couple already exists so we're good
        {
            [_wishList setValue:wish.wishName forKey:wish.facebookID];
            [[NSUserDefaults standardUserDefaults] setObject:_wishList forKey:WISHLIST_DEFAULTS_KEY];
            
            NSString *msg = [NSString stringWithFormat:@"%@ was added to your wishlist!", wish.wishName];
            UIAlertView *goodAlert = [[UIAlertView alloc] initWithTitle:@"Done." message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [goodAlert show];
        }
        else if (objects) //no error and couple doesn't exist --> PUSH
        {
            //Push couple to parse
            NSArray *friends = [[PARDataStore sharedStore] friends];
            NSDictionary *wishFriend = nil;
            
            for (int i = 0; i < [friends count]; i++)
            {
                NSDictionary *friend = [friends objectAtIndex:i];
                if ([[friend objectForKey:@"id"] caseInsensitiveCompare:wish.facebookID] == NSOrderedSame)
                {
                    wishFriend = friend;
                }
            }
            
            NSDictionary *localMalePtr = nil;
            NSDictionary *localFemalePtr = nil;
            
            if ([userGender caseInsensitiveCompare:@"male"] == NSOrderedSame)
            {
                localMalePtr = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA_KEY];
                localFemalePtr = wishFriend;
            }
            else
            {
                localMalePtr = wishFriend;
                localFemalePtr = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA_KEY];
            }
            
            //get edu info: school id and year for male and female
            NSString *maleSchoolID = nil;
            NSNumber *maleSchoolYear = nil;
            NSString *femaleSchoolID = nil;
            NSNumber *femaleSchoolYear = nil;
            
            NSArray *maleEducation = [localMalePtr objectForKey:@"education"];
            NSDictionary *maleEdu = nil;
            if (maleEducation && [maleEducation count] > 0)
            {
                maleEdu = [maleEducation objectAtIndex:[maleEducation count] - 1];
            }
            
            if (maleEdu)
            {
                NSDictionary *school = [maleEdu objectForKey:@"school"];
                if ([school objectForKey:@"id"])
                {
                    maleSchoolID = [school objectForKey:@"id"];
                }
                
                NSDictionary *year = [maleEdu objectForKey:@"year"];
                if ([year objectForKey:@"name"])
                {
                    maleSchoolYear = [NSNumber numberWithInt:[[year objectForKey:@"name"] intValue]];
                }
                
            }
            
            NSDictionary *femaleEdu = nil;
            NSArray *femaleEducation = [localFemalePtr objectForKey:@"education"];
            if (femaleEducation && [femaleEducation count] > 0)
            {
                femaleEdu = [femaleEducation objectAtIndex:[femaleEducation count] - 1];
            }
            
            if (femaleEdu)
            {
                NSDictionary *school = [femaleEdu objectForKey:@"school"];
                if ([school objectForKey:@"id"])
                {
                    femaleSchoolID = [school objectForKey:@"id"];
                }
                
                NSDictionary *year = [femaleEdu objectForKey:@"year"];
                if ([year objectForKey:@"name"])
                {
                    femaleSchoolYear = [NSNumber numberWithInt:[[year objectForKey:@"name"] intValue]];
                }
            }
            
            //create new couple dictionary with fields necessary to create PFObject<Couple> in Parse
            
            NSMutableDictionary *newCouple = [[NSMutableDictionary alloc] init];
            [newCouple setObject:[localMalePtr objectForKey:@"id"] forKey:@"Male"];
            [newCouple setObject:[localFemalePtr objectForKey:@"id"] forKey:@"Female"];
            [newCouple setObject:[localMalePtr objectForKey:@"name"] forKey:@"MaleName"];
            [newCouple setObject:[localFemalePtr objectForKey:@"name"] forKey:@"FemaleName"];
            
            if (maleSchoolID)
            {
                [newCouple setObject:maleSchoolID forKey:@"MaleEducation"];
            }
            if (maleSchoolYear)
            {
                [newCouple setObject:maleSchoolYear forKey:@"MaleEducationYear"];
            }
            if (femaleSchoolID)
            {
                [newCouple setObject:femaleSchoolID forKey:@"FemaleEducation"];
            }
            if (femaleSchoolYear)
            {
                [newCouple setObject:femaleSchoolYear forKey:@"FemaleEducationYear"];
            }
            
            PFObject *couple = [PFObject objectWithClassName:@"Couples"];
            couple[@"Male"] = [newCouple objectForKey:@"Male"];
            couple[@"Female"] = [newCouple objectForKey:@"Female"];
            couple[@"MaleName"] = [newCouple objectForKey:@"MaleName"];
            couple[@"FemaleName"] = [newCouple objectForKey:@"FemaleName"];
            
            if ([newCouple objectForKey:@"MaleEducationYear"])
            {
                couple[@"MaleEducationYear"] = [newCouple objectForKey:@"MaleEducationYear"];
            }
            if ([newCouple objectForKey:@"FemaleEducationYear"])
            {
                couple[@"FemaleEducationYear"] = [newCouple objectForKey:@"FemaleEducationYear"];
            }
            if ([newCouple objectForKey:@"MaleEducation"])
            {
                couple[@"MaleEducation"] = [newCouple objectForKey:@"MaleEducation"];
            }
            if ([newCouple objectForKey:@"FemaleEducation"])
            {
                couple[@"FemaleEducation"] = [newCouple objectForKey:@"FemaleEducation"];
            }
           
            [couple saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    [_wishList setValue:wish.wishName forKey:wish.facebookID];
                    [[NSUserDefaults standardUserDefaults] setObject:_wishList forKey:WISHLIST_DEFAULTS_KEY];
                    
                    NSString *msg = [NSString stringWithFormat:@"%@ was added to your wishlist!", wish.wishName];
                    UIAlertView *goodAlert = [[UIAlertView alloc] initWithTitle:@"Done." message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [goodAlert show];
                }
                else
                {
                    NSString *msg = [NSString stringWithFormat:@"Failed to add %@ to your wishlist!", wish.wishName];
                    UIAlertView *badAlert = [[UIAlertView alloc] initWithTitle:@"Error." message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [badAlert show];
                }
            }];
        }
        else //error on first query to check if couple exist yet
        {
            NSString *msg = [NSString stringWithFormat:@"Failed to add %@ to your wishlist!", wish.wishName];
            UIAlertView *badAlert = [[UIAlertView alloc] initWithTitle:@"Error." message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [badAlert show];
        }
    }];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleInsert;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - UITableViewDataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:USER_GENDER_KEY] caseInsensitiveCompare:@"female"] == NSOrderedSame)
    {
        return @"Choose your man";
    }
    else
    {
        return @"Choose your lady";
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_potentialWishes count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifider];
    cell.editing = YES;
    
    cell.textLabel.text = [[_potentialWishes objectAtIndex:indexPath.row] wishName];
    
    return cell;
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
