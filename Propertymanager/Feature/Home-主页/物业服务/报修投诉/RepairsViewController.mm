//
//  RepairsViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/16.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "RepairsViewController.h"

#import "UntreatedTableViewController.h"
#import "MyProcessingTableViewController.h"
#import "ProcessingTableViewController.h"
#import "MyCompletedTableViewController.h"
#import "CompletedTableViewController.h"

#define kLeft (ScreenWidth/3 - 60)/2

NSString * const untreatedDate = @"untreatedDate";
NSString * const processingDate = @"processingDate";
NSString * const completedDate = @"completedDate";

@interface RepairsViewController ()<UIScrollViewDelegate>

@property (nonatomic,strong) UIView * topView;
@property (nonatomic,strong) UIScrollView * scrollview;
@property (nonatomic,strong) UIButton * topCurrentBtn;
@property (nonatomic,strong) UIView * selectDateView;

//处理过程的scrollview 包含我的/其他
@property (nonatomic,strong) UIScrollView * processingScrollview;
//已完成的scrollview 包含我的/其他
@property (nonatomic,strong) UIScrollView * completeScrollview;

@property (nonatomic,strong) UISegmentedControl * processingSegment;
@property (nonatomic,strong) UISegmentedControl * completeSegment;
@property (nonatomic,strong) UIView *coverView;
/** 当前页面
    0 : 未处理
    1 : 正在处理
    2 : 已完成
 */
@property (nonatomic,assign) NSInteger currentIndex;
@end

@implementation RepairsViewController


#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        self.isRepair = [params[@"isRepair"] boolValue];
    }
    return self;
}



-(void)dealloc{
    SYLog(@"RepairsViewController dealloc");
}


BOOL isAnimation = NO;
-(void)pullDownView{
    SYLog(@"下拉列表");
    //下拉列表/上拉列表
    [self isPullDownView:!isAnimation];
}

-(void)isPullDownView:(BOOL)isPullDown{
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    self.rightbtnImageView.transform = CGAffineTransformMakeRotation(isAnimation?0:M_PI);
    [UIView commitAnimations];
    isAnimation = !isAnimation;
    
    CGRect frame = self.selectDateView.frame;
    frame.size.height = isPullDown ? 160 : 0;
    [UIView animateWithDuration:0.5 animations:^{
        self.selectDateView.frame = frame;
    }];
    
    if (isPullDown) {
        self.coverView.hidden = NO;
    }else{
        self.coverView.hidden = YES;
    }
}


#pragma mark - 正在处理的segment
-(void)didProcessingSegmentAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    
    //正在处理
    CGRect newF = self.processingScrollview.frame;
    newF.origin.x = Index == 0? 0 : - ScreenWidth;
    [UIView animateWithDuration:0.5 animations:^{
        self.processingScrollview.frame = newF;
    } completion:nil];
    
}

-(void)didCompleteSegmentAction:(UISegmentedControl *)Seg{

    NSInteger Index = Seg.selectedSegmentIndex;
    //已完成
    CGRect newF = self.completeScrollview.frame;
    newF.origin.x = Index == 0? 0 : - ScreenWidth;
    [UIView animateWithDuration:0.5 animations:^{
        self.completeScrollview.frame = newF;
    } completion:nil];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeScrollerViewX:) name:@"changeScrollerViewX" object:nil];

    self.view.backgroundColor = BGColor;
    [self createLeftBarButtonItemWithTitle:self.isRepair?@"报修":@"投诉"];
    [self createRightBarButtonItemWithImage:@"down1" WithTitle:@"全部日期" withMethod:@selector(pullDownView)];
    
    self.currentIndex = 0;
    // 更新日期选择状态
    // @"全部日期" 1  @"今天" 2  ,@"一周内" 3  ,@"一月内"  4,
    [MyUserDefaults setObject:@"1" forKey:untreatedDate];
    [MyUserDefaults setObject:@"1" forKey:processingDate];
    [MyUserDefaults setObject:@"1" forKey:completedDate];
    
    
    // 报修时间标识
    NSString * keyStr = self.isRepair?@"repairTimeFlag":@"complainTimeFlag";
    [MyUserDefaults setObject:@"1" forKey:keyStr];
    
    [self createTopview];
    [self createScrollview];
    
    [self.view addSubview:self.selectDateView];
    
    //设置蒙版
    UIView *coverView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    coverView.backgroundColor = [UIColor blackColor];
    coverView.alpha = 0.1;
    self.coverView = coverView;
    self.coverView.hidden = YES;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeCoverview)];
    [coverView addGestureRecognizer:gesture];
    [self.view addSubview:coverView];
    
    [self.view bringSubviewToFront:self.selectDateView];
}

