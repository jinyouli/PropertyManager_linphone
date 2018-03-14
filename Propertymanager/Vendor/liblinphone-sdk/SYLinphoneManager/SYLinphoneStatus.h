//
//  SYLinphoneStatus.h
//  LinphoneDemo
//
//  Created by sayee on 16/7/13.
//  Copyright © 2017年 sayee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYLinphoneStatus : NSObject


typedef enum _SYConnectivityState {
    sy_wifi,
    sy_wwan,
    sy_none
} SYConnectivityState;

typedef enum _SYLinphoneRegistrationState{
    SYLinphoneRegistrationNone,                       /**<登陆信息初始化*/
    SYLinphoneRegistrationProgress,                /**<登陆中 */
    SYLinphoneRegistrationOk,                           /**< 登陆成功 */
    SYLinphoneRegistrationCleared,                   /**< 注销成功 */
    SYLinphoneRegistrationFailed                       /**<登陆失败 */
}SYLinphoneRegistrationState;

typedef enum _SYLinphoneCallState{
    SYLinphoneCallIdle,                                        /**<0通话初始化 */
    SYLinphoneCallIncomingReceived,              /**<1收到来电 */
    SYLinphoneCallOutgoingInit,                         /**<2呼出电话初始化 */
    SYLinphoneCallOutgoingProgress,              /**<3呼出电话拨号中 */
    SYLinphoneCallOutgoingRinging,                 /**<4呼出电话正在响铃 */
    SYLinphoneCallOutgoingEarlyMedia,           /**<5An outgoing call is proposed early media */
    SYLinphoneCallConnected,                           /**<6通话连接成功*/
    SYLinphoneCallStreamsRunning,                 /**<7媒体流已建立*/
    SYLinphoneCallPausing,                                 /**<8通话暂停中 */
    SYLinphoneCallPaused,                                 /**<9通话暂停成功*/
    SYLinphoneCallResuming,                             /**<10通话被恢复*/
    SYLinphoneCallRefered,                                 /**<11通话转移*/
    SYLinphoneCallError,                                      /**<12通话错误*/
    SYLinphoneCallEnd,                                        /**<13通话正常结束*/
    SYLinphoneCallPausedByRemote,               /**<14通话被对方暂停*/
    SYLinphoneCallUpdatedByRemote,              /**<15对方请求更新通话参数 */
    SYLinphoneCallIncomingEarlyMedia,             /**<16We are proposing early media to an incoming call */
    SYLinphoneCallUpdating,                                 /**<17A call update has been initiated by us */
    SYLinphoneCallReleased,                                /**<18通话被释放 */
    SYLinphoneCallEarlyUpdatedByRemote,       /*/<19通话未应答.*/
    SYLinphoneCallEarlyUpdating,                        /*/<20通话未应答我方*/
    SYLinphoneCallNumberError                           /*/<21号码有误*/
} SYLinphoneCallState;


/**
 userInfo 字典 :
 LinphoneProxyConfig config = [[notif.userInfo objectForKeyedSubscript:@"cfg"] pointerValue]
 SYLinphoneRegistrationState astate = [[notif.userInfo objectForKey:@"state"] intValue];
 value NSString    key @"message"
 */
extern NSString *const kSYLinphoneRegistrationUpdate;   //登录状态改变通知

/**
 userInfo 字典 :
 LinphoneCall *acall = [[notif.userInfo objectForKey:@"call"] pointerValue];
 SYLinphoneCallState astate = [[notif.userInfo objectForKey:@"state"] intValue];
 value NSString    key @"message"
 */
extern NSString *const kSYLinphoneCallUpdate;

/**
 userInfo 字典 :
 LinphoneCore *acall = [[notif.userInfo objectForKey:@"core"] pointerValue];
 */
extern NSString *const kSYLinphoneCoreUpdate;

// 通话strut
typedef struct _LinphoneCall SYLinphoneCall;
typedef struct _LinphoneCallParams SYLinphoneCallParams;

@end
