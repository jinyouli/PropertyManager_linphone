//
//  SYCommon.h
//  PropertyManager
//
//  Created by Li JinYou on 2018/1/18.
//  Copyright © 2018年 Momo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYCommon : NSObject

+ (void)addAlertWithTitle:(NSString*)string;
+ (void)showAlert:(NSString *)msg;

+ (id)load:(NSString *)service;
+ (void)save:(NSString *)service data:(id)data;

//md5 加密字符串
+ (NSString *) md5:(NSString *)str;
@end
