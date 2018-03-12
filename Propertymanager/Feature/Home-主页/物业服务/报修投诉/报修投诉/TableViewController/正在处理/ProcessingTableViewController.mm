//
//  ProcessingTableViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/16.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "ProcessingTableViewController.h"
@interface ProcessingTableViewController ()
@end

@implementation ProcessingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataByDate) name:@"processingDate" object:nil];
}
-(void)dealloc{
    SYLog(@"ProcessingTableViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"processingDate" object:nil];
}
@end
