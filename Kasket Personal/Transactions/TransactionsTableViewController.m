//
//  TransactionsTableViewController.m
//  Kasket Personal
//
//  Created by aDb on 4/16/17.
//  Copyright © 2017 Arena. All rights reserved.
//

#import "TransactionsTableViewController.h"
#import "NinaPagerView.h"
#import "UIParameter.h"
#import "OrderTransactionsTableViewController.h"
#import "PersonalTransactionsTableViewController.h"

@interface TransactionsTableViewController ()
@property (nonatomic, strong) NinaPagerView *ninaPagerView;
@end

@implementation TransactionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self CustomizeNavigationBar];
    [self.view addSubview:self.ninaPagerView];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - NinaParaArrays
- (NSArray *)ninaTitleArray {
    return @[
             @"تراکنش ها",
             @"تراکنش های شخصی"
             ];
}

- (NSArray *)ninaVCsArray {
    return @[
             @"OrderTransactionsTableViewController",
             @"PersonalTransactionsTableViewController",
             ];
}

- (NSArray *)ninaDetailVCsArray {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OrderTransactionsTableViewController *current = [storyBoard instantiateViewControllerWithIdentifier:@"order"];
    PersonalTransactionsTableViewController *last = [storyBoard instantiateViewControllerWithIdentifier:@"personal"];
    return @[
             last,
             current
             ];
    
}

#pragma mark - LazyLoad
- (NinaPagerView *)ninaPagerView {
    if (!_ninaPagerView) {
        NSArray *titleArray = [self ninaTitleArray];
        NSArray *vcsArray = [self ninaDetailVCsArray];
        
        CGRect pagerRect = CGRectMake(0, 0, FUll_VIEW_WIDTH, FUll_CONTENT_HEIGHT);
        _ninaPagerView = [[NinaPagerView alloc] initWithFrame:pagerRect WithTitles:titleArray WithVCs:vcsArray];
        _ninaPagerView.ninaPagerStyles = NinaPagerStyleBottomLine;
        _ninaPagerView.ninaDefaultPage = 1;
        _ninaPagerView.loadWholePages = YES;
        _ninaPagerView.underlineColor= [UIColor colorWithRed:39/255.f green:45/255.f blue:62/255.f alpha:1];
        _ninaPagerView.topTabHeight = 55;
        _ninaPagerView.selectTitleColor = [UIColor darkGrayColor];
    }
    return _ninaPagerView;
}

-(void)CustomizeNavigationBar
{
    
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text=@"تراکنش ها";
    label.textColor=[UIColor whiteColor];
    label.backgroundColor =[UIColor clearColor];
    label.adjustsFontSizeToFitWidth=YES;
    label.font = [UIFont fontWithName:@"IRANSans" size:17];
    label.textAlignment = NSTextAlignmentCenter;
    
    self.navigationItem.titleView=label;
    
    
    // Get the previous view controller
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    // Create a UIBarButtonItem
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)];
    // Associate the barButtonItem to the previous view
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
