//
//  DataCollector.h
//  Motori
//
//  Created by adb on 2/14/17.
//  Copyright © 2017 Arena. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"

@interface DataCollector : NSObject
+(DataCollector *)sharedInstance;
@property (nonatomic,strong) NSString *fullname;
@property (nonatomic,strong) NSString *totalCarCleaned;
@property (nonatomic,strong) NSString *rank;
@property (nonatomic,strong) NSString *score;
@property (nonatomic,strong) NSString *sumScore;
@property (nonatomic,strong) NSString *totalOrder;
@property (nonatomic,strong) NSString *totalCanceled;
@property BOOL haveCurrentWork;
@property BOOL accessible;
@property (nonatomic,strong) NSString *phonenumber;
@property (nonatomic,strong) NSString *account;
@property (nonatomic,strong) NSString *version;
@property (nonatomic,strong) NSString *image;
@property (nonatomic,strong) NSString *accountnumber;
@property (nonatomic,strong) NSString *vehicle;
@property (nonatomic,strong) NSString *vehicleplate;
@property (nonatomic,strong) Order *order;
@end
