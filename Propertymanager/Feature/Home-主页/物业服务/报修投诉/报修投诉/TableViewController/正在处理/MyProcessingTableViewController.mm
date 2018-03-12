//
//  MyProcessingTableViewController.m
//  idoubs
//
//  Created by Momo on 16/6/29.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "MyProcessingTableViewController.h"


@interface MyProcessingTableViewController ()
@end

@implementation MyProcessingTableViewController

-(void)dealloc{
    SYLog(@"MyProcessingTableViewController dealloc");
    self.view = nil;
    self.tableView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"processingDate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getDataFromMyDoing" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteOneDataFromMyDoing" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataByDate) name:@"processingDate" object:nil];
    
    //刷新数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDataFromNetWork) name:@"getDataFromMyDoing" object:nil];
    //移除数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteOneData:) name:@"deleteOneDataFromMyDoing" object:nil];

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
//    [self.tableView reloadData];
    
    [self reloadView];
}

@end
