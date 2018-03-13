//
//  PMSipTools.m
//  PropertyManager
//
//  Created by Momo on 16/11/14.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "PMSipTools.h"
//#import "iOSNgnStack.h"
#import "AppDelegate.h"
//#import "GeTuiSdk.h"


@implementation PMSipTools

dispatch_source_t source;


+(BOOL)sipIsRegister{
//    UserManager * user = [UserManagerTool userManager];
//    if (![PMTools isNullOrEmpty:user.user_sip] && [PMTools connectedToNetwork]) {
//        return [[NgnEngine sharedInstance].sipService isRegistered];
//    }
//    else{
//        return NO;
//    }
    return NO;
}


/** 配置*/
+(void)UpdateUser_SipConfig{
    
    UserManager * user = [UserManagerTool userManager];
//    user.user_sip = @"1007";
//    user.sip_host_addr = @"120.24.209.114";
//    user.user_password = @"123456";
//    user.sip_host_port = @"35162";
    
    NSString * kPublicIdentity = [NSString stringWithFormat:@"sip:%@@%@",user.user_sip,user.sip_host_addr];
    // set credentials
//    [[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_DISPLAY_NAME andValue:user.worker_name];
//    [[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_IMPI andValue:user.user_sip];
//    [[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_IMPU andValue:kPublicIdentity];
//    [[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_PASSWORD andValue:user.user_password];
//    [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_REALM andValue:user.sip_host_addr];
//    [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_PCSCF_HOST andValue:user.sip_host_addr];
    
    
//    int intPort = [user.sip_host_port intValue];
//    [[NgnEngine sharedInstance].configurationService setIntWithKey:NETWORK_PCSCF_PORT andValue:intPort];
//    [[NgnEngine sharedInstance].configurationService setBoolWithKey:NETWORK_USE_EARLY_IMS andValue:YES];
//    [[NgnEngine sharedInstance].configurationService setBoolWithKey:NETWORK_USE_3G andValue:YES];
//
//
//    [[NgnEngine sharedInstance].configurationService setBoolWithKey:NETWORK_USE_KEEPAWAKE andValue:YES];
//
//    int registerTimeout = [user.registrationTimeout intValue];
//    [[NgnEngine sharedInstance].configurationService setIntWithKey:NETWORK_REGISTRATION_TIMEOUT andValue:registerTimeout];
    
    SYLog(@" 配置   %@ \n%@\n %@\n",user.user_sip,user.user_password,kPublicIdentity);
}


+ (ContactModel *)gainContactModelFromSipNum:(NSString *)sipNum{
    MyFMDataBase * database = [MyFMDataBase shareMyFMDataBase];
    NSArray * arr = [database selectDataWithTableName:A_ZInfo withDic:@{@"user_sip":sipNum}];
    ContactModel * model;
    if (arr.count != 0) {
        model = arr[0];
    }
    return model;
}

+(BOOL)sipUnRegister{
//    if ([PMTools connectedToNetwork]) {
//        return [[NgnEngine sharedInstance] stop];
//    }
    
    return NO;

}


+ (BOOL)isBetweenTime
{
    // 开始时间
    NSString * startTime = DNDStartTime;
    NSString * sStr = [startTime substringFromIndex:3];
    NSArray * sArr2 = [sStr componentsSeparatedByString:@":"];
    NSString * sHour = sArr2[0];
    NSString * sMin = sArr2[1];
    NSString * startTimeStr = [NSString stringWithFormat:@"%@%@",sHour,sMin];
    NSInteger startTimeInt = [startTimeStr integerValue];
    
    
    // 结束时间
    NSString * endTime = DNDEndTime;
    NSString * eStr = [endTime substringFromIndex:3];
    NSArray * eArr2 = [eStr componentsSeparatedByString:@":"];
    NSString * eHour = eArr2[0];
    NSString * eMin = eArr2[1];
    NSString * endTimeStr = [NSString stringWithFormat:@"%@%@",eHour,eMin];
    NSInteger endTimeInt = [endTimeStr integerValue];
    
    
    // 当前时间
    NSDate *currentDate = [NSDate date];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents * currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    NSString * currentHour = [currentComps hour] > 9 ? [NSString stringWithFormat:@"%ld",[currentComps hour]] :  [NSString stringWithFormat:@"0%ld",[currentComps hour]];
    NSString * currentMin = [currentComps minute] > 9 ? [NSString stringWithFormat:@"%ld",[currentComps minute]] :  [NSString stringWithFormat:@"0%ld",[currentComps minute]];;
    NSString * currentTimeStr = [NSString stringWithFormat:@"%@%@",currentHour,currentMin];
    NSInteger currentTimeInt = [currentTimeStr integerValue];
    
    NSLog(@"%ld",currentTimeInt);
    if (startTimeInt > endTimeInt) {
        //dateStart 大于 dateEnd
        // 隔天
        if (currentTimeInt >= startTimeInt && currentTimeInt <= 2359) {
            SYLog(@"该时间在 %ld - 2359 内！", startTimeInt);
            return YES;
        }
        if (currentTimeInt >= 0 && currentTimeInt <= endTimeInt) {
            NSLog(@"该时间在 0000 - %ld 内！", endTimeInt);
            return YES;
        }
        
        
    }
    else if (startTimeInt ==  endTimeInt) {
        //dateStart 等于 dateEnd
        if (currentTimeInt == startTimeInt)
        {
            NSLog(@"该时间与 %ld - %ld 相等！", startTimeInt, endTimeInt);
            return YES;
        }
    }
    else{
        //dateStart 小于 dateEnd  （不隔天）
        NSLog(@"不隔天");
        if (currentTimeInt >= startTimeInt && currentTimeInt <= endTimeInt)
        {
            SYLog(@"该时间在 %ld - %ld 之间！", startTimeInt, endTimeInt);
            return YES;
        }
    }
    
    
    return NO;
}
/**
 * @brief 生成当天的某个点（返回的是伦敦时间，可直接与当前时间[NSDate date]比较）
 * @param hour 如hour为“8”，就是上午8:00（本地时间）
    @istoday 是否隔天
 */
