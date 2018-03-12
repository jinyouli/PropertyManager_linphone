//
//  CompletedTableViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/16.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "CompletedTableViewController.h"
@interface CompletedTableViewController ()
@end

@implementation CompletedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataByDate) name:@"completedDate" object:nil];
}

-(void)dealloc{
    SYLog(@"CompletedTableViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"completedDate" object:nil];
}

@end
