//
//  BottomChatToolView.m
//  idoubs
//
//  Created by Momo on 16/6/22.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "BottomChatToolView.h"

#import "iflyMSC/iflyMSC.h"
#import "IATConfig.h"
#import "ISRDataHelper.h"


@interface BottomChatToolView()<UITextViewDelegate,IFlySpeechRecognizerDelegate>

@property (nonatomic,assign) CGRect oFrame;
@property (nonatomic,strong) UILabel * placeLabel;

@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象
@property (nonatomic, assign) BOOL isCanceled;
@property (nonatomic, strong) NSString * voiceStr;




@end

@implementation BottomChatToolView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.oFrame = frame;
        self.frame = frame;
        self.backgroundColor = [UIColor whiteColor];
        [self createSubviews];
    }
    return self;
}

- (void)setVoiceEnable
{
    [self pullUpBottomView];
    self.voiceBtn.selected = YES;
    
    
        // 长按按钮可按
        self.talkBtn.enabled = YES;
        self.talkBtn.layer.borderColor = mainColor.CGColor;
        [self.talkBtn setTitleColor:mainColor forState:UIControlStateNormal];
    
    if (self.block) {
        self.block(7,NO,0,@"");
    }
}

-(void)createSubviews{
    
    for (int i = 0; i < 3; i ++) {
        UIButton * btn = [[UIButton alloc]init];
        btn.tag = 1000 + i;
        if (i == 0) {
            btn.frame = CGRectMake(10, 7.5, 35, 35);
            btn.selected = YES;
            [btn setImage:[UIImage imageNamed:@"voice_on"] forState:UIControlStateSelected];
            [btn setImage:[UIImage imageNamed:@"silence_off"] forState:UIControlStateNormal];
            
            [btn addTarget:self action:@selector(setVoiceEnable) forControlEvents:UIControlEventTouchUpInside];
            self.voiceBtn = btn;
        }
        else if (i == 1){
            btn.frame = CGRectMake(50, 7.5, ScreenWidth - 100, 35);
            [btn setTitle:@"按住  说话" forState:UIControlStateNormal];
            [btn setTitle:@"松开 结束" forState:UIControlStateHighlighted];
            btn.layer.borderWidth = 1.0f;
            btn.layer.borderColor = mainColor.CGColor;
            [btn setTitleColor:mainColor forState:UIControlStateNormal];
            btn.layer.cornerRadius = 8.0f;
            self.talkBtn = btn;
            
            //添加点击事件
            //开始监听用户的语音
            [btn addTarget:self action:@selector(touchSpeak:) forControlEvents:UIControlEventTouchDown];
            
            //开始停止监听 并处理用户的输入
            [btn addTarget:self action:@selector(stopSpeak:) forControlEvents:UIControlEventTouchUpInside];
            
            //取消这一次的监听
            [btn addTarget:self action:@selector(cancelSpeak:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
            
            //显示上划取消的动画
            [btn addTarget:self action:@selector(remindDragExit:) forControlEvents:UIControlEventTouchDragExit];
            
            //显示下滑发送的动画
            [btn addTarget:self action:@selector(remindDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
            
            
            self.voiceTextView = [[UITextView alloc]initWithFrame:btn.frame];
            self.voiceTextView.hidden = YES;
            self.voiceTextView.layer.cornerRadius = 8.0f;
            self.voiceTextView.layer.borderColor = mainColor.CGColor;
            self.voiceTextView.layer.borderWidth = 1.0f;
            self.voiceTextView.delegate = self;
            [self addSubview:self.voiceTextView];
            
            
            self.placeLabel = [[UILabel alloc]initWithFrame:btn.frame];
            self.placeLabel.text = @"请在此处输入文字";
            self.placeLabel.textColor = lineColor;
            self.placeLabel.font = SmallFont;
            [self addSubview:self.placeLabel];
        }
        else{
            btn.frame = CGRectMake(ScreenWidth - 40, 10, 30, 30);
            [btn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
            self.addImageRightBtn = btn;
            
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        btn.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:btn];
    }
    
    UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
    line.backgroundColor = lineColor;
    [self addSubview:line];
    
    UIImageView * line1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 49, ScreenWidth, 1)];
    line1.backgroundColor = lineColor;
    [self addSubview:line1];
    
    UIButton * takePhotoBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 60, 80, 80)];
    takePhotoBtn.backgroundColor = mainColor;
    takePhotoBtn.clipsToBounds = YES;
    [takePhotoBtn setImage:[UIImage imageNamed:@"imageLogo"] forState:UIControlStateNormal];
    takePhotoBtn.layer.cornerRadius = 40;
    takePhotoBtn.tag = 2005;
    [takePhotoBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:takePhotoBtn];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(10, 150, 80, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"图片";
    label.textColor = lineColor;
    label.clipsToBounds = YES;
    [self addSubview:label];
    
    
}

-(void)pullUpBottomView{
    // 只要点击此按钮 就收回底部
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = self.oFrame;
    }];
}

