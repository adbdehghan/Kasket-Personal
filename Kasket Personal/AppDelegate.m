//
//  AppDelegate.m
//  Kasket Personal
//
//  Created by aDb on 3/7/17.
//  Copyright © 2017 Arena. All rights reserved.
//

#import "AppDelegate.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "DBManager.h"
@import GoogleMaps;

@interface AppDelegate () <CLLocationManagerDelegate>
@property (strong, nonatomic) DataDownloader *getData;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [GMSServices provideAPIKey:@"AIzaSyCvhTlttp-AAadtH5Azgjg8lZBhWKVJF1o"];
    NSLog(@"didFinishLaunchingWithOptions");
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.shareModel = [LocationManager sharedManager];

    // Override point for customization after application launch.
    //create CLLocationManager variable
    locationManager = [[CLLocationManager alloc] init];
    //set delegate
    locationManager.delegate = self;
    [locationManager requestAlwaysAuthorization];
    
    app = [UIApplication sharedApplication];
    // This is the most important property to set for the manager. It ultimately determines how the manager will
    // attempt to acquire location and thus, the amount of power that will be consumed.
    
    if ([locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        [locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    locationManager.pausesLocationUpdatesAutomatically = NO;
    locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessibilityChanged)
                                                 name:@"accessibilityChanged"
                                               object:nil];
    
    return YES;
}

-(void)accessibilityChanged
{
    if (!([DataCollector sharedInstance].accessible)) {
        [timer invalidate];
        [timerActive invalidate];
        [locationManager stopUpdatingLocation];
    }
    else
    {
        if (!timerActive.isValid) {
            timerActive = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                           target:self
                                                         selector:@selector(startTrackingActive)
                                                         userInfo:nil
                                                          repeats:YES];
        }
    }
    

}

-(void)UpdateLocation
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
        
        [self.getData PushLocation:st.accesstoken Lat:[NSString stringWithFormat:@"%f",self.shareModel.myLocation.latitude] Lon:[NSString stringWithFormat:@"%f",self.shareModel.myLocation.longitude] withCallback:callback];

}


-(void)applicationDidBecomeActive:(UIApplication *)application
{
    [timer invalidate];
    
    timerActive = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                   target:self
                                                 selector:@selector(startTrackingActive)
                                                 userInfo:nil
                                                  repeats:YES];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
    [timerActive invalidate];
    [locationManager stopUpdatingLocation];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    locationManager.pausesLocationUpdatesAutomatically = NO;
    locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    [locationManager startUpdatingLocation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    [locationManager stopUpdatingLocation];
    
    __block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                      target:self
                                                    selector:@selector(startTrackingBg)
                                                    userInfo:nil
                                                     repeats:YES];
    
    
}

-(void)startTrackingBg {
    
    if ([DataCollector sharedInstance].accessible) {
        [locationManager startUpdatingLocation];
        NSLog(@"App is running in background");
        [self UpdateLocation];
    }
}


-(void)startTrackingActive {

    if ([DataCollector sharedInstance].accessible) {
        [locationManager startUpdatingLocation];
        NSLog(@"App is running ");
        [self UpdateLocation];
    }
}

//starts automatically with locationManager
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
        self.shareModel.myLocation = newLocation.coordinate;
        [locationManager stopUpdatingLocation];
    
}

- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
}


@end
