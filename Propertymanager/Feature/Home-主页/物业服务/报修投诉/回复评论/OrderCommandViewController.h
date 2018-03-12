//
//  OrderCommandViewController.h
//  idoubs
//
//  Created by Momo on 16/6/22.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "BaseViewController.h"

@interface OrderCommandViewController : BaseViewController

/** type 1:报修   2:投诉*/
@property (nonatomic,assign) NSInteger type;

/** 由哪个IndexPath传入 为了回复成功后刷新这一行*/
@property (nonatomic,assign) NSInteger section;

/** 工单id*/
@property (nonatomic,strong) NSString * repairs_id;

/** 业主名*/
@property (nonatomic,strong) NSString * fname;

@end
