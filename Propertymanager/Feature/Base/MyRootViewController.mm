//
//  MyRootViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/16.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "MyRootViewController.h"
#import "HomeViewController.h"

#define rightX 250
@interface MyRootViewController ()

@property (nonatomic,strong) UIView * gesView;

@property (nonatomic,assign) CGFloat currentX;

@end

@implementation MyRootViewController

#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
    }
    return self;
}


-(UIView *)gesView{
    if (_gesView == nil) {
        _gesView = [[UIView alloc]initWithFrame:CGRectMake(rightX, 0, ScreenWidth, ScreenHeight)];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesClick)];
        [_gesView addGestureRecognizer:tap];
        //拖拽手势
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panClick:)];
        //无论手指大小都只允许一个手指
        pan.minimumNumberOfTouches = 1;
        pan.maximumNumberOfTouches = 1;
        [_gesView addGestureRecognizer:pan];
    }
    return _gesView;
}

-(void)tapGesClick{
    
    [self didClickLeftBarButtonAction];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didClickLeftBarButtonAction) name:@"ClickLeftBarButtonAction" object:nil];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"leftVCAppear"];
    
    self.leftViewController = [[LeftViewController alloc]init];
    [self addChildViewController:self.leftViewController];
    [self.view addSubview:self.leftViewController.view];
    
    [self addChildViewController:self.midViewController];
    [self.view addSubview:self.midViewController.view];
    
    [self createMiddleVCShowdow];
    
    
    self.currentX = self.midViewController.view.frame.origin.x;
    //增加监听者
    [self addObserver:self forKeyPath:@"currentX" options:NSKeyValueObservingOptionNew context:nil];

    [self.view addSubview:self.gesView];
    [self.view sendSubviewToBack:self.gesView];
    
   
}

-(void)createMiddleVCShowdow{

    self.midViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.midViewController.view.layer.shadowOffset = CGSizeMake(-8,- 3);
    self.midViewController.view.layer.shadowOpacity = 0.3;//阴影透明度，默认0
    self.midViewController.view.layer.shadowRadius = 10;//阴影半径，默认3

}

//实现监听事件
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"currentX"]) {
        
        if (self.currentX == 0.0) {
            [self.view sendSubviewToBack:self.gesView];
        }
        else{
            [self.view bringSubviewToFront:self.gesView];
        }
    }
}

-(void)panClick:(UIPanGestureRecognizer *)pan{
    
    CGPoint location = [pan locationInView:self.view];
    if (pan.state != UIGestureRecognizerStateEnded && pan.state != UIGestureRecognizerStateFailed ) {
        pan.view.center = CGPointMake(location.x, ScreenHeight/2);
        NSInteger x = location.x;
        if (location.x <= ScreenWidth / 2) {
            x = ScreenWidth / 2;
        }
        
        self.midViewController.view.center = CGPointMake(x, ScreenHeight/2);
       
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        
        CGPoint point = self.midViewController.view.frame.origin;
        if (point.x <= rightX - 10) {
            self.midViewController.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        }
        else{
            self.midViewController.view.frame = CGRectMake(rightX, 0, ScreenWidth, ScreenHeight);
        }
        pan.view.frame = self.midViewController.view.frame;
        self.currentX = self.midViewController.view.frame.origin.x;
    }
    
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.midViewController.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
}

-(void)dealloc{
    SYLog(@"MyRootViewController dealloc");
    for (int i = 0 ; i < self.childViewControllers.count ; i ++) {
        [self.childViewControllers[i] removeFromParentViewController];
    }
    
    self.leftViewController.view = nil;
    self.midViewController.view = nil;
    
    self.leftViewController = nil;
    self.midViewController = nil;
    [self removeObserver:self forKeyPath:@"currentX"];
}

//  侧边栏效果
- (void)didClickLeftBarButtonAction{
    //  用这个判断条件是为了左边视图出来后,再点击按钮能够回去
    if (self.currentX == 0.0) {
        [UIView animateWithDuration:0.3 animations:^{
            //  ScreenWidth  ScreenHeight  屏幕实际大小宏
            self.leftViewController.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"leftVCAppear"];
             self.midViewController.view.frame = CGRectMake(rightX, 0, ScreenWidth, ScreenHeight);
            
            self.gesView.frame = self.midViewController.view.frame;
        } completion:^(BOOL finished) {
            
            
        }];
        
        
    }else{
        
        [UIView animateWithDuration:0.3 animations:^{
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"leftVCAppear"];
            self.midViewController.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
            self.gesView.frame = self.midViewController.view.frame;
        } completion:^(BOOL finished) {
        }];
    }
    self.currentX = self.midViewController.view.frame.origin.x;
    
}


#pragma mark - 懒加载
- (UINavigationController *)midViewController{
    if (!_midViewController) {
        HomeViewController * homeVC = [[HomeViewController alloc]init];
        _midViewController = [[UINavigationController alloc]initWithRootViewController:homeVC];
        _midViewController.navigationBar.backgroundColor = mainColor;
        _midViewController.navigationBar.translucent = NO;
        _midViewController.navigationBar.barTintColor = mainColor;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(20, 20, 200, 40);
        UIImageView * imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 11, 18, 18)];
        imageview.userInteractionEnabled = YES;
        imageview.image = [UIImage imageNamed:@"home_my"];
        [button addSubview:imageview];
        
        //点击手势
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickLeftBarButtonAction)];
        [imageview addGestureRecognizer:tap];
        
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(29, 5, 165, 30)];
        label.text = [UserManagerTool userManager].worker_name;
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:18];
        [button addSubview:label];
        [button addTarget:self action:@selector(didClickLeftBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        homeVC.navigationItem.leftBarButtonItem = leftItem;
        

    }
    return _midViewController;
}

@end
