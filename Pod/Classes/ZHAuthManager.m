//
//  ZHAuthManager.m
//
//  Created by Lee on 2017/9/25.
//  Copyright © 2017年 leezhihua All rights reserved.
//

#import "ZHAuthManager.h"
#import <CoreTelephony/CTCellularData.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Contacts/Contacts.h>
#import <AddressBook/AddressBook.h>
#import <EventKit/EventKit.h>
#import <Intents/Intents.h>
#import <Speech/Speech.h>

@interface ZHAuthManager ()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) void(^authorizationResult)(BOOL granted);
@property (nonatomic, assign) BOOL isLocationAlawys;
@end

static ZHAuthManager *manager = nil;
@implementation ZHAuthManager
+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

#pragma mark - Request Authorization
+ (void)requestAuthorization:(AuthType)type
            authorizedResult:(void (^)(BOOL))result {
    switch (type) {
        case AuthTypeLocationAlways: {
            [[ZHAuthManager defaultManager] requestLocationWithAuthorizedResult:result isAlawys:YES];
        }
            break;
        case AuthTypeLocationWhenInUse: {
            [[ZHAuthManager defaultManager] requestLocationWithAuthorizedResult:result isAlawys:NO];
        }
            break;
        case AuthTypeCamera: {
            [self requestAVCaptureDevice:AVMediaTypeVideo withAuthorizedResult:result];
        }
            break;
        case AuthTypePhotoLibrary: {
            [self requestPhotoLibraryWithAuthorizedResult:result];
        }
            break;
        case AuthTypeAudio: {
            [self requestAVCaptureDevice:AVMediaTypeAudio withAuthorizedResult:result];
        }
            break;
        case AuthTypeContacts: {
            [self requestAddressBookWithAuthorizedResult:result];
        }
            break;
        case AuthTypeCalendar: {
            [self requestCalendarWithAuthorizedResult:result];
        }
            break;
        case AuthTypeSiri: {
            [self requestSiriWithAuthorizedResult:result];
        }
            break;
        case AuthTypeSpeechRecognizer: {
            [self requestSpeechRecognizerWithAuthorizedResult:result];
        }
            break;
        case AuthTypeReminder: {
            [self requestReminderWithAuthorizedResult:result];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Location
- (void)requestLocationWithAuthorizedResult:(void(^)(BOOL granted))result isAlawys:(BOOL)isAlawys {
    if (![CLLocationManager locationServicesEnabled]) {
        [self block:result granted:NO];
        return;
    }
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        self.isLocationAlawys = isAlawys;
        self.authorizationResult = result;
        if (isAlawys) {
            [self.locationManager requestAlwaysAuthorization];
        } else {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    } else {
        if (isAlawys) {
            if (status == kCLAuthorizationStatusAuthorizedAlways) {
                [self block:result granted:YES];
            } else {
                [self block:result granted:NO];
            }
        } else {
            if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
                [self block:result granted:YES];
            } else {
                [self block:result granted:NO];
            }
        }
    }
}
- (void)block:(void(^)(BOOL))block  granted:(BOOL)granted {
    if ([NSThread isMainThread]) {
        if (block) {
            block(granted);
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(granted);
            }
        });
    }
}
#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [manager stopUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [manager stopUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (self.isLocationAlawys) {
        if (status == kCLAuthorizationStatusAuthorizedAlways) {
            [self block:self.authorizationResult granted:YES];
        } else {
            [self block:self.authorizationResult granted:NO];
        }
    } else {
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            [self block:self.authorizationResult granted:YES];
        } else {
            [self block:self.authorizationResult granted:NO];
        }
    }
}


#pragma mark - Camera & Audio
+ (void)requestAVCaptureDevice:(NSString *)device withAuthorizedResult:(void(^)(BOOL granted))result {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:device];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:device completionHandler:^(BOOL granted) {
            [self safeBlock:result granted:granted];
        }];
    } else if (authStatus == AVAuthorizationStatusAuthorized){
        [self safeBlock:result granted:YES];
    } else {
        [self safeBlock:result granted:NO];
    }
}

