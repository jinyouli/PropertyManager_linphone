//
//  BaseContactTableViewController.h
//  idoubs
//
//  Created by Momo on 16/7/6.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"
@interface BaseContactTableViewController : UITableViewController

@property (nonatomic,strong) NSMutableArray * dataModel;
@property (nonatomic,strong) MJRefreshHeader * header;
@property (nonatomic,strong) NoDataCountView * noDataCountView;

- (BOOL)checkNetWork;
-(void)getDataFromNetWork;
-(void)reloadView;
-(void)endRefresh;
-(void)createAlertWithMessage:(NSString *)message;
-(void)cheakDataCount:(NSArray *)arr;
@end
