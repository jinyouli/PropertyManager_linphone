//
//  AboutMyAppViewController.m
//  idoubs
//
//  Created by Momo on 16/7/4.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "AboutMyAppViewController.h"

@interface AboutMyAppViewController ()

@end

@implementation AboutMyAppViewController

#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ClickLeftBarButtonAction" object:nil];
    
    self.view.backgroundColor = BGColor;
    [self createLeftBarButtonItemWithImage:@"backArrow" WithTitle:@"关于" withMethod:@selector(returnBtnClick)];
    
    [self createSubviews];
}

-(void)createSubviews{
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth/2 - 30, 30, 60, 60)];
    imageView.layer.cornerRadius = 8;
    imageView.clipsToBounds = YES;
//    imageView.backgroundColor = mainColor;
    imageView.image = [UIImage imageNamed:@"logo80"];
    [self.view addSubview:imageView];

    UILabel * vesionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 5, ScreenWidth, 20)];
    vesionLabel.textAlignment = NSTextAlignmentCenter;
    vesionLabel.font = MiddleFont;
    vesionLabel.text = [NSString stringWithFormat:@"版本号 v%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    vesionLabel.textColor = mainTextColor;
    [self.view addSubview:vesionLabel];

    UIImageView * line1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(vesionLabel.frame) + 25, ScreenWidth, 1)];
    line1.backgroundColor = BGColor;
    [self.view addSubview:line1];
    
    UIButton * commantBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line1.frame) + 1, ScreenWidth, 44)];
    [commantBtn addTarget:self action:@selector(commantBtnClick) forControlEvents:UIControlEventTouchUpInside];
    commantBtn.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:commantBtn];
    
    UILabel * commantLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 7.5, 100, 30)];
    commantLabel.text = @"去评分";
    commantLabel.font = LargeFont;
    commantLabel.textColor = mainTextColor;
    [commantBtn addSubview:commantLabel];
    
    UIImageView * line2 = [[UIImageView alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(commantBtn.frame), ScreenWidth - 40, 1)];
    line2.backgroundColor = BGColor;
    [self.view addSubview:line2];
    
    UIButton * funBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line2.frame) + 1, ScreenWidth, 44)];
    [funBtn addTarget:self action:@selector(funBtnClick) forControlEvents:UIControlEventTouchUpInside];
    funBtn.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:funBtn];
    
    UILabel * funLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 7.5, 100, 30)];
    funLabel.text = @"功能介绍";
    funLabel.font = LargeFont;
    funLabel.textColor = mainTextColor;
    [funBtn addSubview:funLabel];
    
    UIImageView * line3 = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(funBtn.frame) + 1, ScreenWidth, 1)];
    line3.backgroundColor = BGColor;
    [self.view addSubview:line3];
    
    
    UIButton * lookVesionBtn = [[UIButton alloc]init];
    lookVesionBtn.titleLabel.font = MiddleFont;
    [lookVesionBtn setTitleColor:mainColor forState:UIControlStateNormal];
    [lookVesionBtn setTitle:@"用户服务协议" forState:UIControlStateNormal];
    [lookVesionBtn sizeToFit];
    lookVesionBtn.center = CGPointMake(ScreenWidth/2, ScreenHeight - 110 - 64);
    [lookVesionBtn addTarget:self action:@selector(lookVesionBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lookVesionBtn];
    
    NSArray * titleArr = @[@"All Rights Reserved",@"Copyright © 2018 Sayee, Co.,Ltd.",@"赛翼智能 版权所有"];
    for (int i = 0; i < titleArr.count; i ++) {
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, ScreenHeight - 64 - 40 - i * 15, ScreenWidth, 15)];
        label.font = MiddleFont;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = titleArr[i];
        label.textColor = [UIColor lightGrayColor];
        [self.view addSubview:label];
    }
}

-(void)commantBtnClick{
    SYLog(@"去评分");
    
    NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1138808109" ];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
        str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id1138808109"];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];

}

-(void)funBtnClick{
    SYLog(@"功能介绍");
    [[Routable sharedRouter] open:CLAUSE_VIEWCONTROLLER animated:YES extraParams:@{@"myTitle":@"功能介绍"}];
    
}

-(void)lookVesionBtnClick{
    SYLog(@"查看条款和隐私政策");
    [[Routable sharedRouter] open:CLAUSE_VIEWCONTROLLER animated:YES extraParams:@{@"myTitle":@"用户服务协议"}];
}

-(void)returnBtnClick{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ClickLeftBarButtonAction" object:nil];
    [self.navigationController popViewControllerAnimated:NO];
}
@end
