//
//  MainViewController.m
//  Kasket Personal
//
//  Created by aDb on 3/27/17.
//  Copyright © 2017 Arena. All rights reserved.
//

#import "MainViewController.h"
#import "ASJCollectionViewFillLayout.h"
#import "DataCollector.h"
#import "MapCharacter.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "DBManager.h"
#import "FCAlertView.h"

@interface MainViewController ()<ASJCollectionViewFillLayoutDelegate>
@property (strong, nonatomic) ASJCollectionViewFillLayout *aLayout;
@property (copy, nonatomic) NSArray *objects;
@property (copy, nonatomic) NSArray *textObjects;
@property (strong, nonatomic) DataDownloader *getData;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self CustomizeNavigationTitle];
    [self setup];
}

#pragma mark - Setup

- (void)setup
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:[[DataCollector sharedInstance].account integerValue]]];
    
    self.accountLabel.text = [NSString stringWithFormat:@"%@ تومان",[MapCharacter MapCharacter:formatted]];
    
    NSString *privateFormatted = [formatter stringFromNumber:[NSNumber numberWithInteger:[[DataCollector sharedInstance].privateAccount integerValue]]];
    self.privateAccountLabel.text = [NSString stringWithFormat:@"%@ تومان",[MapCharacter MapCharacter:privateFormatted]];
    
    [self setNeedsStatusBarAppearanceUpdate];
    self.accessibilityContainer.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.accessibilityContainer.layer.shadowRadius = 5;
    self.accessibilityContainer.layer.shadowOffset = CGSizeMake(1, 1);
    self.accessibilityContainer.layer.shadowOpacity = .7;
    self.accessibilityContainer.layer.masksToBounds = NO;
    
    self.accountContainer.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.accountContainer.layer.shadowRadius = 5;
    self.accountContainer.layer.shadowOffset = CGSizeMake(1, 1);
    self.accountContainer.layer.shadowOpacity = .7;
    self.accountContainer.layer.masksToBounds = NO;
    [self setupCollectionViewData];
    [self setupLayout];
    [self SetAccessibilitySwitch];
}

-(void)SetAccessibilitySwitch
{
    if ( [DataCollector sharedInstance].accessible ) {
        [_accessibilitySwitch setOn:YES animated:NO];
        self.accessibilityLabel.text = @"در دسترس";
    }
}

-(void)OutOfReach
{
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            
            
        }
        else
        {
            
            
        }
    };
    
    Settings *st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
    [self.getData SetOutOfReach:st.accesstoken withCallback:callback];



}

- (void)setupLayout
{
    _aLayout = [[ASJCollectionViewFillLayout alloc] init];
    _aLayout.delegate = self;
    _aLayout.direction = ASJCollectionViewFillLayoutHorizontal;
    _aLayout.stretchesLastItems = YES;
    _aCollectionView.collectionViewLayout = _aLayout;
}

- (void)setupCollectionViewData
{
    NSArray *temp = [[NSArray alloc] init];
    
    temp = @[@"history.png",@"transactions.png",@"settings.png",@"orders.png",@"rank.png",@"map.png"];
    _objects = [NSArray arrayWithArray:temp];
    
    _textObjects = @[@"تاریخچه سفارشات",@"گردش مالی",@"درباره کاسکت",@"درخواست ها",@"رتبه و امتیاز",@"نقشه"];
}


- (IBAction)AccessibilityChanged:(id)sender {
    
    switch (self.accessibilitySwitch.on) {
        case YES:
            self.accessibilityLabel.text = @"در دسترس";
            [DataCollector sharedInstance].accessible = YES;
            break;
        case NO:
            self.accessibilityLabel.text = @"خارج از دسترس";
            [self OutOfReach];
            [DataCollector sharedInstance].accessible = NO;
            
            break;            
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"accessibilityChanged"
     object:self];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    UILabel *lbl = (UILabel *)[cell viewWithTag:1];
    lbl.text = _textObjects[indexPath.row];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:2];
    imageView.image = [UIImage imageNamed:_objects[indexPath.row]];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"history" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"transactions" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"setting" sender:self];
            break;
        case 3:
            if (self.accessibilitySwitch.isOn) {
                [self performSegueWithIdentifier:@"orders" sender:self];
            }
            else
            {
                FCAlertView *alert = [[FCAlertView alloc] init];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:nil
                          withSubtitle:@"برای مشاهده ی درخواست ها باید در دسترس باشید"
                       withCustomImage:[UIImage imageNamed:@"alert.png"]
                   withDoneButtonTitle:@"تایید"
                            andButtons:nil];
            }
            break;
        case 4:
            [self performSegueWithIdentifier:@"rank" sender:self];
            break;
        case 5:
            [self performSegueWithIdentifier:@"map" sender:self];
            break;
            
        default:
            break;
    }
}

#pragma mark - ASJCollectionViewFillLayoutDelegate

- (NSInteger)numberOfItemsInSide
{
    return 3;
}

- (CGFloat)itemLength
{
    return self.view.frame.size.width/2-3;
}

- (CGFloat)itemSpacing
{
    return 2.0f;
}

-(void)CustomizeNavigationTitle
{
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text=@"کاسکت";
    label.textColor=[UIColor whiteColor];
    label.backgroundColor =[UIColor clearColor];
    label.adjustsFontSizeToFitWidth=YES;
    label.font =[UIFont fontWithName:@"IRANSans" size:17];
    label.textAlignment = NSTextAlignmentCenter;
    
    self.navigationItem.titleView=label;
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
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
