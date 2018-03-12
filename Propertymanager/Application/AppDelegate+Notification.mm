//
//  AppDelegate+Notification.m
//  PropertyManager
//
//  Created by Momo on 16/12/30.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "AppDelegate+Notification.h"
#import "GeTuiSdk.h"
#import "ProOrderNewsViewController.h" // 工单页
#import "NotificationBtn.h"  // 推送btn
#import "SystemAudio.h"   //系统声音
#import "OrderPushItem.h"


@implementation AppDelegate (Notification)


#pragma mark - 注册APNS
- (void)registerRemoteNotification{
    
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        //iOS10特有
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        // 必须写代理，不然无法监听通知的接收与点击
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // 点击允许
                NSLog(@"注册成功");
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"%@", settings);
                }];
            } else {
                // 点击不允许
                NSLog(@"注册失败");
            }
        }];
    }else if ([[UIDevice currentDevice].systemVersion floatValue] >8.0){
        //iOS8 - iOS10
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
        
    }else if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        //iOS8系统以下
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    
    // 注册获得device Token
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}


#pragma mark - 注册DeviceToken消息推送失败
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    NSLog(@"Register Remote Notifications error:{%@}",error);
}


#pragma mark -  Background Fetch 接口回调
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [GeTuiSdk resume];
    completionHandler(UIBackgroundFetchResultNewData);
}



#pragma mark - 个推（application处理）
#pragma mark - APP已经接收到“远程”通知(推送)
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"userInfo === %@", userInfo);
}


#pragma mark -  APP已经接收到“远程”通知(推送) - 透传推送消息
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    NSLog(@"userInfo ==== %@  \n\n",userInfo);
    
    NSString * type = [userInfo objectForKey:@"cmd"];
    
    if (application.applicationState == UIApplicationStateActive) {
        [self handleAlertRemoteNotificationType:type withUserInfo:userInfo];
    }
    else if(application.applicationState == UIApplicationStateInactive)
    {
        
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    NSLog(@"notification ==== %@",notification);
    //把icon上的小图标设置为0
    //    [application setApplicationIconBadgeNumber:0];
    [self getLocalPush:notification application:application];
}

// iOS 10收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSDictionary * userInfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 前台收到远程通知:%@", userInfo);
        
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"deviceToken ====== %@",token);
    
    //向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token];
}


// 通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    NSLog(@"通知的点击事件");
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    NSString * key = userInfo[@"key"];
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知:%@", userInfo);
        
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
        
        /**
         iOS10 收到本地通知:{\\nbody:小庄: 咯咯，\\ntitle:,\\nsubtitle:(null),\\nbadge：1，\\nsound：<UNNotificationSound: 0xdd2e8d0>，\\nuserInfo：{
         content = <e592afe5 92af>;
         key = imsg;
         userName = 2000001307;
         }\\n}
         */
        
        [self userInfo:userInfo type:key];
    }
    
    completionHandler();  // 系统要求执行这个方法
    
}

#pragma mark - 收到本地推送 有sip信息 语音 视频  和个推离线消息的推送形成的工单信息
-(void)getLocalPush:(UILocalNotification *)notification application:(UIApplication *)application{
    
    NSString *notifKey = [notification.userInfo objectForKey:kNotifKey];
    if([notifKey isEqualToString:kNotifKey_IncomingCall]){
        //来电
        NSNumber* sessionId = [notification.userInfo objectForKey:kNotifIncomingCall_SessionId];
        NgnAVSession* session = [NgnAVSession getSessionWithId:[sessionId longValue]];
        
        if(session){
            
            if (session.state == INVITE_STATE_TERMINATED || session.state == INVITE_STATE_TERMINATING) {
                
                [SVProgressHUD showErrorWithStatus:@"对方已挂断"];
            }
            else{
                [CallViewController receiveIncomingCall:session];
            }
            
            application.applicationIconBadgeNumber -= notification.applicationIconBadgeNumber;
        }
    }
    else if([notifKey isEqualToString:kNotifKey_IncomingMsg]){
        // 信息
        UserManager * user = [UserManagerTool userManager];
        NSDictionary * dic = notification.userInfo;
        NSString * userName = [dic objectForKey:@"userName"];
        NSString * myClientId = clientID;
        NSString * showStr = [dic objectForKey:@"content"];
        
        
        myClientId = [NSString stringWithFormat:@"|=|%@|=|",myClientId];
        if ([userName isEqualToString:user.user_sip]) {
            if (![myClientId isEqualToString: showStr]) {
                //id账号不同踢下线
                [PMSipTools sipUnRegister];
                [self alertLoginOtherWhere];
                return;
            }
            else{
                
            }
        }
        
        if (![self.window.rootViewController isKindOfClass:[MyRootViewController class]]) {
            return;
        }
        MyRootViewController * rootVC = (MyRootViewController *)self.window.rootViewController;
        UINavigationController * nav = rootVC.midViewController;
        [nav popToRootViewControllerAnimated:NO];
        
        //跳去聊天界面
        [[NSNotificationCenter defaultCenter]postNotificationName:@"pushChatVC" object:userName];
        
    }
    else if ([notifKey isEqualToString:kNotifOrderComingCmd]){
        // 工单动态
        NSDictionary * dic = notification.userInfo;
        NSString * cmd = dic[@"cmd"];
        [self handleAlertRemoteNotificationType:cmd withUserInfo:dic];
    }
    
}

