//
//  LookEntranceVedioViewController.h
//  PropertyManager
//
//  Created by Momo on 16/9/13.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "LookEntranceVedioViewController.h"

#import <QuartzCore/QuartzCore.h> /* cornerRadius... */

#import "Appdelegate.h"
#import "PSTAlertController.h"
#import "SliderScroView.h"

#define degreesToRadian(x) (M_PI * (x) / 180.0)
#define SlideScrHeight iPhone4s || iPhone5s ? 30 : 35

@interface LookEntranceVedioViewController()<SliderScroViewDelegate>
{
    UIView* viewLocalVideo;
    NSTimer * _timer;
    NgnAVSession * videoSession;
    BOOL sendingVideo;
    
    BOOL isOnLine;
}

@property (nonatomic,strong) UIImageView * bgImageView;
@property (nonatomic,strong) UIView * videoBgView;
@property (nonatomic,strong) UIImageView * vedioImageView; //显示视频界面
@property (nonatomic,strong) UIImageView * vedioAniImageView; //背景动效图
@property (nonatomic,strong) UILabel * TLabel;//提示用语
@property (nonatomic,strong) UILabel * timekeepingLabel;   //计时


@property (nonatomic,strong) iOSGLView * glViewVideoRemote;
@property (nonatomic,strong) UIView* viewLocalVideo;

@property (nonatomic,strong) UIButton *buttonMute;
@property (nonatomic,strong) UIButton *buttonHangUp;
@property (nonatomic,strong) UIButton *buttonEnd;


@property (nonatomic,strong) SliderScroView * slideScr;
@property (nonatomic,assign) NSInteger count;


@property (nonatomic,strong) NSTimer * timer;
@property (nonatomic,assign) NSInteger timeout;

/**  */
@property (strong, nonatomic) PSTAlertController *dismiss;

@end

@implementation LookEntranceVedioViewController

-(instancetype)init{
    if (self = [super init]) {
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        
        isOnLine = YES;
        sendingVideo = YES;
        _domain_sn = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // listen to the events
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
   
    
    [self createVideoBgView];
    
    [self createDialBtn];
    
    //监听占线
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(LineISBusy) name:@"LineISBusy" object:nil];
}

-(void)LineISBusy{
    NSLog(@"占线");
    
    
    _dismiss = [PSTAlertController presentDismissableAlertWithTitle:@"⚠️\n" message:@"门口机忙，请稍后再试！" controller:self];
    [_dismiss addDidDismissBlock:^(PSTAlertAction * _Nonnull action) {
        [NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
                                         target:self
                                       selector:@selector(timerSuicideTick:)
                                       userInfo:nil
                                        repeats:NO];
    }];
}

- (void)startTime{

    _timeout = 0;
    
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeStarCount) userInfo:nil repeats:YES];
    }
    
}

