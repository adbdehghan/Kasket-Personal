//
//  MainViewController.h
//  Kasket Personal
//
//  Created by aDb on 3/27/17.
//  Copyright © 2017 Arena. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *aCollectionView;
@property (weak, nonatomic) IBOutlet UIView *accessibilityContainer;
@property (weak, nonatomic) IBOutlet UISwitch *accessibilitySwitch;
@property (weak, nonatomic) IBOutlet UILabel *accessibilityLabel;
@property (weak, nonatomic) IBOutlet UIView *accountContainer;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;

@end
