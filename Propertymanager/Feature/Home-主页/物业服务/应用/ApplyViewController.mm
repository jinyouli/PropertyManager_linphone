//
//  ApplyViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/16.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "ApplyViewController.h"

@interface ApplyViewController ()

@end

@implementation ApplyViewController

#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        
        if (![PMTools isNullOrEmpty:params[@"myTitle"]]) {
            self.myTitle = params[@"myTitle"];
        }
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([PMTools isNullOrEmpty:self.myTitle]) {
        [self createLeftBarButtonItemWithTitle:@"应用"];
    }
    else{
        [self createLeftBarButtonItemWithTitle:self.myTitle];
    }
    

    ZYLabel * tLabel = [[ZYLabel alloc]initWithText:@"开发中，敬请期待" font:MiddleFont color:mainTextColor];
    tLabel.frame = CGRectMake(10, 200, ScreenWidth - 20, 20);
    [self.view addSubview:tLabel];
}


@end
