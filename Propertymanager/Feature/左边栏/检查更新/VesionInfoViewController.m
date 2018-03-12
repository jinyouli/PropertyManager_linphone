//
//  VesionInfoViewController.m
//  idoubs
//
//  Created by Momo on 16/7/18.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "VesionInfoViewController.h"

@interface VesionInfoViewController ()

@property (nonatomic,strong) NSString * content;

@end

@implementation VesionInfoViewController

#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        
        self.content = params[@"content"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createLeftBarButtonItemWithTitle:@"版本信息"];
}

@end
