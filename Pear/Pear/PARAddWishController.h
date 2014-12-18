//
//  PARAddWishController.h
//  Pear
//
//  Created by Alex Ramey on 12/14/14.
//  Copyright (c) 2014 Pear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PARAddWishController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *potentialWishes;

@property (nonatomic, strong) NSMutableDictionary *wishList;

@end
