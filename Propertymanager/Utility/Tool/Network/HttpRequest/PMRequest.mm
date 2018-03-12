//
//  PMRequest.m
//  PropertyManage
//
//  Created by Momo on 16/6/16.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "PMRequest.h"
#import "AppDelegate.h"
#import "iOSNgnStack.h"

@implementation PMRequest


// get请求
+ (void)getRequestURL:(NSString *) url withHeaderDic:(NSDictionary*)headerDic parameters:(NSDictionary *) parameter withBlock:(void(^)( id dict)) block andFailure:(void(^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)) failure {
    
    AFHTTPSessionManager *manager = [PMRequest gainAFNManager];
    for (NSString * key in headerDic) {
        [manager.requestSerializer setValue:headerDic[key] forHTTPHeaderField:key];
    }
    
    SYLog(@"GET");
    SYLog(@"url === %@",url);
//    SYLog(@"headerDic === %@",headerDic);
//    SYLog(@"parameter === %@",parameter);
  
    [manager GET:url parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject == nil) {
            SYLog(@"responseObject == nil");
            return ;
        }
        NSDictionary *returnData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//        SYLog(@"returnData === %@",returnData);
        if ([returnData[@"code"] integerValue] == 3) {
            //身份验证失败
            NSLog(@"身份验证失败 %@  \n responseObject = %@  \n token == %@",url,returnData,userToken);
            [DetailRequest loginBtnClickWithPhone:userLoginUsername password:userPassword isFirstLogin:NO];

//            if (block) {
//                block(returnData);
//            }
            
//            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"token"];
//            [PMSipTools sipUnRegister];
//            [UserManager cancelManage];
//            [UserManagerTool saveUserManager:[UserManager manager]];
//            [GeTuiSdk setPushModeForOff:YES];
//            [[AppDelegate sharedInstance] setmanagerRootVC];
        }
        else{
            if (block) {
                block(returnData);
            }
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        failure(task,error);
        SYLog(@"%@\n%@",url,error);
        [SVProgressHUD dismiss];
        if (error.code != NSURLErrorCancelled) {
            //[SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试"];
        }
    }];
}

