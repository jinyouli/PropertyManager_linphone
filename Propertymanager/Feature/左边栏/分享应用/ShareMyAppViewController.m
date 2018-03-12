//
//  ShareMyAppViewController.m
//  PropertyManager
//
//  Created by Momo on 16/12/23.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "ShareMyAppViewController.h"

@interface ShareMyAppViewController ()

@end

@implementation ShareMyAppViewController

#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
    }
    return self;
}


-(void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ClickLeftBarButtonAction" object:nil];
    
    self.view.backgroundColor = BGColor;
    [self createLeftBarButtonItemWithImage:@"backArrow" WithTitle:@"分享应用" withMethod:@selector(returnBtnClick)];
    
    
    [self createSubviews];
 
}

-(void)createSubviews{
    
    UILabel * lab_version = [[UILabel alloc]init];
    lab_version.text = [NSString stringWithFormat:@"版本号 v%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    lab_version.textColor = mainTextColor;
    [self.view addSubview:lab_version];
    
    
    UIImageView * img_QR = [[UIImageView alloc]init];
    img_QR.image = [UIImage imageNamed:@"shareQRCode"];
    [self.view addSubview:img_QR];
    
    UILabel * lab_invite = [[UILabel alloc]init];
    lab_invite.text = @"邀请好友扫一扫下载赛翼物业宝~";
    lab_invite.textColor = mainTextColor;
    [self.view addSubview:lab_invite];
    
    
    [img_QR mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(@250);
        make.height.equalTo(@250);
    }];
    
    
    [lab_version mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(img_QR.mas_top).with.offset(-10);
        make.height.equalTo(@30);
    }];
    
    
    
    [lab_invite mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(img_QR.mas_bottom).with.offset(10);
        make.height.equalTo(@30);
    }];
}

-(void)returnBtnClick{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ClickLeftBarButtonAction" object:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

@end
