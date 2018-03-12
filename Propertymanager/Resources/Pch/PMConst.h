//
//  PMConst.h
//  PropertyManager
//
//  Created by Momo on 17/2/28.
//  Copyright © 2017年 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//============================================================================
//                  逆向传值对应的type
//============================================================================

/** 完成工单的逆向传值类型 */
UIKIT_EXTERN NSString * const COMPLETEORDERTYPE;
/** 评论工单的逆向传值类型 */
UIKIT_EXTERN NSString * const COMMANDORDERTYPE;

//============================================================================
//                  个推对应的命令字，实际上就是cmd对应的字符串
//============================================================================

/** 派单个推 */
UIKIT_EXTERN NSString * const SYREPAIRS_SEND;
/** 接单个推 */
UIKIT_EXTERN NSString * const SYREPAIRS_GET;
/** 完成工单个推 */
UIKIT_EXTERN NSString * const SYREPAIRS_COMPLETE;
/** 转单个推 */
UIKIT_EXTERN NSString * const SYREPAIRS_CHANGE;
/**回复个推*/
UIKIT_EXTERN NSString * const SYREPAIRS_REPLY;
/**评论个推*/
UIKIT_EXTERN NSString * const SYREPAIRS_COMMENT;
/**提醒转单个推*/
UIKIT_EXTERN NSString * const SYREPAIRS_REMIND;
/**系统结束工单个推*/
UIKIT_EXTERN NSString * const SYREPAIRS_FINISH;
/**催单个推*/
UIKIT_EXTERN NSString * const SYREPAIRS_REMINDER;
/**新建工单个推*/
UIKIT_EXTERN NSString * const SYREPAIRS_CREATE;
/**返单个推*/
UIKIT_EXTERN NSString * const SYREPAIRS_RETURN;
/** 取消工单个推 */
UIKIT_EXTERN NSString * const SYREPAIRS_CANCEL;
/** 用户登录个推 */
UIKIT_EXTERN NSString * const SYUSERLOGIN;


//============================================================================
//                  偏好设置对应的key（消息设置）
//============================================================================
/** 全部消息通知开关 */
UIKIT_EXTERN NSString * const AllSoundOpen;

/** 消息声音开关 */
UIKIT_EXTERN NSString * const NewsSoundOpen;

/** 工单动态消息开关 */
UIKIT_EXTERN NSString * const OrdersSoundOpen;

/** 全部消息通知震动 */
UIKIT_EXTERN NSString * const AllShakeOpen;

/** 消息震动 */
UIKIT_EXTERN NSString * const NewsShakeOpen;

/** 工单动态消息震动 */
UIKIT_EXTERN NSString * const OrdersShakeOpen;




//============================================================================
//                  数据库
//============================================================================

/** 订单表单名称*/
UIKIT_EXTERN NSString* const OrderInfo;

/** 订单表单字段*/
UIKIT_EXTERN NSArray * const OrderInfoInfoDic;


/** 回复（详情）表单*/
UIKIT_EXTERN NSString* const DetailInfo;

/** 回复（详情）表单字段*/
UIKIT_EXTERN NSArray * const DetailInfoDic;

/** 按A_Z排列表单*/
UIKIT_EXTERN NSString* const A_ZInfo;

/** 按A_Z排列表单字段*/
UIKIT_EXTERN NSArray * const A_ZInfoDic;

UIKIT_EXTERN NSString* const ListenHistoryInfo;
UIKIT_EXTERN NSArray * const ListenHistoryInfoDic;

/** 按分组排列表单*/
UIKIT_EXTERN NSString* const SortInfo;

/** 按分组排列表单字段*/
UIKIT_EXTERN NSArray * const SortInfoDic;

/** 数据联系人存储*/
UIKIT_EXTERN NSString* const StorageInfo;

/** 数据联系人存储字段*/
UIKIT_EXTERN NSArray * const StorageInfoDic;

/** 勿扰模式*/
UIKIT_EXTERN NSString* const DontDisturbInfo;

/** 勿扰模式字段*/
UIKIT_EXTERN NSArray * const DontDisturbInfoDic;

/** 小区公告是否已读*/
UIKIT_EXTERN NSString* const PlotNewsInfo;

/** 小区公告是否已读字段*/
UIKIT_EXTERN NSArray * const PlotNewsInfoDic;