- (void)closeCoverview
{
    self.coverView.hidden = YES;
    [self isPullDownView:NO];
}

-(void)changeScrollerViewX:(NSNotification *)noti{
    
    
    NSString * strX = [noti object];
    NSInteger tag = [strX integerValue];

    UIButton * btn = (UIButton *)[self.topView viewWithTag:4000 + tag];
    [self topBtnClick:btn];
}


-(void)createTopview{
    
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    self.topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.topView];
    
    NSArray * btnTitleArr = @[@"未处理",@"正在处理",@"已完成"];
    for (int i = 0; i < 3; i ++) {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth/3 * i, 0, ScreenWidth/3, 43)];
        [btn setTitle:btnTitleArr[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(topBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = MiddleFont;
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
    
    
    self.topView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.topView.layer.shadowOffset = CGSizeMake(-2,3);
    self.topView.layer.shadowOpacity = 0.3;
    self.topView.layer.shadowRadius = 4;
    
    
    CGFloat scrollY = self.topView.frame.size.height + self.topView.frame.origin.y;
    self.scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, scrollY, ScreenWidth, ScreenHeight - scrollY - 64)];
    [self.view addSubview:self.scrollview];
    
    UIView * testView = [[UIView alloc]init];
    [self.scrollview addSubview:testView];
    
    self.scrollview.contentSize = CGSizeMake(ScreenWidth * 3, self.scrollview.frame.size.height);
    self.scrollview.delegate = self;
    self.scrollview.pagingEnabled = YES;
    
    [self.view bringSubviewToFront:self.topView];
}


-(void)topBtnClick:(UIButton *)btn{
    self.topCurrentBtn.selected = NO;
    btn.selected = YES;
    self.topCurrentBtn = btn;
    

    NSInteger tag = btn.tag - 4000;
    self.currentIndex = tag;
    UIImageView * line = (UIImageView *)[self.topView viewWithTag:4005];
    CGRect lineRect = line.frame;
    lineRect.origin.x = tag * ScreenWidth/3 + kLeft;
    
    [UIView animateWithDuration:0.5 animations:^{
        line.frame = lineRect;
        self.scrollview.contentOffset = CGPointMake(tag * ScreenWidth, 0);
    } completion:nil];
    
    [self updataNavigationTitleView:tag];
}

#pragma mark - 更新导航栏TitleView
-(void)updataNavigationTitleView:(NSInteger)index{
    NSString * type = @"1";
    if (index == 0) {
        // 无样式
        self.navigationItem.titleView = nil;
        
        // 日期
        type = [MyUserDefaults objectForKey:untreatedDate];
        
    }
    else if (index == 1){
        // 选择我的/其他
        self.navigationItem.titleView = self.processingSegment;
        type = [MyUserDefaults objectForKey:processingDate];
    }
    else if (index == 2){
        // 选择我的/其他
        self.navigationItem.titleView = self.completeSegment;
        type = [MyUserDefaults objectForKey:completedDate];
    }
    
    self.rightBtnTitleLabel.text = [self selectDateTitleWithType:type];
}

-(NSString *) selectDateTitleWithType:(NSString *)type{
    
    NSInteger btnType = [type integerValue];
    NSArray * arr = @[@"全部日期",@"今天",@"一周内",@"一月内"];
    if (btnType - 1 < arr.count) {
        return arr[btnType - 1];
    }
    else{
        return @"";
    }
}

