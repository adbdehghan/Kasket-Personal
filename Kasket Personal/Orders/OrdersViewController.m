//
//  OrdersViewController.m
//  Kasket Personal
//
//  Created by aDb on 3/28/17.
//  Copyright © 2017 Arena. All rights reserved.
//

#import "OrdersViewController.h"
#import "RadialGradient.h"
#import "InstagramActivityIndicator.h"
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

@interface OrdersViewController ()
{

    InstagramActivityIndicator *indicator;
    UIView *containerView;
    UILabel* label;
    NSMutableArray *tableItems;
    UIActivityIndicatorView *activityIndicator;
    UILabel *clearMessage;
    BOOL isViewDown;
    Order *selectedOrder;
    NSTimer *timer;
    
}

@property (strong, nonatomic) DataDownloader *getData;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic,assign) BOOL useActivityIndicator;
@property (nonatomic, assign) NSInteger rowsCount;

@end

@implementation OrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(ActiveIndicator)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    [self CustomizeNavigationTitle];
    [self AddBackgroundStaff];
    [self InitialObjects];
    if(IS_IOS7 || IS_IOS8)
        self.automaticallyAdjustsScrollViewInsets = YES;
}

-(void)InitialObjects
{
    tableItems = [[NSMutableArray alloc]init];
    self.currentPage = 1;
    self.totalPages = 1;
//    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    [self.view addSubview:activityIndicator];
//    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
//    [activityIndicator startAnimating];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 80;
    self.tableView.backgroundColor = [UIColor colorWithRed:250/255.f green:250/255.f blue:250/255.f alpha:1];
    __weak typeof(self) weakSelf =self;
    [self.tableView addLoadMoreActionHandler:^{
        typeof(self) strongSelf = weakSelf;
        if (self.currentPage <= self.totalPages)
        {
            [strongSelf loadNextBatch];
        }
        else
            [strongSelf.tableView removeLoadMoreActionHandler];
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
            
            [tableItems removeAllObjects];
            
            if (data.count > 0) {
                [self AnimateViewDown];
            }
            else if(isViewDown)
                [self AnimateViewUp];
            
            
            for (NSDictionary *item in (NSMutableArray*)data) {
                Order *order = [[Order alloc]init];
                order.orderId = [item valueForKey:@"id"];
                order.orderTime =[item valueForKey:@"orderTime"];
                order.orderType =[item valueForKey:@"orderType"];
                order.price = [item valueForKey:@"price"];
                order.haveReturn =[item valueForKey:@"roundtrip"];
                order.sourceAddress =[item valueForKey:@"sourceAddress"];
                order.destinationAddress =[item valueForKey:@"destinationAddress"];
                NSDictionary *sourceLocation = [item valueForKey:@"sourcelocation"];
                order.sourceLat = [sourceLocation valueForKey:@"latitude"];
                order.sourceLon = [sourceLocation valueForKey:@"longitude"];
                
                NSDictionary *destLocation = [item valueForKey:@"destinationlocation"];
                order.destinationLat = [destLocation valueForKey:@"latitude"];
                order.destinationLon = [destLocation valueForKey:@"longitude"];
                
                [tableItems addObject:order];
                [temp addObject:order];
            }
            [activityIndicator stopAnimating];
            
            if (temp.count == 0) {
                clearMessage.alpha = 1;
            }
            else
                clearMessage.alpha = 0;
            
            [self.tableView reloadData];
            
            self.currentPage = self.currentPage +1 ;
            
            [strongSelf.tableView stopLoadMoreAnimation];
            strongSelf.isLoading =NO;
            
            timer =  [NSTimer scheduledTimerWithTimeInterval:3.f
                                             target:self
                                           selector:@selector(TriggerNextRequest)
                                           userInfo:nil
                                            repeats:NO];
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
            
            [NSTimer scheduledTimerWithTimeInterval:3.f
                                             target:self
                                           selector:@selector(TriggerNextRequest)
                                           userInfo:nil
                                            repeats:NO];
        }
    };
    
    Settings *st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
    
    [self.getData Orders:st.accesstoken Page:[NSString stringWithFormat:@"%ld",(long)self.currentPage] withCallback:callback];
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.getData = nil;
    [timer invalidate];
}

