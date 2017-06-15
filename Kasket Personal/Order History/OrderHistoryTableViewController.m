//
//  OrderHistoryTableViewController.m
//  Kasket Personal
//
//  Created by aDb on 4/16/17.
//  Copyright © 2017 Arena. All rights reserved.
//

#import "OrderHistoryTableViewController.h"
#import "UIScrollView+UzysAnimatedGifLoadMore.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "DBManager.h"
#import "Order.h"
#import "HistoryTableViewCell.h"
#import "MapCharacter.h"
#import "OrderViewController.h"
#define IS_IOS7 (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1 && floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)
#define IS_IOS8  ([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending)
#define IS_IPHONE6PLUS ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && [[UIScreen mainScreen] nativeScale] == 3.0f)

@interface OrderHistoryTableViewController ()
{
    UIView *containerView;
    UILabel* label;
    NSMutableArray *tableItems;
    UIActivityIndicatorView *activityIndicator;
    UILabel *clearMessage;
}

@property (strong, nonatomic) DataDownloader *getData;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, assign) NSInteger rowsCount;
@property (nonatomic, assign) BOOL isLoading;
@end

@implementation OrderHistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self CustomizeNavigationTitle];
    
    [self CustomizeNavigationTitle];
    [self InitialObjects];
    if(IS_IOS7 || IS_IOS8)
        self.automaticallyAdjustsScrollViewInsets = YES;
    
    clearMessage = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.center.y - 60, self.view.frame.size.width,30 )];
    clearMessage.textColor=[UIColor grayColor];
    clearMessage.backgroundColor =[UIColor clearColor];
    clearMessage.font = [UIFont fontWithName:@"IRANSans" size:16];
    clearMessage.textAlignment = NSTextAlignmentCenter;
    clearMessage.text = @"هیج تراکنشی انجام نشده است";
    clearMessage.alpha = 0;
    [self.view addSubview:clearMessage];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.tableView triggerLoadMoreActionHandler];
}

