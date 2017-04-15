//
//  OrdersViewController.h
//  Kasket Personal
//
//  Created by aDb on 3/28/17.
//  Copyright © 2017 Arena. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrdersViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) IBOutlet UITableView *tableView;
@end
