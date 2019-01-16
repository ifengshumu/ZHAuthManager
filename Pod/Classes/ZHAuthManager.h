//
//  ZHAuthManager.h
//
//  Created by Lee on 2017/9/25.
//  Copyright © 2017年 leezhihua. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AuthType) {
    AuthTypeLocationAlways = 0,  //定位(一直)
    AuthTypeLocationWhenInUse,   //定位(使用时)
    AuthTypeCamera,              //相机
    AuthTypePhotoLibrary,        //相册
    AuthTypeAudio,               //麦克风
    AuthTypeContacts,            //通讯录
    AuthTypeCalendar,            //日历
    AuthTypeSiri,                //Siri
    AuthTypeSpeechRecognizer,    //语音识别
    AuthTypeReminder             //提醒事项
};

@interface ZHAuthManager : NSObject

/**
 请求权限

 @param type 权限类型
 @param result 结果
 */
+ (void)requestAuthorization:(AuthType)type
            authorizedResult:(void(^)(BOOL granted))result;

/**
 设置权限
 */
+ (void)setAppAuthorization;

@end

