//
//  SYLinphoneDelegate.h
//  LinPhone
//
//  Created by sayee. on 16/7/13.
//  Copyright © 2016年 sayee. All rights reserved.
//

#ifndef SYLinphoneDelegate_h
#define SYLinphoneDelegate_h

#import "SYLinphoneStatus.h"
@protocol SYLinphoneDelegate <NSObject>
@optional


//  登陆状态变化回调
- (void)onRegisterStateChange:(SYLinphoneRegistrationState) state message:(const char*) message;

// 发起来电回调
- (void)onOutgoingCall:(SYLinphoneCall *)call withState:(SYLinphoneCallState)state withMessage:(NSDictionary *) message;

// 收到来电回调
- (void)onIncomingCall:(SYLinphoneCall *)call withState:(SYLinphoneCallState)state withMessage:(NSDictionary *) message withIsVideo:(BOOL)isVideo;

// 接听回调
-(void)onAnswer:(SYLinphoneCall *)call withState:(SYLinphoneCallState)state withMessage:(NSDictionary *) message;

// 释放通话回调
- (void)onHangUp:(SYLinphoneCall *)call withState:(SYLinphoneCallState)state withMessage:(NSDictionary *) message;

// 呼叫失败回调
- (void)onDialFailed:(SYLinphoneCallState)state withMessage:(NSDictionary *) message;

// 暂停通话回调
- (void)onPaused:(SYLinphoneCall *)call withState:(SYLinphoneCallState)state withMessage:(NSDictionary *) message;
@end

#endif /* SYLinphoneDelegate_h */
