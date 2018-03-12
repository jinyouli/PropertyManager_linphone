//
//  SendOrderCauseViewController.h
//  idoubs
//
//  Created by Momo on 16/7/2.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "BaseViewController.h"

@interface SendOrderCauseViewController : BaseViewController

/** 工单id*/
@property (nonatomic,strong) NSString * repairs_id;
/** 转派则传入之前一个工人的id*/
@property (nonatomic,strong) NSString * deal_worker_id;
/** 转单人id*/
@property (nonatomic,strong) NSString * worker_id;

@end
