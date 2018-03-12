//
//  BottomChatToolView.h
//  idoubs
//
//  Created by Momo on 16/6/22.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
///** 长按开始*/
//typedef void(^TalkBtnLongPressUp)(); 
///** 长按结束*/
//typedef void(^TalkBtnLongPressDown)();
///** 左边语音按钮点击 文本聚焦事件*/
//typedef void(^VoiceBtnSelected)(BOOL isUp);
///** 右边添加图片按钮点击 文本聚焦事件*/
//typedef void(^AddImageBtnSelected)();
///** 子视图图片相册选择添加图片*/
//typedef void(^BottomPushPhotoAlumVC)();

//添加点击事件
//开始监听用户的语音 index = 1

//开始停止监听 并处理用户的输入 index = 2

//取消这一次的监听（上滑/点击一次按钮） index = 3

//显示上划取消的动画 index = 4

//显示下滑发送的动画 index = 5

//左边语音按钮点击 文本聚焦事件 index = 6  isUp = YES/NO

//右边添加图片按钮点击 文本聚焦事件 index = 7

//子视图图片相册选择添加图片 index = 8

//声音检测 index = 9


typedef void(^BtnClickBlock)(NSInteger index,BOOL isUp,NSInteger volume,NSString * myVoiceStr);
@interface BottomChatToolView : UIView

@property (nonatomic,strong) UIButton * talkBtn;
@property (nonatomic,strong) UIButton * voiceBtn;
@property (nonatomic,strong) UITextView * voiceTextView;
@property (nonatomic,strong) UIButton * addImageRightBtn;

@property (nonatomic,copy) BtnClickBlock block;
-(void)myBtnClickBlock:(BtnClickBlock)block;


//- (void) canVoiceInput;
//- (void) cantVoiceInput;

@end
