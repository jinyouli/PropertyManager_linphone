//
//  AddressBookViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "AddressBookViewController.h"

#import "A_ZTableViewController.h"
#import "GroupTableViewController.h"
#import "PhoneHistTableViewController.h"

#define kLeft (ScreenWidth/3 - 60)/2
@interface AddressBookViewController ()<UIScrollViewDelegate>

@property (nonatomic,strong) UIView * topView;
@property (nonatomic,strong) UIScrollView * scrollview;
@property (nonatomic,strong) UIButton * topCurrentBtn;



@end

@implementation AddressBookViewController

-(void)dealloc{
    SYLog(@"AddressBookViewController dealloc");
    self.view = nil;
    self.topView = nil;
    self.scrollview = nil;
    self.topCurrentBtn = nil;
}

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

    [self createTopview];
    [self createScrollview];
}

-(void)createTopview{
    
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    self.topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.topView];
    
    NSArray * btnTitleArr = @[@"按A_Z",@"按分组",@"通话记录"];
    for (int i = 0; i < 3; i ++) {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth/3 * i, 0, ScreenWidth/3, 43)];
        [btn setTitle:btnTitleArr[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(topBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = LargeFont;
        [btn setTitleColor:mainTextColor forState:UIControlStateNormal];
        [btn setTitleColor:mainColor forState:UIControlStateSelected];
        btn.tag = 4000 + i;
        [self.topView addSubview:btn];
        
        if (i == 0) {
            [self topBtnClick:btn];
        }
    }
    
    UIImageView * line = [[UIImageView alloc]init];
    line.frame = CGRectMake(kLeft, 41, 60, 3);
    line.tag = 4005;
    line.backgroundColor = mainColor;
    [self.topView addSubview:line];
    
    
}

-(void)topBtnClick:(UIButton *)btn{
    self.topCurrentBtn.selected = NO;
    btn.selected = YES;
    self.topCurrentBtn = btn;
    
    NSInteger tag = btn.tag - 4000;
    UIImageView * line = (UIImageView *)[self.topView viewWithTag:4005];
    CGRect lineRect = line.frame;
    lineRect.origin.x = tag * ScreenWidth/3 + kLeft;
    
    
    CGFloat x = tag == 0? 0:tag == 1 ? (tag * ScreenWidth - 2):(tag * ScreenWidth - 5.5);
    [UIView animateWithDuration:0.5 animations:^{
        line.frame = lineRect;
        self.scrollview.contentOffset = CGPointMake(x, 0);
    } completion:nil];
}


-(void)createScrollview{
    CGFloat scrollY = self.topView.frame.size.height + self.topView.frame.origin.y;
    self.scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(1.5, scrollY, ScreenWidth - 3, ScreenHeight - scrollY - 64 - 44 )];
    UIView * testView = [[UIView alloc]init];
    self.scrollview.showsHorizontalScrollIndicator = NO;
    self.scrollview.showsVerticalScrollIndicator = NO;
    self.scrollview.bounces = NO;
    [self.scrollview addSubview:testView];
    
    
    A_ZTableViewController * newsVC = [[A_ZTableViewController alloc]init];
    GroupTableViewController * proportyVC = [[GroupTableViewController alloc]init];
    PhoneHistTableViewController * addressVC = [[PhoneHistTableViewController alloc]init];
    
    NSArray * tableVCArr = @[newsVC,proportyVC,addressVC];
    // 禁止滑动
    self.scrollview.contentSize = CGSizeMake((ScreenWidth- 3)*3, self.scrollview.frame.size.height);
    self.scrollview.delegate = self;
    self.scrollview.pagingEnabled = YES;
    for (int i = 0 ; i < tableVCArr.count; i ++) {
        BaseContactTableViewController * tableVC = tableVCArr[i];
        tableVC.tableView.frame = CGRectMake((ScreenWidth-3) * i, 0, ScreenWidth - 3, self.scrollview.frame.size.height);
        [self.scrollview addSubview:tableVC.tableView];
        [self addChildViewController:tableVC];
    }
    [self.view addSubview:self.scrollview];
    
}

#pragma mark - scrollview的协议
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    UIImageView * line = (UIImageView *)[self.topView viewWithTag:4005];
    CGRect lineRect = line.frame;
    lineRect.origin.x = scrollView.contentOffset.x/3 + kLeft;
    line.frame = lineRect;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat x = scrollView.contentOffset.x;
    
    if (x >= 0 && x < ScreenWidth * 0.5)
    {
        UIButton *btn1 = (UIButton *)[self.topView viewWithTag:4000 + 0];
        self.topCurrentBtn.selected = NO;
        btn1.selected = YES;
        self.topCurrentBtn = btn1;
    }
    
    if(x >= ScreenWidth * 0.5 && x < ScreenWidth * 1.5)
    {
        UIButton *btn1 = (UIButton *)[self.topView viewWithTag:4000 + 1];
        self.topCurrentBtn.selected = NO;
        btn1.selected = YES;
        self.topCurrentBtn = btn1;
    }
    if (x > ScreenWidth * 1.5 && x<= ScreenWidth * 2.0)
    {
        UIButton *btn1 = (UIButton *)[self.topView viewWithTag:4000+2];
        self.topCurrentBtn.selected = NO;
        btn1.selected = YES;
        self.topCurrentBtn = btn1;
    }
    
}


@end