+ (NSDate *)getCustomDateWithHour:(NSInteger)hour WithMinute:(NSInteger)minute isNextDay:(BOOL)isnext
{
    //获取当前时间
    NSDate *currentDate = [NSDate date];
    if (isnext) {
        currentDate = [NSDate dateWithTimeIntervalSinceNow:24 * 60 * 60];
    }
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents * currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    
    //设置当天的某个点
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];
    [resultComps setMinute:minute];
    
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [resultCalendar dateFromComponents:resultComps];
}


/** 播放声音*/
+(void)playRing{
    
    SYLog(@"播放");
//    [[[NgnEngine sharedInstance] getSoundService] playRingTone];
//    [[[NgnEngine sharedInstance] getSoundService] playRingBackTone];
}

/** 停止播放*/
+(void)stopRing{
    
//    SYLog(@"停止播放");
//    [[[NgnEngine sharedInstance] getSoundService] stopRingTone];
//    [[[NgnEngine sharedInstance] getSoundService] stopRingBackTone];
}

/**注册*/
+(void)sipRegister{
    SYLog(@"sip注册");
    
    UserManager * user = [UserManagerTool userManager];
    if (![PMTools isNullOrEmpty:user.user_sip] && [PMTools connectedToNetwork]) {
   
        SYLog(@"sip注册开始");
        // start the engine
//        [[NgnEngine sharedInstance] start];
//        [PMSipTools UpdateUser_SipConfig];
//
////        [PMSipTools UpdateUser_SipConfig];
//        [[NgnEngine sharedInstance].historyService load];
//        [[NgnEngine sharedInstance].sipService registerIdentity];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(480 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@" 8分钟进来啦！");
            
            //在这里执行事件
            if (![PMTools isNullOrEmpty:userToken]) {
                NSLog(@" 8分钟进来啦！ 重新注册sip");
                
                //注册之前 先把栈停掉 之后重新注册
                
                UIViewController * currentVC = [UIViewController currentViewController];
                
                if (![NSStringFromClass([MyRootViewController class]) isEqualToString:[[AppDelegate sharedInstance].window.rootViewController class]]) {
                    NSLog(@"根页面不是 MyRootViewController");
                    return ;
                }
                
                
                if ([NSStringFromClass([AudioCallViewController class]) isEqualToString:[currentVC class]]) {
                    NSLog(@"当前页面是 AudioCallViewController");
                    return ;
                }
                
                if ([NSStringFromClass([VideoCallViewController class]) isEqualToString:[currentVC class]]) {
                    NSLog(@"当前页面是 VideoCallViewController");
                    return ;
                }
                
                if ([NSStringFromClass([LookEntranceVedioViewController class]) isEqualToString:[currentVC class]]) {
                    NSLog(@"当前页面是 LookEntranceVedioViewController");
                    return ;
                }
                
                //获取当前的控制器
//                MyRootViewController * rootVC = (MyRootViewController *)[AppDelegate sharedInstance].window.rootViewController;
//                UIViewController * modalViewController = [rootVC.childViewControllers lastObject];
//                NgnAVSession * audioSession;
//                
//                if ([modalViewController isKindOfClass:[AudioCallViewController class]] ) {
//                    AudioCallViewController * videoVC = (AudioCallViewController *)modalViewController;
//                    audioSession = [NgnAVSession getSessionWithId: videoVC.sessionId];
//                    
//                    
//                }
//                else if ([modalViewController isKindOfClass:[VideoCallViewController class]] ) {
//                    VideoCallViewController * videoVC = (VideoCallViewController *)modalViewController;
//                    audioSession = [NgnAVSession getSessionWithId: videoVC.sessionId];
//                    
//                }
//                else if ([modalViewController isKindOfClass:[LookEntranceVedioViewController class]] ) {
//                    LookEntranceVedioViewController * videoVC = (LookEntranceVedioViewController *)modalViewController;
//                    audioSession = [NgnAVSession getSessionWithId: videoVC.sessionId];
//                }
//                
//                if (audioSession) {
//                    if (audioSession.state == INVITE_STATE_INCOMING ||
//                        audioSession.state == INVITE_STATE_INPROGRESS ||
//                        audioSession.state == INVITE_STATE_REMOTE_RINGING ||
//                        audioSession.state == INVITE_STATE_EARLY_MEDIA ||
//                        audioSession.state == INVITE_STATE_INCALL) {
//                        
//                        return ;
//                    }
//                }
//                
                
                if ([PMSipTools sipUnRegister]) {
                    [PMSipTools sipRegister];
                }
 
            }

        });
    }
}



@end
