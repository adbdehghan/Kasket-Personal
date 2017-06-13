//
//  OrderViewController.m
//  Kasket Personal
//
//  Created by adb on 4/12/17.
//  Copyright © 2017 Arena. All rights reserved.
//

#import "OrderViewController.h"
#import "MapCharacter.h"
#import "UIImage+OHPDF.h"
@import GoogleMaps;

@interface OrderViewController ()<GMSMapViewDelegate>
{
    IBOutlet UIButton *acceptButton;
    IBOutlet UILabel *sourceAddressLabel;
    IBOutlet UILabel *destinationAddressLabel;
    IBOutlet UILabel *haveReturnLabel;
    UIButton *arriveButton;
    UIButton *cancelButton;
    UIView *introView;
    UIView *acceptedView;
    GMSMapView *mapView;
}
@end

@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self CustomizeNavigationTitle];
    [self FillUIComponents];
    [self CreateShadow];
    [self setupMapView];
    
}

-(void)FillUIComponents
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:[_order.price integerValue]]];
    
    [acceptButton setTitle:[NSString stringWithFormat:@"پذیرفتن (%@ تومان)",[MapCharacter MapCharacter:formatted]] forState:UIControlStateNormal];
    sourceAddressLabel.text = _order.sourceAddress;
    destinationAddressLabel.text = _order.destinationAddress;
    haveReturnLabel.text =  [[NSString stringWithFormat:@"%@",_order.haveReturn] isEqualToString:@"0"] ? @"یک طرفه" :@"دو طرفه";
    
}

-(void)CreateShadow
{
    _mapView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _mapView.layer.shadowRadius = 5;
    _mapView.layer.shadowOffset = CGSizeMake(1, 1);
    _mapView.layer.shadowOpacity = .7;
    _mapView.layer.masksToBounds = NO;
}

-(void)setupMapView {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:35.6961
                                                            longitude:51.4231
                                                                 zoom:12];
    
    mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, _mapView.frame.size.width, _mapView.frame.size.height) camera:camera];
    
    mapView.myLocationEnabled = NO;
    
    //Shows the compass button on the map
    mapView.settings.compassButton = NO;
    
    //Shows the my location button on the map
    mapView.settings.myLocationButton = NO;
    mapView.delegate = self;
    
    [_mapView addSubview:mapView];
    [self DropPinsOnMap];
}

-(void)DropPinsOnMap
{
    CLLocationCoordinate2D sourceLocation = CLLocationCoordinate2DMake([_order.sourceLat doubleValue],[_order.sourceLon doubleValue]);
    CLLocationCoordinate2D destinationLocation = CLLocationCoordinate2DMake([_order.destinationLat doubleValue],[_order.destinationLon doubleValue]);
    
    GMSMarker *sourceMarker = [[GMSMarker alloc] init];
    sourceMarker.appearAnimation = YES;
    sourceMarker.flat = YES;
    
    
    sourceMarker.position = sourceLocation;
    sourceMarker.map = mapView;
    sourceMarker.icon = [UIImage imageWithPDFNamed:@"sourcemarker.pdf"
                                         fitInSize:CGSizeMake(50, 50)];
    
    GMSMarker *desmarker = [[GMSMarker alloc] init];
    desmarker.appearAnimation = YES;
    desmarker.flat = YES;
    desmarker.position = destinationLocation;
    desmarker.map = mapView;
    desmarker.icon =  [UIImage imageWithPDFNamed:@"destinationmarker.pdf"
                                       fitInSize:CGSizeMake(50, 50)];
    
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:sourceLocation coordinate:destinationLocation];
    GMSCameraPosition *camera = [mapView cameraForBounds:bounds insets:UIEdgeInsetsMake(100, 60, 70, 60)];
    
    [mapView animateToCameraPosition:camera];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)CustomizeNavigationTitle
{
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text=@"درخواست";
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


@end
