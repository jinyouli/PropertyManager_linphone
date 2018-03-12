//
//  MyCompletedTableViewController.m
//  idoubs
//
//  Created by Momo on 16/6/29.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "MyCompletedTableViewController.h"
@interface MyCompletedTableViewController ()
@end

@implementation MyCompletedTableViewController

-(void)dealloc{
    SYLog(@"MyCompletedTableViewController dealloc");
    self.view = nil;
    self.tableView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getDataFromMyFinish" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"completedDate" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMyDataFromNetWork) name:@"getDataFromMyFinish" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataByDate) name:@"completedDate" object:nil];
    
}

-(void)getMyDataFromNetWork{
    [self getDataFromNetWork];

    //打开详情
    if (self.framesArr.count != 0) {
        SYLog(@"打开第一行");
        ComplainHeaderFrame * frameModel = self.framesArr[0];
        ComplainHeaderDataModel * dataModel = frameModel.headerDataModel;
        [self getOrder_details:dataModel.repair_id withSecion:0];
    }
}

@end
