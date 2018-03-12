//
//  SendOrderViewController.h
//  idoubs
//
//  Created by Momo on 16/6/28.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "BaseViewController.h"

@interface SendOrderViewController : BaseViewController

/** 1:派单/已派  2.转派*/
@property (nonatomic,strong) NSString * do_type;

/** 工单id*/
@property (nonatomic,strong) NSString * repairs_id;

/** 转派则传入之前一个工人id*/
@property (nonatomic,strong) NSString * deal_worker_id;

@end
