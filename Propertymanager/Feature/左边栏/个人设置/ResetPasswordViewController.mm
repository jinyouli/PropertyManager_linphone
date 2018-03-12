//
//  ResetPasswordViewController.m
//  idoubs
//
//  Created by Momo on 16/7/4.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "TextFieldCustom.h"
@interface ResetPasswordViewController ()<UITextFieldDelegate>

@property (nonatomic,strong) UILabel * tLabel;
@property (nonatomic,strong) TextFieldCustom *oldPsssTextField;
@property (nonatomic,strong) TextFieldCustom *nowPassTextField1;
@property (nonatomic,strong) TextFieldCustom *nowPassTextField2;
@property (nonatomic,strong) UIButton *commitBtn;

@end

@implementation ResetPasswordViewController

#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createLeftBarButtonItemWithTitle:@"重设密码"];
    self.view.backgroundColor = BGColor;
    [self createSubviews];
}

-(void)createSubviews{
    self.tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 200, 30)];
    self.tLabel.font = MiddleFont;
    self.tLabel.textColor = lineColor;
    self.tLabel.text = @"根据提示完成输入";
    [self.view addSubview:self.tLabel];

    
    self.oldPsssTextField = [[TextFieldCustom alloc]initWithPreLeftImageName:@"login_password" withPlaceholder:@"请输入原密码" isSecure:YES];
    self.oldPsssTextField.frame = CGRectMake(0, CGRectGetMaxY(self.tLabel.frame), ScreenWidth - 10, 50);
    [self.oldPsssTextField createTopLineIsLong:YES];
    [self.oldPsssTextField createBottomLineIsLong:NO];
    [self.oldPsssTextField createLookPasswordRightBtn];
    [self.oldPsssTextField sendTextBlock:^{
        [self updateCommitBtnStatus];
    }];
    [self.view addSubview:self.oldPsssTextField];
    
    self.nowPassTextField1 = [[TextFieldCustom alloc]initWithPreLeftImageName:@"login_password" withPlaceholder:@"请输入新密码" isSecure:YES];
    self.nowPassTextField1.frame = CGRectMake(0, CGRectGetMaxY(self.oldPsssTextField.frame), ScreenWidth - 10, 50);
    [self.nowPassTextField1 createBottomLineIsLong:NO];
    [self.nowPassTextField1 createLookPasswordRightBtn];
    [self.nowPassTextField1 sendTextBlock:^{
        [self updateCommitBtnStatus];
    }];
    [self.view addSubview:self.nowPassTextField1];
    
    self.nowPassTextField2 = [[TextFieldCustom alloc]initWithPreLeftImageName:@"login_password" withPlaceholder:@"请再次输入新密码" isSecure:YES];
    self.nowPassTextField2.frame = CGRectMake(0, CGRectGetMaxY(self.nowPassTextField1.frame), ScreenWidth - 10, 50);
    [self.nowPassTextField2 createBottomLineIsLong:YES];
    [self.nowPassTextField2 createLookPasswordRightBtn];
    [self.nowPassTextField2 sendTextBlock:^{
        [self updateCommitBtnStatus];
    }];
    [self.view addSubview:self.nowPassTextField2];
    
    
    self.commitBtn = [[UIButton alloc]initWithFrame:CGRectMake(20,  CGRectGetMaxY(self.nowPassTextField2.frame)+50, ScreenWidth - 40 , 30)];
    [self.commitBtn setTitle:@"完成" forState:UIControlStateNormal];
    [self.commitBtn addTarget:self action:@selector(commitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.commitBtn.backgroundColor = lineColor;
    self.commitBtn.layer.cornerRadius = 8;
    [self.commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.commitBtn.enabled = NO;
    [self.view addSubview:self.commitBtn];
    
}

-(void)updateCommitBtnStatus{
    if (![PMTools isNullOrEmpty:self.oldPsssTextField.contentTextField.text]
        &&![PMTools isNullOrEmpty:self.nowPassTextField1.contentTextField.text]
        &&![PMTools isNullOrEmpty:self.nowPassTextField2.contentTextField.text]) {
        self.commitBtn.enabled = YES;
        self.commitBtn.backgroundColor = mainColor;
    }
    else{
        self.commitBtn.enabled = NO;
        self.commitBtn.backgroundColor = lineColor;
    }
}

-(void)commitBtnClick{
    //判断是否输入为空
    if ([PMTools isNullOrEmpty:self.oldPsssTextField.contentTextField.text]||[PMTools isNullOrEmpty:self.nowPassTextField1.contentTextField.text]||[PMTools isNullOrEmpty:self.nowPassTextField2.contentTextField.text]) {
        [self createAlertWithMessage:@"其中输入一项不能为空！"];
        return;
    }
    
    //判断是否有非法字符
    if ([PMTools isHaveIllegalChar:self.oldPsssTextField.contentTextField.text] || [PMTools isHaveIllegalChar:self.nowPassTextField1.contentTextField.text]|| [PMTools isHaveIllegalChar:self.nowPassTextField2.contentTextField.text]) {
        [self createAlertWithMessage:@"您输入的密码含有非法字符"];
        return;
    }
    //判断两次密码是否一致
    if (![self.nowPassTextField1.contentTextField.text isEqualToString:self.nowPassTextField2.contentTextField.text]) {
        [self createAlertWithMessage:@"两次密码输入不一致"];
        return;
    }
    
    //判断密码是否小于6位
    if (self.nowPassTextField1.contentTextField.text.length < 6) {
        [self createAlertWithMessage:@"密码应在6-16位"];
        return;
    }
    
    //检查是否有网络
    if ([self checkNetWork]) {
    
        UserManager * user = [UserManagerTool userManager];
        NSDictionary * paraDic = @{@"username":user.username,@"old_password":[MD5Util md5:self.oldPsssTextField.contentTextField.text],@"new_password":[MD5Util md5:self.nowPassTextField1.contentTextField.text]};
        
        [DetailRequest SYChange_pwd_by_old_pwdWithParms:paraDic SuccessBlock:^{
             [self.navigationController popViewControllerAnimated:YES];
        } FailureBlock:^(NSString *msg) {
            [self createAlertWithMessage:msg];
        }];

    }
}

@end
