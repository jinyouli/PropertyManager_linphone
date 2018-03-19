//
//  PMConst.m
//  PropertyManager
//
//  Created by Momo on 17/2/28.
//  Copyright © 2017年 Doubango Telecom. All rights reserved.
//

#import "PMConst.h"

//============================================================================
//                  逆向传值对应的type
//============================================================================

/** 完成工单的逆向传值类型 */
NSString * const COMPLETEORDERTYPE = @"COMPLETEORDERTYPE";

/** 评论工单的逆向传值类型 */
NSString * const COMMANDORDERTYPE = @"COMMANDORDERTYPE";



//============================================================================
//                  个推对应的命令字，实际上就是cmd对应的字符串
//============================================================================

/** 派单个推 */
NSString * const SYREPAIRS_SEND = @"0910";
/** 接单个推 */
NSString * const SYREPAIRS_GET = @"0911";
/** 完成工单个推 */
NSString * const SYREPAIRS_COMPLETE = @"0912";
/** 转单个推 */
NSString * const SYREPAIRS_CHANGE = @"0913";
/** 回复个推 */
NSString * const SYREPAIRS_REPLY = @"0914";
/** 评论个推 */
NSString * const SYREPAIRS_COMMENT = @"0915";
/** 提醒转单个推 */
NSString * const SYREPAIRS_REMIND = @"0916";
/** 系统结束工单个推 */
NSString * const SYREPAIRS_FINISH = @"0917";
/** 催单个推 */
NSString * const SYREPAIRS_REMINDER = @"0918";
/** 新建工单个推 */
NSString * const SYREPAIRS_CREATE = @"0919";
/** 返单个推 */
NSString * const SYREPAIRS_RETURN = @"0920";
/** 取消工单个推 */
NSString * const SYREPAIRS_CANCEL = @"0921";
/** 用户登录个推 */
NSString * const SYUSERLOGIN = @"0819";


//============================================================================
//                  偏好设置对应的key（消息设置）
//============================================================================
/** 全部消息通知开关 */
NSString * const AllSoundOpen = @"news_AllSoundOpen";

/** 消息声音开关 */
NSString * const NewsSoundOpen = @"news_NewsSoundOpen";

/** 工单动态消息开关 */
NSString * const OrdersSoundOpen = @"news_OrdersSoundOpen";

/** 全部消息通知震动 */
NSString * const AllShakeOpen = @"news_AllShakeOpen";

/** 消息震动 */
NSString * const NewsShakeOpen = @"news_NewsShakeOpen";

/** 工单动态消息震动 */
NSString * const OrdersShakeOpen = @"news_OrdersShakeOpen";




//============================================================================
//                  数据库
//============================================================================

/** 订单表单名称*/
NSString* const OrderInfo = @"orderInfo";
NSArray * const OrderInfoInfoDic = @[@"isRepair",@"orderType",@"power_do",@"fstatus",@"normal_do",@"deal_worker_id",@"fscore",@"record_num",@"repair_id",@"faddress",@"fservicecontent",@"frealname",@"fcreatetime",@"fordernum",@"fworkername",@"fusername",@"fheadurl",@"fremindercount",@"flinkman_phone",@"flinkman",@"isOpenDetail",@"fimagpath1",@"fimagpath2",@"fimagpath3"];


/** 回复（详情）表单*/
NSString* const DetailInfo = @"detailInfo";
NSArray * const DetailInfoDic = @[@"repair_id",@"reply_id",@"ftype",@"fcreatetime",@"name",@"old_name",@"nMyName1",@"fcontent",@"fimagpath1",@"fimagpath2",@"fimagpath3"];


/** 通话记录表单*/
NSString* const PhoneHistory = @"PhoneHistory";
NSArray * const PhoneHistoryDic = @[@"id",@"mediaType",@"start",@"end",@"remoteParty",@"remotePartyDisplayName",@"seen",@"status"];


/** 按A_Z排列表单*/
NSString* const A_ZInfo = @"A_ZInfo";
/** 按A_Z排列表单字段*/
NSArray * const A_ZInfoDic = @[@"fusername",@"first_py",@"fdepartmentname",@"fworkername",@"worker_id",@"user_sip"];

/** 按分组排列表单*/
NSString* const SortInfo = @"SortInfo";
/** 按分组排列表单字段*/
NSArray * const SortInfoDic = @[@"fusername",@"fgroup_name",@"first_py",@"fdepartmentname",@"fworkername",@"worker_id",@"user_sip"];

/** 数据联系人存储*/
NSString* const StorageInfo = @"StorageInfo";
/** 数据联系人存储字段*/
NSArray * const StorageInfoDic = @[@"fusername",@"first_py",@"fdepartmentname",@"fworkername",@"worker_id",@"user_sip",@"storageWorkerID"];

/** 勿扰模式*/
NSString * const DontDisturbInfo = @"DontDisturbInfo";
/** 勿扰模式字段*/
NSArray * const DontDisturbInfoDic =  @[@"fusername",@"isDontDisturb",@"statTime",@"endTime"];

/** 小区公告是否已读*/
NSString* const PlotNewsInfo = @"PlotNewsInfo";
/** 小区公告是否已读字段*/
NSArray * const PlotNewsInfoDic = @[@"fusername",@"noticeID"];

NSString* const ListenHistoryInfo = @"hist_event";
/** 小区公告是否已读字段*/
NSArray * const ListenHistoryInfoDic = @[@"seen",@"status",@"mediaType",@"remoteParty",@"start",@"end",@"content"];