-(void)btnClick:(UIButton *)btn{
    
    if (btn.tag == 1000) {
        btn.selected = !btn.selected;
        [self pullUpBottomView];
        
        
        if (btn.selected) {
            // 长按按钮可按
            self.talkBtn.enabled = YES;
            self.talkBtn.layer.borderColor = mainColor.CGColor;
            [self.talkBtn setTitleColor:mainColor forState:UIControlStateNormal];
            
            
        }
        
        //文本获得第一响应 NO键盘弹出  YES键盘收回
        if (self.block) {
            self.block(6,btn.selected,0,@"");
        }
        
        SYLog(@"语音按钮");
    }
    if (btn.tag == 1002){
        btn.selected = !btn.selected;
        SYLog(@"添加图片按钮");
        
        if (!btn.selected) {
            // 长按按钮可按  收回键盘 收回选择图片
            self.voiceBtn.selected = YES;
            self.talkBtn.enabled = YES;
            self.talkBtn.layer.borderColor = mainColor.CGColor;
            [self.talkBtn setTitleColor:mainColor forState:UIControlStateNormal];
            
            [UIView animateWithDuration:0.5 animations:^{
                self.frame = self.oFrame;
            }];
            
            
        }
        else{
            // 长按按钮不可按
            self.voiceBtn.selected = NO;
            self.talkBtn.enabled = NO;
            self.talkBtn.layer.borderColor = lineColor.CGColor;
            [self.talkBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [UIView animateWithDuration:0.5 animations:^{
                CGRect newframe = self.frame;
                newframe.size.height += 150;
                newframe.origin.y -= 150;
                self.frame =btn.selected? newframe: self.oFrame;
            }];
        }
        if (self.block) {
            self.block(7,NO,0,@"");
        }
    }
    if (btn.tag == 2005){
        if (self.block) {
            self.block(8,NO,0,@"");
        }
    }
}


-(void)myBtnClickBlock:(BtnClickBlock)block{
    if (!self.block) {
        self.block = block;
    }
}

#pragma mark - textViewDelegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if ([PMTools isNullOrEmpty:self.voiceTextView.text]) {
        self.placeLabel.text = @"请在此处输入文字";
    }
    else{
        self.placeLabel.text = @"";
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    if ([PMTools isNullOrEmpty:self.voiceTextView.text]) {
        self.placeLabel.text = @"请在此处输入文字";
    }
    else{
        self.placeLabel.text = @"";
    }
}


