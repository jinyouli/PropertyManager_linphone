//
//  DefaultsMacros.h
//  PropertyManager
//
//  Created by Momo on 16/12/23.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#ifndef DefaultsMacros_h
#define DefaultsMacros_h

#define MyUserDefaults [NSUserDefaults standardUserDefaults]


//77接口调用 http方式：http://gdsayee.cn:8086    https方式https://gdsayee.cn:28086
//69接口调用 http方式：http://gdsayee.cn:8084    https方式https://gdsayee.cn:28084

#define FirstLocalhost [[NSUserDefaults standardUserDefaults] objectForKey:@"firLocalhost"]
#define FirstUrl(path) [NSString stringWithFormat:@"%@%@%@",SYHTTPSSTR,FirstLocalhost,path]

//#define FirstLocalhost @"https://120.25.78.167:8084"
//#define FirstLocalhost @"https://120.236.162.132:8084"
//#define FirstLocalhost @"https://192.168.1.112:8084"


// ************************ 二级平台 *****************************//
#define KMyScoendLocalhost @"125.46.73.49:8084" //初始化使用
#define ScoendLocalhost [MyUserDefaults objectForKey:@"scoendLocalhost"]


// ************************ 二级平台拼接网址 *****************************//
#define MyUrl(path) [NSString stringWithFormat:@"%@%@%@",SYHTTPSSTR,ScoendLocalhost,path]


// ************************ 用户token等 *****************************//
#define userToken [MyUserDefaults stringForKey:@"token"]
#define userLoginUsername [MyUserDefaults stringForKey:@"loginUsername"]
#define userPassword [MyUserDefaults stringForKey:@"password"]
#define clientID  [MyUserDefaults stringForKey:@"clientId"]

// 请求头字典
#define HeadDic @{@"uuid":[PMTools getUUID],@"username":userLoginUsername,@"token":userToken}

// ************************ 七牛Token *****************************//
#define QinniuToken [MyUserDefaults objectForKey:@"QNToken"]


// ************************ 勿扰模式 *****************************//
//是否打开勿扰模式
#define isOpenDnd [DontDisturbManager shareManager].isDontDisturb
//勿扰模式的开始时间
#define DNDStartTime [DontDisturbManager shareManager].statTime
//勿扰模式的结束时间
#define DNDEndTime [DontDisturbManager shareManager].endTime


#define SetBoolDefaults(ret,key) [MyUserDefaults setBool:ret forKey:key]

#define BoolFromKey(key) [MyUserDefaults boolForKey:key]


#endif /* DefaultsMacros_h */
