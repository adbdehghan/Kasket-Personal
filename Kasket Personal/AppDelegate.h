//
//  AppDelegate.h
//  Kasket Personal
//
//  Created by aDb on 3/7/17.
//  Copyright © 2017 Arena. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{

   CLLocationManager * locationManager;
    UIApplication *app;
    NSTimer *timer;
    NSTimer *timerActive;

}
@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) LocationManager * shareModel;

@end

