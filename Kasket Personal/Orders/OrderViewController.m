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
#import "DataDownloader.h"
#import "Settings.h"
#import "DBManager.h"
#import "FCAlertView.h"
#import "UIWindow+YzdHUD.h"
@import GoogleMaps;

@interface OrderViewController ()<GMSMapViewDelegate>
{
    IBOutlet UIButton *acceptButton;
    IBOutlet UIButton *arrivedAndDoneButton;
    IBOutlet UIButton *payedByCashButton;
    IBOutlet UIButton *cancelButton;
    IBOutlet UIButton *toggleButton;
    IBOutlet UIButton *sourceNumberButton;
    IBOutlet UIButton *destinationNumberButton;
    IBOutlet UILabel *sourceAddressLabel;
    IBOutlet UILabel *destinationAddressLabel;
    IBOutlet UILabel *sourceAddressLabelAccepted;
    IBOutlet UILabel *destinationAddressLabelAccepted;
    IBOutlet UILabel *haveReturnLabel;
    IBOutlet UILabel *haveReturnLabelAccepted;
    IBOutlet UILabel *paymentLabel;
    IBOutlet UILabel *priceLabel;
    IBOutlet UILabel *sourceFullNameLabel;
    IBOutlet UILabel *destinationFullNameLabel;
    IBOutlet UILabel *sourceAddressDetailLabel;
    IBOutlet UILabel *destinationAddressDetailLabel;
    IBOutlet UIView *toggleView;
    
    NSTimer *timer;
    GMSMapView *mapView;
    BOOL isShown;
    BOOL isAlertShown;
}
@property (strong, nonatomic) DataDownloader *getData;

@end

@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self CustomizeNavigationTitle];
    [self FillUIComponents];
    [self CheckState];
    [self CreateShadow];
    [self setupMapView];
    [self AddLongPressGesture];
    [self StyleButtons];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    self.getData = nil;
    [timer invalidate];
}


-(void)StyleButtons
{
    payedByCashButton.layer.cornerRadius = 5;
    
}

- (IBAction)ToggleEvent:(id)sender
{
    if (!isShown) {
        isShown = YES;
        toggleView.hidden = NO;
    }
    else
    {
        isShown = NO;
        toggleView.hidden = YES;
    }
}

-(void)CheckState
{
    if ( [DataCollector sharedInstance].haveCurrentWork) {
        _bottomView.hidden = YES;
        self.acceptedView.hidden = NO;
        toggleButton.hidden = NO;
        [self GetOrder];
    }
}

- (IBAction)CallSourceNumber:(id)sender
{
   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",_order.phoneNumber]]];
}

- (IBAction)CallDestinationNumber:(id)sender
{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",_order.destinationPhoneNumber]]];
}

-(void)AddLongPressGesture{
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [acceptButton addGestureRecognizer:longPress];
    
    UILongPressGestureRecognizer *arrivedAndDonelongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(ArrivedAndDonelongPress:)];
    [arrivedAndDoneButton addGestureRecognizer:arrivedAndDonelongPress];
    
    UILongPressGestureRecognizer *cancellongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(CancelLongPress:)];
    [cancelButton addGestureRecognizer:cancellongPress];
    
    UILongPressGestureRecognizer *payedLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(PayedLongPress:)];
    [payedByCashButton addGestureRecognizer:payedLongPress];
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateBegan ) {
        [self AcceptOrder:@"0"];
    }
}

- (void)ArrivedAndDonelongPress:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateBegan ) {
        NSString *status =[NSString stringWithFormat:@"%@", _order.status];
        if ([status isEqualToString:@"2"]) {
            [self AcceptOrder:@"1"];
        }
        else if ([status isEqualToString:@"3"]) {
            [self AcceptOrder:@"2"];
        }
        else if ([status isEqualToString:@"4"]) {
            [self AcceptOrder:@"3"];
        }
    }
}

- (void)CancelLongPress:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateBegan ) {
        [self AcceptOrder:@"4"];
    }
}

