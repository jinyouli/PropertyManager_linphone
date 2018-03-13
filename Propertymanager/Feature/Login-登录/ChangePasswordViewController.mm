//
//  ChangePasswordViewController.m
//  idoubs
//
//  Created by Momo on 16/6/22.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "TextFieldCustom.h"
@interface ChangePasswordViewController ()

@property (nonatomic,strong) TextFieldCustom *passwordTextField1;
@property (nonatomic,strong) TextFieldCustom *passwordTextField2;
@property (nonatomic,strong) UIButton *updateBtn;
@end

@implementation ChangePasswordViewController

#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        
        if (![PMTools isNullOrEmpty:params[@"verify_code"]]) {
            self.verify_code = params[@"verify_code"];
        }
        
        if (![PMTools isNullOrEmpty:params[@"username"]]) {
            self.username = params[@"username"];
        }
    }
    return self;
}

-(void)dealloc{
    SYLog(@"ChangePasswordViewController dealloc");
    self.view = nil;
    self.passwordTextField1 = nil;
    self.passwordTextField2 = nil;
    self.updateBtn = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createLeftBarButtonItemWithTitle:@"修改密码"];
    self.view.backgroundColor = BGColor;

    [self createSubviews];
}

-(void)createSubviews{
    
    UIView * myTextView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, ScreenWidth, 100)];
    [self.view addSubview:myTextView];

    
    self.passwordTextField1 = [[TextFieldCustom alloc]initWithPreLeftImageName:@"login_password" withPlaceholder:@"输入新密码" isSecure:YES];
    self.passwordTextField1.frame = CGRectMake(0, 0, ScreenWidth, 50);
    [self.passwordTextField1 createLookPasswordRightBtn];
    [self.passwordTextField1 createTopLineIsLong:YES];
    [self.passwordTextField1 createBottomLineIsLong:NO];
    [myTextView addSubview:self.passwordTextField1];
    
    self.passwordTextField2 = [[TextFieldCustom alloc]initWithPreLeftImageName:@"login_password" withPlaceholder:@"再次输入新密码" isSecure:YES];
    self.passwordTextField2.frame = CGRectMake(0, 50, ScreenWidth, 50);
    [self.passwordTextField2 createLookPasswordRightBtn];
    [self.passwordTextField2 createBottomLineIsLong:YES];
    [myTextView addSubview:self.passwordTextField2];
    
    
    
    self.updateBtn = [[UIButton alloc]initWithFrame:CGRectMake(20,  CGRectGetMaxY(myTextView.frame) + 50, ScreenWidth - 40, 40)];
    [self.updateBtn setTitle:@"确认修改" forState:UIControlStateNormal];
    [self.updateBtn addTarget:self action:@selector(updateBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.updateBtn.backgroundColor = mainColor;
    self.updateBtn.layer.cornerRadius = 8;
    [self.view addSubview:self.updateBtn];
    

}

#pragma Mark - 点击更新密码
-(void)updateBtnClick{
    
    if([PMTools isHaveIllegalChar:self.passwordTextField1.contentTextField.text] || [PMTools isHaveIllegalChar:self.passwordTextField2.contentTextField.text])
    {
        [self createAlertWithMessage:@"您输入的密码含有非法字符"];
        return;
    }
    
    if (![self.passwordTextField1.contentTextField.text isEqualToString:self.passwordTextField2.contentTextField.text]) {
        [self createAlertWithMessage:@"您两次输入的密码不一致"];
        return;
    }
    
    if (self.passwordTextField1.contentTextField.text.length < 6 || self.passwordTextField1.contentTextField.text.length > 16) {
        [self createAlertWithMessage:@"密码应在6-16位"];
        return;
    }
    
    
    //修改密码
    if ([self checkNetWork]) {
        
        NSDictionary * headDic = @{@"uuid":[PMTools getUUID],@"username":self.username};
//        NSDictionary * paraDic = @{@"username":self.username,@"verify_code":self.verify_code,@"new_password":[MD5Util md5:self.passwordTextField1.contentTextField.text]};
//        
//        [DetailRequest SYChange_pwd_by_verify_codeWithHeader:headDic WithParms:paraDic SuccessBlock:^{
//            [[NSUserDefaults standardUserDefaults] setObject:self.passwordTextField1.contentTextField.text forKey:@"password"];
//            
//            //[SVProgressHUD showSuccessWithStatus:@"修改密码成功"];
//            [SYCommon addAlertWithTitle:@"修改密码成功"];
//            
//            //[self performSelector:@selector(popToRootVC) withObject:nil afterDelay:1.5f];
//        }];
        
    }
    
    //确认完毕后 返回登录根目录 重新登录
    [self.navigationController popToRootViewControllerAnimated:NO];
}

-(void)popToRootVC{
    
    //验证成功
    [[Routable sharedRouter] open:CHANGEPASSWORD_VIEWCONTROLLER];
}

@end
