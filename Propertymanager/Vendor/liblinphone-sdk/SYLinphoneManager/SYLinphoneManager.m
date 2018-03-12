//
//  SYLinphoneManager.m
//  LinphoneDemo
//
//  Created by sayee on 16/7/13.
//  Copyright © 2016年 sayee. All rights reserved.
//

#import "SYLinphoneManager.h"
#import "LinphoneManager.h"

#define LC ([LinphoneManager getLc])

@implementation SYLinphoneManager

static SYLinphoneManager* theSYLinphoneManager = nil;
static id _SYLinphoneDelegate =nil; //代理对象，用于回调

/**
 @author Jozo, 16-06-30 11:06:07
 
 实例化
 */
+ (SYLinphoneManager*)instance {
    if(theSYLinphoneManager == nil) {
        theSYLinphoneManager = [SYLinphoneManager new];
    }
    return theSYLinphoneManager;
}

- (id)init {
    self = [super init];
    if (self) {
//        dict = [[NSMutableDictionary alloc] init];
//        changedDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/**
 @author Jozo, 16-07-01 15:07:51
 
 扬声器状态
 */
- (BOOL)speakerEnabled {
    return [LinphoneManager instance].speakerEnabled;
}
- (void)setSpeakerEnabled:(BOOL)speakerEnabled {
    [[LinphoneManager instance] setSpeakerEnabled:speakerEnabled];
}


/**
 @author Jozo, 16-07-01 15:07:37
 
 获取当前通话
 */
- (SYLinphoneCall *)currentCall {
    return linphone_core_get_current_call(LC) ? linphone_core_get_current_call(LC) : nil;
}


/**
 @author Jozo, 16-07-01 15:07:06
 
 SYLinphone是否已经准备好
 */
- (BOOL)isSYLinphoneReady {
    return [LinphoneManager isLcReady];
}


/*!
 *  @brief  设置代理
 */
//- (void)setDelegate:(id<SYLinphoneDelegate>)delegate
//{
//    [SYLinphoneManager instance].delegate = delegate;
////    _SYLinphoneDelegate = delegate;
//}


/**
 @author Jozo, 16-06-30 11:06:18
 
 初始化
 */
- (void)startSYLinphonephone {
    
    [[LinphoneManager instance] startLibLinphone];
}


/**
 @author Jozo, 16-06-30 11:06:13
 
 登陆
 
 @param username  用户名
 @param password  密码
 @param displayName  昵称
 @param domain    域名或IP
 @param port      端口
 @param transport 连接方式
 
 */
- (BOOL)addProxyConfig:(NSString*)username password:(NSString*)password displayName:(NSString *)displayName domain:(NSString*)domain port:(NSString *)port withTransport:(NSString*)transport {
    if (!username || !password || !domain || !port) {
        NSLog(@"======注册linphone user_sip password domain port 为空==========");
        return NO;
    }
    
    if (!transport) {
        transport = @"TCP";
    }

    LinphoneCore* lc = [LinphoneManager getLc];
    
    if (lc == nil) {
        [self startSYLinphonephone];
        lc = [LinphoneManager getLc];
    }
    
    LinphoneProxyConfig* proxyCfg = linphone_core_create_proxy_config(lc);
    NSString* server_address = domain;
    
    char normalizedUserName[256];
    linphone_proxy_config_normalize_number(proxyCfg, [username cStringUsingEncoding:[NSString defaultCStringEncoding]], normalizedUserName, sizeof(normalizedUserName));
    
    
    const char *identity = [[NSString stringWithFormat:@"sip:%@@%@", username, domain] cStringUsingEncoding:NSUTF8StringEncoding];
    
    LinphoneAddress* linphoneAddress = linphone_address_new(identity);
    linphone_address_set_username(linphoneAddress, normalizedUserName);
    if (displayName && displayName.length != 0) {
        linphone_address_set_display_name(linphoneAddress, (displayName.length > 0 ? displayName.UTF8String : NULL));
    }
    if( domain && [domain length] != 0) {
        if( transport != nil ){
            server_address = [NSString stringWithFormat:@"%@:%@;transport=%@", server_address, port, [transport lowercaseString]];
        }
        // when the domain is specified (for external login), take it as the server address
        linphone_proxy_config_set_server_addr(proxyCfg, [server_address UTF8String]);
        linphone_address_set_domain(linphoneAddress, [domain UTF8String]);
        
    }
    
    // 添加了昵称后的identity
    identity = linphone_address_as_string(linphoneAddress);
    
    //    char* extractedAddres = linphone_address_as_string_uri_only(linphoneAddress);
    linphone_address_destroy(linphoneAddress);
    //    LinphoneAddress* parsedAddress = linphone_address_new(extractedAddres);
    //    ms_free(extractedAddres); // 释放
    
    //    if( parsedAddress == NULL || !linphone_address_is_sip(parsedAddress) ){
    //        if( parsedAddress ) linphone_address_destroy(parsedAddress);
    //        UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Check error(s)",nil)
    //                                                            message:NSLocalizedString(@"Please enter a valid username", nil)
    //                                                           delegate:nil
    //                                                  cancelButtonTitle:NSLocalizedString(@"Continue",nil)
    //                                                  otherButtonTitles:nil,nil];
    //        [errorView show];
    //        return FALSE;
    //    }
    //
    //    char *c_parsedAddress = linphone_address_as_string_uri_only(parsedAddress);
    ////    linphone_proxy_config_set_identity(proxyCfg, c_parsedAddress);
    //    linphone_address_destroy(parsedAddress);
    LinphoneAuthInfo* info = linphone_auth_info_new([username UTF8String]
                                                    , NULL, [password UTF8String]
                                                    , NULL
                                                    , linphone_proxy_config_get_realm(proxyCfg)
                                                    ,linphone_proxy_config_get_domain(proxyCfg));
    
    [self setDefaultSettings:proxyCfg];
    
    LCSipTransports transportValue={-1,-1,-1,-1};
    if (linphone_core_set_sip_transports(lc, &transportValue)) {
        [LinphoneLogger logc:LinphoneLoggerError format:"cannot set transport"];
    }
    
    [self clearProxyConfig];
    
    //    linphone_core_clear_all_auth_info(lc);
    linphone_proxy_config_set_identity(proxyCfg, identity);
    linphone_proxy_config_set_expires(proxyCfg, 3600);
    linphone_proxy_config_enable_register(proxyCfg, true);
    linphone_core_add_auth_info(lc, info);
    linphone_core_add_proxy_config(lc, proxyCfg);
    linphone_core_set_default_proxy_config(lc, proxyCfg);
    ms_free(identity);
    
    return TRUE;
}


- (void)resumeCall{
    [[LinphoneManager instance] resumeCall:self.currentCall];
}

/**
 @author Kohler, 16-07-04 17:07:33
 
 注销登陆信息
 */
- (void)removeAccount {

    if (self.isSYLinphoneReady == YES) {
        [self clearProxyConfig];
        //        [[LinphoneManager instance] destroyLibLinphone];
        [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"pushnotification_preference"];
        
        LinphoneCore *lc = [LinphoneManager getLc];
        LCSipTransports transportValue={5060,5060,-1,-1};
        
        if (linphone_core_set_sip_transports(lc, &transportValue)) {
            [LinphoneLogger logc:LinphoneLoggerError format:"cannot set transport"];
        }
        
        [[LinphoneManager instance] lpConfigSetString:@"" forKey:@"sharing_server_preference"];
        [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"ice_preference"];
        [[LinphoneManager instance] lpConfigSetString:@"" forKey:@"stun_preference"];
        linphone_core_set_stun_server(lc, NULL);
        linphone_core_set_firewall_policy(lc, LinphonePolicyNoFirewall);
    }
}


- (void)clearProxyConfig {
    linphone_core_clear_proxy_config([LinphoneManager getLc]);
    linphone_core_clear_all_auth_info([LinphoneManager getLc]);
}


- (void)setDefaultSettings:(LinphoneProxyConfig*)proxyCfg {
    LinphoneManager* lm = [LinphoneManager instance];
    
    [lm configurePushTokenForProxyConfig:proxyCfg];
    
}


/**
 @author Jozo, 16-06-30 11:06:52
 
 拨打电话
 
 @param address     ID
 @param displayName 昵称
 @param transfer    transfer
 @param video    视频显示区域  当传nil过来时，拨打电话，电话通了之后，再传vidwo显示视频
 */
- (void)call:(NSString *)address displayName:(NSString*)displayName transfer:(BOOL)transfer Video:(UIView *)video{
    
    if (video) {
        linphone_core_set_native_video_window_id(LC, (__bridge void *)(video));
    }

    [[LinphoneManager instance] call:address displayName:displayName transfer:transfer];

}


/**
 @author Jozo, 16-06-30 20:06:43
 
 接听电话
 */
- (void)acceptCall:(SYLinphoneCall *)call Video:(UIView *)video
{
    if (video) {
        linphone_core_set_native_video_window_id(LC, (__bridge void *)(video));
    }
    
    [[LinphoneManager instance] acceptCall:call];
}


/**
 @author Jozo, 16-06-30 11:06:41
 
 挂断电话
 */
- (void)hangUpCall {
    
    LinphoneCore* lc = [LinphoneManager getLc];
    LinphoneCall* currentcall = linphone_core_get_current_call(lc);

    if (currentcall != NULL) {
        linphone_core_terminate_call(lc, currentcall);
    }
    else if (linphone_core_is_in_conference(lc)){
        linphone_core_terminate_conference(lc);
    }
    else {
        const MSList* calls = linphone_core_get_calls(lc);
        if (ms_list_size(calls) == 1) { // Only one call
            linphone_core_terminate_call(lc,(LinphoneCall*)(calls->data));
        }
    }
}

- (void)hangUpCall:(LinphoneCall *)currentcall
{
    LinphoneCore* lc = [LinphoneManager getLc];
    
    if (currentcall != NULL) {
        linphone_core_terminate_call(lc, currentcall);
    }
    else if (linphone_core_is_in_conference(lc)){
        linphone_core_terminate_conference(lc);
    }
    else {
        const MSList* calls = linphone_core_get_calls(lc);
        if (ms_list_size(calls) == 1) { // Only one call
            linphone_core_terminate_call(lc,(LinphoneCall*)(calls->data));
        }
    }
}

/**
 @author Jozo, 16-06-30 17:06:47
 
 获取通话状态
 */
- (SYLinphoneCallState)getCallState:(SYLinphoneCall *)call {
    return linphone_call_get_state(call);
}


/**
 @author Jozo, 16-06-30 18:06:06
 
 获取通话时长
 */
- (int)getCallDuration {
    if (LC == nil || self.isSYLinphoneReady == NO) {
        return 0;
    }
    int duration =
    linphone_core_get_current_call(LC) ? linphone_call_get_duration(linphone_core_get_current_call(LC)) : 0;
    
    return duration;
}


/**
 @author Jozo, 16-06-30 18:06:19
 
 获取对方号码
 */
- (NSString *)getRemoteAddress:(SYLinphoneCall *)call {
    if (call == nil) {
        return nil;
    }
    LinphoneAddress *address = linphone_call_get_remote_address(call);
    
    char *uri = linphone_address_as_string_uri_only(address);
    NSString *addressStr = [NSString stringWithUTF8String:uri];
    NSString *normalizedSipAddress = [[addressStr
                                       componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@" "];
    LinphoneAddress *addr = linphone_core_interpret_url(LC, [addressStr UTF8String]);
    
    if (addr != NULL) {
        linphone_address_clean(addr);
        char *tmp = linphone_address_as_string(addr);
        normalizedSipAddress = [NSString stringWithUTF8String:tmp];
        ms_free(tmp);
        linphone_address_destroy(addr);
    }
    
    //    char *name = linphone_address_get_username(address);
    //    NSString *addressStr = [NSString stringWithUTF8String:name];
    
    return addressStr;
}


/**
 @author Jozo, 16-06-30 18:06:19
 
 获取对方昵称
 */
- (NSString *)getRemoteDisplayName:(SYLinphoneCall *)call {
//    if (self.currentCall == nil) {
//        return nil;
//    }
//
//    LinphoneAddress *address = linphone_core_get_current_call_remote_address(LC);
//
//    char *uri = linphone_address_get_display_name(address);
//    if (uri) {
//        return [NSString stringWithUTF8String:uri];
//    }
//    return @"";
    
    
    const LinphoneAddress *addr;
    if (!call) {
        addr = linphone_core_get_current_call_remote_address(LC);
    }else{
        addr = linphone_call_get_remote_address(call);
    }

    NSString* address = nil;
    if(addr != NULL) {
        BOOL useLinphoneAddress = true;
        
        if(useLinphoneAddress) {
            const char* lDisplayName = linphone_address_get_display_name(addr);
            const char* lUserName = linphone_address_get_username(addr);
            if (lDisplayName)
                address = [NSString stringWithUTF8String:lDisplayName];
            else if(lUserName)
                address = [NSString stringWithUTF8String:lUserName];
        }
    }
    
    
    //门口机拨打过来的名字
    NSMutableString *displayName = [[NSMutableString alloc] initWithString:@""];
    
    if ([address rangeOfString:@","].location == NSNotFound) {
        [displayName appendString:address];
    } else {
        NSArray * codeArr = [address componentsSeparatedByString:@","];
        
        for (int i = 0; i < codeArr.count - 1; i ++) {
            NSString * codeStr = codeArr[i];
            unichar theChar = [codeStr intValue];
            [displayName appendFormat:@"%@", [NSString stringWithFormat:@"%C",theChar]];
        }
    }

    return displayName;
}


/**
 @author Jozo, 16-07-04 09:07:50
 
 获取通话参数
 */
- (SYLinphoneCallParams *)getCallParams {
    if (!self.currentCall) {
        return nil;
    }
    return linphone_call_get_current_params(self.currentCall);
}


/**
 获取sip账号
 */
- (NSString *)getSipNumber:(SYLinphoneCall *)call {

    LinphoneAddress *address;
    if (call == nil) {
        address = linphone_core_get_current_call_remote_address(LC);
    }
    else{
        address = linphone_call_get_remote_address(call);
    }

    return  [NSString stringWithUTF8String:linphone_address_get_username(address)];
}


/**
 发送sip消息
 */
- (BOOL)sendMessage:(NSString *)message withExterlBodyUrl:(NSURL *)externalUrl withInternalURL:(NSURL *)internalUrl Address:(NSString *)sipNumber{

   return [[LinphoneManager instance] sendMessage:message withExterlBodyUrl:externalUrl withInternalURL:internalUrl Address:sipNumber];
}

//把流停掉（让红色状态栏和锁屏后的音乐播放页面关掉）
- (BOOL)resignActive{
   return [[LinphoneManager instance] resignActive];
}

- (void)becomeActive{
   return [[LinphoneManager instance] becomeActive];
}

- (BOOL)enterBackgroundMode{
   return [[LinphoneManager instance] enterBackgroundMode];
}


#pragma mark - =======自己加的=====
/* 是否支持IPV6
 */
- (BOOL)ipv6Enabled {
    return [LinphoneManager instance].ipv6Enabled;
}
- (void)setIpv6Enabled:(BOOL)ipv6Enabled{
    [[LinphoneManager instance] setIpv6Enabled:ipv6Enabled];
}

//是否支持视频呼叫
- (BOOL)videoEnable{
    return [LinphoneManager instance].videoEnable;
}

- (void)setVideoEnable:(BOOL)videoEnable{
    [[LinphoneManager instance] setVideoEnable:videoEnable];
}


//expires
- (unsigned int)nExpires{
    return [LinphoneManager instance].nExpires;
}

- (void)setNExpires:(unsigned int)nExpires{
    [[LinphoneManager instance] setNExpires:nExpires];
}




- (void)playRing{
    [[LinphoneManager instance] playMessageSound];
}
- (void)stopRing{
    [[LinphoneManager instance] stopMessageSound];
}


//- (BOOL)isSameCall:(SYLinphoneCall *)call{
//    LinphoneCallLog* callLog=linphone_call_get_call_log(call);
//    NSString* callId=[NSString stringWithUTF8String:linphone_call_log_get_call_id(callLog)];
////    NSLog(@"====callId===%@", callId);
//    if ([callId rangeOfString:@"-"].location != NSNotFound) {
//        return NO;
//    }
//    return YES;
////    if (currentCallId && [currentCallId isEqualToString:callId]) {
////        return YES;
////    }
//    return NO;
//}

- (void)resetSYLinphoneCore{
    [[LinphoneManager instance] resetLinphoneCore];
}
- (BOOL)popPushSYCall:(SYLinphoneCall *)call{
    
    if (call == NULL){
        call = linphone_core_get_current_call(LC);
    }
    LinphoneCallLog* callLog = linphone_call_get_call_log(call);
    NSString* callId = [NSString stringWithUTF8String:linphone_call_log_get_call_id(callLog)];
   return [[LinphoneManager instance] popPushCallID:callId];
}
- (void)destroyLibLinphone{
    [[LinphoneManager instance] destroyLibLinphone];
}


- (SYLinphoneCall *)callByCallId:(NSString *)call_id{
   return [[LinphoneManager instance] callByCallId:call_id];
}

- (void)refreshRegisters{
[[LinphoneManager instance] refreshRegisters];
}
@end