- (void)PayedLongPress:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateBegan ) {
        [self AcceptOrder:@"5"];
    }
}

- (IBAction)AcceptTouched:(id)sender {
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    [alert makeAlertTypeCaution];
    [alert showAlertInView:self
                 withTitle:nil
              withSubtitle:@"لطفا دکمه را نگهدارید"
           withCustomImage:[UIImage imageNamed:@"alert.png"]
       withDoneButtonTitle:@"تایید"
                andButtons:nil];
}

-(void)AcceptOrder:(NSString*)action
{
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        [self.view.window showHUDWithText:nil Type:ShowDismiss Enabled:YES];
        if (wasSuccessful) {
            
            NSString *status =[NSString stringWithFormat:@"%@",[data valueForKey:@"status"] ];
            if ([status isEqualToString:@"0"]) {
                FCAlertView *alert = [[FCAlertView alloc] init];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:nil
                          withSubtitle:[data valueForKey:@"message"]
                       withCustomImage:[UIImage imageNamed:@"alert.png"]
                   withDoneButtonTitle:@"تایید"
                            andButtons:nil];
            }
            else if ([status isEqualToString:@"2"])
            {
                _acceptedView.hidden = NO;
                _bottomView.hidden = YES;
                toggleButton.hidden = NO;
                [DataCollector sharedInstance].order.orderId =[NSString stringWithFormat:@"%@",[data valueForKey:@"data"]];
                [self DisableBackButton];
                [self GetOrder];
            }
            else if ([status isEqualToString:@"3"])
            {
                [arrivedAndDoneButton setTitle:@"رسیدن به گیرنده" forState:UIControlStateNormal];
            }
            else if ([status isEqualToString:@"4"])
            {
                [arrivedAndDoneButton setTitle:@"پایان عملیات" forState:UIControlStateNormal];
                FCAlertView *alert = [[FCAlertView alloc] init];
                [alert makeAlertTypeCaution];
                [alert showAlertInView:self
                             withTitle:nil
                          withSubtitle:[data valueForKey:@"message"]
                       withCustomImage:[UIImage imageNamed:@"alert.png"]
                   withDoneButtonTitle:@"تایید"
                            andButtons:nil];
            }
            else if ([status isEqualToString:@"6"])
            {
//                FCAlertView *alert = [[FCAlertView alloc] init];
//                [alert makeAlertTypeCaution];
//                [alert showAlertInView:self
//                             withTitle:nil
//                          withSubtitle:@"درخواست لغو شد"
//                       withCustomImage:[UIImage imageNamed:@"alert.png"]
//                   withDoneButtonTitle:@"تایید"
//                            andButtons:nil];
                [timer invalidate];
                 self.getData = nil;
                [DataCollector sharedInstance].haveCurrentWork = NO;
                [DataCollector sharedInstance].order = nil;
                [self performSegueWithIdentifier:@"tomain" sender:self];
            }
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"👻"
                                                            message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
                                                           delegate:self
                                                  cancelButtonTitle:@"خب"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    };
    
    Settings *st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    [self.view.window showHUDWithText:@"لطفا صبر کنید" Type:ShowLoading Enabled:YES];
    [self.getData AcceptOrder:st.accesstoken OrderId:_order.orderId OrderAction:action withCallback:callback];
    
}


-(void)GetOrder
{
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        
        if (wasSuccessful) {
            
            [self ParseOrderData:data];
            
            timer =  [NSTimer scheduledTimerWithTimeInterval:3.f
                                                      target:self
                                                    selector:@selector(GetOrder)
                                                    userInfo:nil
                                                     repeats:NO];
            
        }
        else
        {
            
        }
    };
    
    Settings *st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    [self.getData GetOrder:st.accesstoken OrderId:_order.orderId  withCallback:callback];
    
}