#pragma mark - Photo Library
+ (void)requestPhotoLibraryWithAuthorizedResult:(void(^)(BOOL granted))result {
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (authStatus == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self safeBlock:result granted:YES];
            }else{
                [self safeBlock:result granted:NO];
            }
        }];
    } else if (authStatus == PHAuthorizationStatusAuthorized){
        [self safeBlock:result granted:YES];
    } else {
        [self safeBlock:result granted:NO];
    }
}

#pragma mark - AddressBook
+ (void)requestAddressBookWithAuthorizedResult:(void(^)(BOOL granted))result {
    if (@available(iOS 9.0, *)) {
        CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (authStatus == CNAuthorizationStatusNotDetermined) {
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                [self safeBlock:result granted:granted];
            }];
        }else if (authStatus == CNAuthorizationStatusAuthorized){
            [self safeBlock:result granted:YES];
        }else{
            [self safeBlock:result granted:NO];
        }
    } else {
        ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
        if (authStatus == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRef addressBook = ABAddressBookCreate();
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                [self safeBlock:result granted:granted];
            });
            
            if (addressBook) {
                CFRelease(addressBook);
            }
        }else if (authStatus == kABAuthorizationStatusAuthorized){
            [self safeBlock:result granted:YES];
        }else{
            [self safeBlock:result granted:NO];
        }
    }
}

#pragma mark - Calendar
+ (void)requestCalendarWithAuthorizedResult:(void(^)(BOOL granted))result {
    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if (authStatus == EKAuthorizationStatusNotDetermined) {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            [self safeBlock:result granted:granted];
        }];
    } else if (authStatus == EKAuthorizationStatusAuthorized){
        [self safeBlock:result granted:YES];
    } else {
        [self safeBlock:result granted:NO];
    }
}

#pragma mark - Siri
+ (void)requestSiriWithAuthorizedResult:(void(^)(BOOL granted))result {
    if (@available(iOS 10.0, *)) {
        INSiriAuthorizationStatus authStatus = [INPreferences siriAuthorizationStatus];
        if (authStatus == INSiriAuthorizationStatusNotDetermined) {
            [INPreferences requestSiriAuthorization:^(INSiriAuthorizationStatus status) {
                if (status == INSiriAuthorizationStatusAuthorized) {
                    [self safeBlock:result granted:YES];
                }else{
                    [self safeBlock:result granted:NO];
                }
            }];
            
        } else if (authStatus == INSiriAuthorizationStatusAuthorized){
            [self safeBlock:result granted:YES];
        } else {
            [self safeBlock:result granted:NO];
        }
    } else {
        [self safeBlock:result granted:NO];
    }
}


#pragma mark - SpeechRecognizer
+ (void)requestSpeechRecognizerWithAuthorizedResult:(void(^)(BOOL granted))result {
    if (@available(iOS 10.0, *)) {
        SFSpeechRecognizerAuthorizationStatus authStatus = [SFSpeechRecognizer authorizationStatus];
        if (authStatus == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
            [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
                if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
                    [self safeBlock:result granted:YES];
                }else{
                    [self safeBlock:result granted:NO];
                }
            }];
            
        }else if (authStatus == SFSpeechRecognizerAuthorizationStatusAuthorized){
            [self safeBlock:result granted:YES];
        }else{
            [self safeBlock:result granted:NO];
        }
    } else {
        [self safeBlock:result granted:NO];
    }
}

#pragma mark - Reminder
+ (void)requestReminderWithAuthorizedResult:(void(^)(BOOL granted))result {
    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    if (authStatus == EKAuthorizationStatusNotDetermined) {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
            [self safeBlock:result granted:granted];
        }];
    }else if (authStatus == EKAuthorizationStatusAuthorized){
        [self safeBlock:result granted:YES];
    }else{
        [self safeBlock:result granted:NO];
    }
}

#pragma mark - Safe Block
+ (void)safeBlock:(void(^)(BOOL))block  granted:(BOOL)granted {
    if ([NSThread isMainThread]) {
        if (block) {
            block(granted);
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(granted);
            }
        });
    }
}

+ (void)setAppAuthorization {
    NSURL*URL =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:URL]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:URL];
        }
    }
}
@end