// post请求
+ (void)postRequestURL:(NSString *)url withHeaderDic:(NSDictionary*)headerDic parameters:(NSDictionary *)parameter withBlock:(void(^)(NSDictionary * dict)) block andFailure:(nullable void(^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;{
    
    SYLog(@"POST");
    SYLog(@"url === %@",url);
    SYLog(@"headerDic === %@",headerDic);
    SYLog(@"parameter === %@",parameter);
    
    AFHTTPSessionManager *manager = [PMRequest gainAFNManager];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 20.0f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    for (NSString * key in headerDic) {
        [manager.requestSerializer setValue:headerDic[key] forHTTPHeaderField:key];
    }
    [manager POST:url parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        if (responseObject == nil) {
            return ;
        }
        
        NSDictionary *returnData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//        SYLog(@"returnData === %@",returnData);
        
        if ([returnData[@"code"] integerValue] == 3) {
            //身份验证失败
        
            [DetailRequest loginBtnClickWithPhone:userLoginUsername password:userPassword isFirstLogin:NO];
            
        }
        
        else{
            if (block) {
                block(returnData);
            }
            
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideHub" object:nil];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideHub" object:nil];
        if (error.code == NSURLErrorTimedOut) {
            [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试"];
            return;
        }
        
        failure(task,error);
        SYLog(@"%@\n%@",url,error);
       // [SVProgressHUD dismiss];
        if (error.code != NSURLErrorCancelled) {
            //[SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试"];
        }
    }];
}

//上传图片(可多图)
+(void) postUploadPhotosWithURL:(NSString *)url withImageArr:(NSArray *)imageArr withHeaderDic:(NSDictionary*)headerDic parameters:(NSDictionary *)parameter withBlock:(void(^)(NSDictionary * dict))block andFailure:(nullable void(^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure{
    
    SYLog(@"POST - image");
    SYLog(@"url === %@",url);
    SYLog(@"imageArr === %@",imageArr);
    SYLog(@"headerDic === %@",headerDic);
    SYLog(@"parameter === %@",parameter);
    
    AFHTTPSessionManager *manager = [PMRequest gainAFNManager];
    for (NSString * key in headerDic) {
        [manager.requestSerializer setValue:headerDic[key] forHTTPHeaderField:key];
    }
    [manager POST:url parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
     
        for (int i = 0; i < imageArr.count; i ++) {
            UIImage * image = imageArr[i];
            NSData * imageData = [PMRequest resetSizeOfImageData:image maxSize:100];
            
            //判断图片是不是png格式的文件
            if (UIImagePNGRepresentation(image)) {
                //返回为png图像。
                if (imageData != nil) {
                  
                    [formData appendPartWithFileData:imageData name:@"image" fileName:[NSString stringWithFormat:@"image%d.png",i] mimeType:@"image/png"];
                }else{
                    SYLog(@"数据流 为空");
                }
                
            }else{
                
                //返回为JPEG图像。
                [formData appendPartWithFileData:imageData name:@"image" fileName:[NSString stringWithFormat:@"image%d.jpeg",i] mimeType:@"image/jpeg"];
                if (imageData != nil) {
                  
                    [formData appendPartWithFileData:imageData name:@"image" fileName:[NSString stringWithFormat:@"image%d.jpeg",i] mimeType:@"image/jpeg"];
                }
                else{
                    SYLog(@"数据流 为空");
                }
            }
        }
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject == nil) {
            return ;
        }
        NSString * str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        SYLog(@"PMRequest str ==== %@",str);
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
//        SYLog(@"returnData === %@",dic);
        if ([dic[@"code"] integerValue] == 3) {
            //身份验证失败
            [DetailRequest loginBtnClickWithPhone:userLoginUsername password:userPassword isFirstLogin:NO];
            
        }
        else{
            if (block) {
                block(dic);
            }
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(task,error);
        SYLog(@"%@\n%@",url,error);
        [SVProgressHUD dismiss];
        if (error.code != NSURLErrorCancelled) {
            [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试"];
        }
    }];

    
}



/**
 *  动态发布图片压缩
 *
 *  @param source_image 原图image
 *  @param maxSize      限定的图片大小
 *
 *  @return 返回处理后的图片数据流
 */
+ (NSData *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize{
    //先调整分辨率
    CGSize newSize = CGSizeMake(source_image.size.width, source_image.size.height);
    
    CGFloat tempHeight = newSize.height / 1024;
    CGFloat tempWidth = newSize.width / 1024;
    
    if (tempWidth > 1.0 && tempWidth != tempHeight) {
        newSize = CGSizeMake(source_image.size.width / tempWidth, source_image.size.height / tempWidth);
    }
    
    UIGraphicsBeginImageContext(newSize);
    [source_image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    
    //调整大小
    NSData *imageData = UIImageJPEGRepresentation(newImage,1.0);
    NSUInteger sizeOrigin = [imageData length];
    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    NSLog(@"sizeOriginKB === %ld",sizeOriginKB);
    if (sizeOriginKB > maxSize) {
        NSData *finallImageData = UIImageJPEGRepresentation(newImage,0.50);
        NSLog(@"finallImageDataKB === %ld",[finallImageData length]/1024);
        return finallImageData;
    }
//    NSData *imageData = [PMRequest image:newImage maxSize:maxSize];
     NSLog(@"imageDataKB === %ld",[imageData length]/1024);
    return imageData;
}


+(AFHTTPSessionManager *)gainAFNManager{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFSecurityPolicy * securityPolicy= [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    [securityPolicy setValidatesDomainName:NO];
    manager.requestSerializer.timeoutInterval = 10;
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy = securityPolicy;
    //    manager.operationQueue.maxConcurrentOperationCount = 3;
    return manager;
}





@end
