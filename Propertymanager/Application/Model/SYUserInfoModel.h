//
//  SYUserInfoModel.h
//  YLB
//
//  Created by YAYA on 2017/4/10.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYUserInfoModel : NSObject

//第二次登录
@property (nonatomic,copy) NSString *username;   ///账号
@property (nonatomic,copy) NSString *fs_ip;    // 112.74.13.109;
@property (nonatomic,copy) NSString *fs_port;    // 35162;
@property (nonatomic,copy) NSString *gestire_pwd;    // 手势密码
@property (nonatomic,strong) NSArray *neibor_id_list;   //社区ID list (废用，已不再返回数据，改为/users/is_can_binding.json返回)
@property (nonatomic,assign) BOOL register_yet;    // 是否已经有其他设备登录
@property (nonatomic,assign) unsigned int registrationTimeout;    // 120;    expire时间 
@property (nonatomic,assign) unsigned int token_timeout;    // token失效时间 分钟
@property (nonatomic,copy) NSString *transport;    // tcp;
@property (nonatomic,copy) NSString *user_password;    // 3a322ff7809248b891d44639106c3708; sip账号密码
@property (nonatomic,copy) NSString *user_sip;    // 2000006226;
@property (nonatomic,copy) NSString *token; //令牌
@property (nonatomic,assign) unsigned long user_id;   //用户id

@end
