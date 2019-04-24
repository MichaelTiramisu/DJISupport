//
//  ViewController.m
//  DJISupport
//
//  Created by Siyang Liu on 12/21/18.
//  Copyright © 2018 Siyang Liu. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "NetworkUrls.h"

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isGettingLocation;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UITextField *heightTextField;
@property (weak, nonatomic) IBOutlet UITextField *cameraAngleTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UISwitch *djiSwitch;

@property (nonatomic, strong) CLLocation *lastLocation;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.isGettingLocation = NO;
    self.djiSwitch.layer.borderWidth = 1.0;
    self.djiSwitch.layer.cornerRadius = self.djiSwitch.frame.size.height / 2;
//    self.djiSwitch.backgroundColor = UIColor.greenColor;
    self.djiSwitch.thumbTintColor = UIColor.grayColor;
//    self.djiSwitch.tintColor = UIColor.blueColor;
    self.djiSwitch.onTintColor = UIColor.whiteColor;
}

#pragma mark - 懒加载CLLocationManager
- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        // 处理权限
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
            [_locationManager requestAlwaysAuthorization];
        }
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.delegate = self;
        
    }
    return _locationManager;
}

#pragma mark - lastLocation set方法
- (void)setLastLocation:(CLLocation *)lastLocation {
    _lastLocation = lastLocation;
    self.locationLabel.text = [NSString stringWithFormat:@"longitude: %.6lf\nlatitude: %.6lf", lastLocation.coordinate.longitude, lastLocation.coordinate.latitude];
}

#pragma mark - 开始按钮点击事件
- (IBAction)startBtnClick:(UIButton *)sender {
    if (!self.isGettingLocation) {
        [self.locationManager startUpdatingLocation];
        self.isGettingLocation = YES;
    }
}

#pragma mark - 停止按钮点击事件
- (IBAction)stopBtnClick:(UIButton *)sender {
    if (self.isGettingLocation) {
        [self.locationManager stopUpdatingLocation];
        self.isGettingLocation = NO;
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    self.lastLocation = location;
}

#pragma mark - 上传GPS信息按钮点击事件
- (IBAction)uploadGPSInfoBtnClick:(UIButton *)sender {
    if (self.lastLocation == nil) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"Please Get GPS First!";
        [hud hideAnimated:YES afterDelay:1.0];
        return;
    }
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//    NSString *timeStr = [formatter stringFromDate:[[NSDate alloc] init]];
    
    NSDictionary *params = @{
                             @"gps.latitude" : @(self.lastLocation.coordinate.latitude),
                             @"gps.longitude" : @(self.lastLocation.coordinate.longitude),
                             @"gps.height" : self.heightTextField.text,
                             @"gps.cameraAngle" : self.cameraAngleTextField.text,
                             @"gps.port" : self.portTextField.text,
                             @"gps.djiName" : !self.djiSwitch.isOn ? @"dji1" : @"dji2"
                             };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Uploading...";
    [[AFHTTPSessionManager manager] POST:kSAVE_GPS_INFO parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *respDict = responseObject;
        BOOL isSuccess = [respDict[@"success"] boolValue];
        if (isSuccess) {
            hud.label.text = respDict[@"message"];
        } else {
            hud.label.text = respDict[@"errorMsg"];
        }
        [hud hideAnimated:YES afterDelay:1.0];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        hud.label.text = @"Upload Failed!";
        [hud hideAnimated:YES afterDelay:1.0];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
