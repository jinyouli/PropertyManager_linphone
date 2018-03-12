//
//  PlotCellDetailViewController.h
//  idoubs
//
//  Created by Momo on 16/6/22.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "BaseViewController.h"

@interface PlotCellDetailViewController : BaseViewController

/** YES: 小区公告 NO：系统公告*/
@property (nonatomic,assign) BOOL isPloy;

/** 导航栏标题*/
@property (nonatomic,strong) NSString *myTitle;

/** 时间*/
@property (nonatomic,strong) NSString *myTime;

/** 内容*/
@property (nonatomic,strong) NSString *myContent;

@end
