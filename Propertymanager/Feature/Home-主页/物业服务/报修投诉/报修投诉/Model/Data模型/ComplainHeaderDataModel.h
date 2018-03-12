//
//  ComplainHeaderDataModel.h
//  idoubs
//
//  Created by Momo on 16/6/30.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//  报修工单列表获取
//  访问路径
//  /tenement/get_work_order_list.json

#import <Foundation/Foundation.h>
@interface ComplainHeaderDataModel : NSObject

// **************** 判断部分 **********
/**  如果登陆者具备派单权限，为0表示不可以对该工单操作，1为派单，2为转单*/
@property (nonatomic,strong) NSNumber * power_do;
/**  工单状态 1未处理 2待接单 3正在处理 4处理完成（维修人员） 5结束*/
@property (nonatomic,strong) NSString * fstatus;
/**  所有登陆者，包括派单人，0表示不可操作，1表示可接单，2表示可完成（注：派单人可能同时具备转单以及点击完成两个操作）*/
@property (nonatomic,strong) NSNumber * normal_do;
/**  当前处理人员id，如果等于登陆者id，则表示是“我”在处理*/
@property (nonatomic,strong) NSString * deal_worker_id;

// **************** 内容部分 **********
/**  评分*/
@property (nonatomic,strong) NSString * fscore;
/**  回复、评论等记录数*/
@property (nonatomic,strong) NSNumber * record_num;
/**  工单id*/
@property (nonatomic,strong) NSString * repair_id;
/**  地址*/
@property (nonatomic,strong) NSString * faddress;
/**  工单内容*/
@property (nonatomic,strong) NSString * fservicecontent;
/**  业主名字*/
@property (nonatomic,strong) NSString * frealname;
/**  时间*/
@property (nonatomic,strong) NSString * fcreatetime;
/**  工单号*/
@property (nonatomic,strong) NSString * fordernum;
/**  当前处理工单人*/
@property (nonatomic,strong) NSString * fworkername;
/**  业主号码*/
@property (nonatomic,strong) NSString * fusername;
/**  工单图片*/
@property (nonatomic,strong) NSArray * repairs_imag_list;
/**  业主头像*/
@property (nonatomic,strong) NSString * fheadurl;
/**  催单次数*/
@property (nonatomic,strong) NSString * fremindercount;
/**  联系人电话*/
@property (nonatomic,strong) NSString * flinkman_phone;
/**  联系人名字*/
@property (nonatomic,strong) NSString * flinkman;

/**  是否打开详情*/
@property (nonatomic,assign) BOOL isOpenDetail;

@end
