//
//  PARAddWishController.m
//  Pear
//
//  Created by Alex Ramey on 12/14/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import "PARAddWishController.h"
#import "PARDataStore.h"
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
        //custom initialization
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:USER_GENDER_KEY] caseInsensitiveCompare:@"female"] == NSOrderedSame)
        {
            _otherGenderIDs = [[PARDataStore sharedStore] maleFriendIDs];
            _otherGenderNames = [[PARDataStore sharedStore] maleFriendNames];
        }
        else
        {
            _otherGenderIDs = [[PARDataStore sharedStore] femaleFriendIDs];
            _otherGenderNames = [[PARDataStore sharedStore] femaleFriendNames];
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifider];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleInsert;
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
    return [_otherGenderNames count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifider];
    cell.editing = YES;
    
    cell.textLabel.text = [_otherGenderNames objectAtIndex:indexPath.row];
    
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
