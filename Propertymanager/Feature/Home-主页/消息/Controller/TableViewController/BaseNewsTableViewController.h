//
//  BaseNewsTableViewController.h
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"
@interface BaseNewsTableViewController : UITableViewController

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray * models;
@property (nonatomic,strong) MJRefreshHeader * header;

@property (nonatomic,strong) NoDataCountView * noDataCountView;

-(void)cheakDataCount:(NSArray *)arr;
- (BOOL)checkNetWork;
-(void)getDataFromNetWork;
-(void)reloadView;
-(void)endRefresh;

@end
