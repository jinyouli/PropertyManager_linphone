//
//  OwnerViewController.h
//  idoubs
//
//  Created by Momo on 16/6/24.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "BaseViewController.h"
@class ContactModel;

@interface OwnerViewController : BaseViewController



/** 是否为业主 YES：业主  NO：联系人*/
@property (nonatomic,assign) BOOL isOwner;

/** 只能使用这属性   fworkername  fdepartmentname  worker_id  user_sip*/
@property (nonatomic,strong) ContactModel * contactModel;

/** 业主姓名*/
@property (nonatomic,strong) NSString * ownerName;
/** 业主联系方式*/
@property (nonatomic,strong) NSString * ownerPhone;
/** 业主地址*/
@property (nonatomic,strong) NSString * ownerAddr;

@end
