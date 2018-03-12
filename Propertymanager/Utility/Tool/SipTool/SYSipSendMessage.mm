//
//  SYSipSendMessage.m
//  YLB
//
//  Created by chenjiangchuan on 16/12/7.
//  Copyright © 2016年 Sayee Intelligent Technology. All rights reserved.
//

#import "SYSipSendMessage.h"
#import "iOSNgnStack.h"

@implementation SYSipSendMessage

/**
 *  滑动解锁向门口机发送一条sip短信
 */
+ (void)sipSendMessageUnlockDoorMonitorWithParams:(NSDictionary *)params {
    
    NSString *username = params[@"username"];
    NSString *domainSN = params[@"domain_sn"];
    NSString *type = params[@"type"];
    NSString *time = params[@"time"];
    NSString *sipNumber = params[@"sip_number"]; // 1000000719

    
    NSString *text = [NSString stringWithFormat:@"{\"ver\":\"1.0\",\"typ\":\"req\",\"cmd\":\"0610\",\"tgt\":\"%@\",\"cnt\":{\"username\":\"%@\",\"type\":\"%@\",\"time\":\"%@\"}}", domainSN, username,  type, time];
    NSString *sipString = [NSString stringWithFormat: @"sip:%@@%@", sipNumber, domainSN];
    
    SYLog(@"%s\n%@", __FUNCTION__, sipString);
    SYLog(@"text = %@", text);
    
    ActionConfig* actionConfig = new ActionConfig();
    if(actionConfig){
        actionConfig->addHeader("Organization", "Doubango Telecom");
        actionConfig->addHeader("Subject", "testMessaging for iOS");
    }
    NgnMessagingSession* imSession = [[NgnMessagingSession sendTextMessageWithSipStack: [[NgnEngine sharedInstance].sipService getSipStack]
                                                                              andToUri: sipString
                                                                            andMessage: text
                                                                        andContentType: kContentTypePlainText
                                                                       andActionConfig: actionConfig] retain]; // Do not retain the session if you don't want it
    // do whatever you want with the session
    if(actionConfig){
        delete actionConfig, actionConfig = tsk_null;
    }
    [NgnMessagingSession releaseSession: &imSession];
}


@end
