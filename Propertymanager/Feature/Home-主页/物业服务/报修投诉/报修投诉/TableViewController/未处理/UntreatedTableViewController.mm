//
//  UntreatedTableViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/16.
//  Copyright © 2016年 Momo. All rights reserved.
//  orderType  1 : 未处理  2：我的正在处理 3：其他正在处理 4：我的已完成 5：其他已完成

#import "UntreatedTableViewController.h"


@interface UntreatedTableViewController ()




@end

@implementation UntreatedTableViewController

-(void)dealloc{
    SYLog(@"UntreatedTableViewController dealloc");
    self.view = nil;
    self.tableView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"untreatedDate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteOneDataFromUnStar" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RepairUpdateUnDoing" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataByDate) name:@"untreatedDate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteOneData:) name:@"deleteOneDataFromUnStar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDataFromNetWork) name:@"RepairUpdateUnDoing" object:nil];
}

-(void)deleteOneData:(NSNotification *)noti{
    NSNumber * num = [noti object];
    NSInteger section = [num integerValue];
    if (self.framesArr.count == 0) {
        [self.tableView reloadData];
        return;
    }
    if (section > self.framesArr.count) {
        [self.tableView reloadData];
        return;
    }
    NSString * repair_id = ((ComplainHeaderFrame *)self.framesArr[section]).headerDataModel.repair_id;
    [self.framesArr removeObjectAtIndex:section];
    [self.detailDic removeObjectForKey:repair_id];
    [self.tableView reloadData];
}

@end
