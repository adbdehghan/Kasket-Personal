//
//  RankViewController.m
//  Kasket Personal
//
//  Created by aDb on 4/16/17.
//  Copyright © 2017 Arena. All rights reserved.
//

#import "RankViewController.h"
#import "MapCharacter.h"
#import "DataCollector.h"
#import "TPFloatRatingView.h"

@interface RankViewController ()<TPFloatRatingViewDelegate>
{
    IBOutlet UIView *headerView;
    IBOutlet UIView *secondView;
    IBOutlet UIView *rankView;
    IBOutlet UIView *rankInnerView;
    IBOutlet UIView *scoreView;
    IBOutlet UIView *scoreInnerView;
    IBOutlet UIView *avatarContainerView;
    IBOutlet UIImageView *avatarImageView;
    IBOutlet UILabel *fullNameLabel;
    IBOutlet UILabel *allOrdersLabel;
    IBOutlet UILabel *doneOrderLabel;
    IBOutlet UILabel *canceledOrdersLabel;
    IBOutlet UILabel *scoreLabel;
    IBOutlet UILabel *rankLabel;
}
@property (strong, nonatomic) IBOutlet TPFloatRatingView *ratingView;

@end

@implementation RankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self CustomizeNavigationTitle];
    [self CreateShadow];
    [self FillUIComponent];
}

-(void)FillUIComponent
{
    self.ratingView.delegate = self;
    self.ratingView.emptySelectedImage = [UIImage imageNamed:@"StarEmpty"];
    self.ratingView.fullSelectedImage = [UIImage imageNamed:@"StarFull"];
    self.ratingView.contentMode = UIViewContentModeScaleAspectFill;
    self.ratingView.maxRating = 5;
    self.ratingView.minRating = 1;
    self.ratingView.editable = YES;
    self.ratingView.halfRatings = NO;
    self.ratingView.floatRatings = NO;
    self.ratingView.rating = [[DataCollector sharedInstance].score floatValue];
    
    fullNameLabel.text = [DataCollector sharedInstance].fullname;
    allOrdersLabel.text =[MapCharacter MapCharacter:[DataCollector sharedInstance].totalOrder];
    doneOrderLabel.text = [MapCharacter MapCharacter:[DataCollector sharedInstance].totalCarCleaned];
    canceledOrdersLabel.text = [MapCharacter MapCharacter:[DataCollector sharedInstance].totalCanceled];
    scoreLabel.text = [MapCharacter MapCharacter:[DataCollector sharedInstance].sumScore];
    rankLabel.text = [MapCharacter MapCharacter:[DataCollector sharedInstance].rank];
    
    NSString *str = @"data:image/jpg;base64,";
    str = [str stringByAppendingString:[DataCollector sharedInstance].image];
    
    NSURL *url = [NSURL URLWithString:str];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *ret = [UIImage imageWithData:imageData];
    avatarImageView.image = ret;
}

-(void)CreateShadow
{
    headerView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    headerView.layer.shadowRadius = 5;
    headerView.layer.shadowOffset = CGSizeMake(1, 1);
    headerView.layer.shadowOpacity = .7;
    headerView.layer.masksToBounds = NO;
    
    secondView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    secondView.layer.shadowRadius = 5;
    secondView.layer.shadowOffset = CGSizeMake(1, 1);
    secondView.layer.shadowOpacity = .7;
    secondView.layer.masksToBounds = NO;

    avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height/2;
    avatarImageView.clipsToBounds = YES;
    
    avatarContainerView.layer.cornerRadius = avatarContainerView.frame.size.height/2;
    avatarContainerView.clipsToBounds = YES;
    
    rankView.layer.cornerRadius = rankView.frame.size.height/2;
    rankView.clipsToBounds = YES;
    
    rankInnerView.layer.cornerRadius = rankInnerView.frame.size.height/2;
    rankInnerView.clipsToBounds = YES;
    
    scoreView.layer.cornerRadius = scoreView.frame.size.height/2;
    scoreView.clipsToBounds = YES;
    
    scoreInnerView.layer.cornerRadius = scoreInnerView.frame.size.height/2;
    scoreInnerView.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)CustomizeNavigationTitle
{
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text=@"رتبه و امتیاز";
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
