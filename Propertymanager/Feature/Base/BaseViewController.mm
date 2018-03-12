//
//  BaseViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

-(void)loadView
{   // textField上移 导航栏不上移
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = scrollView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //点击背景收回键盘
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
}



#pragma mark - 检查网络
// 检查网络是否通畅
- (BOOL)checkNetWork{
    
    if (![PMTools connectedToNetwork]) {
        if ([NSThread isMainThread])
        {
            [SVProgressHUD showWithStatus:@"网络异常,请检查网络连接" maskType:SVProgressHUDMaskTypeGradient];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NotReachable" object:nil];
            [self dismissAction];
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                //Update UI in UI thread here
                [SVProgressHUD showWithStatus:@"网络异常,请检查网络连接" maskType:SVProgressHUDMaskTypeGradient];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NotReachable" object:nil];
                [self dismissAction];
                
            });
        }
        
        return NO;
    }
    return YES;
}

- (void)dismissAction {
    [self performSelector:@selector(disappear) withObject:nil afterDelay:1.5f];
}

- (void)disappear {
    [SVProgressHUD dismiss];
}


-(void)createSVProgressMessage:(NSString *)str withMethod:(SEL)method{
    [SVProgressHUD showWithStatus:str maskType:SVProgressHUDMaskTypeGradient];
    
    [self dismisswithMethod:method];
}

- (void)dismisswithMethod:(SEL)method{
    [self performSelector:method withObject:nil afterDelay:1.5f];
}

//设置导航栏标题白色字体
-(void)setWhiteTitle:(NSString *)title{
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.center = CGPointMake(ScreenWidth/2, 32);
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.text = title;
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}

// 创建导航栏左边的图标
- (void)createLeftImage:(NSString *)imageName{
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    img.image = [UIImage imageNamed:imageName];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:img];
    self.navigationItem.leftBarButtonItem = leftItem;
    
}

/** 创建导航栏左边的按钮 （图片+文字）*/
- (void)createLeftBarButtonItemWithTitle:(NSString *)title{
    
    self.leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];

    UIImageView * imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 12, 16, 16)];
    imageview.userInteractionEnabled = YES;
    imageview.image = [UIImage imageNamed:@"backArrow"];
    [self.leftBtn addSubview:imageview];
    
    CGSize titleSize = [PMTools sizeWithText:title font:LargeFont maxSize:CGSizeMake(200, 30)];
    if (![PMTools isNullOrEmpty:title]) {
        
        self.leftBtnTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, titleSize.width + 10, 30)];
        self.leftBtnTitleLabel.text = title;
        self.leftBtnTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.leftBtnTitleLabel.textColor = [UIColor whiteColor];
        self.leftBtnTitleLabel.font = LargeFont;
        [self.leftBtn addSubview:self.leftBtnTitleLabel];
    }
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.leftBtn.frame = CGRectMake(0, 0, titleSize.width + 10 + 16, 30);
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)backAction
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
    });
    
}

/** 创建导航栏左边的按钮 (文字+图片）*/
- (void)createLeftBarButtonItemWithImage:(NSString *)imageName WithTitle:(NSString *)title withMethod:(SEL)method{
    
    self.leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    
    UIImageView * imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 12, 16, 16)];
    imageview.userInteractionEnabled = YES;
    imageview.image = [UIImage imageNamed:@"backArrow"];
    [self.leftBtn addSubview:imageview];
    
    
    CGSize titleSize = [PMTools sizeWithText:title font:LargeFont maxSize:CGSizeMake(200, 30)];
    if (![PMTools isNullOrEmpty:title]) {
        
        self.leftBtnTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, titleSize.width + 10, 30)];
        self.leftBtnTitleLabel.text = title;
        self.leftBtnTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.leftBtnTitleLabel.textColor = [UIColor whiteColor];
        self.leftBtnTitleLabel.font = LargeFont;
        [self.leftBtn addSubview:self.leftBtnTitleLabel];
    }
    [self.leftBtn addTarget:self action:method forControlEvents:UIControlEventTouchUpInside];
    self.leftBtn.frame = CGRectMake(0, 0, titleSize.width + 10 + 16, 30);
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
}


/** 创建导航栏右边的按钮 （图片+文字）*/
- (void)createRightBarButtonItemWithImage:(NSString *)imageName WithTitle:(NSString *)title withMethod:(SEL)method{
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 35)];
    if (![PMTools isNullOrEmpty:imageName]) {
        
        UIImageView * imageview = [[UIImageView alloc]initWithFrame:CGRectMake(85, 12.5, 15, 15)];
        imageview.userInteractionEnabled = YES;
        imageview.image = [UIImage imageNamed:imageName];
        self.rightbtnImageView = imageview;
        [button addSubview:imageview];

    }

    if (![PMTools isNullOrEmpty:title]) {
        self.rightBtnTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 80, 30)];
        if ([PMTools isNullOrEmpty:imageName]) {
            self.rightBtnTitleLabel.frame = CGRectMake(0, 5, 100, 30);
        }
        self.rightBtnTitleLabel.text = title;
        self.rightBtnTitleLabel.textAlignment = NSTextAlignmentRight;
        self.rightBtnTitleLabel.textColor = [UIColor whiteColor];
        self.rightBtnTitleLabel.font = [UIFont boldSystemFontOfSize:16];
        [button addSubview:self.rightBtnTitleLabel];
    }
    [button addTarget:self action:method forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = leftItem;
    self.rightBtn = button;
}



// alertView
-(void)createAlertWithMessage:(NSString *)message{
    
    [self.view endEditing:YES];
    if (iOSVersion >= 8.0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}



@end