-(void)ActiveIndicator
{
   [indicator startAnimating];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.tableView triggerLoadMoreActionHandler];
    
    

}

-(void)TriggerNextRequest
{
    if (self.getData != nil) {
        [self loadNextBatch];
    }
    else
    {
        [timer invalidate];
    
    }
    
}


#pragma mark - Table view data source
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
    cell.priceLabel.text = [NSString stringWithFormat:@"%@: %@ تومان" ,@"هزینه",[MapCharacter MapCharacter:formatted]];
    cell.roundTripLabel.text = [[NSString stringWithFormat:@"%@",order.haveReturn] isEqualToString:@"0"] ? @"یک طرفه" :@"دو طرفه";
    
    
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


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [DataCollector sharedInstance].order = (Order*)([tableItems objectAtIndex:indexPath.row]);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.getData = nil;
    [timer invalidate];
    [self performSegueWithIdentifier:@"order" sender:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)AddBackgroundStaff
{
    containerView = [[UIView alloc]initWithFrame:self.view.frame];
    containerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:containerView];
    
    RadialGradient *radialView = [[RadialGradient alloc] initWithFrame:containerView.frame];
    radialView.backgroundColor = [UIColor colorWithRed:118/255.f green:106/255.f blue:247/255.f alpha:.9];
    [containerView insertSubview:radialView atIndex:0];
    
    indicator = [[InstagramActivityIndicator alloc]initWithFrame:CGRectMake(0, 0, containerView.frame.size.width - 75, containerView.frame.size.width - 75)];
    indicator.lineWidth = 1;
    indicator.strokeColor = [UIColor whiteColor];
    indicator.numSegments = 50;
    indicator.rotationDuration = 10;
    indicator.animationDuration = 1.5;
    indicator.center = self.view.center;
    [containerView addSubview:indicator];
    [indicator startAnimating];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(containerView.frame.size.width/2-75,containerView.frame.size.height/2-20, 150, 40)];
    label.text=@"در انتظار دریافت درخواست";
    label.textColor=[UIColor whiteColor];
    label.backgroundColor =[UIColor clearColor];
    label.adjustsFontSizeToFitWidth=YES;
    label.font =[UIFont fontWithName:@"IRANSans" size:14];
    label.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:label];
}


-(void)AnimateViewDown
{
    isViewDown = YES;
    
    [UIView animateWithDuration:.8 animations:^(){
    
    containerView.frame = CGRectMake(containerView.frame.origin.x, self.view.frame.size.height-50, containerView.frame.size.width, 50);
    
    } completion:^(BOOL finished){
    
        if (finished) {
            [UIView animateWithDuration:.2 animations:^(){
            
                indicator.frame = CGRectMake(20, containerView.frame.size.height/2-17.5, 35, 35);
                
                label.frame = CGRectMake(containerView.frame.size.width/2-75,containerView.frame.size.height/2-20, 150, 40);
                
            }];
        }
    }];

}

-(void)AnimateViewUp
{
    isViewDown  =NO;

    [UIView animateWithDuration:.8 animations:^(){
        
        containerView.frame = CGRectMake(containerView.frame.origin.x, 0, containerView.frame.size.width, self.view.frame.size.height);
        indicator.frame =CGRectMake(0, 0, containerView.frame.size.width - 75, containerView.frame.size.width - 75);
        indicator.center = containerView.center;
        label.frame = CGRectMake(containerView.frame.size.width/2-75,containerView.frame.size.height/2-20, 150, 40);
    } completion:^(BOOL finished){
        
        if (finished) {
            
        }
    }];

}


-(void)CustomizeNavigationTitle
{
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text=@"درخواست ها";
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

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}


@end
