//
//  PersonalTransactionsTableViewController.m
//  Kasket Personal
//
//  Created by adb on 6/15/17.
//  Copyright © 2017 Arena. All rights reserved.
//

#import "PersonalTransactionsTableViewController.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "DBManager.h"
#import "UIScrollView+UzysAnimatedGifLoadMore.h"
#import "Transaction.h"
#import "TransactionTableViewCell.h"
#import "MapCharacter.h"
#import "FCAlertView.h"

@interface PersonalTransactionsTableViewController ()
{
    NSMutableArray *tableItems;
    UIActivityIndicatorView *activityIndicator;
    UILabel *clearMessage;
    NSString *credit;
    IBOutlet UIButton *raiseCredit;
}
@property (strong, nonatomic) DataDownloader *getData;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic,assign) BOOL useActivityIndicator;
@property (nonatomic, assign) NSInteger rowsCount;
@end
#define IS_IOS7 (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1 && floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)
#define IS_IOS8  ([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending)
#define IS_IPHONE6PLUS ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && [[UIScreen mainScreen] nativeScale] == 3.0f)

@implementation CALayer (Additions)

- (void)setBorderColorFromUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}

@end
@implementation PersonalTransactionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    raiseCredit.layer.cornerRadius = raiseCredit.frame.size.height/2;
    raiseCredit.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    raiseCredit.layer.shadowRadius = 5;
    raiseCredit.layer.shadowOffset = CGSizeMake(1, 1);
    raiseCredit.layer.shadowOpacity = .7;
    raiseCredit.layer.masksToBounds = NO;
    
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

            [strongSelf loadNextBatch];
            
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
            credit = [data valueForKey:@"privateAccount"];
            data = [data valueForKey:@"data"];
            for (NSDictionary *item in (NSMutableArray*)data) {
                Transaction *transaction = [[Transaction alloc]init];
                transaction.Amount = [item valueForKey:@"amount"];
                transaction.Desc =[item valueForKey:@"description"];
                transaction.Time =[item valueForKey:@"time"];
                transaction.IsIncrease = [item valueForKey:@"transactionType"];
                self.totalPages = [[item valueForKey:@"totalpage"] integerValue];
                
                [tableItems addObject:transaction];
                [temp addObject:transaction];
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
    
    
    [self.getData Transactions:st.accesstoken Page:[NSString stringWithFormat:@"%ld",(long)self.currentPage] PrivateAccount:@"True" withCallback:callback];
    
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    Manually trigger
    [self.tableView triggerLoadMoreActionHandler];
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
    TransactionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell)
        cell = [[TransactionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    
    Transaction *item = [[Transaction alloc]init];
    item = [tableItems objectAtIndex:indexPath.row];
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:[item.Amount integerValue]]];
    cell.amountLabel.text =[NSString stringWithFormat:@"%@ تومان",[MapCharacter MapCharacter:formatted]];
    cell.dateTimeLabel.text =[MapCharacter MapCharacter:item.Time];
    cell.descLabel.text = item.Desc;
    cell.statusLabel.text = [self ParseTransactionType:item.IsIncrease];
    cell.backgroundColor = [UIColor clearColor];
    
    cell.containerView.layer.shadowOffset = CGSizeMake(0, 0);
    cell.containerView.layer.shadowRadius = 2;
    cell.containerView.layer.shadowOpacity = 0.15;
    cell.containerView.layer.cornerRadius = 8;
    
    return cell;
}

- (IBAction)RaiseCreditEvent:(id)sender
{
    
    Settings *st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.blurBackground = 1;
    alert.bounceAnimations = 1;
    alert.dismissOnOutsideTouch = 1;
    alert.fullCircleCustomImage = NO;
    [alert makeAlertTypeSuccess];
    
    [alert addTextFieldWithPlaceholder:@"-----" andTextReturnBlock:^(NSString *text) {
        
    }];
    
    
    [alert showAlertInView:self
                 withTitle:@""
              withSubtitle:@"مبلغ مورد نظر را وارد نمایید"
           withCustomImage:[UIImage imageNamed:@"alert.png"]
       withDoneButtonTitle:@"تایید"
                andButtons:nil];
    
    [alert doneActionBlock:^{
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://kaskett.ir/payment/pay?amount=%@&phoneNumber=%@",alert.textField.text,st.settingId ]];
        
        if (![[UIApplication sharedApplication] openURL:url]) {
            NSLog(@"%@%@",@"Failed to open url:",[url description]);
        }
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)CustomizeNavigationTitle
{
    
    // Get the previous view controller
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    // Create a UIBarButtonItem
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)];
    // Associate the barButtonItem to the previous view
    //    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    UIButton *settingButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    
}

-(NSString*)ParseTransactionType:(NSString*)transactionType
{
    switch ([transactionType integerValue]) {
        case 2:
            return @"واریز به کارت";
        case 0:
            return @"افزایش اعتبار";
        case 3:
            return @"پرداخت درگاه";
        case 1:
            return @"کاهش اعتبار";
        case 4:
            return @"کاهش اعتبار";
    }
    return @"نا معلوم";
}

- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
}
@end