#pragma mark - 点击通知
-(void)userInfo:(NSDictionary *)userInfo type:(NSString *)type{
    
    UIApplication * application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    if ([type isEqualToString:kNotifKey_IncomingCall]) {
        //来电
        NSNumber* sessionId = [userInfo objectForKey:kNotifIncomingCall_SessionId];
        NgnAVSession* session = [NgnAVSession getSessionWithId:[sessionId longValue]];

        if(session){
            if (session.state == INVITE_STATE_TERMINATED || session.state == INVITE_STATE_TERMINATING) {
                
                [SVProgressHUD showErrorWithStatus:@"对方已挂断"];
            }
            else{
                [CallViewController receiveIncomingCall:session];
            }
        }
    }
    else if ([type isEqualToString:kNotifKey_IncomingMsg]){
        //信息
        
        UserManager * user = [UserManagerTool userManager];
        NSString * userName = [userInfo objectForKey:@"userName"];
        NSString * myClientId = clientID;
        NSString * showStr = [userInfo objectForKey:@"content"];
        
        
        myClientId = [NSString stringWithFormat:@"|=|%@|=|",myClientId];
        if ([userName isEqualToString:user.user_sip]) {
            if (![myClientId isEqualToString: showStr]) {
                //id账号不同踢下线
                [PMSipTools sipUnRegister];
                [self alertLoginOtherWhere];
                return;
            }
            else{
                
            }
        }
        
        if (![self.window.rootViewController isKindOfClass:[MyRootViewController class]]) {
            return;
        }
        MyRootViewController * rootVC = (MyRootViewController *)self.window.rootViewController;
        UINavigationController * nav = rootVC.midViewController;
        [nav popToRootViewControllerAnimated:NO];
        
        //跳去聊天界面
        [[NSNotificationCenter defaultCenter]postNotificationName:@"pushChatVC" object:userName];
        
    }
    else if ([type isEqualToString:kNotifOrderComingCmd]){
        // 工单动态
        NSString * repairs_id = userInfo[@"orderComingId"];
        
        if (![self.window.rootViewController isKindOfClass:[MyRootViewController class]]) {
            return;
        }
        
        
        MyRootViewController * rootVC = (MyRootViewController *)self.window.rootViewController;
        UINavigationController * nav = rootVC.midViewController;
        [nav popToRootViewControllerAnimated:NO];
        
        [[Routable sharedRouter] open:PROORDERNEWS_VIEWCONTROLLER animated:YES extraParams:@{@"frepairs_id":repairs_id}];
    
    }
}

#pragma mark - 处理远程通知的弹窗类型
-(void)handleAlertRemoteNotificationType:(NSString *)type withUserInfo:(NSDictionary *)userInfo{
    
    
    if (![self.window.rootViewController isKindOfClass:[MyRootViewController class]]) {
        return;
    }
    
    if ([type isEqualToString:SYUSERLOGIN]) {
        
        if ([userInfo[@"cnt"][@"username"] isEqualToString:userLoginUsername]) {
            NSLog(@"个推 下线 --- %@",SYUSERLOGIN);
            [WJYAlertView showOneButtonWithTitle:@"提示信息" Message:@"您的账号已在别处登录，请重新登录！" ButtonType:WJYAlertViewButtonTypeNone ButtonTitle:@"确定" Click:^{
                
                /**下线*/
                [PMSipTools sipUnRegister];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"token"];
                [UserManager cancelManage];
                [UserManagerTool saveUserManager:[UserManager manager]];
                [self setmanagerRootVC];
                
            }];
        }
    }
    else{
        NSString *content = userInfo[@"cnt"][@"content"];
        NSString *repair_id = userInfo[@"cnt"][@"repairs_id"];
        //工单消息
        if ([PMTools isNullOrEmpty:repair_id]) {
            return;
        }
        [NotificationBtn toast:content withRepair:repair_id];
        
    }
}


