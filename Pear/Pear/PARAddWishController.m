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
    PARWish *wish = [_potentialWishes objectAtIndex:indexPath.row];
    
    NSArray *keys = [_wishList allKeys];
    
    UIAlertView *alert;
    
    for (int i = 0; i < [keys count]; i++)
    {
        if ([[keys objectAtIndex:i] caseInsensitiveCompare:wish.facebookID] == NSOrderedSame)
        {
            NSString *msg = [NSString stringWithFormat:@"%@ is already on your wishlist!", wish.wishName];
            alert = [[UIAlertView alloc] initWithTitle:@"Done." message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    [_wishList setValue:wish.wishName forKey:wish.facebookID];
    [[NSUserDefaults standardUserDefaults] setObject:_wishList forKey:WISHLIST_DEFAULTS_KEY];
    
    //1. Query Parse to See if Couple Already Exists, if so we're good
    
    //2. If not, Push Couple to Parse and on Success notify data store in case it was a potentail couple
    
    NSString *msg = [NSString stringWithFormat:@"%@ was added to your wishlist!", wish.wishName];
    alert = [[UIAlertView alloc] initWithTitle:@"Done." message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
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
