//
//  PMTools.h
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import <Foundation/Foundation.h>
//需要用到UIKit框架里的文件
#import <UIKit/UIKit.h>

//针对判断是否有网络需要的头文件
#import <CommonCrypto/CommonHMAC.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import <arpa/inet.h>

#import "ContactModel.h"

@interface PMTools : NSObject


+ (NSString*)FilteSQLStr:(NSString *)originStr;
/**
    判断当前是否可以连接到网络
 */
+ (BOOL) connectedToNetwork;

/**
    正则表达式判断手机号
 */
+ (BOOL) isPhoneNumber:(NSString *)phoneNumber;

/** 
    拨打电话
 */
+ (void) callPhoneNumber:(NSString *)phoneNum inView:(UIView *)view;

/** 
    判断字符串是否为空
 */
+ (BOOL) isNullOrEmpty:(id)string;

/** 
    getUUID
 */
+(NSString *) getUUID;

/**
    16进制颜色转换
 */
+ (UIColor *) colorFromHexRGB:(NSString *)inColorString;

/**
    判断是否含有非法字符
 */
+ (BOOL) isHaveIllegalChar:(NSString *)str;

/**
    计算文字尺寸
 */
+ (CGSize) sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize;

/** 
    截取字符串
 */
+ (NSString *) subStringFromString:(NSString *)str isFrom:(BOOL)isFrom;

/**
    json串转换为字典
 */
+ (NSDictionary *) dictionaryWithJsonString:(NSString *)jsonString;

/** 
    获取当前页
 */
+ (UIViewController *) getCurrentVC;

/** 
    版本更新
 */
+ (void) updateVersion;

/**
    移除相册选择的照片
 */
+ (void) removeSelectsPhotos;
@end
