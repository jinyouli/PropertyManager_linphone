//
//  Common.h
//  YLB_IPAD
//
//  Created by jinyou on 2017/6/27.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Common : NSObject

+ (BOOL)isLandScap;
//+ (void)showMessageWithContent:(NSString *)msg duration:(NSTimeInterval)duration view:(UIView*)addView;
+ (void)showAlert:(UIView*)hubview alertText:(NSString*)text afterDelay:(NSTimeInterval)delay;
+ (BOOL)isIncludeSpecialCharact: (NSString *)str;

+ (void)addAlertWithTitle:(NSString*)string;

+ (NSString *)encryptWithText:(NSString *)sText;//加密
+ (NSString *)decryptWithText:(NSString *)sText;//解密

+ (NSInteger)getNowTimestamp;
+ (BOOL)isDisturbTime;

//将16进制的字符串转换成NSData
+ (NSMutableData *)convertHexStrToData:(NSString *)str;

+ (NSDate *)getPriousorLaterDateFromDate:(NSDate *)date withMonth:(int)month;
//保存用户绑定小区信息
+ (void)saveNeiBindingUser;
+ (BOOL)playRing;
//获取Window当前显示的ViewController
+ (UIViewController*)currentViewController;

//生成二维码
+ (UIImage *)encodeQRImageWithContent:(NSString *)content size:(CGSize)size;

+ (void)showAlert:(NSString*)msg;
+ (UIViewController*)topViewController;
@end
