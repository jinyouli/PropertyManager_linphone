//
//  BaseRepairsTableViewController.h
//  PropertyManage
//
//  Created by Momo on 16/6/16.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComplainOrderTableViewCell.h"
#import "ComplainHeaderView.h"
#import "ComplainHeaderDataModel.h"

#import "ComplainReplyFrame.h"
#import "ComplainReplyDataModel.h"

//#import "MJRefresh.h"

#import "OwnerViewController.h" //业主
#import "FGalleryViewController.h" //图片展示
#import "SendOrderViewController.h" //派单界面
#import "OrderCommandViewController.h" //订单评论页面
#import "AcceptOrderViewController.h"  //接受订单页面
#import "CompleteOrderViewController.h" //完成订单页面

@interface BaseRepairsTableViewController : UITableViewController<FGalleryViewControllerDelegate>

/** 当前页数 */
@property (nonatomic,assign) NSInteger page;
/** data模型数组 装Header数据模型*/
@property (nonatomic,strong) NSArray * ordelsArr;
/** Frame模型数组*/
@property (nonatomic,strong) NSMutableArray * framesArr;
/** detailDic[@"repairs_id"] -- >  arr : ComplainReplyFrame模型*/
@property (nonatomic,strong) NSMutableDictionary * detailDic;

//@property (nonatomic,strong) MJRefreshHeader * header;
@property (nonatomic,strong) NSArray * lookImageList;

-(void)updateDataByDate;
-(void)myBlock:(NSInteger)section withFlag:(NSInteger)flag withImageIndex:(NSInteger)imageIndex;
-(void)getDataFromDB;
-(void)getDataFromNetWork;
-(void)getDataWithURl:(NSString *)url withHeader:(NSDictionary *)headDic withParaDic:(NSDictionary *)paraDic withType:(NSString *)type;
- (BOOL)checkNetWork;
-(void)getOrder_details:(NSString *)repairs_id withSecion:(NSInteger)secion;

-(instancetype)initWithIsRepairType:(BOOL)isRepairType status:(NSString *)status is_get_my:(NSString *)is_get_my dBType:(NSString *)dBType;
-(void)reloadView;
//参数部分
@property (nonatomic,assign) BOOL isRepairType;
@property (nonatomic,strong) NSString * status;
@property (nonatomic,strong) NSString * is_get_my;
@property (nonatomic,strong) NSString * dBType;

// 没有数据部分
@property (nonatomic,strong) NoDataCountView * noDataCountView;

@end
