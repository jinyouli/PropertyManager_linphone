//
//  UserManager.h
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface UserManager : NSObject <NSCoding>

//用户信息（属性）
@property (nonatomic,strong) NSString * department_id; //物业公司id
@property (nonatomic,strong) NSString * worker_name; // 用户昵称
@property (nonatomic,strong) NSString * department_name; //用户所在部门名称
@property (nonatomic,strong) NSString * username;
@property (nonatomic,strong) NSString * token;
@property (nonatomic,strong) NSString * worker_id;   //用户id
@property (nonatomic,strong) NSString * power_type;  //1为派单人权限，0为普通员工
@property (nonatomic,strong) NSString * user_sip;  //sip账号
@property (nonatomic,strong) NSString * user_password;  //sip密码
@property (nonatomic,assign) BOOL register_yet;  //是否已在其它设备登陆
@property (nonatomic,strong) NSString * sip_host_addr; //地址
@property (nonatomic,strong) NSString * sip_host_port;//端口
@property (nonatomic,assign) NSInteger token_timeout;  // token失效时间
@property (nonatomic,strong) NSString * registrationTimeout; //注册周期
@property (nonatomic,strong) NSString * transport; //协议



//创建用户管理单例
+ (UserManager *)manager;

//注销用户单例子
+(void)cancelManage;

+ (instancetype)userManagerWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;

@end
