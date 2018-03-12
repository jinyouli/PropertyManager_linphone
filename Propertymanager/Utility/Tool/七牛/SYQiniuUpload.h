//
//  SYQiniuUpload.h
//  YLB
//
//  Created by chenjiangchuan on 16/11/9.
//  Copyright © 2016年 Sayee Intelligent Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QiniuSDK.h>

@interface SYQiniuUpload : NSObject

/**
 *  上传单张图片数据到七牛
 *
 *  @param imagePath     图片的路径
 *  @param complete
 */
+ (NSString *)QiniuPutSingleImage:(NSString *)imagePath complete:(void (^)(QNResponseInfo *info, NSString *key, NSDictionary *resp))complete;

/**
 *  上传多张图片数据到七牛
 *
 *  @param imagePath     图片
 *  @param complete
 */
+ (NSString *)QiniuPutImageArray:(NSArray *)images complete:(void (^)(QNResponseInfo *info, NSString *key, NSDictionary *resp))complete;

@end
