//
//  ViewController.m
//  Propertymanager
//
//  Created by Li JinYou on 2018/3/9.
//  Copyright © 2018年 Li JinYou. All rights reserved.
//

#import "ViewController.h"
#import "MonitorViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    SYLockListModel *model = [[SYLockListModel alloc] init];
    model.domain_sn = @"10000297";
    model.sip_number = @"1000149723";
    
    MonitorViewController *viewController = [[MonitorViewController alloc] initWithCall:nil GuardInfo:model InComingCall:NO];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
