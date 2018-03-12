//
//  ForgetPasswordViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/16.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "ForgetPasswordViewController.h"
#import "TextFieldCustom.h"
@interface ForgetPasswordViewController ()
@property (nonatomic,strong) TextFieldCustom *phoneTextField;
@property (nonatomic,strong) TextFieldCustom *codeTextField;
@property (nonatomic,strong) UIButton *nextBtn;

@property (nonatomic,strong) NSTimer * timer;
/** 剩余时间秒数*/
@property (nonatomic,assign) NSInteger leftTime;
@end

@implementation ForgetPasswordViewController
#pragma mark - 初始化
#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
    }
    return self;
}

-(void)dealloc{
    SYLog(@"ForgetPasswordViewController dealloc");
    self.view = nil;
    self.phoneTextField = nil;
    self.codeTextField = nil;
    self.nextBtn = nil;
    [self.timer invalidate];
    self.timer = nil;
    
}

- (void)backAction
{
    [self.timer invalidate];
    self.timer = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createLeftBarButtonItemWithTitle:@"身份验证"];
    self.view.backgroundColor = BGColor;
    self.leftTime = 60;
    [self createSubviews];
}

-(void)createSubviews{
    
    UIView * myTextView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, ScreenWidth, 100)];
    [self.view addSubview:myTextView];
    
    self.phoneTextField = [[TextFieldCustom alloc]initWithPreLeftImageName:@"login_phone" withPlaceholder:@"手机号（账号）" isSecure:NO];
    self.phoneTextField.frame = CGRectMake(0, 0, ScreenWidth, 50);
    [self.phoneTextField createTopLineIsLong:YES];
    [self.phoneTextField createBottomLineIsLong:NO];
    [myTextView addSubview:self.phoneTextField];
    
    
    self.codeTextField = [[TextFieldCustom alloc]initWithPreLeftImageName:nil withPlaceholder:@"验证码" isSecure:NO];
    self.codeTextField.frame = CGRectMake(0, 50, ScreenWidth, 50);
    self.codeTextField.contentTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.codeTextField createSendMsgCodeRightBtn];
    [self.codeTextField createBottomLineIsLong:YES];
    [myTextView addSubview:self.codeTextField];
    [self.codeTextField sendMsgBlock:^{
       //点击了发送验证码按钮
        SYLog(@"block中 开始处理验证码");
        
        //判断是否输入为空
        if ([PMTools isNullOrEmpty:self.phoneTextField.contentTextField.text]) {
            [self createAlertWithMessage:@"手机号不能为空！"];
            return;
        }

        //判断是否为手机号
        if (![PMTools isPhoneNumber:self.phoneTextField.contentTextField.text] ) {
            [self createAlertWithMessage:@"请按照提示输入信息"];
            return;
        }
        
        //检查是否有网络
        if ([self checkNetWork]) {
        
            [self btnAndLabelStateChange];
            NSDictionary * paraDic = @{@"username":self.phoneTextField.contentTextField.text};
            [DetailRequest SYGet_verify_code_messageWithParms:paraDic SuccessBlock:^{
                [self.codeTextField.contentTextField isFirstResponder];
                
            }];
        }

    }];

    self.nextBtn = [[UIButton alloc]initWithFrame:CGRectMake(20,  CGRectGetMaxY(myTextView.frame) + 50, ScreenWidth - 40, 40)];
    [self.nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [self.nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.nextBtn.backgroundColor = mainColor;
    self.nextBtn.layer.cornerRadius = 8;
    [self.view addSubview:self.nextBtn];
}

-(void)btnAndLabelStateChange{
    
    self.codeTextField.rightButton.layer.borderColor = lineColor.CGColor;
    [self.codeTextField.rightButton setTitleColor:lineColor forState:UIControlStateNormal];
    self.codeTextField.secondLabel.hidden = NO;
    self.codeTextField.rightButton.enabled = NO;
    self.leftTime = 60;
    self.codeTextField.secondLabel.text = [NSString stringWithFormat:@"%ld",(long)self.leftTime];
    
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeBtnTime) userInfo:nil repeats:YES];
    }
    else{
        
        //
        self.timer.fireDate = [NSDate distantPast];
    }
}
#pragma mark - 时间轮询
-(void)changeBtnTime{
    
    self.leftTime --;
    self.codeTextField.secondLabel.text = [NSString stringWithFormat:@"%ld",(long)self.leftTime];
    
    
    if (self.leftTime == 0) {
        [self.codeTextField.rightButton setTitle:@"重发" forState:UIControlStateNormal];
        self.codeTextField.rightButton.enabled = YES;
        self.timer.fireDate = [NSDate distantFuture];
        self.codeTextField.secondLabel.hidden = YES;
        self.codeTextField.rightButton.selected = NO;
        self.codeTextField.rightButton.layer.borderColor = mainColor.CGColor;
        [self.codeTextField.rightButton setTitleColor:mainColor forState:UIControlStateNormal];
    }
    
}


#pragma mark - 下一步验证短信验证码
-(void)nextBtnClick{
    //判断是否输入为空
    if ([PMTools isNullOrEmpty:self.codeTextField.contentTextField.text]) {
        [self createAlertWithMessage:@"验证码不能为空！"];
        return;
    }
    
    //验证短信验证码
    if ([self checkNetWork]) {
        
        NSDictionary * headDic = @{@"uuid":[PMTools getUUID],@"username":self.phoneTextField.contentTextField.text};
        NSDictionary * paraDic = @{@"username":self.phoneTextField.contentTextField.text,@"mobile_phone":self.phoneTextField.contentTextField.text,@"verify_code":self.codeTextField.contentTextField.text};
        
        [DetailRequest SYValidate_mobile_phoneWithHeader:headDic WithParms:paraDic SuccessBlock:^{
            //验证成功
            [[Routable sharedRouter] open:CHANGEPASSWORD_VIEWCONTROLLER animated:YES extraParams:@{@"verify_code":self.codeTextField.contentTextField.text,@"username":self.phoneTextField.contentTextField.text}];
        }];
        
    }
}


@end
