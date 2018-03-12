//
//  SYSipSendMessage.h
//  YLB
//
//  Created by chenjiangchuan on 16/12/7.
//  Copyright © 2016年 Sayee Intelligent Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYSipSendMessage : NSObject

/**
 *  滑动解锁向门口机发送一条sip短信
 */
+ (void)sipSendMessageUnlockDoorMonitorWithParams:(NSDictionary *)params;


@end
