//
//  StringUtil.h
//  FXTool
//
//  Created by 房杨平 on 11-8-18.
//  Copyright 2011 EmatChina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h> 

//md5 加密
@interface MD5Util : NSObject {

}

+ (NSString *)MD5ForLower32Bate:(NSString *)str;

+ (NSString *) md5:(NSString *)str;
+ (NSString *) md5ForFileContent:(NSString *)file;
+ (NSString *) md5ForData:(NSData *)data;

@end
