//
//  MonitorViewController.m
//  Propertymanager
//
//  Created by Li JinYou on 2018/3/9.
//  Copyright © 2018年 Li JinYou. All rights reserved.
//

#import "MonitorViewController.h"

@interface MonitorViewController ()
@property (nonatomic,strong) UIView *monitorView;
@end

@implementation MonitorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.monitorView = [[UIView alloc] initWithFrame:CGRectMake(10, 50, 200, 200)];
    self.monitorView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.monitorView];
    
    [[SYLinphoneManager instance] call:self.model.sip_number displayName:@"测试" transfer:NO Video:self.monitorView];
}

- (instancetype)initWithCall:(SYLinphoneCall *)call GuardInfo:(SYLockListModel *)model InComingCall:(BOOL)isInComingCall{
    
    if (self == [super init]) {
        self.call = call;
        self.model = model;
        self.isInComingCall = isInComingCall;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
