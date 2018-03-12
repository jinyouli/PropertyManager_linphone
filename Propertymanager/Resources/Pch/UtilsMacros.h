//
//  UtilsMacros.h
//  PropertyManager
//
//  Created by Momo on 16/11/14.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#ifndef UtilsMacros_h
#define UtilsMacros_h

// ************************ 打印 *****************************
/**
 *  日志输出
 */
#define SYFunc SYLog(@"%s",__func__);

#ifdef DEBUG // 调试

#define SYLog(...) NSLog(__VA_ARGS__);

#else // 发布

#define SYLog(...)

#endif

// ************************ 颜色 *****************************

/**
 *  主色调颜色
 */
#define mainColor  [PMTools colorFromHexRGB:@"00b4c7"]
/**
 *  提醒色 图标背景
 */
#define TImageColor  [PMTools colorFromHexRGB:@"ffaf05"]
/**
 *  提醒色 文字
 */
#define ITextColor  [PMTools colorFromHexRGB:@"ec5f05"]
/**
 *  正常文字
 */
#define mainTextColor  [PMTools colorFromHexRGB:@"555555"]
/**
 *  线 描述性非重要文字
 */
#define lineColor  [PMTools colorFromHexRGB:@"d1d1d1"]
/**
 *  背景色
 */
#define BGColor  [PMTools colorFromHexRGB:@"ebebeb"]
/**
 *  辅助性背景色
 */
#define sBGColor  [PMTools colorFromHexRGB:@"fafafa"]
/**
 *  rgb
 */
#define MYColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]


// ************************ 字号 *****************************
/**
 *  小号字体
 */
#define SmallFont [UIFont systemFontOfSize:11]
/**
 *  中号字体
 */
#define MiddleFont [UIFont systemFontOfSize:14]
/**
 *  正常字体
 */
#define LargeFont [UIFont systemFontOfSize:16]


// ************************ 屏幕宽高 *****************************
/**
 *  屏幕宽度
 */
#define ScreenWidth [[UIScreen mainScreen]bounds].size.width
/**
 *  屏幕高度
 */
#define ScreenHeight [[UIScreen mainScreen]bounds].size.height


/**
 *  图片路径
 */
#define YLBSrcName(file) [@"YLBlibAssetsA.bundle" stringByAppendingPathComponent:file]


// ************************ 设备系统 *****************************
/**
 *  设备系统版本相关
 */
#define SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define iOSVersion [[[UIDevice currentDevice] systemVersion] doubleValue]
#define iPhone4s ([UIScreen mainScreen].bounds.size.height == 480 ? YES : NO)
#define iPhone5s ([UIScreen mainScreen].bounds.size.height == 568 ? YES : NO)
#define iPhone6s ([UIScreen mainScreen].bounds.size.height == 667 ? YES : NO)
#define iPhone6plus ([UIScreen mainScreen].bounds.size.height == 736 ? YES : NO)

/**
 *  大于等于7.0的ios版本
 */
#define iOS7_OR_LATER SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")
/**
 *  大于等于8.0的ios版本
 */
#define iOS8_OR_LATER SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")

/**
 *  获取系统时间戳
 */
#define CURRENT_TIME [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]]
#endif /* UtilsMacros_h */
