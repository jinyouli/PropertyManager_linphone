//
//  AppDelegate+Notification.h
//  PropertyManager
//
//  Created by Momo on 16/12/30.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "AppDelegate.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif


@interface AppDelegate (Notification)<UNUserNotificationCenterDelegate>

- (void)registerRemoteNotification;

/**
    收到本地推送 有sip信息 语音 视频  和个推离线消息的推送形成的工单信息
 */
-(void)getLocalPush:(UILocalNotification *)notification application:(UIApplication *)application;

@end
