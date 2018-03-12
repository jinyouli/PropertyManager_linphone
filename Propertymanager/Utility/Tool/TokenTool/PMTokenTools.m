//
//  PMTokenTools.m
//  PropertyManager
//
//  Created by Momo on 17/1/15.
//  Copyright © 2017年 Doubango Telecom. All rights reserved.
//

#import "PMTokenTools.h"

@interface PMTokenTools ()

@end


@implementation PMTokenTools

/**
 重新获取token
 */
+(void)getTokenByOldToken{

    //新接口不需要重新获取token
    NSInteger sec = ([UserManagerTool userManager].token_timeout - 5) * 60;
//    sec = 60;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@" %zd秒 重新获取新token",sec);
        [self gainNewToken];
 
    });


}

+(void)gainNewToken{
    
    return;
    [DetailRequest SYGet_token_by_old_tokenSuccessBlock:^(NSDictionary *result) {
        // 更新成功
        //token(根视图有用到)
        [[NSUserDefaults standardUserDefaults] setObject:result[@"token"] forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //更新时间
        UserManager * user = [UserManagerTool userManager];
        user.token_timeout = [result[@"token_timeout"] integerValue];
        [UserManagerTool saveUserManager:user];
        
        [self getTokenByOldToken];

    }];
}

@end
