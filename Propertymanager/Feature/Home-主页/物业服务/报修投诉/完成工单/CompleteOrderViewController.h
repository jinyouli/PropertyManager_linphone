//
//  CompleteOrderViewController.h
//  idoubs
//
//  Created by Momo on 16/6/29.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "BaseViewController.h"

@interface CompleteOrderViewController : BaseViewController


/** 是否是最初派单的那个人*/
/** 如果登陆者具备派单权限，为0表示不可以对该工单操作，1为派单，2为转单（用户端不返回该字段）*/
@property (nonatomic,strong) NSNumber * isFirstSendMgr;

/** 工单id号*/
@property (nonatomic,strong) NSString * repairs_id;

/** 第几组*/
@property (nonatomic,assign) NSInteger section;

/** 是否是由工单动态跳入  YES：是 NO：不是*/
@property(nonatomic,assign) BOOL isProOrderPush;

@end