-(void)InitialObjects
{
    tableItems = [[NSMutableArray alloc]init];
    self.currentPage = 1;
    self.totalPages = 1;
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [activityIndicator startAnimating];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 80;
      self.tableView.backgroundColor = [UIColor colorWithRed:255/255.f green:255/255.f blue:255/255.f alpha:1];
    __weak typeof(self) weakSelf =self;
    [self.tableView addLoadMoreActionHandler:^{
        typeof(self) strongSelf = weakSelf;
//        if (self.currentPage <= self.totalPages)
//        {
            [strongSelf loadNextBatch];
//        }
//        else
//            [strongSelf.tableView removeLoadMoreActionHandler];
    } ProgressImagesGifName:@"nevertoolate@2x.gif" LoadingImagesGifName:@"nevertoolate@2x.gif" ProgressScrollThreshold:30 LoadingImageFrameRate:30];
    
    _rowsCount = 0;
}
- (void)loadNextBatch {
    self.isLoading =YES;
    __weak typeof(self) weakSelf = self;
    typeof(self) strongSelf = weakSelf;
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            NSMutableArray *temp = [[NSMutableArray alloc]init];
            
            for (NSDictionary *item in (NSMutableArray*)data) {
                Order *order = [[Order alloc]init];
                order.orderId = [item valueForKey:@"orderNumber"] == [NSNull null] ? @"-" : [item valueForKey:@"orderNumber"];
                order.orderTime =[item valueForKey:@"orderTime"] == [NSNull null] ? @"-" :[item valueForKey:@"orderTime"] ;
                order.orderType =[item valueForKey:@"orderType"] == [NSNull null] ? @"-" :[item valueForKey:@"orderType"];
                order.price = [item valueForKey:@"price"]== [NSNull null] ? @"0" :[item valueForKey:@"price"];
                order.haveReturn =[item valueForKey:@"roundtrip"]== [NSNull null] ? @"0" :[item valueForKey:@"roundtrip"];
                order.sourceAddress =[item valueForKey:@"sourceAddress"]== [NSNull null] ? @"-" :[item valueForKey:@"sourceAddress"];
                order.destinationAddress =[item valueForKey:@"destinationAddress"]== [NSNull null] ? @"-" :[item valueForKey:@"destinationAddress"];
                order.sourceBell =[item valueForKey:@"sourceBell"]== [NSNull null] ? @"-" :[item valueForKey:@"sourceBell"];
                order.sourcePlate =[item valueForKey:@"sourceNum"]== [NSNull null] ? @"-" :[item valueForKey:@"sourceNum"];
                order.destinationBell =[item valueForKey:@"destinationBell"]== [NSNull null] ? @"-" :[item valueForKey:@"destinationBell"];
                order.destinationPlate =[item valueForKey:@"destinationNum"]== [NSNull null] ? @"-" :[item valueForKey:@"destinationNum"];
                order.destinationFullName = [item valueForKey:@"destinationFullName"]== [NSNull null] ? @"-" :[item valueForKey:@"destinationFullName"];
                order.fullName = [item valueForKey:@"fullName"]== [NSNull null] ? @"-" :[item valueForKey:@"fullName"];
                order.status =[item valueForKey:@"status"]== [NSNull null] ? @"0" :[item valueForKey:@"status"];
                order.phoneNumber =[item valueForKey:@"phonenumber"]== [NSNull null] ? @"-" :[item valueForKey:@"phonenumber"];
                order.destinationPhoneNumber = [item valueForKey:@"destinationPhoneNumber"]== [NSNull null] ? @"-" : [item valueForKey:@"destinationPhoneNumber"];
                order.paymentStatus =[NSString stringWithFormat:@"%@",[item valueForKey:@"paymentstatus"]]== [NSNull null] ? @"0" :[NSString stringWithFormat:@"%@",[item valueForKey:@"paymentstatus"]];
                order.payInDestination = [NSString stringWithFormat:@"%@",[item valueForKey:@"payinDestination"]]== [NSNull null] ? @"0" : [NSString stringWithFormat:@"%@",[item valueForKey:@"payinDestination"]];
                
                [tableItems addObject:order];
                [temp addObject:order];
            }
            
            [activityIndicator stopAnimating];
            
            if (tableItems.count == 0) {
                clearMessage.alpha = 1;
            }
            else
                clearMessage.alpha = 0;
            
            NSInteger rows = [strongSelf.tableView numberOfRowsInSection:0];
            
            [strongSelf.tableView beginUpdates];
            NSMutableArray *Indexpaths = [NSMutableArray array];
            for (int i=0 ; i<temp.count ; i++) {
                [Indexpaths addObject:[NSIndexPath indexPathForRow:rows+i inSection:0]];
            }
            
            [strongSelf.tableView insertRowsAtIndexPaths:Indexpaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [strongSelf.tableView endUpdates];
            
            if (temp.count == 0) {
                [strongSelf.tableView removeLoadMoreActionHandler];
            }
            
            self.currentPage = self.currentPage +1 ;
            
            [strongSelf.tableView stopLoadMoreAnimation];
            strongSelf.isLoading =NO;
            
        }
        
        else
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"👻"
                                                            message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
                                                           delegate:self
                                                  cancelButtonTitle:@"خب"
                                                  otherButtonTitles:nil];
            [alert show];
            
            
            NSLog( @"Unable to fetch Data. Try again.");
        }
    };
    
    Settings *st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
    
    [self.getData OrderHistory:st.accesstoken Page:[NSString stringWithFormat:@"%ld",(long)self.currentPage] withCallback:callback];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return tableItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellID = @"Cell";
    HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell)
        cell = [[HistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    
    Order *order = (Order*)([tableItems objectAtIndex:indexPath.row]);
    
    cell.sourceAddressInfoLabel.text = order.sourceAddress;
    cell.destinationAddressLabel.text = order.destinationAddress;
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:[order.price integerValue]]];
    cell.orderIdLabel.text = order.orderId;
    cell.priceLabel.text = [NSString stringWithFormat:@"%@: %@ تومان" ,@"هزینه",[MapCharacter MapCharacter:formatted]];
    cell.dateTimeLabel.text = [MapCharacter MapCharacter:order.orderTime];
    cell.roundTripLabel.text = [[NSString stringWithFormat:@"%@",order.haveReturn] isEqualToString:@"0"] ? @"یک طرفه" :@"دو طرفه";
    
    NSString *status = [NSString stringWithFormat:@"%@",order.status];
    cell.orderStatus.text = [status isEqualToString:@"6"] ? @"لغو شده" : @"انجام شده";
    
    if ([status isEqualToString:@"6"] || [status isEqualToString:@"7"]) {
        cell.statusView.backgroundColor = [UIColor colorWithRed:212/255.f green:76/255.f blue:60/255.f alpha:1];
    }
    else
    {
        cell.statusView.backgroundColor = [UIColor colorWithRed:46/255.f green:204/255.f blue:113/255.f alpha:1];
    }
    
    switch ([order.paymentStatus integerValue]) {
        case 0:
            cell.paymentStatusLabel.text = @"پرداخت نشده";
            break;
        case 1:
            cell.paymentStatusLabel.text = @"نقدا پرداخت شده";
            break;
        case 2:
            cell.paymentStatusLabel.text = @"پرداخت شده";
            break;
        case 3:
            cell.paymentStatusLabel.text = @"گیرنده پرداخت کرد";
            break;
            
        default:
            break;
    }
    
    cell.background.layer.cornerRadius = 5;
    cell.background.layer.masksToBounds = YES;
    cell.background.clipsToBounds = YES;
    
    cell.layerView.layer.cornerRadius = 5;
    cell.layerView.layer.masksToBounds = NO;
    cell.layerView.layer.shadowOffset = CGSizeMake(1,1);
    cell.layerView.layer.shadowRadius = 2;
    cell.layerView.layer.shadowOpacity = 0.2;
    
    return cell;
}

-(void)CustomizeNavigationTitle
{
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text=@"تاریخچه سفارشات";
    label.textColor=[UIColor whiteColor];
    label.backgroundColor =[UIColor clearColor];
    label.adjustsFontSizeToFitWidth=YES;
    label.font =[UIFont fontWithName:@"IRANSans" size:17];
    label.textAlignment = NSTextAlignmentCenter;
    
    self.navigationItem.titleView=label;
    
    // Get the previous view controller
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    // Create a UIBarButtonItem
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)];
    // Associate the barButtonItem to the previous view
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    
}

- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
}


@end
