//
//  SYLinphoneManager.h
//  LinphoneDemo
//
//  Created by sayee on 16/7/13.
//  Copyright © 2016年 sayee. All rights reserved.
//

/**
 *  SYLinphone ip phone manager
 */
@class LinphoneCall;
#import <Foundation/Foundation.h>
#import "SYLinphoneStatus.h"
#import "SYLinphoneDelegate.h"

/**正常视频呼叫状态码顺序
 ====state==2   message===Starting outgoing call
 ====state==3   message===Outgoing call in progress
 ====state==5   message===Early media
 ====state==6   message===Connected
 ====state==7   message===Streams running
 ====state==13   message===Call ended
 ====state==18   message===Call released
*/

@interface SYLinphoneManager : NSObject <SYLinphoneDelegate>


@property (nonatomic, readwrite, assign) id<SYLinphoneDelegate> delegate;      // 回调代理
@property (nonatomic, assign) BOOL speakerEnabled;                              // 是否打开扬声器
@property (nonatomic, assign, readonly) BOOL isSYLinphoneReady;                    // SYLinphone是否已初始化
@property (nonatomic, assign, readonly) SYLinphoneCall *currentCall;                 // 当前通话

@property (nonatomic, assign) BOOL ipv6Enabled; //是否支持IPV6
@property (nonatomic, assign) BOOL videoEnable; //是否支持视频呼叫
@property (nonatomic, assign) unsigned int nExpires; //expires

/**
 单例对象
 */
+ (SYLinphoneManager*)instance;

/**
 初始化
 */
-(void)startSYLinphonephone;


/**
 设置登陆信息
 */
- (BOOL)addProxyConfig:(NSString*)username password:(NSString*)password displayName:(NSString *)displayName domain:(NSString*)domain port:(NSString *)port withTransport:(NSString*)transport;


/**
 注销登陆信息
 */
- (void)removeAccount;


/**
 拨打电话
 */
- (void)call:(NSString *)address displayName:(NSString*)displayName transfer:(BOOL)transfer Video:(UIView *)video;


/**
 接听通话
 */
- (void)acceptCall:(SYLinphoneCall *)call Video:(UIView *)video;


/**
 挂断通话
 */
- (void)hangUpCall;
- (void)hangUpCall:(SYLinphoneCall *)currentcall;


/**
 获取通话时长
 */
- (int)getCallDuration;


/**
 获取对方号码
 */
- (NSString *)getRemoteAddress;


/**
 获取对方昵称
 */
- (NSString *)getRemoteDisplayName;


/**
 获取通话参数
 */
- (SYLinphoneCallParams *)getCallParams;


/**
 将int转为标准格式的NSString时间
 */
+ (NSString *)durationToString:(int)duration;

/**
 获取sip账号
 */
- (NSString *)getSipNumber;

/**
 发送sip消息
 */
- (BOOL)sendMessage:(NSString *)message withExterlBodyUrl:(NSURL *)externalUrl withInternalURL:(NSURL *)internalUrl Address:(NSString *)sipNumber;

//切换视频音频
- (void)changeVideoEnable:(BOOL)isEnable;

//把流停掉（让红色状态栏和锁屏后的音乐播放页面关掉）
- (BOOL)resignActive;
- (void)becomeActive;   //激活（也就是登录）
- (BOOL)enterBackgroundMode;    //进入后台常驻（不让杀死）
- (void)stopLinphoneCore:(LinphoneCall *)call;

- (void)changeVideoSize:(int)videoSize; //0清晰  1流畅
- (float)getVideoQualityWithCall:(SYLinphoneCall *)call;//获取通话质量
- (void)muteMic:(BOOL)mute; //静音
- (void)refreshRegisters;//刷新 

//--------友邻帮

/**
 获取sip账号
 */
- (NSString *)getSipNumber:(SYLinphoneCall *)call;

- (SYLinphoneCall *)callByCallId:(NSString *)call_id;

- (void)changeVideoSize:(int)type;
- (void)defaultVideoEnable:(BOOL)isEnable;


@end