-(void)ParseOrderData:(NSMutableDictionary*)item
{
    _order = [[Order alloc]init];
    _order.orderId = [item valueForKey:@"id"];
    _order.status = [item valueForKey:@"status"];
    _order.orderTime =[item valueForKey:@"orderTime"];
    _order.orderType =[item valueForKey:@"orderType"];
    _order.price = [item valueForKey:@"price"];
    _order.haveReturn =[item valueForKey:@"roundtrip"];
    _order.sourceAddress =[item valueForKey:@"sourceAddress"];
    _order.destinationAddress =[item valueForKey:@"destinationAddress"];
    _order.status =[item valueForKey:@"status"];
    _order.sourceBell =[item valueForKey:@"sourceBell"];
    _order.sourcePlate =[item valueForKey:@"sourceNum"];
    _order.destinationBell =[item valueForKey:@"destinationBell"];
    _order.destinationPlate =[item valueForKey:@"destinationNum"];
    _order.destinationFullName = [item valueForKey:@"destinationFullName"];
    _order.fullName = [item valueForKey:@"fullName"];
    _order.paymentStatus =[NSString stringWithFormat:@"%@",[item valueForKey:@"paymentstatus"]];
    _order.payInDestination = [NSString stringWithFormat:@"%@",[item valueForKey:@"payinDestination"]];
    NSDictionary *sourceLocation = [item valueForKey:@"sourcelocation"];
    _order.sourceLat = [sourceLocation valueForKey:@"latitude"];
    _order.sourceLon = [sourceLocation valueForKey:@"longitude"];
    _order.phoneNumber = [item valueForKey:@"phonenumber"];
    _order.destinationPhoneNumber = [item valueForKey:@"destinationPhoneNumber"];
    NSDictionary *destLocation = [item valueForKey:@"destinationlocation"];
    _order.destinationLat = [destLocation valueForKey:@"latitude"];
    _order.destinationLon = [destLocation valueForKey:@"longitude"];
    
    if ([_order.paymentStatus isEqualToString:@"1"]) {
        paymentLabel.text = @"هزینه پرداخت شده لطفا وجه نقد دریافت نکنید";
    }
    
    [sourceNumberButton setTitle:_order.phoneNumber == [NSNull null] ? @"-" : [MapCharacter MapCharacter:_order.phoneNumber] forState:UIControlStateNormal];
    [destinationNumberButton setTitle:_order.destinationPhoneNumber == [NSNull null] ? @"-" : [MapCharacter MapCharacter:_order.destinationPhoneNumber] forState:UIControlStateNormal];
    
    NSString *sourceAddressDetail = [NSString stringWithFormat:@"پلاک %@  زنگ یا واحد %@",_order.sourcePlate == [NSNull null] ? @"-" : [MapCharacter MapCharacter:_order.sourcePlate],_order.sourceBell== [NSNull null] ? @"-" :[MapCharacter MapCharacter:_order.sourceBell]];
    sourceAddressDetailLabel.text = sourceAddressDetail;
    
    NSString *destinationAddressDetail = [NSString stringWithFormat:@"پلاک %@  زنگ یا واحد %@",_order.destinationPlate == [NSNull null] ? @"-" :[MapCharacter MapCharacter: _order.destinationPlate],_order.destinationBell== [NSNull null] ? @"-" :[MapCharacter MapCharacter:_order.destinationBell]];
    destinationAddressDetailLabel.text = destinationAddressDetail;
    
    sourceFullNameLabel.text = _order.fullName == [NSNull null] ? @"-" : _order.fullName;
    destinationFullNameLabel.text = _order.destinationFullName == [NSNull null] ? @"-" : _order.destinationFullName;
    
     if ([[NSString stringWithFormat:@"%@", _order.status] isEqualToString:@"7"] && !isAlertShown)
    {
        isAlertShown = YES;
        
        FCAlertView *alert = [[FCAlertView alloc] init];
        [alert makeAlertTypeWarning];
        [alert showAlertInView:self
                     withTitle:nil
                  withSubtitle:@"درخواست لغو شد"
               withCustomImage:[UIImage imageNamed:@"alert.png"]
           withDoneButtonTitle:@"تایید"
                    andButtons:nil];
        
        [alert doneActionBlock:^{
            [timer invalidate];
            self.getData = nil;
            [DataCollector sharedInstance].haveCurrentWork = NO;
            [DataCollector sharedInstance].order = nil;
            [self performSegueWithIdentifier:@"tomain" sender:self];
        }];
        
        
    }
}