//============================================================================
//                  doubango 定义
//============================================================================

NSString* const KEY_USERNAME_PASSWORD = @"com.company.app.usernamepassword";
NSString* const KEY_USERNAME = @"com.company.app.username";
NSString* const KEY_PASSWORD = @"com.company.app.password";


NSString* const kTAG = @"AppDelegate///: ";

NSString* const kNotifOrderComingCmd = @"orderComingCmd";
NSString* const kNotifOrderComingId = @"orderComingId";
NSString* const kNotifKey = @"key";
NSString* const kNotifKey_IncomingCall = @"icall";
NSString* const kNotifKey_IncomingMsg = @"imsg";
NSString* const kNotifIncomingCall_SessionId = @"sid";
NSString* const kNetworkAlertMsgThreedGNotEnabled = @"只有3G网络可用。请启用3G和再试一次。";
NSString* const kNetworkAlertMsgNotReachable = @"没有网络连接。";
NSString* const kNewMessageAlertText = @"你有一条新消息";
NSString* const kAlertMsgButtonOkText = @"确认";
NSString* const kAlertMsgButtonCancelText = @"取消";



NSArray * kColorsDarkBlack = @[(id)[[UIColor colorWithRed:.1f green:.1f blue:.1f alpha:1] CGColor],(id)[[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:1] CGColor]];

NSArray * kColorsLightBlack = @[(id)[[UIColor colorWithRed:.2f green:.2f blue:.2f alpha:0.7] CGColor],(id)[[UIColor colorWithRed:.1f green:.1f blue:.1f alpha:0.7] CGColor],(id)[[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.7] CGColor]];

UIControlState kButtonStateAll = UIControlStateSelected | UIControlStateNormal | UIControlStateHighlighted | UIControlStateDisabled | UIControlStateApplication;


CGFloat const kCallTimerSuicide = 0.0f;
CGFloat const kQoSTimer = 1.0f;



//============================================================================
//                  获取后台数据的接口
//============================================================================

/** 协议 */
NSString * const SYHTTPSSTR = @"https://";

/** 一级平台 接口调试模式 0:外网  1:公司内部测试服务器 */
#define DEBUGMODE 0

#if DEBUGMODE == 0
//外网测试
NSString * SYFirIP = @"api.sayee.cn:28084";

#elif DEBUGMODE == 1
//内网测试
NSString * SYFirIP = @"gdsayede.cn:28086";

#endif


/** 用户登录的访问路径 */
NSString* const SYLoginURL = @"/tenement/login.json";

/** 获取联系人列表 a_z */
NSString* const SYGet_communicate_list = @"/tenement/get_communicate_list.json";

/** 更新订单状态 */
NSString* const SYUpdate_order_status = @"/tenement/update_order_status.json";

/** 获取工单列表 */
NSString* const SYGet_work_order_list = @"/tenement/get_work_order_list.json";

/** 获取工单详情 */
NSString* const SYGet_work_order_details = @"/tenement/get_work_order_details.json";

/** 短信验证码修改密码 */
NSString* const SYChange_pwd_by_verify_code = @"/tenement/change_pwd_by_verify_code.json";

/** 获取app版本信息 */
NSString* const SYGet_app_version = @"/device/get_app_version.json";

/** 保存工单记录 */
NSString* const SYSave_repairs_record = @"/upload/save_repairs_record.json";

/** 获取短信验证码 */
NSString* const SYGet_verify_code_message = @"/tenement/get_verify_code_message.json";

/** 验证短信验证码 */
NSString* const SYValidate_mobile_phone = @"/users/validate_mobile_phone.json";

/** 获取派单工人 */
NSString* const SYGet_worker_list = @"/tenement/get_worker_list.json";

/** 获取小区公告轮播图 */
NSString* const SYGet_notice_by_pager = @"/tenement/get_notice_by_pager.json";

/** 获取小区信息信息详情 */
NSString* const SYGet_neibor_msg = @"/tenement/get_neibor_msg.json";

/** 通过工单号获取工单详情 */
NSString* const SYGet_work_order_by_id = @"/tenement/get_work_order_by_id.json";

/** 更新物业动态为已读 */
NSString* const SYUpdate_push_msg_to_read = @"/tenement/update_push_msg_to_read.json";

/** 获取物业动态消息 */
NSString* const SYGet_push_msg_list = @"/tenement/get_push_msg_list.json";

/** 通过旧密码修改新密码 */
NSString* const SYChange_pwd_by_old_pwd = @"/tenement/change_pwd_by_old_pwd.json";

/** 物管端–开锁权限列表 */
NSString* const SYGet_department_lock_list = @"/tenement/get_department_lock_list.json";

/** 物管端打开APP获取ip以及社区列表 */
NSString* const SYGet_nei_list_of_tenement = @"/tenement/get_nei_list_of_tenement.json";

/** 23.1门禁解锁(app请求门口机开锁) */
NSString* const SYRemote_unlock = @"/device/remote_unlock.json";

/** 获取ip地址列表 */
NSString* const SYGet_server_ip_list = @"/config/get_server_ip_list.json";

/** 获取七牛云token */
NSString* const SYGet_upload_token = @"/upload/get_upload_token.json";

/** 20.根据未过期的旧token换取新token（物管、用户端) */
NSString* const SYGet_token_by_old_token = @"/fir_platform/get_token_by_old_token.json";


