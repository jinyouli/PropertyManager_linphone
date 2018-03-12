//
//  BaseViewController.h
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface BaseViewController : UIViewController
@property (nonatomic,strong) UIImageView * rightbtnImageView;
@property (nonatomic,strong) UILabel * rightBtnTitleLabel;
@property (nonatomic,strong) UIButton * rightBtn;

@property (nonatomic,strong) UILabel * leftBtnTitleLabel;
@property (nonatomic,strong) UIButton * leftBtn;
/** 检查网络是否通畅 */
- (BOOL)checkNetWork;

/** 取消对话框*/
- (void)dismissAction;

/** SVP对话框 取消SVP后并带方法*/
-(void)createSVProgressMessage:(NSString *)str withMethod:(SEL)method;


/** 设置导航栏标题白色字体*/
-(void)setWhiteTitle:(NSString *)title;


/** 创建导航栏左边的图标（无方法）*/
- (void)createLeftImage:(NSString *)imageName;

/** 创建导航栏左边的按钮 （图片+文字） 自带方法*/
//- (void)createLeftBarButtonItemWithTitle:(NSString *)title withMethod:(SEL)method;

/** 创建导航栏左边的返回按钮 (文字） 默认有返回按钮*/
- (void)createLeftBarButtonItemWithTitle:(NSString *)title;

/** 创建导航栏左边的按钮 (文字+图片）*/
- (void)createLeftBarButtonItemWithImage:(NSString *)imageName WithTitle:(NSString *)title withMethod:(SEL)method;

/** 创建导航栏右边的按钮 （图片+文字）*/
- (void)createRightBarButtonItemWithImage:(NSString *)imageName WithTitle:(NSString *)title withMethod:(SEL)method;

// alertView
-(void)createAlertWithMessage:(NSString *)message;


@end
