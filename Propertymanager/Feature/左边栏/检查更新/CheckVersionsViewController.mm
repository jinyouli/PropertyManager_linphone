//
//  CheckVersionsViewController.m
//  idoubs
//
//  Created by Momo on 16/7/4.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "CheckVersionsViewController.h"

@interface CheckVersionsViewController ()

@property (nonatomic,strong) NSDictionary * VersionInfo;

@property (nonatomic,strong) UILabel * cheateVesionLabel;

@property (nonatomic,strong) NSString * desc;
@end

@implementation CheckVersionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ClickLeftBarButtonAction" object:nil];
    
    NSThread * thread = [[NSThread alloc]initWithTarget:self selector:@selector(getDataFromNetWork) object:nil];
    [thread start];
    [self createLeftBarButtonItemWithImage:@"backArrow" WithTitle:@"检查更新" withMethod:@selector(returnBtnClick)];
    
    [self createSubviews];
    
    
}

-(void)getDataFromNetWork{
    if (![self checkNetWork]) {
        return;
    }
    
    [DetailRequest SYGet_app_versionSuccessBlock:^(NSDictionary *VersionInfo) {
        self.VersionInfo = VersionInfo;
        [self updataSubviews];
    }];
  
}

-(void)updataSubviews{
    NSString * vesionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if ([vesionStr integerValue] < [self.VersionInfo[@"version_code"] integerValue]) {
        //去升级
        self.cheateVesionLabel.text = @"系统版本已更新,请及时升级";
    }
    
    if (![PMTools isNullOrEmpty:self.VersionInfo[@"desc"]]) {
        self.desc = self.VersionInfo[@"desc"];
    }
    
}

-(void)createSubviews{
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth/2 - 50, 30, 100, 100)];
    imageView.layer.cornerRadius = 8;
    imageView.clipsToBounds = YES;
//    imageView.backgroundColor = mainColor;
    imageView.image = [UIImage imageNamed:@"logo80"];
    [self.view addSubview:imageView];
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 10, ScreenWidth, 20)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = LargeFont;
    titleLabel.text = @"物业管理";
    titleLabel.textColor = mainTextColor;
    [self.view addSubview:titleLabel];
    
    UILabel * vesionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame) + 5, ScreenWidth, 20)];
    vesionLabel.textAlignment = NSTextAlignmentCenter;
    vesionLabel.font = MiddleFont;
    vesionLabel.text = [NSString stringWithFormat:@"版本号 v%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    vesionLabel.textColor = mainTextColor;
    [self.view addSubview:vesionLabel];
    
    self.cheateVesionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(vesionLabel.frame) + 25, ScreenWidth, 20)];
    self.cheateVesionLabel.textAlignment = NSTextAlignmentCenter;
    self.cheateVesionLabel.font = SmallFont;
    self.cheateVesionLabel.textColor = mainColor;
    self.cheateVesionLabel.text = @"当前已是最新版本";
    [self.view addSubview:self.cheateVesionLabel];
    
    UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(self.cheateVesionLabel.frame) + 5, ScreenWidth - 40, 1)];
    line.backgroundColor = lineColor;
    [self.view addSubview:line];
    
    UIButton * lookVesionBtn = [[UIButton alloc]init];
    lookVesionBtn.titleLabel.font = SmallFont;
    [lookVesionBtn setTitleColor:mainColor forState:UIControlStateNormal];
    [lookVesionBtn setTitle:@"查看版本信息" forState:UIControlStateNormal];
    [lookVesionBtn sizeToFit];
    lookVesionBtn.center = CGPointMake(ScreenWidth/2, ScreenHeight - 110 - 64);
    [lookVesionBtn addTarget:self action:@selector(lookVesionBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lookVesionBtn];
    
    UIButton * updateVesionBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, ScreenHeight - 64 - 80, ScreenWidth - 40, 30)];
    updateVesionBtn.titleLabel.font = LargeFont;
    [updateVesionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [updateVesionBtn setBackgroundColor:mainColor];
    [updateVesionBtn setTitle:@"版本升级" forState:UIControlStateNormal];
    [updateVesionBtn addTarget:self action:@selector(updateVesionBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:updateVesionBtn];
}

-(void)lookVesionBtnClick{
    SYLog(@"查看版本信息");
    if ([PMTools isNullOrEmpty:self.desc]) {
        [self createAlertWithMessage:@"无法查看当前版本信息，请稍后尝试"];
        return;
    }    
    [[Routable sharedRouter] open:VESIONINFO_VIEWCONTROLLER animated:YES extraParams:@{@"content":self.desc}];
}

-(void)updateVesionBtnClick{
    
    SYLog(@"版本升级");
    if ([PMTools isNullOrEmpty:self.VersionInfo[@"url"]]) {
        [self createAlertWithMessage:@"无法查看当前版本信息，请稍后尝试"];
        return;
    }
    [[UIApplication sharedApplication] openURL: [ NSURL URLWithString:self.VersionInfo[@"url"]]];
}

-(void)returnBtnClick{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ClickLeftBarButtonAction" object:nil];
    [self.navigationController popViewControllerAnimated:NO];
}
@end
