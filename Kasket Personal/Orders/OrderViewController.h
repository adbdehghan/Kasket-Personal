//
//  OrderViewController.h
//  Kasket Personal
//
//  Created by adb on 4/12/17.
//  Copyright © 2017 Arena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface OrderViewController : UIViewController
@property(nonatomic,weak) IBOutlet UIView *mapView;
@property(nonatomic,weak) IBOutlet UIView *bottomView;
@property(nonatomic,strong) Order *order;
@end