-(void)timeStarCount{
    
    if (videoSession && videoSession.connected) {
        _timeout ++;
        NSString * secStr = @"00";
        if (_timeout == 0) {
            secStr = @"00";
        }
        else if (_timeout > 0 && _timeout <= 9 ) {
            
            secStr = [NSString stringWithFormat:@"0%zd",_timeout];
            
        }else if (_timeout > 9 && _timeout <= 30){
            secStr = [NSString stringWithFormat:@"%zd",_timeout];
        }
        else if (_timeout == 31){
            //挂断
            
            SYLog(@"挂断");
            [videoSession hangUpCall];
            // releases session
            [NgnAVSession releaseSession:&videoSession];
            // starts timer suicide
            [NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
                                             target:self
                                           selector:@selector(timerSuicideTick:)
                                           userInfo:nil
                                            repeats:NO];

        }
        _timekeepingLabel.text = [NSString stringWithFormat:@"00:%@",secStr];
        NSLog(@"时间%@",secStr);
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [videoSession release];
    videoSession = [[NgnAVSession getSessionWithId: self.sessionId] retain];
    if(videoSession){
        if([videoSession isConnected]){
            [videoSession setSpeakerEnabled:YES];
            self.buttonMute.selected = YES;
            [videoSession setMute:YES];
            [videoSession setRemoteVideoDisplay:_glViewVideoRemote];
            [videoSession setLocalVideoDisplay:viewLocalVideo];
        }
    }
    
    isOnLine = YES;
    _buttonEnd.selected = NO;
    _buttonHangUp.selected = YES;
    
    _timeout = 0;
    //开启动画
    [_vedioImageView startAnimating];
    _TLabel.text = @"请稍等...";
    
    //更新数据
    _slideScr.domain_sn = _domain_sn;
    _slideScr.sip_number = _sipnum;
    
    [self updateViewAndState];
    [self updateVideoOrientation];
    [self updateRemoteDeviceInfo];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    if(videoSession && [videoSession isConnected]){
        
        [videoSession setRemoteVideoDisplay:nil];
        [videoSession setLocalVideoDisplay:nil];
        [NgnAVSession releaseSession: &videoSession];
        
    }
    
    //停止动画
    SYLog(@"停止动画");
    [_vedioImageView stopAnimating];
    [[NgnEngine sharedInstance].soundService setSpeakerEnabled:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [NgnCamera setPreview:nil];
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self updateVideoOrientation];
    
    [self sendDeviceInfo];
}

#pragma mark - 创建视频界面
-(void)createVideoBgView{
    
    _bgImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    _bgImageView.userInteractionEnabled = YES;
    _bgImageView.image = [UIImage imageNamed:@"EntranceBG"];
    [self.view addSubview:_bgImageView];
    
    
    _videoBgView = [[UIView alloc]initWithFrame:CGRectMake(10, 20 + 13, ScreenWidth - 20, ScreenHeight * 0.4)];
    _videoBgView.layer.cornerRadius = 8;
    _videoBgView.backgroundColor = MYColor(63, 65, 80);
    [_bgImageView addSubview:_videoBgView];
    
    //视频图层
    _vedioImageView = [[UIImageView alloc]initWithFrame:CGRectMake(2, 15, _videoBgView.frame.size.width - 4, _videoBgView.frame.size.height - 20)];
    _vedioImageView.image = [UIImage imageNamed:@"VedioBG"];
    [_videoBgView addSubview:_vedioImageView];
    

    //视频界面动效图
    _vedioAniImageView = [[UIImageView alloc]init];
    _vedioAniImageView.bounds = CGRectMake((_vedioImageView.frame.size.width - 200) * 0.5, 0, 200, 80);
    _vedioAniImageView.center = _vedioImageView.center;
    [_vedioImageView addSubview:_vedioAniImageView];
    NSArray *imagesArray = [NSArray arrayWithObjects:
                            [UIImage imageNamed:@"entrance1.png"],
                            [UIImage imageNamed:@"entrance2.png"],
                            [UIImage imageNamed:@"entrance3.png"],
                            [UIImage imageNamed:@"entrance4.png"],
                            [UIImage imageNamed:@"entrance5.png"],
                            [UIImage imageNamed:@"entrance6.png"],
                            [UIImage imageNamed:@"entrance7.png"],
                            [UIImage imageNamed:@"entrance8.png"],
                            [UIImage imageNamed:@"entrance9.png"],nil];
    _vedioAniImageView.animationImages = imagesArray;
    _vedioAniImageView.animationDuration = 2;
    _vedioAniImageView.animationRepeatCount = 0;
    [_vedioAniImageView startAnimating];
    _TLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, _vedioImageView.frame.size.height - 25, _vedioImageView.frame.size.width, 20)];
    _TLabel.text = @"请稍等...";
    _TLabel.textColor = [UIColor whiteColor];
    _TLabel.textAlignment = NSTextAlignmentCenter;
    _TLabel.font = MiddleFont;
    [_vedioImageView addSubview:_TLabel];
    
    
    
    //门口机视频图像
    // GLView
    _glViewVideoRemote = [[[iOSGLView alloc] initWithFrame:_vedioImageView.bounds] autorelease];
    [_vedioImageView addSubview:_glViewVideoRemote];
    _glViewVideoRemote.hidden = YES;
    
    
    //本地摄像头视频
    self.viewLocalVideo = [[[UIView alloc] initWithFrame:CGRectMake(10, 200, 0, 0)] autorelease];
    self.viewLocalVideo.hidden = YES;
    
    
    
    //时间计时标签
    _timekeepingLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 2, CGRectGetMaxY(_glViewVideoRemote.frame) - 30, 20)];
    _timekeepingLabel.font = MiddleFont;
    _timekeepingLabel.text = @"00:00";
    _timekeepingLabel.textColor = [UIColor whiteColor];
    [_glViewVideoRemote addSubview:_timekeepingLabel];
    
    
    //滑块解锁
    _slideScr = [[SliderScroView alloc]initWithFrame:CGRectMake(30, ScreenHeight - 150 , ScreenWidth - 60, SlideScrHeight) withSn_Domain:_domain_sn type:@"1" sipNum:_sipnum];
    _slideScr.myDelegate = self;
    _slideScr.contentOffset = CGPointMake(_slideScr.frame.size.width, 0);
    [_bgImageView addSubview:_slideScr];

    
}

