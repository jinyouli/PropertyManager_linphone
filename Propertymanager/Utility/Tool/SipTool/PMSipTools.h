//
//  PMSipTools.h
//  PropertyManager
//
//  Created by Momo on 16/11/14.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMSipTools : NSObject

/**注册*/
+(void)sipRegister;
/** sip是否已经注册*/
+(BOOL)sipIsRegister;
/** 配置*/
+(void)UpdateUser_SipConfig;
/**取消注册*/
+(BOOL)sipUnRegister;

/** 通过sip账号获取联系人*/
+(ContactModel *)gainContactModelFromSipNum:(NSString *)sipNum;

/** 是否在时间范围之内*/
+ (BOOL)isBetweenTime;

/** 播放声音*/
+(void)playRing;

/** 停止播放*/
+(void)stopRing;
@end