-(void)initRecognizer{
    
    //单例模式，无UI的实例
    
    if (_iFlySpeechRecognizer == nil) {
        
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        
        [_iFlySpeechRecognizer setParameter:@"" forKey: [IFlySpeechConstant PARAMS]];
        
        //设置听写模式
        
        [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        
    }
    
    _iFlySpeechRecognizer.delegate = self;
    
    if (_iFlySpeechRecognizer != nil) {
        
        IATConfig *instance = [IATConfig sharedInstance];
        
        //设置最长录音时间
        
        [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        
        //设置后端点
        
        [_iFlySpeechRecognizer setParameter:instance.vadEos forKey: [IFlySpeechConstant VAD_EOS]];
        
        //设置前端点
        
        [_iFlySpeechRecognizer setParameter:instance.vadBos forKey: [IFlySpeechConstant VAD_BOS]];
        
        //网络等待时间
        
        [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        
        //设置采样率，推荐使用16K
        
        [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        
        if ([instance.language isEqualToString:[IATConfig chinese]]) {
            
            //设置语言
            
            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            
            //设置方言
            
            [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
            
        }else if ([instance.language isEqualToString:[IATConfig english]]) {
            
            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            
        }
        
        //设置是否返回标点符号
        
        [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
        
    }
    
}

#pragma mark - 语音听写方法
//开始监听用户的语音
-(void)touchSpeak:(UIButton *)btn{
    
    SYLog(@"说话了....");
    
    if (self.block) {
        self.block(1,NO,0,@"");
    }
    //    self.showView.hidden = NO;
    
    //启动识别服务
    
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        
        self.voiceStr = @"";
        
        self.isCanceled = NO;
        
        if(_iFlySpeechRecognizer == nil)
            
        {
            
            [self initRecognizer];
            
        }
        
        [_iFlySpeechRecognizer cancel];
        
        //设置音频来源为麦克风
        
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        
        //设置听写结果格式为json
        
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
        //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
        
        [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        
        [_iFlySpeechRecognizer setDelegate:self];
        
        BOOL ret = [_iFlySpeechRecognizer startListening];
        
        if (ret) {
            
            //启动识别服务成功
            
        }else{
            
            //启动识别服务失败
            
        }
        
    }
    
}

//开始停止监听 并处理用户的输入
-(void)stopSpeak:(UIButton *)btn{
    
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        
        self.isCanceled = NO;
        //        self.showView.hidden = YES;
        
        
        if(_iFlySpeechRecognizer == nil)
            
        {
            
            [self initRecognizer];
            
        }
        
        [_iFlySpeechRecognizer stopListening];
        
        if (self.block) {
            self.block(3,NO,0,@"");
        }
    }
    
}
//取消这一次的监听
-(void)cancelSpeak:(UIButton *)btn{
    
    self.isCanceled = YES;
    //    self.showView.hidden = YES;
    if (self.block) {
        self.block(3,NO,0,@"");
    }
    [_iFlySpeechRecognizer cancel];
    
}
//显示上划取消的动画
-(void)remindDragExit:(UIButton *)btn{
    SYLog(@"显示上划取消的动画");
    self.isCanceled = YES;
    //    self.showVoiceLabel.text = @"松开手指，取消发送";
    //    self.showVoiceLabel.backgroundColor = [UIColor redColor];
    //    self.showVoiceView.image = [UIImage imageNamed:@"redVoice"];
    if (self.block) {
        self.block(4,NO,0,@"");
    }
}
//显示下滑发送的动画
-(void)remindDragEnter:(UIButton *)btn{
    SYLog(@"显示下滑发送的动画");
    self.isCanceled = NO;
    //    self.showVoiceLabel.backgroundColor = [UIColor clearColor];
    //    self.showVoiceLabel.text = @"手指上滑,取消发送";
    //    self.showVoiceView.image = [UIImage imageNamed:@"1"];
    if (self.block) {
        self.block(5,NO,0,@"");
    }
}



#pragma mark 语音代理方法 IFlySpeechRecognizerDelegate

/**
 
 无界面，听写结果回调
 
 results：听写结果
 
 isLast：表示最后一次
 
 ****/

- (void) onResults:(NSArray *) results isLast:(BOOL)isLast

{
    
    SYLog(@"说完了...");
    
    NSMutableString *resultString = [[NSMutableString alloc] init];
    
    NSDictionary *dic = results[0];
    
    for (NSString *key in dic) {
        
        [resultString appendFormat:@"%@",key];
        
    }
    
    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    
    self.voiceStr = [NSString stringWithFormat:@"%@%@",    self.voiceStr,resultFromJson];
    
    if (isLast){//是否是最后一次回调 因为此方法会调用多次
        
        SYLog(@"听写结果(json)：%@测试",  self.voiceStr);
        
        if (!self.isCanceled) {
            if (self.voiceStr.length>0) {
                if (self.block) {
                    self.block(2,NO,0,self.voiceStr);
                }
            }
            
            else{
                
                SYLog(@"未检测到");
                
            }
        }
        
        
    }
    
}

/**
 
 听写结束回调（注：无论听写是否正确都会回调）
 
 error.errorCode =
 
 0     听写正确
 
 other 听写出错
 
 ****/

- (void) onError:(IFlySpeechError *) error

{
    
    SYLog(@"%s",__func__);
    
    NSString *text = [NSString stringWithFormat:@"发生错误：%d %@",    error.errorCode,error.errorDesc];
    SYLog(@"%@",text);
}

/**
 
 音量回调函数
 
 volume 0－30
 
 ****/

- (void) onVolumeChanged: (int)volume

{
    
    SYLog(@"%d",volume);
    
    if (self.isCanceled) {
        
        return;
        
    }
    
    //    if (volume == 0) {
    //        //没有检测到声音 做一个静态的麦克风图片
    //        self.showVoiceView.image = [UIImage imageNamed:@"1"];
    //    }
    //
    if (volume > 0) {
        //有检测到声音 做一个动态的麦克风图片
        //        NSString * volumeStr = [NSString stringWithFormat:@"%d",volume/2];
        //        self.showVoiceView.image = [UIImage imageNamed:volumeStr];
        if (self.block) {
            self.block(9,NO,volume,@"");
        }
    }
    
}

@end
