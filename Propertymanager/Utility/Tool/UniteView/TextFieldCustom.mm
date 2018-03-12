//
//  TextFieldCustom.m
//  idoubs
//
//  Created by Momo on 16/6/23.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "TextFieldCustom.h"

@interface TextFieldCustom ()

@property (nonatomic,strong) NSString * preLeftName;

@end

@implementation TextFieldCustom

-(instancetype)initWithPreLeftImageName:(NSString *)preName withPlaceholder:(NSString *)placeholder isSecure:(BOOL)secure{
    
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        if ([PMTools isNullOrEmpty:preName]) {
            self.preLeftName = @"";
        }else{
            self.preLeftName = preName;
        }
        
        self.bounds = CGRectMake(0, 0, ScreenWidth, 50);
        [self createSubViewsIsSecure:secure withPlaceholder:placeholder];
    }
    return self;
}

-(void)createSubViewsIsSecure:(BOOL)secure withPlaceholder:(NSString *)placeholder{
    
    self.leftImageView = [[UIImageView alloc]init];
    if ([PMTools isNullOrEmpty:self.preLeftName]) {
        self.leftImageView.backgroundColor = [UIColor clearColor];
    }
    else{
        self.leftImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_off",self.preLeftName]];
    }
    [self addSubview:self.leftImageView];
    
    self.contentTextField = [[UITextField alloc]init];
    self.contentTextField.delegate = self;
    self.contentTextField.secureTextEntry = secure;
    if (![PMTools isNullOrEmpty:placeholder]) {
        self.contentTextField.placeholder = placeholder;
    }
    [self addSubview:self.contentTextField];
    
    self.leftImageView.frame = CGRectMake(15, 12.5, 25, 25);
    self.contentTextField.frame = CGRectMake(50, 10, ScreenWidth - 50 - 20, 30);
    
    self.rightButton = [[UIButton alloc]init];
    [self addSubview:self.rightButton];
}

//右边看密码按钮
-(void)createLookPasswordRightBtn{
    [self.rightButton setImage:[UIImage imageNamed:@"login_look_off"] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"login_look_on"] forState:UIControlStateSelected];
    [self.rightButton addTarget:self action:@selector(lookBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.rightButton.frame = CGRectMake(ScreenWidth - 45, 12.5, 25, 25);
}

-(void)lookBtnClick:(UIButton *)btn{
    
    self.contentTextField.secureTextEntry = btn.selected;
    btn.selected = !btn.selected;
    
}

//右边发送验证码功能
-(void)createSendMsgCodeRightBtn{
    
    [self.rightButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.rightButton setTitleColor:mainColor forState:UIControlStateNormal];
    self.rightButton.layer.borderColor = mainColor.CGColor;
    self.rightButton.layer.borderWidth = 1;
    self.rightButton.layer.cornerRadius = 8;
    [self.rightButton addTarget:self action:@selector(sendCodeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.rightButton];
    
    //创建秒数Label
    self.secondLabel = [[UILabel alloc]init];
    self.secondLabel.text = @"59";
    self.secondLabel.textColor = lineColor;
    self.secondLabel.font = MiddleFont;
    [self addSubview:self.secondLabel];
    
    self.rightButton.frame = CGRectMake(ScreenWidth - 80, 10, 65, 32);
    self.secondLabel.frame = CGRectMake(ScreenWidth - 100, 12.5, 20, 25);
    
    //先隐藏
    self.secondLabel.hidden = YES;
}

#pragma mark - 发送验证码按钮
-(void)sendCodeBtnClick:(UIButton *)btn{
    //请求验证码
    SYLog(@"回调 ----  验证码按钮点击");
    // 回调 告诉VC应该去处理时间轮询了
    if (self.block) {
        self.block();
    }

}



#pragma mark - line横线
//新建上边line BOOL：长或短
-(void)createTopLineIsLong:(BOOL)lineLong{
    CGFloat x = lineLong ? 0 : 20;
    UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(x, 0, ScreenWidth - 2*x, 1)];
    line.backgroundColor = [PMTools colorFromHexRGB:@"d1d1d1"];
    [self addSubview:line];
}

//新建下边line BOOL: 长或短
-(void)createBottomLineIsLong:(BOOL)lineLong{
    CGFloat x = lineLong ? 0 : 20;
    UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(x, self.frame.size.height - 1, ScreenWidth - 2*x, 1)];
    line.backgroundColor = [PMTools colorFromHexRGB:@"d1d1d1"];
    [self addSubview:line];
}


#pragma mark - 代理
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSString * imageName = [NSString stringWithFormat:@"%@_on",self.preLeftName];
    self.leftImageView.image = [UIImage imageNamed:imageName];
    if (self.textBlock) {
        self.textBlock();
    }
    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    if (![PMTools isNullOrEmpty:self.preLeftName]) {
        NSString * imageName = [NSString stringWithFormat:@"%@_off",self.preLeftName];
        self.leftImageView.image = [UIImage imageNamed:imageName];
    }
    if (self.textBlock) {
        self.textBlock();
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.contentTextField) {
        if (textField.text.length >= 16)
        {
            textField.text = [textField.text substringToIndex:16];
        }
    }
    
    return YES;
}

- (void)sendMsgBlock:(sendMsgCodeBlock)block{
    
    self.block = block;
}

- (void)sendTextBlock:(textFieldContent)block{
    self.textBlock = block;
}

@end
