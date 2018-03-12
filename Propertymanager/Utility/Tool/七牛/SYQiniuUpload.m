//
//  SYQiniuUpload.m
//  YLB
//
//  Created by chenjiangchuan on 16/11/9.
//  Copyright © 2016年 Sayee Intelligent Technology. All rights reserved.
//

#import "SYQiniuUpload.h"

@implementation SYQiniuUpload

+ (NSString *)QiniuPutSingleImage:(NSString *)imagePath complete:(void (^)(QNResponseInfo *info, NSString *key, NSDictionary *resp))complete; {
    
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    
    UIImage *newImage = [UIImage imageWithContentsOfFile:imagePath];
    NSData *data = UIImageJPEGRepresentation(newImage, 1.0);

    NSString *keyHeader = [NSMutableString stringWithFormat:@"ios/property"];
    NSString *keyTime = [self currentTime];
    NSString *keyRandom = [self randomString];
    NSString *keyString = [NSString stringWithFormat:@"%@/%@/%@/%@.jpg", keyHeader, keyTime, [UserManagerTool userManager].username,keyRandom];
    SYLog(@"keyString = %@", keyString);
    
    // key为图片的名字，这里的规范是：ios/pm/时间/10位数随机数.png
    [upManager putData:data key:keyString token:QinniuToken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (complete) {
            complete(info, key, resp);
        }
    } option:nil];
    
    return keyString;
}

+ (NSString *)QiniuPutImageArray:(NSArray *)images complete:(void (^)(QNResponseInfo *info, NSString *key, NSDictionary *resp))complete {
    
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    
    NSMutableString *imageMString = [NSMutableString string];
    
    for (int i = 0; i < images.count; i++) {
    
        UIImage *newImage = images[i];
        NSData *data = [PMRequest resetSizeOfImageData:newImage maxSize:100];
    
        NSString *keyHeader = [NSMutableString stringWithFormat:@"ios/property"];
        NSString *keyTime = [self currentTime];
        NSString *keyRandom = [self randomString];
        NSString *keyString = [NSString stringWithFormat:@"%@/%@/%@/%@.jpg", keyHeader, keyTime,[UserManagerTool userManager].username, keyRandom];
        SYLog(@"keyString = %@", keyString);
        
        [imageMString appendFormat:@"%@,", keyString];
        
        // key为图片的名字
        [upManager putData:data key:keyString token:QinniuToken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            if (complete) {
                complete(info, key, resp);
            }
        } option:nil];
    }
    return [imageMString substringToIndex:imageMString.length - 1];
}

+ (NSString *)currentTime {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:[NSString stringWithFormat:@"yyyyMMddHHmmss"]];
    return [formatter stringFromDate:date];
}

+ (NSString *)randomString {
    NSString *kRandomAlphabet = @"0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:10];
    for (int i = 0; i < 10; i++) {
        [randomString appendFormat: @"%C", [kRandomAlphabet characterAtIndex:arc4random_uniform((u_int32_t)[kRandomAlphabet length])]];
    }
    return randomString;
}

@end