//============================================================================
//                  doubango 定义
//============================================================================

UIKIT_EXTERN NSString* const kTAG;

UIKIT_EXTERN NSString* const KEY_USERNAME_PASSWORD;
UIKIT_EXTERN NSString* const KEY_USERNAME;
UIKIT_EXTERN NSString* const KEY_PASSWORD;


UIKIT_EXTERN NSString* const kNotifOrderComingCmd;
UIKIT_EXTERN NSString* const kNotifOrderComingId;
UIKIT_EXTERN NSString* const kNotifKey;
UIKIT_EXTERN NSString* const kNotifKey_IncomingCall;
UIKIT_EXTERN NSString* const kNotifKey_IncomingMsg;
UIKIT_EXTERN NSString* const kNotifIncomingCall_SessionId;
UIKIT_EXTERN NSString* const kNetworkAlertMsgThreedGNotEnabled;
UIKIT_EXTERN NSString* const kNetworkAlertMsgNotReachable;
UIKIT_EXTERN NSString* const kNewMessageAlertText;
UIKIT_EXTERN NSString* const kAlertMsgButtonOkText;
UIKIT_EXTERN NSString* const kAlertMsgButtonCancelText;


UIKIT_EXTERN NSArray * kColorsDarkBlack;
UIKIT_EXTERN NSArray * kColorsLightBlack;
UIKIT_EXTERN UIControlState kButtonStateAll;

UIKIT_EXTERN CGFloat const kCallTimerSuicide;
UIKIT_EXTERN CGFloat const kQoSTimer;



//============================================================================
//                  获取后台数据的接口
//============================================================================

/** 协议 */
UIKIT_EXTERN NSString* const SYHTTPSSTR;

/** 一级平台 */
UIKIT_EXTERN NSString * SYFirIP;

/** 用户登录的访问路径 */
UIKIT_EXTERN NSString* const SYLoginURL;

/** 获取联系人列表 a_z */
UIKIT_EXTERN NSString* const SYGet_communicate_list;

/** 更新订单状态 */
UIKIT_EXTERN NSString* const SYUpdate_order_status;

/** 获取工单列表 */
UIKIT_EXTERN NSString* const SYGet_work_order_list;

/** 获取工单详情 */
UIKIT_EXTERN NSString* const SYGet_work_order_details;

/** 短信验证码修改密码 */
UIKIT_EXTERN NSString* const SYChange_pwd_by_verify_code;

/** 获取app版本信息 */
UIKIT_EXTERN NSString* const SYGet_app_version;

/** 保存工单记录 */
UIKIT_EXTERN NSString* const SYSave_repairs_record;

/** 获取短信验证码 */
UIKIT_EXTERN NSString* const SYGet_verify_code_message;

/** 验证短信验证码 */
UIKIT_EXTERN NSString* const SYValidate_mobile_phone;

/** 获取派单工人 */
UIKIT_EXTERN NSString* const SYGet_worker_list;

/** 获取小区公告轮播图 */
UIKIT_EXTERN NSString* const SYGet_notice_by_pager;

/** 获取小区信息信息详情 */
UIKIT_EXTERN NSString* const SYGet_neibor_msg;

/** 通过工单号获取工单详情 */
UIKIT_EXTERN NSString* const SYGet_work_order_by_id;

/** 更新物业动态为已读 */
UIKIT_EXTERN NSString* const SYUpdate_push_msg_to_read;

/** 获取物业动态消息 */
UIKIT_EXTERN NSString* const SYGet_push_msg_list;

/** 通过旧密码修改新密码 */
UIKIT_EXTERN NSString* const SYChange_pwd_by_old_pwd;

/** 物管端–开锁权限列表 */
UIKIT_EXTERN NSString* const SYGet_department_lock_list;

/** 物管端打开APP获取ip以及社区列表 */
UIKIT_EXTERN NSString* const SYGet_nei_list_of_tenement;

/** 23.1门禁解锁(app请求门口机开锁) */
UIKIT_EXTERN NSString* const SYRemote_unlock;

/** 获取ip地址列表 */
UIKIT_EXTERN NSString* const SYGet_server_ip_list;

/** 获取七牛云token */
UIKIT_EXTERN NSString* const SYGet_upload_token;

/** 20.根据未过期的旧token换取新token（物管、用户端) */
UIKIT_EXTERN NSString* const SYGet_token_by_old_token;

