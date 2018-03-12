//
//  ComplainReplyDataModel.h
//  idoubs
//
//  Created by Momo on 16/6/30.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
// 获取工单详情
//  访问路径
//  /tenement/get_work_order_details.json

#import <Foundation/Foundation.h>

@interface ComplainReplyDataModel : NSObject
{
    NSString * _id;
    NSString * _new_name;
}

//工单ID
@property (nonatomic,strong) NSString * ID;
//工单回复ID
@property (nonatomic,strong) NSString * reply_id;
//类型 1表示工单回复，2表示工单评论，3表示转单记录，4表示完成订单信息记录
@property (nonatomic,strong) NSString * ftype;
//时间
@property (nonatomic,strong) NSString * fcreatetime;
//昵称
@property (nonatomic,strong) NSString * name;
//上一个人
@property (nonatomic,strong) NSString * old_name;
//下一个人
@property (nonatomic,strong) NSString * nMyName1; 
//内容
@property (nonatomic,strong) NSString * fcontent;
//图片列表
@property (nonatomic,strong) NSArray * reply_imag_list;

@end
