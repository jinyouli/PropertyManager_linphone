//
//  NewsViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "NewsViewController.h"
#import "ProportyTableViewController.h"
#import "MyNewsTableViewController.h"
#import "PlotTableViewController.h"
#import "SystemNewsTableViewController.h"
#import "AppDelegate.h"

#define kLeft (ScreenWidth * 0.25 - 50) * 0.5

@interface NewsViewController ()<UIScrollViewDelegate>

@property (nonatomic,strong) UIView * topView;
@property (nonatomic,strong) UIScrollView * scrollview;
@property (nonatomic,strong) UIButton * topCurrentBtn;


@property (nonatomic,strong) ProportyTableViewController * proTlVC;
@property (nonatomic,strong) MyNewsTableViewController * nesTVC;
@property (nonatomic,strong) PlotTableViewController * ploTVC;
@property (nonatomic,strong) SystemNewsTableViewController * sysTVC;
@end

@implementation NewsViewController

#pragma mark - life cycle
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //定位
    NSInteger tag = self.topCurrentBtn.tag - 4000;
    UIImageView * line = (UIImageView *)[self.topView viewWithTag:4010];
    CGRect lineRect = line.frame;
    lineRect.origin.x = tag * ScreenWidth/4 + kLeft;
    line.frame = lineRect;
    self.scrollview.contentOffset = CGPointMake(tag * ScreenWidth, 0);
 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.topView];
    [self.view addSubview:self.scrollview];
}

#pragma mark - Delegate 实现方法
#pragma mark - scrollview的协议
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    UIImageView * line = (UIImageView *)[self.topView viewWithTag:4010];
    CGRect lineRect = line.frame;
    lineRect.origin.x = scrollView.contentOffset.x/4 + kLeft;
    line.frame = lineRect;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat contentX = scrollView.contentOffset.x + 1.5;
    CGFloat sX = ScreenWidth;
    
    if(contentX >= 0 && contentX < sX * 0.5)
    {
        UIButton *btn1 = (UIButton *)[self.topView viewWithTag:4000 + 0];
        self.topCurrentBtn.selected = NO;
        btn1.selected = YES;
        self.topCurrentBtn = btn1;
    }
    if (contentX >= sX * 0.5 && contentX < sX * 1.5)
    {
        UIButton *btn1 = (UIButton *)[self.topView viewWithTag:4000 + 1];
        self.topCurrentBtn.selected = NO;
        btn1.selected = YES;
        self.topCurrentBtn = btn1;
    }
    if (contentX >= sX * 1.5 && contentX < sX * 2.5)
    {
        UIButton *btn1 = (UIButton *)[self.topView viewWithTag:4000+2];
        self.topCurrentBtn.selected = NO;
        btn1.selected = YES;
        self.topCurrentBtn = btn1;
    }
    if (contentX >= sX * 2.5 && contentX < sX * 3.0)
    {
        UIButton *btn1 = (UIButton *)[self.topView viewWithTag:4000+3];
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
    
    UIImageView * line = (UIImageView *)[self.topView viewWithTag:4010];
    CGRect lineRect = line.frame;
    lineRect.origin.x = tag * (ScreenWidth * 0.25) + kLeft;
    
    switch (tag) {
        case 0:
            tag = 0;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"requestData1" object:nil];
            break;
        case 1:
            tag = tag * ScreenWidth - 2;
            break;
        case 2:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"requestData3" object:nil];
            tag = tag * ScreenWidth - 5;
            break;
        case 3:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"requestData4" object:nil];
            tag = tag * ScreenWidth - 8;
            break;
            
        default:
            break;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        line.frame = lineRect;
        self.scrollview.contentOffset = CGPointMake(tag, 0);
    } completion:nil];
    
    
    
}


#pragma mark - getters and setters
- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
        _topView.backgroundColor = [UIColor whiteColor];
        
        NSArray * btnTitleArr = @[@"工单动态",@"个人消息",@"小区公告",@"系统消息"];
        for (int i = 0; i < 4; i ++) {
            UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth/4 * i, 0, ScreenWidth/4, 43)];
            [btn setTitle:btnTitleArr[i] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(topBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font = MiddleFont;
            [btn setTitleColor:mainTextColor forState:UIControlStateNormal];
            [btn setTitleColor:mainColor forState:UIControlStateSelected];
            btn.tag = 4000 + i;
            [_topView addSubview:btn];
            
            if (i == 0) {
                [self topBtnClick:btn];
            }
        }
        
        UIImageView * line = [[UIImageView alloc]init];
        line.frame = CGRectMake(kLeft, 41, 50, 3);
        line.tag = 4010;
        line.backgroundColor = mainColor;
        [_topView addSubview:line];
    }
    return _topView;
}

- (UIScrollView *)scrollview{
    if (!_scrollview) {
        CGFloat scrollY = self.topView.frame.size.height + self.topView.frame.origin.y;
        _scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(1.5, scrollY, ScreenWidth-3, ScreenHeight - scrollY - 64 - 45)];
        _scrollview.userInteractionEnabled = YES;
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.bounces = NO;
        UIView * testView = [[UIView alloc]init];
        [_scrollview addSubview:testView];
        
        self.proTlVC = [[ProportyTableViewController alloc]init];
        self.nesTVC = [[MyNewsTableViewController alloc]init];
        self.ploTVC = [[PlotTableViewController alloc]init];
        self.sysTVC = [[SystemNewsTableViewController alloc]init];
        
        NSArray * tableVCArr = @[self.proTlVC,self.nesTVC,self.ploTVC,self.sysTVC];
        _scrollview.contentSize = CGSizeMake((ScreenWidth-3) * 4, _scrollview.frame.size.height);
        _scrollview.delegate = self;
        _scrollview.pagingEnabled = YES;
        for (int i = 0 ; i < tableVCArr.count; i ++) {
            
            BaseNewsTableViewController * tableVC = tableVCArr[i];
            tableVC.tableView.frame = CGRectMake((ScreenWidth-3) * i, 0, _scrollview.frame.size.width, _scrollview.frame.size.height);
            [_scrollview addSubview:tableVC.tableView];
            [self addChildViewController:tableVC];
            
            
        }
        
    }
    
    return _scrollview;
}



@end