-(void)createScrollview{

    UntreatedTableViewController * newsVC = [[UntreatedTableViewController alloc]initWithIsRepairType:self.isRepair status:@"1" is_get_my:@"0" dBType:@"1"];
    MyProcessingTableViewController *myProportyVC = [[MyProcessingTableViewController alloc]initWithIsRepairType:self.isRepair status:@"2" is_get_my:@"1" dBType:@"2"];
    ProcessingTableViewController * proportyVC = [[ProcessingTableViewController alloc]initWithIsRepairType:self.isRepair status:@"2" is_get_my:@"0" dBType:@"3"];
    MyCompletedTableViewController * mycompleteVC = [[MyCompletedTableViewController alloc]initWithIsRepairType:self.isRepair status:@"3" is_get_my:@"1" dBType:@"4"];
    CompletedTableViewController * completeVC = [[CompletedTableViewController alloc]initWithIsRepairType:self.isRepair status:@"3" is_get_my:@"0" dBType:@"5"];
    
    
    newsVC.tableView.frame = CGRectMake(0, 0, ScreenWidth, self.scrollview.frame.size.height);
    [self.scrollview addSubview:newsVC.tableView];
    [self addChildViewController:newsVC];
    
    
    UIView * processing = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth, 0, ScreenWidth, self.scrollview.frame.size.height)];
    processing.clipsToBounds = YES;
    [self.scrollview addSubview:processing];


    //初始化正在处理的scrollview
    self.processingScrollview = [[UIScrollView alloc]init];
    self.processingScrollview.frame = CGRectMake(0, 0, ScreenWidth * 2, self.scrollview.frame.size.height);
    self.processingScrollview.contentSize = CGSizeMake(ScreenWidth, self.scrollview.frame.size.height);
    self.processingScrollview.pagingEnabled = YES;
    [processing addSubview:self.processingScrollview];
    UIView * view1 = [[UIView alloc]init];
    [self.processingScrollview addSubview:view1];
    
    //往正在处理的scrollview中添加内容
    // 添加 我的正在处理
    myProportyVC.tableView.frame = CGRectMake(0, 0, ScreenWidth, self.scrollview.frame.size.height);
    [self.processingScrollview addSubview:myProportyVC.tableView];
    [self addChildViewController:myProportyVC];
    
    // 添加 其他正在处理
    proportyVC.tableView.frame = CGRectMake(ScreenWidth, 0, ScreenWidth, self.scrollview.frame.size.height);
    [self.processingScrollview addSubview:proportyVC.tableView];
    [self addChildViewController:proportyVC];
    
    
    UIView * complete = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth * 2, 0, ScreenWidth, self.scrollview.frame.size.height)];
    complete.clipsToBounds = YES;
    [self.scrollview addSubview:complete];
    
    //初始化已完成的scrollview
    self.completeScrollview = [[UIScrollView alloc]init];
    UIView * view2 = [[UIView alloc]init];
    [self.completeScrollview addSubview:view2];
    self.completeScrollview.frame = CGRectMake(0, 0, ScreenWidth * 2, self.scrollview.frame.size.height);
    self.completeScrollview.contentSize = CGSizeMake(ScreenWidth, self.scrollview.frame.size.height);
    self.completeScrollview.pagingEnabled = YES;
    
    //往正在处理的scrollview中添加内容
    // 添加 我的
    mycompleteVC.tableView.frame = CGRectMake(0, 0, ScreenWidth, self.scrollview.frame.size.height);
    [self.completeScrollview addSubview:mycompleteVC.tableView];
    [self addChildViewController:mycompleteVC];
    // 添加 其他
    completeVC.tableView.frame = CGRectMake(ScreenWidth, 0, ScreenWidth, self.scrollview.frame.size.height);
    [self.completeScrollview addSubview:completeVC.tableView];
    [self addChildViewController:completeVC];
    [complete addSubview:self.completeScrollview];
    
    
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
    
    if((x>ScreenWidth/2&&x<=ScreenWidth)|| (x<ScreenWidth*3/2 && x>=ScreenWidth))
    {
        UIButton *btn1 = (UIButton *)[self.topView viewWithTag:4000 + 1];
        self.topCurrentBtn.selected = NO;
        btn1.selected = YES;
        self.topCurrentBtn = btn1;
    }
    if (x>=0 && x<ScreenWidth/2)
    {
        UIButton *btn1 = (UIButton *)[self.topView viewWithTag:4000 + 0];
        self.topCurrentBtn.selected = NO;
        btn1.selected = YES;
        self.topCurrentBtn = btn1;
    }
    if (x>ScreenWidth*3/2 && x<=2*ScreenWidth)
    {
        UIButton *btn1 = (UIButton *)[self.topView viewWithTag:4000+2];
        self.topCurrentBtn.selected = NO;
        btn1.selected = YES;
        self.topCurrentBtn = btn1;
    }
    
    [self updataNavigationTitleView:x / ScreenWidth];
}



