//
//  ViewController.m
//  Propertymanager
//
//  Created by Li JinYou on 2018/3/9.
//  Copyright © 2018年 Li JinYou. All rights reserved.
//

#import "ViewController.h"
#import "MonitorViewController.h"
#import "SYLinphoneManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configLinphone];
    [[SYLinphoneManager instance] addProxyConfig:@"2000011787" password:@"aaeb54e1a18b456d9a94dae8bce4b87d" displayName:@"13632550150" domain:@"192.168.1.79" port:@"35162" withTransport:nil];
}

- (void)configLinphone{
    
    [[SYLinphoneManager instance] startSYLinphonephone];
    [SYLinphoneManager instance].nExpires = 120;
    [SYLinphoneManager instance].ipv6Enabled = NO;
    [SYLinphoneManager instance].videoEnable = YES;
   // [[SYLinphoneManager instance] setDelegate:self];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    SYLockListModel *model = [[SYLockListModel alloc] init];
    model.domain_sn = @"10000313";
    model.sip_number = @"1000150246";
    
    MonitorViewController *viewController = [[MonitorViewController alloc] initWithCall:nil GuardInfo:model InComingCall:NO];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
