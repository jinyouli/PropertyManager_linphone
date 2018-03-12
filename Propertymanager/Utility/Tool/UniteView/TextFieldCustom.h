//
//  TextFieldCustom.h
//  idoubs
//
//  Created by Momo on 16/6/23.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
//执行发送验证码的回调
typedef void (^sendMsgCodeBlock)();

//判断是否输入
typedef void (^textFieldContent)();

@interface TextFieldCustom : UIView<UITextFieldDelegate>

@property (nonatomic,strong) UIImageView * leftImageView; //左边按钮
@property (nonatomic,strong) UITextField * contentTextField;//文字区域
@property (nonatomic,strong) UIButton * rightButton; //右边按钮
@property (nonatomic,strong) UILabel * secondLabel; //剩余秒数

-(instancetype)initWithPreLeftImageName:(NSString *)preName withPlaceholder:(NSString *)placeholder isSecure:(BOOL)secure;

//右边看密码按钮
-(void)createLookPasswordRightBtn;

//右边发送验证码功能
-(void)createSendMsgCodeRightBtn;

//新建上边line BOOL：长或短
-(void)createTopLineIsLong:(BOOL)lineLong;

//新建下边line BOOL: 长或短
-(void)createBottomLineIsLong:(BOOL)lineLong;

@property (nonatomic, copy) sendMsgCodeBlock block;
- (void)sendMsgBlock:(sendMsgCodeBlock)block;


@property (nonatomic, copy) textFieldContent textBlock;
- (void)sendTextBlock:(textFieldContent)block;
@end
