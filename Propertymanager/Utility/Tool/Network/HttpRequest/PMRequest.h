//
//  PMRequest.h
//  PropertyManage
//
//  Created by Momo on 16/6/16.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPSessionManager;

@interface PMRequest : NSObject

// get请求
+ (void)getRequestURL:(NSString *) url withHeaderDic:(NSDictionary*)headerDic parameters:(NSDictionary *) parameter withBlock:(void(^)( id dict)) block andFailure:(void(^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)) failure ;


// post请求
+ (void)postRequestURL:(NSString *)url withHeaderDic:(NSDictionary*)headerDic parameters:(NSDictionary *)parameter withBlock:(void(^)(NSDictionary * dict)) block andFailure:(nullable void(^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;


//上传图片(可多图)
+(void) postUploadPhotosWithURL:(NSString *)url withImageArr:(NSArray *)imageArr withHeaderDic:(NSDictionary*)headerDic parameters:(NSDictionary *)parameter withBlock:(void(^)(NSDictionary * dict))block andFailure:(nullable void(^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

/**
 *  动态发布图片压缩
 *
 *  @param source_image 原图image
 *  @param maxSize      限定的图片大小
 *
 *  @return 返回处理后的图片数据流
 */
+ (NSData *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize;

+(AFHTTPSessionManager *)gainAFNManager;



@end
