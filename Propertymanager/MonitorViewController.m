//
//  MonitorViewController.m
//  Propertymanager
//
//  Created by Li JinYou on 2018/3/9.
//  Copyright © 2018年 Li JinYou. All rights reserved.
//

#import "MonitorViewController.h"

@interface MonitorViewController ()
@property (nonatomic,retain) UIView *monitorView;
@end

@implementation MonitorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, 300, 200)];
    myView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:myView];
    
    [[SYLinphoneManager instance] call:self.model.sip_number displayName:@"13632550150" transfer:NO Video:myView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[SYLinphoneManager instance] hangUpCall];
}

- (instancetype)initWithCall:(SYLinphoneCall *)call GuardInfo:(SYLockListModel *)model InComingCall:(BOOL)isInComingCall{
    
    if (self == [super init]) {
        self.call = call;
        self.model = model;
        self.isInComingCall = isInComingCall;
    }
    NSLog(@"2");
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