-(void)FillUIComponents
{
    if (_order == nil) {
        _order = [DataCollector sharedInstance].order;
    }
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:[_order.price integerValue]]];
    
    [acceptButton setTitle:[NSString stringWithFormat:@"پذیرفتن (%@ تومان)",[MapCharacter MapCharacter:formatted]] forState:UIControlStateNormal];
    sourceAddressLabel.text = _order.sourceAddress;
    destinationAddressLabel.text = _order.destinationAddress;
    haveReturnLabel.text =  [[NSString stringWithFormat:@"%@",_order.haveReturn] isEqualToString:@"0"] ? @"یک طرفه" :@"دو طرفه";
    haveReturnLabelAccepted.text = [[NSString stringWithFormat:@"%@",_order.haveReturn] isEqualToString:@"0"] ? @"یک طرفه" :@"دو طرفه";
    priceLabel.text = [NSString stringWithFormat:@"%@ تومان",[MapCharacter MapCharacter:formatted]];
     NSString *status =[NSString stringWithFormat:@"%@", _order.status];
    
    sourceAddressLabelAccepted.text = _order.sourceAddress;
    destinationAddressLabelAccepted.text = _order.destinationAddress;
    
    [sourceNumberButton setTitle:_order.phoneNumber == nil ? @"-" : [MapCharacter MapCharacter:_order.phoneNumber] forState:UIControlStateNormal];
    [destinationNumberButton setTitle:_order.destinationPhoneNumber == [NSNull null] ? @"-" : [MapCharacter MapCharacter:_order.destinationPhoneNumber] forState:UIControlStateNormal];
    
    NSString *sourceAddressDetail = [NSString stringWithFormat:@"پلاک %@  زنگ یا واحد %@",_order.sourcePlate == [NSNull null] ? @"-" : [MapCharacter MapCharacter:_order.sourcePlate],_order.sourceBell== [NSNull null] ? @"-" :[MapCharacter MapCharacter:_order.sourceBell]];
    sourceAddressDetailLabel.text = sourceAddressDetail;
    
    NSString *destinationAddressDetail = [NSString stringWithFormat:@"پلاک %@  زنگ یا واحد %@",_order.destinationPlate == [NSNull null] ? @"-" :[MapCharacter MapCharacter: _order.destinationPlate],_order.destinationBell== [NSNull null] ? @"-" :[MapCharacter MapCharacter:_order.destinationBell]];
    destinationAddressDetailLabel.text = destinationAddressDetail;
    
    sourceFullNameLabel.text = _order.fullName == [NSNull null] ? @"-" : _order.fullName;
    destinationFullNameLabel.text = _order.destinationFullName == [NSNull null] ? @"-" : _order.destinationFullName;
    
    if (_order.destinationPhoneNumber == [NSNull null]) {
        destinationNumberButton.enabled = NO;
    }
    if (_order.phoneNumber == nil) {
        sourceNumberButton.enabled = NO;
    }
    
    if ([status isEqualToString:@"3"]) {
        [arrivedAndDoneButton setTitle:@"رسیدن به گیرنده" forState:UIControlStateNormal];
    }
    else if ([status isEqualToString:@"4"]) {
        [arrivedAndDoneButton setTitle:@"پایان عملیات" forState:UIControlStateNormal];
    }
    
    if ([_order.paymentStatus isEqualToString:@"1"]) {
        paymentLabel.text = @"هزینه پرداخت شده لطفا وجه نقد دریافت نکنید";
    }
    if ([_order.payInDestination isEqualToString:@"1"]) {
        paymentLabel.text = @"هزینه را از دریافت کننده بگیرید";
    }
}