#pragma mark - GeTuiSdkDelegate
#pragma mark -  SDK收到透传消息回调
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    
    if (offLine) {
        //离线消息 从后台进入前台
        //        NSLog(@"有新的消息，点击查看");
    }
    else{
        
        
        BOOL AllSoundOpenBool = [[NSUserDefaults standardUserDefaults] boolForKey:AllSoundOpen];
        BOOL OrdersSoundOpenBool = [[NSUserDefaults standardUserDefaults] boolForKey:OrdersSoundOpen];
        
        BOOL AllShakeOpenBool = [[NSUserDefaults standardUserDefaults] boolForKey:AllShakeOpen];
        BOOL OrdersShakeOpenBool = [[NSUserDefaults standardUserDefaults] boolForKey:OrdersShakeOpen];
        
        BOOL isSoundOpen = AllSoundOpenBool && OrdersSoundOpenBool;
        BOOL isShakeOpen = AllShakeOpenBool && OrdersShakeOpenBool;
        if (isSoundOpen && isShakeOpen) {
            SystemAudio *audio = [[SystemAudio alloc] init];
            [audio playShakeAndSound];
        }
        else if (isSoundOpen && !isShakeOpen){
            
            SystemAudio *audio = [[SystemAudio alloc] init];
            [audio playSound];
            
        }
        else if (!isSoundOpen && isShakeOpen){
            
            
            SystemAudio *audio = [[SystemAudio alloc] init];
            [audio playShake];
            
        }
        
    }
    
    
    //收到个推消息
    NSString *payloadMsg = nil;
    if (payloadData) {
        payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes
                                              length:payloadData.length
                                            encoding:NSUTF8StringEncoding];
    }
    
    NSString *msg = [NSString stringWithFormat:@"payloadMsg ==== %@%@",payloadMsg,offLine ? @"<离线消息>" : @""];
    NSLog(@"\n msg ==== %@\n\n", msg);
    
    //=======================================
    //      对payloadMsg数据进行解析
    //=======================================
    OrderPushItem * orderPushItem = [OrderPushItem mj_objectWithKeyValues:payloadMsg];
    DDLogInfo(@"orderInfo.cmd = %@", orderPushItem.cmd);
    DDLogInfo(@"orderInfo.cnt.content = %@", orderPushItem.cnt.content);
    
    
    
    NSError *err = nil;
    NSDictionary *dic = [PMTools dictionaryWithJsonString:payloadMsg];
//    NSString * cmd = dic[@"cmd"];
//    NSString * repairs_id = dic[@"cnt"][@"repairs_id"];
//    NSString * alertBody = dic[@"cnt"][@"content"];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        
        
        
        UILocalNotification* localNotif = [[UILocalNotification alloc] init];
        localNotif.alertBody = orderPushItem.cnt.content;
        
        //                        NSLog(@"content === %@",content);
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.applicationIconBadgeNumber = ++[UIApplication sharedApplication].applicationIconBadgeNumber;
        localNotif.repeatInterval = 0;
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  kNotifOrderComingCmd, kNotifKey,
                                  orderPushItem.cmd, kNotifOrderComingCmd,
                                  orderPushItem.cnt.repairs_id,kNotifOrderComingId,
                                  nil];
        localNotif.userInfo = userInfo;
        [[UIApplication sharedApplication]  presentLocalNotificationNow:localNotif];
        [self handleAlertRemoteNotificationType:orderPushItem.cmd withUserInfo:dic];
    }
    else{
        [self handleAlertRemoteNotificationType:orderPushItem.cmd withUserInfo:dic];
    }
    
    [GeTuiSdk sendFeedbackMessage:90001 taskId:taskId msgId:msgId];
}

#pragma mark -  个推（clientID）
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    SYLog(@"clientID ==== %@",clientId);
    [[NSUserDefaults standardUserDefaults] setObject:clientId forKey:@"clientId"];
}

#pragma mark -  个推（error）
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    //个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    NSLog(@"\n 个推错误 ==== %@\n\n", [error localizedDescription]);
}

#pragma mark - 在其他设备登录
-(void)alertLoginOtherWhere{
    if (![self.window.rootViewController isKindOfClass:[MyRootViewController class]]) {
        return;
    }
    
    [WJYAlertView showOneButtonWithTitle:@"提示信息" Message:@"您的账号已在别处登录，请重新登录！" ButtonType:WJYAlertViewButtonTypeNone ButtonTitle:@"确定" Click:^{
        /**下线*/
        [PMSipTools sipUnRegister];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"token"];
        [UserManager cancelManage];
        [UserManagerTool saveUserManager:[UserManager manager]];
        [self setmanagerRootVC];
    }];
    
}


@end
