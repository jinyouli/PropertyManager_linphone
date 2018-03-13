//
//  HomeViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "HomeViewController.h"
#import "NewsViewController.h"
#import "PropertyManageViewController.h"
#import "AddressBookViewController.h"
//#import "iOSNgnStack.h"

#import "NotificationBtn.h"

@interface HomeViewController ()<UIScrollViewDelegate>

@property (nonatomic,strong) UIView * topView;
@property (nonatomic,strong) UIScrollView * scrollview;
@property (nonatomic,strong) UIButton * topCurrentBtn;

@property (nonatomic,strong) NewsViewController * newsVC;
@property (nonatomic,strong) PropertyManageViewController * proVC;
@property (nonatomic,strong) AddressBookViewController * addVC;

@end

@implementation HomeViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.topView];
    [self.view addSubview:self.scrollview];
    [self.view bringSubviewToFront:self.topView];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoOtherPage:) name:@"gotoOtherPage" object:nil];
}

#pragma mark - Delegate 实现方法
#pragma mark - scrollviewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    UIImageView * line = (UIImageView *)[self.topView viewWithTag:4005];
    CGRect lineRect = line.frame;
    lineRect.origin.x = scrollView.contentOffset.x/3;
    line.frame = lineRect;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    CGFloat scrX = scrollView.contentOffset.x;
    if (scrX >= 0 && scrX < ScreenWidth * 0.5)
    {
        UIButton *btn1 = (UIButton *)[self.topView viewWithTag:4000 + 0];
        self.topCurrentBtn.selected = NO;
        btn1.selected = YES;
        self.topCurrentBtn = btn1;
    }
    
    if(scrX >= ScreenWidth * 0.5 && scrX < ScreenWidth* 1.5)
    {
        UIButton *btn1 = (UIButton *)[self.topView viewWithTag:4000 + 1];
        self.topCurrentBtn.selected = NO;
        btn1.selected = YES;
        self.topCurrentBtn = btn1;
    }
    
    if (scrX >ScreenWidth * 1.5 && scrX <= ScreenWidth * 2.0)
    {
        UIButton *btn1 = (UIButton *)[self.topView viewWithTag:4000+2];
        self.topCurrentBtn.selected = NO;
        btn1.selected = YES;
        self.topCurrentBtn = btn1;
    }
}


#pragma mark - event response
-(void)topBtnClick:(UIButton *)btn{
    self.topCurrentBtn.selected = NO;
    btn.selected = YES;
    self.topCurrentBtn = btn;
    
    NSInteger tag = btn.tag - 4000;
    UIImageView * line = (UIImageView *)[self.topView viewWithTag:4005];
    CGRect lineRect = line.frame;
    lineRect.origin.x = tag * ScreenWidth/3;
    
    [UIView animateWithDuration:0.5 animations:^{
        line.frame = lineRect;
        self.scrollview.contentOffset = CGPointMake(tag * ScreenWidth, 0);
    } completion:nil];
}


#pragma mark - 通知-跳转页面
-(void)gotoOtherPage:(NSNotification *)noti{
    NSNumber * num = [noti object];
    NSInteger row = [num integerValue];
    if (row == 0) {
        // 设置页面
        [[Routable sharedRouter] open:SETTING_VIEWCONTROLLER];
        
    }
    else if (row == 1){
        // 分享应用
        [[Routable sharedRouter] open:SHARE_VIEWCONTROLLER];
    }
    else if (row == 2){
        
        // 关于页面
        [[Routable sharedRouter] open:ABOUT_VIEWCONTROLLER];

    }
}



#pragma mark - getters and setters
- (UIView *) topView{
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
        _topView.backgroundColor = mainColor;
        
        //加阴影
        _topView.layer.shadowColor = [UIColor blackColor].CGColor;
        _topView.layer.shadowOffset = CGSizeMake(-2,3);
        _topView.layer.shadowOpacity = 0.3;
        _topView.layer.shadowRadius = 4;
        
        NSArray * btnTitleArr = @[@"消息",@"物业服务",@"通讯录"];
        
        for (int i = 0; i < 3; i ++) {
            UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth/3 * i, 0, ScreenWidth/3, 43)];
            [btn setTitle:btnTitleArr[i] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(topBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font = LargeFont;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.tag = 4000 + i;
            [_topView addSubview:btn];
            
            if (i == 1) {
                [self topBtnClick:btn];
            }
            
        }
        
        UIImageView * line = [[UIImageView alloc]init];
        line.frame = CGRectMake(ScreenWidth/3, 41, ScreenWidth/3, 3);
        line.tag = 4005;
        line.backgroundColor = lineColor;
        [_topView addSubview:line];
    }
    return _topView;
}

- (UIScrollView *)scrollview{
    if (!_scrollview) {
        CGFloat scrollY = self.topView.frame.size.height + self.topView.frame.origin.y;
        _scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, scrollY, ScreenWidth, ScreenHeight - scrollY - 64)];
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.bounces = NO;
        
        UIView * testView = [[UIView alloc]init];
        [_scrollview addSubview:testView];
        
        NSArray * viewControllerArr = @[self.newsVC,self.proVC,self.addVC];
        _scrollview.contentSize = CGSizeMake(ScreenWidth * 3, _scrollview.frame.size.height);
        _scrollview.delegate = self;
        _scrollview.pagingEnabled = YES;
        for (int i = 0 ; i < viewControllerArr.count; i ++) {
            UIViewController * vc = viewControllerArr[i];
            vc.view.frame = CGRectMake(ScreenWidth * i, 0, ScreenWidth, _scrollview.frame.size.height);
            [_scrollview addSubview:vc.view];
            [self addChildViewController:vc];
        }
        _scrollview.contentOffset = CGPointMake(ScreenWidth, 0);
    }
    
    return _scrollview;
}

- (NewsViewController *)newsVC{
    if (!_newsVC) {
        _newsVC = [[NewsViewController alloc] init];
    }
    return _newsVC;
}

- (PropertyManageViewController *)proVC{
    if (!_proVC) {
        _proVC = [[PropertyManageViewController alloc] init];
    }
    return _proVC;
}

- (AddressBookViewController *)addVC{
    if (!_addVC) {
        _addVC = [[AddressBookViewController alloc] init];
    }
    return _addVC;
}
@end