-(void)CreateShadow
{
    _mapView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _mapView.layer.shadowRadius = 5;
    _mapView.layer.shadowOffset = CGSizeMake(1, 1);
    _mapView.layer.shadowOpacity = .7;
    _mapView.layer.masksToBounds = NO;
    
    toggleButton.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    toggleButton.layer.shadowRadius = 5;
    toggleButton.layer.shadowOffset = CGSizeMake(1, 1);
    toggleButton.layer.shadowOpacity = .7;
    toggleButton.layer.masksToBounds = NO;
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
- (IBAction)ConfirmPerson:(id)sender {
    [self ShowConfirmationAlert];
}

-(void)ShowConfirmationAlert
{
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.blurBackground = 1;
    alert.bounceAnimations = 1;
    alert.dismissOnOutsideTouch = 1;
    alert.fullCircleCustomImage = NO;
    [alert makeAlertTypeCaution];
    
    [alert addTextFieldWithPlaceholder:@"----" andTextReturnBlock:^(NSString *text) {
        
    }];
    
    
    [alert showAlertInView:self
                 withTitle:@""
              withSubtitle:@"لطفا کد دریافتی را وارد نمایید"
           withCustomImage:[UIImage imageNamed:@"alert.png"]
       withDoneButtonTitle:@"تایید"
                andButtons:nil];
    
    [alert doneActionBlock:^{
        
        [self ConfirmNumber:alert.textField.text];
        
    }];
}

-(void)ConfirmNumber:(NSString*)code
{
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
         [self.view.window showHUDWithText:nil Type:ShowDismiss Enabled:YES];
        if (wasSuccessful) {
            
            NSString *status = [NSString stringWithFormat:@"%@",data];
            
            if ([status isEqualToString:@"1"]) {
                
                [self.view.window showHUDWithText:nil Type:ShowDismiss Enabled:YES];
                FCAlertView *alert = [[FCAlertView alloc] init];
                [alert makeAlertTypeSuccess];
                [alert showAlertInView:self
                             withTitle:nil
                          withSubtitle:@"کد وارد شده صحیح است"
                       withCustomImage:[UIImage imageNamed:@"alert.png"]
                   withDoneButtonTitle:@"تایید"
                            andButtons:nil];
            }
            else
            {
                [self.view.window showHUDWithText:nil Type:ShowDismiss Enabled:YES];
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.blurBackground = 1;
                alert.bounceAnimations = 1;
                alert.dismissOnOutsideTouch = 1;
                alert.fullCircleCustomImage = NO;
                [alert makeAlertTypeWarning];
                [alert addTextFieldWithPlaceholder:@"----" andTextReturnBlock:^(NSString *text) {
                    
                }];
                
                [alert showAlertInView:self
                             withTitle:@"کد وارد شده اشتباه است"
                          withSubtitle:@"لطفا کد دریافتی را وارد نمایید"
                       withCustomImage:[UIImage imageNamed:@"alert.png"]
                   withDoneButtonTitle:@"تایید"
                            andButtons:nil];
                
                [alert doneActionBlock:^{
                    [self ConfirmNumber:alert.textField.text];
                    
                }];
                
            }
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"👻"
                                                            message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
                                                           delegate:self
                                                  cancelButtonTitle:@"خب"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    };
    
    Settings *st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
    [self.view.window showHUDWithText:@"لطفا صبر نمایید" Type:ShowLoading Enabled:YES];
    [self.getData ConfirmNumber:st.accesstoken Code:code OrderId:_order.orderId withCallback:callback];
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
    
    if ([DataCollector sharedInstance].haveCurrentWork) {
        // Get the previous view controller
        UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 1];
        // Create a UIBarButtonItem
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)];
        // Associate the barButtonItem to the previous view
        [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    }
    else
    {
        // Get the previous view controller
        UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        // Create a UIBarButtonItem
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)];
        // Associate the barButtonItem to the previous view
        [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    }
    
}

-(void)DisableBackButton
{
   [self.navigationItem setHidesBackButton:YES];
}

- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
}


@end
