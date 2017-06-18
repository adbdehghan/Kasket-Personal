//
//  MapViewController.m
//  Kasket Personal
//
//  Created by aDb on 4/16/17.
//  Copyright © 2017 Arena. All rights reserved.
//

#import "MapViewController.h"
@import GoogleMaps;

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
@interface MapViewController ()<CLLocationManagerDelegate>
{
    GMSMapView *mapView;
}
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self CustomizeNavigationTitle];
    [self setupMapView];
    [self InitLocationManager];
}


-(void)InitLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    

    [self.locationManager startUpdatingLocation];

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    
    [self DrawCircle:location.coordinate];
    
    [self.locationManager stopUpdatingLocation];
}

-(void)setupMapView {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:35.6961
                                                            longitude:51.4231
                                                                 zoom:11];
    
    mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height) camera:camera];
    
    mapView.myLocationEnabled = YES;
    
    //Shows the compass button on the map
    mapView.settings.compassButton = YES;
    
    //Shows the my location button on the map
    mapView.settings.myLocationButton = YES;
    mapView.delegate = self;
    
    [self.view addSubview:mapView];
}

-(void)DrawCircle:(CLLocationCoordinate2D)coordinate
{
    GMSCircle *circ = [GMSCircle circleWithPosition:coordinate
                                             radius:1000];
    
    circ.fillColor = [UIColor colorWithRed:0.07 green:.6 blue:.1 alpha:.15];
    circ.strokeColor = [UIColor clearColor];
    circ.strokeWidth = 1;
    circ.map = mapView;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                                            longitude:coordinate.longitude
                                                                 zoom:14.0];
    [mapView animateToCameraPosition:camera];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)CustomizeNavigationTitle
{
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text=@"محدوده پوشش دهی";
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