#pragma mark - 创建静音免提挂断按钮
-(void)createDialBtn{
    for (int i = 0; i < 3; i ++) {
        UIButton * btn = [[UIButton alloc]init];
        btn.tag = 101 + i;
        [btn addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [btn setTitleColor:ITextColor forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = MiddleFont;
        
        if (i == 0) {
            btn.frame = CGRectMake(30, CGRectGetMaxY(_videoBgView.frame) + 10, 30, 40);
            [btn setTitle:@"静音" forState:UIControlStateNormal];
            self.buttonMute = btn;
            self.buttonMute.selected = YES;
        }
        else if (i == 1){
            [btn setBackgroundImage:[UIImage imageNamed:@"entrance_end"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"entrance_end_click"] forState:UIControlStateHighlighted];
            btn.frame = CGRectMake(ScreenWidth/2 - 75, CGRectGetMaxY(_videoBgView.frame) + 10, 150, 40);
            _buttonEnd = btn;
        }else if (i == 2){
            btn.frame = CGRectMake(ScreenWidth - 70, CGRectGetMaxY(_videoBgView.frame) + 10, 30, 40);
            [btn setTitle:@"免提" forState:UIControlStateNormal];
            _buttonHangUp = btn;
        }
        [_bgImageView addSubview:btn];
    }
}


#pragma mark - 按钮点击
-(void)selectBtn:(UIButton *)btn{
    
    switch (btn.tag) {
        case 101:
        {
          //  静音
            if(videoSession && [videoSession isConnected]) {
                //self.buttonMute.selected = !self.buttonMute.selected;
                
                btn.selected = !btn.selected;
                [videoSession setMute:btn.selected];
            }
        }
            break;
        case 102:
        {
            //挂断
            if(videoSession && [videoSession isConnected]) {
                SYLog(@"videoSession 存在  连接");
                [videoSession hangUpCall];
                // releases session
                [NgnAVSession releaseSession:&videoSession];
                // starts timer suicide
                [NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
                                                 target:self
                                               selector:@selector(timerSuicideTick:)
                                               userInfo:nil
                                                repeats:NO];
                
            }
            else if(videoSession && ![videoSession isConnected]) {
                SYLog(@"videoSession 存在  但未连接");
//                [videoSession hangUpCall];
//                videoSession.connectionState = CONN_STATE_CONNECTED;
                // releases session
                
                [videoSession setSpeakerEnabled:YES];
                [videoSession setMute:YES];

                [NgnAVSession releaseSession:&videoSession];
                // starts timer suicide
                [NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
                                                 target:self
                                               selector:@selector(timerSuicideTick:)
                                               userInfo:nil
                                                repeats:NO];
                
            }
            else {
                SYLog(@"videoSession 为空  挂断不起作用");
                [NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
                                                 target:self
                                               selector:@selector(timerSuicideTick:)
                                               userInfo:nil
                                                repeats:NO];
                
                [self performSelector:@selector(releaseSessionAfterDelay) withObject:nil afterDelay:2];
            }
            
            
        }
            break;
        case 103:
        {
//            btn.selected = !btn.selected;
            //免提
//            if(videoSession) {
//                [videoSession setSpeakerEnabled:btn.selected];
//                if([[NgnEngine sharedInstance].soundService setSpeakerEnabled:[videoSession isSpeakerEnabled]]){
//                }
//            }
            
            if(!videoSession || ![videoSession isConnected]){
                NSLog(@"视频还没加载完成");
                return;
            }
            
            [videoSession setSpeakerEnabled:![videoSession isSpeakerEnabled]];
            if([[NgnEngine sharedInstance].soundService setSpeakerEnabled:[videoSession isSpeakerEnabled]]){
                btn.selected = [videoSession isSpeakerEnabled];
            }
            
        }
            break;
            
        default:
            break;
    }
}

-(void)releaseSessionAfterDelay{
    [self selectBtn:_buttonEnd];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    SYLog(@"LookEntranceVedioViewController dealloc");
    
    [_glViewVideoRemote release];
    [viewLocalVideo release];
    [_TLabel release];
    [_bgImageView release];
    [_vedioImageView release];
    
    [_timekeepingLabel release];
    [_slideScr release];

    [_timekeepingLabel release];
    [_vedioImageView release];

    [_slideScr removeFromSuperview];
    [_slideScr release];
    _slideScr.myDelegate = nil;
    
    [_buttonEnd release];
    [_buttonHangUp release];
    [_buttonMute release];
    [_domain_sn release];
    [_sipnum release];
    
    [_timer invalidate];
    _timer = nil;
    [_vedioAniImageView release];
    [_viewLocalVideo release];
    [_videoBgView release];
    
    if (_dismiss) [_dismiss release];
    
    [super dealloc];
}


-(void)RequestFinish{
    SYLog(@"请求结束");
    _vedioAniImageView.hidden = NO;
    _slideScr.contentOffset = CGPointMake(_slideScr.frame.size.width, 0);
}



-(void) onInviteEvent:(NSNotification*)notification {
    
    @synchronized (self) {
        NgnInviteEventArgs* eargs = [notification object];
        if(!videoSession || videoSession.id != eargs.sessionId){
            return;
        }
        
        if (!eargs.otherIsOnLine) {
            _TLabel.text = @"对方不在线...";
            isOnLine = NO;
            _dismiss = [PSTAlertController presentDismissableAlertWithTitle:@"⚠️\n" message:@"对方不在线，请稍后尝试！" controller:self];
            

        }
        
        if (eargs.otherNotAnswer) {
            _TLabel.text = @"对方没有接听...";
            NSLog(@"!!!!对方没有接听");
       
        }
        
        switch (eargs.otherInCallstate) {
            case OTHER_DEFAULT:{
                
                break;
            }
                
            case OTHER_ANSWER_NOT:{
                //"对方没有接听";
                break;
            }
                
            case OTHER_ANSWER_OR_REJECT:{
                //"对方接听或拒绝";
                
                break;
            }
                
            case OTHER_REJECT:{
                //"对方拒接";

            }
        }
        
        
        
        switch (eargs.eventType) {
            case INVITE_EVENT_INPROGRESS:
            case INVITE_EVENT_INCOMING:
            case INVITE_EVENT_RINGING:
            default:
            {
                // updates status info
                [self updateViewAndState];
                
                // video session
                [NgnCamera setPreview:_glViewVideoRemote];
                if(sendingVideo){
                    [videoSession setRemoteVideoDisplay:nil];
                    [videoSession setLocalVideoDisplay:viewLocalVideo];
                    
                }
                
                break;
            }
                
            case INVITE_EVENT_CONNECTED:
                //            [videoSession setSpeakerEnabled:NO];
                [videoSession toggleCamera];
                [videoSession toggleCamera];
                [videoSession setSpeakerEnabled:YES];
                [videoSession setMute:YES];
                
            case INVITE_EVENT_EARLY_MEDIA:
                
                
            case INVITE_EVENT_MEDIA_UPDATED:
            {
                // updates status info 1
                [self updateViewAndState];
                
                // video session
                [self updateVideoOrientation];
                
                if (sendingVideo) {
                    [videoSession setLocalVideoDisplay:viewLocalVideo];
                }
                
                [NgnCamera setPreview:nil];
                [videoSession setRemoteVideoDisplay:_glViewVideoRemote];
                [self updateRemoteDeviceInfo];
                [self sendDeviceInfo];
                
                [self startTime];
                
                break;
            }
                
            case INVITE_EVENT_REMOTE_DEVICE_INFO_CHANGED:
            {
                [self updateRemoteDeviceInfo];
                break;
            }
                
            case INVITE_EVENT_TERMINATED:
            case INVITE_EVENT_TERMWAIT:
            {
                // stops QoS timer
                if (_timer) {
                    [_timer invalidate];
                    _timer = nil;
                }
                
                
                
//                dispatch_source_cancel(_timer);
                
                // updates status info
                [self updateViewAndState];
                
                // video session
                if(videoSession){
                    [videoSession setRemoteVideoDisplay:nil];
                    [videoSession setLocalVideoDisplay:nil];
                }
                [_glViewVideoRemote stopAnimation];
                //                [NgnCamera setPreview:_glViewVideoRemote];
                
                // releases session
                [NgnAVSession releaseSession:&videoSession];
                // starts timer suicide
                
                
                if (!isOnLine) {
                    [_dismiss addDidDismissBlock:^(PSTAlertAction * _Nonnull action) {
                        [NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
                                                         target:self
                                                       selector:@selector(timerSuicideTick:)
                                                       userInfo:nil
                                                        repeats:NO];
                    }];

                }
                else{
                    [NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
                                                     target:self
                                                   selector:@selector(timerSuicideTick:)
                                                   userInfo:nil
                                                    repeats:NO];
                }
                
                
                
                break;
            }
        }
    }
    
    
}


-(void) updateViewAndState{
    if(videoSession){
        switch (videoSession.state) {
            case INVITE_STATE_INPROGRESS:
            {
                //@"视频请求中...";
                _glViewVideoRemote.hidden = YES;
                
                break;
            }
            case INVITE_STATE_INCOMING:
            {
                
                _glViewVideoRemote.hidden = YES;
                //@"视频来电..."
                
                break;
            }
            case INVITE_STATE_REMOTE_RINGING:
            {
                
                _glViewVideoRemote.hidden = YES;
                [videoSession setSpeakerEnabled:YES];
                [videoSession setMute:YES];
                //@"正在视频通话...";
                
                [videoSession toggleCamera];
                [videoSession toggleCamera];
                
                [[[NgnEngine sharedInstance] getSoundService] stopRingTone];
                [[[NgnEngine sharedInstance] getSoundService] stopRingBackTone];
                
                //                if(sendingVideo){
                //                    [videoSession setLocalVideoDisplay:viewLocalVideo];
                //                }
                
                break;
            }
            case INVITE_STATE_INCALL:
            {
                [SVProgressHUD dismiss];
                _glViewVideoRemote.hidden = NO;
                //@"正在视频通话...";
                
                [[NgnEngine sharedInstance].soundService setSpeakerEnabled:[videoSession isSpeakerEnabled]];
                
                [[[NgnEngine sharedInstance] getSoundService] stopRingTone];
                [[[NgnEngine sharedInstance] getSoundService] stopRingBackTone];
                break;
            }
            case INVITE_STATE_TERMINATED:
            case INVITE_STATE_TERMINATING:
            {
                
                //@"视频结束中...";
                _glViewVideoRemote.hidden = YES;
                
                [[NgnEngine sharedInstance].soundService stopRingBackTone];
                [[NgnEngine sharedInstance].soundService stopRingTone];
                break;
            }
            default:
                break;
        }
    }
}

-(void) closeView{
//    [SVProgressHUD dismiss];
    [NgnCamera setPreview:nil];
    
//    dispatch_source_cancel(_timer);
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void) updateVideoOrientation{
    if(videoSession){
        if(![videoSession isConnected]){
            [NgnCamera setPreview:_glViewVideoRemote];
        }
#if 0 // @deprecated
        switch ([UIDevice currentDevice].orientation) {
            case UIInterfaceOrientationPortrait:
                [videoSession setOrientation:AVCaptureVideoOrientationPortrait];
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                [videoSession setOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
                break;
            case UIInterfaceOrientationLandscapeLeft:
                [videoSession setOrientation:AVCaptureVideoOrientationLandscapeLeft];
                break;
            case UIInterfaceOrientationLandscapeRight:
                [videoSession setOrientation:AVCaptureVideoOrientationLandscapeRight];
                break;
        }
#endif
    }
#if 0 // @deprecated
    if(glViewVideoRemote){
        [glViewVideoRemote setOrientation:[UIDevice currentDevice].orientation];
    }
#endif
}

-(void) updateRemoteDeviceInfo{
    BOOL deviceOrientPortrait = [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown;
    switch(videoSession.remoteDeviceInfo.orientation)
    {
        case NgnDeviceInfo_Orientation_Portrait:
            [_glViewVideoRemote setContentMode:UIViewContentModeScaleAspectFill];
            if(!deviceOrientPortrait){
#if 0
#endif
            }
            break;
        case NgnDeviceInfo_Orientation_Landscape:
            [_glViewVideoRemote setContentMode:UIViewContentModeCenter];
            if(deviceOrientPortrait){
#if 0
                CGAffineTransform landscapeTransform = CGAffineTransformMakeRotation(degreesToRadian(90));
                landscapeTransform = CGAffineTransformTranslate(landscapeTransform, +90.0, +90.0);
                [_view setTransform:landscapeTransform];
#endif
            }
            break;
    }
}

-(void) sendDeviceInfo{
    if([[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_SEND_DEVICE_INFO]){
        if(videoSession){
            NSString* content = nil;
            switch ([[UIDevice currentDevice] orientation]) {
                case UIDeviceOrientationPortrait:
                case UIDeviceOrientationPortraitUpsideDown:
                    content = @"orientation:portrait\r\nlang:fr-FR\r\n";
                    break;
                default:
                    content = @"orientation:landscape\r\nlang:fr-FR\r\n";
                    break;
            }
            [videoSession sendInfoWithContentString:content contentType:kContentDoubangoDeviceInfo];
        }
    }
}


-(void)timerSuicideTick:(NSTimer*)timer{
    _TLabel.text = @"已结束...";
    [self performSelectorOnMainThread:@selector(closeView) withObject:nil waitUntilDone:NO];
}

@end

