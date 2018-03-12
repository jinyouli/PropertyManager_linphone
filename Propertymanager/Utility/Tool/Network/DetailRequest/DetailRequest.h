//
//  DetailRequest.h
//  PropertyManager
//
//  Created by Momo on 17/3/3.
//  Copyright © 2017年 Momo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DetailRequest : NSObject

/** 获取七牛token*/
+ (void) getQiNiuToken;

/** 登陆 ret：yes 是首次登陆 no：token失效重新登录 登录*/
+(void)loginBtnClickWithPhone:(NSString *)phone password:(NSString *)password isFirstLogin:(BOOL)ret;

/** 获取IP地址*/
+ (void)SYGet_nei_list_of_tenementWithSuccessBlock:(void(^)(NSArray * value)) success;

/** 获取验证码*/
+ (void)SYGet_verify_code_messageWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)()) success;

/** 验证短信验证码*/
+ (void)SYValidate_mobile_phoneWithHeader:(NSDictionary *)header WithParms:(NSDictionary *)parmas SuccessBlock:(void(^)()) success;

/** 修改密码*/
+ (void)SYChange_pwd_by_verify_codeWithHeader:(NSDictionary *)header WithParms:(NSDictionary *)parmas SuccessBlock:(void(^)()) success;

/** 获取小区公告 系统消息*/
+ (void)SYGet_notice_by_pagerWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)(NSArray * value)) success FailureBlock:(void(^)()) failure;

/** 获取物业消息*/
+ (void)SYGet_push_msg_listWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)(NSArray * value)) success FailureBlock:(void(^)()) failure;

/** 小区简介*/
+ (void)SYGet_neibor_msgWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)(NSDictionary * result)) success;

/** 完成工单状态 接受工单 派单结果*/
+ (void)SYUpdate_order_statusWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)()) success FailureBlock:(void(^)()) failure;

/** 保存工单相关信息记录*/
+ (void)SYSave_repairs_recordWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)()) success FailureBlock:(void(^)()) failure;

/** 请求工单*/
+ (void)SYGet_work_order_listWithParms:(NSDictionary *)parmas isFirstRequest:(BOOL)first SuccessBlock:(void(^)(NSArray * list)) success FailureBlock:(void(^)()) failure;

/** 获取工单详情(评论)*/
+ (void)SYGet_work_order_detailsWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)(NSArray * details)) success;

/** 获取工单详情(更多评论中评论获取)*/
+ (void)MoreVCSYGet_work_order_detailsWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)(NSArray * details)) success FailureBlock:(void(^)()) failure;

/** 获取派单工单组*/
+ (void)SYGet_worker_listWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)(NSArray * workers)) success FailureBlock:(void(^)()) failure;

/** 获取联系人列表*/
+ (void)SYGet_communicate_listWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)(NSArray * arr)) success FailureBlock:(void(^)()) failure;

/** 获取app版本信息 */
+ (void)SYGet_app_versionSuccessBlock:(void(^)(NSDictionary * VersionInfo)) success;

/** 旧token换取新token（物管、用户端) */
+ (void)SYGet_token_by_old_tokenSuccessBlock:(void(^)(NSDictionary * result)) success;

/** 通过工单号获取工单详情 */
+ (void)SYGet_work_order_by_idWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)(NSDictionary * result,NSArray * details_list)) success;

/** 更新物业动态为已读*/
+ (void)SYUpdate_push_msg_to_readWithParms:(NSDictionary *)parmas;

/** 通过旧密码修改新密码 */
+ (void)SYChange_pwd_by_old_pwdWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)()) success FailureBlock:(void(^)(NSString * msg)) failure;

/** 物管端–开锁权限列表 */
+ (void)SYGet_department_lock_listWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)(NSArray * result)) success FailureBlock:(void(^)()) failure;

/** 门禁解锁(app请求门口机开锁) */
+ (void)SYRemote_unlockWithParms:(NSDictionary *)parmas;
@end
