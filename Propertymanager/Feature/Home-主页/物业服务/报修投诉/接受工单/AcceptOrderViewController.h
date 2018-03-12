//
//  AcceptOrderViewController.h
//  idoubs
//
//  Created by Momo on 16/6/29.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "BaseViewController.h"
@class ComplainHeaderDataModel;
@class ComplainHeaderFrame;

@interface AcceptOrderViewController : BaseViewController

/** 数据模型*/
@property (nonatomic,strong) ComplainHeaderDataModel * dataModel;
/** Frame模型*/
@property (nonatomic,strong) ComplainHeaderFrame * frameModel;
/** 组*/
@property (nonatomic,assign) NSInteger section;
/**是否由工单动态点入 YES:跳回根目录 再进入正在处理我的页面*/
@property (nonatomic,assign) BOOL isOrderDetail;
/** YES:报修 NO：投诉*/
@property (nonatomic,assign) BOOL isRepair;

@end