-(UISegmentedControl *)processingSegment{
    if (_processingSegment == nil) {
        _processingSegment = [[UISegmentedControl alloc]initWithItems:@[@"我的",@"其他"]];
        _processingSegment.frame = CGRectMake(0, 0, 60, 25);
        _processingSegment.tintColor = [UIColor whiteColor];
        _processingSegment.selectedSegmentIndex = 0;
        [_processingSegment addTarget:self action:@selector(didProcessingSegmentAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _processingSegment;
}

-(UISegmentedControl *)completeSegment{
    if (_completeSegment == nil) {
        _completeSegment = [[UISegmentedControl alloc]initWithItems:@[@"我的",@"其他"]];
        _completeSegment.frame = CGRectMake(0, 0, 60, 25);
        _completeSegment.tintColor = [UIColor whiteColor];
        _completeSegment.selectedSegmentIndex = 0;
        [_completeSegment addTarget:self action:@selector(didCompleteSegmentAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _completeSegment;
}

-(UIView *)selectDateView{
    if (_selectDateView == nil) {
        _selectDateView = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth - 100, 0, 100, 0)];
        _selectDateView.backgroundColor = mainColor;
        _selectDateView.clipsToBounds = YES;
        NSArray * arr = @[@"今天",@"一周内",@"一月内",@"全部日期"];
        for (int i = 0; i < arr.count; i ++) {
            UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 40 * i, 100, 40)];
            [btn setTitle:arr[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font = LargeFont;
            [btn addTarget:self action:@selector(dateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 3000 + i;
            [_selectDateView addSubview:btn];
            
            
            UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(0, btn.frame.origin.y - 1, 100, 1)];
            line.backgroundColor = [UIColor whiteColor];
            [_selectDateView addSubview:line];
        }
        
    }
    return _selectDateView;
}
-(void)dateBtnClick:(UIButton *)btn{
    NSArray * arr = @[@"今天",@"一周内",@"一月内",@"全部日期"];
    NSInteger tag = btn.tag - 3000;
    self.rightBtnTitleLabel.text = arr[tag];
    
    NSString * key = [self userDefaultTitleWithCurrentIndex];
    switch (tag) {
        case 0:
            [MyUserDefaults setObject:@"2" forKey:key];
            break;
        case 1:
            [MyUserDefaults setObject:@"3" forKey:key];
            break;
        case 2:
            
            [MyUserDefaults setObject:@"4" forKey:key];
            break;
        case 3:
            
            [MyUserDefaults setObject:@"1" forKey:key];
            break;
            
        default:
            break;
    }
    
    // 发通知请求数据
    [[NSNotificationCenter defaultCenter] postNotificationName:key object:nil];

    
    
    [self isPullDownView:NO];
}

-(NSString *) userDefaultTitleWithCurrentIndex{
    if (self.currentIndex == 0) {
        return untreatedDate;
    }
    else if (self.currentIndex == 1) {
        return processingDate;
    }
    else
        return completedDate;
}

@end
