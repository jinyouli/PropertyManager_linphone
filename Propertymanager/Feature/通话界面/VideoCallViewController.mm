/* Copyright (C) 2010-2011, Mamadou Diop.
 * Copyright (c) 2011, Doubango Telecom. All rights reserved.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango(dot)org>
 *
 * This file is part of iDoubs Project ( http://code.google.com/p/idoubs )
 *
 * idoubs is free software: you can redistribute it and/or modify it under the terms of
 * the GNU General Public License as published by the Free Software Foundation, either version 3
 * of the License, or (at your option) any later version.
 *
 * idoubs is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 */
#import "VideoCallViewController.h"

#import <QuartzCore/QuartzCore.h> /* cornerRadius... */

#define degreesToRadian(x) (M_PI * (x) / 180.0)

@interface VideoCallViewController()
/** 是否获取事件*/
@property (nonatomic,strong) ContactModel * ContactModel;
@property (nonatomic, assign) SYLinphoneCall *call;
@property (nonatomic, strong) SYLockListModel *model;
@property (nonatomic, assign) BOOL isInComingCall;
@property (nonatomic, strong) UIView *glViewVideoRemote;

-(void) showBottomView: (UIView*)view_ shouldRefresh:(BOOL)refresh;
@end

@implementation VideoCallViewController

-(instancetype)init{
    if (self = [super init]) {
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        
        self->sendingVideo = YES;
        isOnLine = YES;
        
       // [self createDefaultSubviews];
    }
    return self;
}

- (instancetype)initWithCall:(SYLinphoneCall *)call GuardInfo:(SYLockListModel *)model InComingCall:(BOOL)isInComingCall{
    
    if (self == [super init]) {
        self.call = call;
        self.model = model;
        self.isInComingCall = isInComingCall;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // listen to the events
    //    [[NSNotificationCenter defaultCenter]
    //     addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
    
    //监听占线
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(LineISBusy) name:@"LineISBusy" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(linphoneCallUpdate:) name:kSYLinphoneCallUpdate object:nil];
    
    [self createDefaultSubviews];
    [self configData];
}

#pragma mark - private
- (void)configData{

    if (self.isInComingCall) {
        
    }
    else {
        
        [[SYLinphoneManager instance] call:self.model.sip_number displayName:@"测试" transfer:NO Video:self.glViewVideoRemote];
    }
    
    linphone_core_set_native_preview_window_id(LC, (__bridge void *)(_viewLocalVideo));
}

-(void)createDefaultSubviews{
    _bgImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    _bgImageView.userInteractionEnabled = YES;
    _bgImageView.image = [UIImage imageNamed:@"dailBG"];
    [self.view addSubview:_bgImageView];

    //viewTop
    _viewTop = [[UIView alloc]initWithFrame:self.view.bounds];
    _viewTop.backgroundColor = [UIColor clearColor];
    _viewTop.frame = self.view.bounds;
    
    
    _myIconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth/2 - 45, 100, 90, 90)];
    _myIconImageView.layer.cornerRadius = _myIconImageView.frame.size.width / 2;
   _myIconImageView.backgroundColor = [UIColor greenColor];
    [self.viewTop addSubview:_myIconImageView];
    
    
    _nameL = [[UILabel alloc]initWithFrame:_myIconImageView.bounds];
    _nameL.textAlignment = NSTextAlignmentCenter;
    _nameL.textColor = [UIColor whiteColor];
    [self.myIconImageView addSubview:_nameL];
  
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.frame = CGRectMake(0, CGRectGetMaxY(_myIconImageView.frame) + 20, ScreenWidth, 30);
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.font = MiddleFont;
    [self.viewTop addSubview:_nameLabel];
   
    _labelStatus = [[UILabel alloc]init];
    _labelStatus.frame = CGRectMake(0, CGRectGetMaxY(_nameLabel.frame) + 30, ScreenWidth, 30);
    _labelStatus.text = @"语音请求中...";
    _labelStatus.textAlignment = NSTextAlignmentCenter;
    _labelStatus.textColor = [UIColor whiteColor];
    _labelStatus.font = LargeFont;
    [self.viewTop addSubview:_labelStatus];

    //免提
    _handsFreeBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, ScreenHeight - 60, 45, 30)];
    [_handsFreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_handsFreeBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    _handsFreeBtn.titleLabel.font = MiddleFont;
    [_handsFreeBtn setTitle:@"免提" forState:UIControlStateNormal];
    [_handsFreeBtn addTarget:self action:@selector(handsFreeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewTop addSubview:_handsFreeBtn];
    
    
    //静音
    _muteBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - 15 - 45, ScreenHeight - 60, 45, 30)];
    [_muteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_muteBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    _muteBtn.titleLabel.font = MiddleFont;
    [_muteBtn setTitle:@"静音" forState:UIControlStateNormal];
    [_muteBtn addTarget:self action:@selector(muteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewTop addSubview:_muteBtn];
    
    
    //挂断
    _buttonHangup = [[UIButton alloc]init];
    CGFloat frameX = CGRectGetMaxX(_handsFreeBtn.frame) + 20;
    _buttonHangup.frame = CGRectMake(frameX,ScreenHeight - 60,CGRectGetMinX(_muteBtn.frame) - 20 - frameX,30);
    [_buttonHangup setTitle:@"挂断" forState:UIControlStateNormal];
    [_buttonHangup addTarget:self action:@selector(buttonHangupClick) forControlEvents:UIControlEventTouchUpInside];
    [_buttonHangup setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    _buttonHangup.titleLabel.font = MiddleFont;
    _buttonHangup.layer.cornerRadius = 15;
    _buttonHangup.layer.borderWidth = 1.f;
    _buttonHangup.layer.borderColor = [[UIColor redColor] CGColor];
    [self.viewTop addSubview:_buttonHangup];
    
    //接受
    _buttonAccept = [[UIButton alloc]init];
    _buttonAccept.frame = CGRectMake(frameX,ScreenHeight - 100,CGRectGetMinX(_muteBtn.frame) - 20 - frameX,30);
    [_buttonAccept setTitle:@"接受" forState:UIControlStateNormal];
    [_buttonAccept addTarget:self action:@selector(buttonAcceptClick) forControlEvents:UIControlEventTouchUpInside];
    [_buttonAccept setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    _buttonAccept.titleLabel.font = MiddleFont;
    _buttonAccept.layer.cornerRadius = 15;
    _buttonAccept.layer.borderWidth = 1.f;
    _buttonAccept.layer.borderColor = [[UIColor greenColor] CGColor];
    [self.viewTop addSubview:self.buttonAccept];
    
    
    _viewToolbar = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 60, ScreenWidth, 44)];
    _viewToolbar.hidden = YES;
    [self.view addSubview:_viewToolbar];
    
    //前置后置
    _buttonToolBarToggle = [[UIButton alloc]initWithFrame:CGRectMake(15, 0, 30, 30)];
    _buttonToolBarToggle.titleLabel.font = MiddleFont;
    [_buttonToolBarToggle setTitle:@"后置" forState:UIControlStateNormal];
    [_buttonToolBarToggle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_buttonToolBarToggle setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [_buttonToolBarToggle addTarget:self action:@selector(btnToggleClick) forControlEvents:UIControlEventTouchUpInside];
    [self.viewToolbar addSubview:_buttonToolBarToggle];
    
    //视频中挂断
    _buttonToolBarEnd = [[UIButton alloc]init];
    _buttonToolBarEnd.frame = CGRectMake(60,0, ScreenWidth - 120,30);
    _buttonToolBarEnd.titleLabel.font = MiddleFont;
    [_buttonToolBarEnd setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_buttonToolBarEnd setTitle:@"挂断" forState:UIControlStateNormal];
    _buttonToolBarEnd.layer.borderWidth = 1.f;
    _buttonToolBarEnd.layer.borderColor = [[UIColor redColor] CGColor];
    _buttonToolBarEnd.layer.cornerRadius = 15.f;
    [_buttonToolBarEnd addTarget:self action:@selector(buttonHangupClick) forControlEvents:UIControlEventTouchUpInside];
    [self.viewToolbar addSubview:_buttonToolBarEnd];
    
    //静音
    _buttonToolBarMute = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - 15 - 30, 0, 30, 30)];
    _buttonToolBarMute.titleLabel.font = MiddleFont;
    [_buttonToolBarMute setTitle:@"静音" forState:UIControlStateNormal];
    [_buttonToolBarMute setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_buttonToolBarMute setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [_buttonToolBarMute addTarget:self action:@selector(toolbarMuteClick) forControlEvents:UIControlEventTouchUpInside];
    [self.viewToolbar addSubview:_buttonToolBarMute];
    
    _buttonToolBarEnd.backgroundColor =
    _buttonToolBarMute.backgroundColor =
    _buttonToolBarToggle.backgroundColor =
    [UIColor clearColor];

    // GLView
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.glViewVideoRemote = [[UIView alloc] initWithFrame:screenBounds] ;
    //[self.view insertSubview:self.glViewVideoRemote atIndex:0];
    self.glViewVideoRemote.hidden = YES;
    [self.view addSubview:self.glViewVideoRemote];
    
    [self.view addSubview:_viewTop];
    
    //本地视频图像
    _viewLocalVideo = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth - 74, 20, 64, 86)];
    _viewLocalVideo.layer.borderWidth = 1.f;
    _viewLocalVideo.layer.borderColor = [[UIColor blackColor] CGColor];
    [self.view addSubview:_viewLocalVideo];
    _viewLocalVideo.hidden = NO;
}

-(void)btnToggleClick{
//    if(videoSession){
//        self.buttonToolBarToggle.selected = !self.buttonToolBarToggle.selected;
//        [videoSession toggleCamera];
//    }
}

//挂断
- (void) buttonHangupClick{
    
    [[SYLinphoneManager instance] hangUpCall];
    [self dismissViewControllerAnimated:YES completion:nil];
    
//    if(videoSession && [videoSession isConnected]) {
//        SYLog(@"videoSession 存在  连接");
//        [videoSession hangUpCall];
//        // releases session
//        [NgnAVSession releaseSession:&videoSession];
//        // starts timer suicide
//        [NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
//                                         target:self
//                                       selector:@selector(timerSuicideTick:)
//                                       userInfo:nil
//                                        repeats:NO];
//
//    }
//    else if(videoSession && ![videoSession isConnected]) {
//        SYLog(@"videoSession 存在  但未连接");
//        [videoSession hangUpCall];
//        // releases session
//        [NgnAVSession releaseSession:&videoSession];
//        // starts timer suicide
//        [NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
//                                         target:self
//                                       selector:@selector(timerSuicideTick:)
//                                       userInfo:nil
//                                        repeats:NO];
//
//    }
//    else {
//        SYLog(@"videoSession 为空  挂断不起作用");
//        [NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
//                                         target:self
//                                       selector:@selector(timerSuicideTick:)
//                                       userInfo:nil
//                                        repeats:NO];
//    }

}
//接受
- (void) buttonAcceptClick{
//    if(videoSession){
//        [videoSession acceptCall];
//    }
    
    [[SYLinphoneManager instance] acceptCall:self.call Video:self.glViewVideoRemote];
}

//免提
- (void)handsFreeBtnClick:(UIButton *)sender {
    
//    [videoSession setSpeakerEnabled:![videoSession isSpeakerEnabled]];
//    if([[NgnEngine sharedInstance].soundService setSpeakerEnabled:[videoSession isSpeakerEnabled]]){
//        sender.selected = [videoSession isSpeakerEnabled];
//    }

}

//静音
- (void)muteBtnClick:(UIButton *)sender{
    
//    self.muteBtn.selected = !self.muteBtn.selected;
//    [videoSession setMute:self.muteBtn.selected];
//    self.muteBtn.selected = [videoSession isMuted];
}

// 视频中静音
-(void)toolbarMuteClick{
    self.buttonToolBarMute.selected = !self.buttonToolBarMute.selected;
//    [videoSession setMute:![videoSession isMuted]];
//    self.buttonToolBarMute.selected = [videoSession isMuted];
    [self showBottomView:self.viewToolbar shouldRefresh:YES];
}

-(void)LineISBusy{
    NSLog(@"占线");
    
    
    _dismiss = [PSTAlertController presentDismissableAlertWithTitle:@"⚠️\n" message:@"对方已占线,请稍后尝试" controller:self];
    [_dismiss addDidDismissBlock:^(PSTAlertAction * _Nonnull action) {
        [NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
                                         target:self
                                       selector:@selector(timerSuicideTick:)
                                       userInfo:nil
                                        repeats:NO];
    }];
    
}

-(void)LineISBusyView{
    
    [self performSelectorOnMainThread:@selector(closeView) withObject:nil waitUntilDone:NO];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.isDail = YES;
//    [videoSession release];
//    videoSession = [[NgnAVSession getSessionWithId: self.sessionId] retain];
//    if(videoSession){
//        if([videoSession isConnected]){
//            [videoSession setSpeakerEnabled:YES];
//            [videoSession setRemoteVideoDisplay:self.glViewVideoRemote];
//            [videoSession setLocalVideoDisplay:self.viewLocalVideo];
//        }
//    }
//    [self updateViewAndState];
//    [self updateVideoOrientation];
//    [self updateRemoteDeviceInfo];
    
//    if (videoSession.historyEvent) {
//        self.ContactModel = [PMSipTools gainContactModelFromSipNum:videoSession.historyEvent.remoteParty];
//    }
    isOnLine = YES;
    self.handsFreeBtn.selected = YES;
    self.muteBtn.selected = NO;
    self.buttonToolBarToggle.selected = NO;
    self.buttonToolBarMute.selected = NO;
    
    self.nameLabel.text = _workname;
    self.nameL.text = [PMTools subStringFromString:_workname isFrom:NO];
    
    // 勿扰模式
    isOpenDnd = [[DontDisturbManager shareManager] getDisturbStatusWithUsername:[UserManagerTool userManager].username];
    BOOL isOpen = isOpenDnd;
    BOOL res = [PMSipTools isBetweenTime];
    if (isOpen && res) {
        
        SYLog(@"开启勿扰模式 且 在时间范围内 不打扰");
        [PMSipTools stopRing];
        
    }
    else{
        SYLog(@"没开启勿扰模式");
        [PMSipTools playRing];
        
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
//    if(videoSession && [videoSession isConnected]){
//        [videoSession setRemoteVideoDisplay:nil];
//        [videoSession setLocalVideoDisplay:nil];
//    }
//    [NgnAVSession releaseSession: &videoSession];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.isDail = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   // [NgnCamera setPreview:nil];
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
   // [self updateVideoOrientation];
    
    if(!self.viewToolbar.hidden){
        [self showBottomView:self.viewToolbar shouldRefresh:YES];
    }

    //[self sendDeviceInfo];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
    SYLog(@"视频通话界面 内存警告");
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


//- (void)dealloc {
//
////    [_viewToolbar release];
////    [_nameLabel release];
////    [_labelStatus release];
////
////    [_viewTop release];
////    [_buttonToolBarMute release];
//    [_buttonToolBarEnd release];
//    [_buttonToolBarToggle release];
//
//    [_buttonAccept release];
//    [_buttonHangup release];
//
//    [_glViewVideoRemote release];
//
//    [_timerQoS release];
//
//    [super dealloc];
//}



-(void) showBottomView: (UIView*)view_ shouldRefresh:(BOOL)refresh{
    if(!view_.superview){
        [self.view addSubview:view_];
        refresh = YES;
    }
    
    if(refresh){
        CGRect frame = CGRectMake(0.f, self.view.frame.size.height - view_.frame.size.height,
                                  self.view.frame.size.width, view_.frame.size.height);
        
        frame = CGRectMake(0, ScreenHeight - 60, ScreenWidth, 80);
        view_.frame = frame;
        
        view_.backgroundColor = [UIColor clearColor];
        
        
        if(view_ == self.viewToolbar){
            // update content
            
            //self.buttonToolBarMute.selected = [videoSession isMuted];
            
        }
        
    }
    view_.hidden = NO;
}

-(void) hideBottomView:(UIView*)view_{
    view_.hidden = YES;
}

#pragma mark - notifi
- (void)linphoneCallUpdate:(NSNotification *)notif{
    SYLinphoneCallState state = (SYLinphoneCallState)[[notif.userInfo objectForKey:@"state"] intValue];
    if (state == SYLinphoneCallStreamsRunning) {
        self.glViewVideoRemote.hidden = NO;
        _myIconImageView.hidden = YES;
        _buttonAccept.hidden = YES;
        _labelStatus.hidden = YES;
    }
    else if (state == SYLinphoneCallOutgoingInit){
        
    }
    else if (state == SYLinphoneCallReleased){
        //用户没有主动退出页面，则视频通话结束后，自动退出当前页面
        self.glViewVideoRemote.hidden = YES;
        _myIconImageView.hidden = NO;
        _buttonAccept.hidden = NO;
        _labelStatus.hidden = NO;
        
        [self closeView];
    }
    else if (state == SYLinphoneCallOutgoingEarlyMedia || state == SYLinphoneCallIncomingEarlyMedia){
        
    }
    else if (state == SYLinphoneCallPaused){
        
    }
}

- (void)closeView
{
    [[SYLinphoneManager instance] hangUpCall];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//-(void) updateViewAndState{
//
//    if(videoSession){
//        switch (videoSession.state) {
//            case INVITE_STATE_INPROGRESS:
//            {
//                self.viewTop.hidden = NO;
//                self.bgImageView.hidden = NO;
//                self.labelStatus.text = @"视频请求中...";
//                self.viewLocalVideo.hidden = YES;
//
//
//                [self hideBottomView:self.viewToolbar];
//
//                self.buttonAccept.hidden = YES;
//                self.buttonHangup.hidden = NO;
//
//                CGRect rect = self.buttonHangup.frame;
//                rect.origin.y = self.buttonHangup.frame.origin.y;
//                self.buttonHangup.frame = rect;
//
//                [self.buttonHangup setTitle:@"结束" forState:UIControlStateNormal];
//                break;
//            }
//            case INVITE_STATE_INCOMING:
//            {
//
//
//                self.viewTop.hidden = NO;
//                self.bgImageView.hidden = NO;
//                self.viewLocalVideo.hidden = YES;
//                self.labelStatus.text = @"视频来电...";
//
//                [self hideBottomView:self.viewToolbar];
//
//
//                self.buttonHangup.hidden = NO;
//                [self.buttonHangup setTitle:@"挂断" forState:UIControlStateNormal];
//
//
//                self.buttonAccept.hidden = NO;
//                [self.buttonAccept setTitle:@"接受" forState:UIControlStateNormal];
//
//                // 勿扰模式
//                BOOL isOpen = isOpenDnd;
//                BOOL res = [PMSipTools isBetweenTime];
//                if (isOpen && res) {
//
//                    SYLog(@"开启勿扰模式 且 在时间范围内 不打扰");
//                    [PMSipTools stopRing];
//
//                }
//                else{
//                    SYLog(@"没开启勿扰模式");
//                    [PMSipTools playRing];
//
//                }
//
//                break;
//            }
//            case INVITE_STATE_REMOTE_RINGING:
//            {
//                self.viewTop.hidden = NO;
//                self.bgImageView.hidden = NO;
//                self.viewLocalVideo.hidden = YES;
//                self.labelStatus.text = @"正在视频通话...";
//
//                [self btnToggleClick];
//                [self btnToggleClick];
//
//                [self hideBottomView:self.viewToolbar];
//
//
//                self.buttonAccept.hidden = YES;
//                self.buttonHangup.hidden = NO;
//                [self.buttonHangup setTitle:@"结束" forState:UIControlStateNormal];
//
//
//                [videoSession setSpeakerEnabled:YES];
//                [[[NgnEngine sharedInstance] getSoundService] stopRingTone];
//                [[[NgnEngine sharedInstance] getSoundService] stopRingBackTone];
//
//                if(sendingVideo){
//                    [videoSession setLocalVideoDisplay:_viewLocalVideo];
//                }
//
//                break;
//            }
//            case INVITE_STATE_INCALL:
//            {
//                self.viewTop.hidden = YES;
//                self.bgImageView.hidden = YES;
//                self.viewLocalVideo.hidden = NO;
//                self.labelStatus.text = @"正在视频通话...";
//
//                [self showBottomView:self.viewToolbar shouldRefresh:NO];
//
//                [[NgnEngine sharedInstance].soundService setSpeakerEnabled:[videoSession isSpeakerEnabled]];
//
//                [[[NgnEngine sharedInstance] getSoundService] stopRingTone];
//                [[[NgnEngine sharedInstance] getSoundService] stopRingBackTone];
//                break;
//            }
//            case INVITE_STATE_TERMINATED:
//            {
//                [self buttonHangupClick];
//                [self closeView];
//            }
//            case INVITE_STATE_TERMINATING:
//            {
//                self.viewTop.hidden = NO;
//                self.bgImageView.hidden = NO;
//                self.labelStatus.text = @"视频结束中...";
//                self.viewLocalVideo.hidden = YES;
//
//
//                [self hideBottomView:self.viewToolbar];
//
//                [[NgnEngine sharedInstance].soundService stopRingBackTone];
//                [[NgnEngine sharedInstance].soundService stopRingTone];
//                break;
//            }
//            default:
//                break;
//        }
//    }
//}

//-(void) closeView{
//    [[NgnEngine sharedInstance].soundService stopRingBackTone];
//    [[NgnEngine sharedInstance].soundService stopRingTone];
//    [NgnCamera setPreview:nil];
//    [self dismissViewControllerAnimated:YES completion:nil];
//
//}

//-(void) updateVideoOrientation{
//    if(videoSession){
//        if(![videoSession isConnected]){
//            [NgnCamera setPreview:self.glViewVideoRemote];
//        }
//#if 0 // @deprecated
//        switch ([UIDevice currentDevice].orientation) {
//            case UIInterfaceOrientationPortrait:
//                [videoSession setOrientation:AVCaptureVideoOrientationPortrait];
//                break;
//            case UIInterfaceOrientationPortraitUpsideDown:
//                [videoSession setOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
//                break;
//            case UIInterfaceOrientationLandscapeLeft:
//                [videoSession setOrientation:AVCaptureVideoOrientationLandscapeLeft];
//                break;
//            case UIInterfaceOrientationLandscapeRight:
//                [videoSession setOrientation:AVCaptureVideoOrientationLandscapeRight];
//                break;
//        }
//#endif
//    }
//#if 0 // @deprecated
//    if(glViewVideoRemote){
//        [glViewVideoRemote setOrientation:[UIDevice currentDevice].orientation];
//    }
//#endif
//}
//
//-(void) updateRemoteDeviceInfo{
//    BOOL deviceOrientPortrait = [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown;
//    switch(videoSession.remoteDeviceInfo.orientation)
//    {
//        case NgnDeviceInfo_Orientation_Portrait:
//            [self.glViewVideoRemote setContentMode:UIViewContentModeScaleAspectFill];
//            if(!deviceOrientPortrait){
//#if 0
//#endif
//            }
//            break;
//        case NgnDeviceInfo_Orientation_Landscape:
//            [self.glViewVideoRemote setContentMode:UIViewContentModeCenter];
//            if(deviceOrientPortrait){
//#if 0
//                CGAffineTransform landscapeTransform = CGAffineTransformMakeRotation(degreesToRadian(90));
//                landscapeTransform = CGAffineTransformTranslate(landscapeTransform, +90.0, +90.0);
//                [self.view setTransform:landscapeTransform];
//#endif
//            }
//            break;
//    }
//}
//
//-(void) sendDeviceInfo{
//    if([[NgnEngine sharedInstance].configurationService getBoolWithKey:GENERAL_SEND_DEVICE_INFO]){
//        if(videoSession){
//            NSString* content = nil;
//            switch ([[UIDevice currentDevice] orientation]) {
//                case UIDeviceOrientationPortrait:
//                case UIDeviceOrientationPortraitUpsideDown:
//                    content = @"orientation:portrait\r\nlang:fr-FR\r\n";
//                    break;
//                default:
//                    content = @"orientation:landscape\r\nlang:fr-FR\r\n";
//                    break;
//            }
//            [videoSession sendInfoWithContentString:content contentType:kContentDoubangoDeviceInfo];
//        }
//    }
//}


//-(void) onInviteEvent:(NSNotification*)notification {
//
//    NgnInviteEventArgs* eargs = [notification object];
//
//    if(!videoSession || videoSession.id != eargs.sessionId){
//        return;
//    }
//
//    if (!eargs.otherIsOnLine) {
//        self.labelStatus.text = @"对方不在线...";
//
//        isOnLine = NO;
//        _dismiss = [PSTAlertController presentDismissableAlertWithTitle:@"⚠️\n" message:@"对方不在线，请稍后尝试！" controller:self];
//
//    }
//
//    if (eargs.otherNotAnswer) {
//        self.labelStatus.text = @"对方没有接听...";
//        NSLog(@"!!!!对方没有接听");
//    }
//
//    NSLog(@"状态==%d",eargs.eventType);
//    switch (eargs.eventType) {
//        case INVITE_EVENT_INPROGRESS:
//        case INVITE_EVENT_INCOMING:
//
//
//        case INVITE_EVENT_RINGING:
//        default:
//        {
//            // updates status info
//            [self updateViewAndState];
//
//            // video session
//            [NgnCamera setPreview:self.glViewVideoRemote];
//            if(sendingVideo){
//                [videoSession setRemoteVideoDisplay:nil];
//                [videoSession setLocalVideoDisplay:_viewLocalVideo];
//
//            }
//
//            break;
//        }
//
//
//        case INVITE_EVENT_CONNECTED:
//
//            [self btnToggleClick];
//            [self btnToggleClick];
//            [videoSession setSpeakerEnabled:YES];
//
//        case INVITE_EVENT_EARLY_MEDIA:
//
//
//        case INVITE_EVENT_MEDIA_UPDATED:
//        {
//            // updates status info 1
//            [self updateViewAndState];
//
//            // video session
//            [self updateVideoOrientation];
//
//            [NgnCamera setPreview:nil];
//            [videoSession setRemoteVideoDisplay:self.glViewVideoRemote];
//
//            [self updateRemoteDeviceInfo];
//            [self sendDeviceInfo];
//            // starts QoS timer
//            if (self.timerQoS == nil) {
//                self.timerQoS = [NSTimer scheduledTimerWithTimeInterval:kQoSTimer
//                                                                 target:self
//                                                               selector:@selector(timerQoSTick:)
//                                                               userInfo:nil
//                                                                repeats:YES];
//            }
//            sendingVideo = YES;
//            [videoSession setLocalVideoDisplay:_viewLocalVideo];
//            break;
//        }
//
//        case INVITE_EVENT_REMOTE_DEVICE_INFO_CHANGED:
//        {
//            [self updateRemoteDeviceInfo];
//            break;
//        }
//
//        case INVITE_EVENT_TERMINATED:
//        {
//            // stops QoS timer
//            if (self.timerQoS) {
//                [self.timerQoS invalidate];
//                self.timerQoS = nil;
//            }
//
//            // updates status info
//            [self updateViewAndState];
//
//            // video session
//            if(videoSession){
//                [videoSession setRemoteVideoDisplay:nil];
//                [videoSession setLocalVideoDisplay:nil];
//            }
//            //            [self.glViewVideoRemote stopAnimation];
//            [NgnCamera setPreview:self.glViewVideoRemote];
//
//            // releases session
//            [NgnAVSession releaseSession:&videoSession];
//
//
//            if (!isOnLine) {
//                [_dismiss addDidDismissBlock:^(PSTAlertAction * _Nonnull action) {
//                    [NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
//                                                     target:self
//                                                   selector:@selector(timerSuicideTick:)
//                                                   userInfo:nil
//                                                    repeats:NO];
//                }];
//
//            }
//            else{
//                [NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
//                                                 target:self
//                                               selector:@selector(timerSuicideTick:)
//                                               userInfo:nil
//                                                repeats:NO];
//            }
//
//
//            break;
//        }
//        case INVITE_EVENT_TERMWAIT:
//        {
//            // stops QoS timer
//            if (self.timerQoS) {
//                [self.timerQoS invalidate];
//                self.timerQoS = nil;
//            }
//
//            // updates status info
//            [self updateViewAndState];
//
//            // video session
//            if(videoSession){
//                [videoSession setRemoteVideoDisplay:nil];
//                [videoSession setLocalVideoDisplay:nil];
//            }
//            //            [self.glViewVideoRemote stopAnimation];
//            [NgnCamera setPreview:self.glViewVideoRemote];
//
//            // releases session
//            [NgnAVSession releaseSession:&videoSession];
//
//
//            if (!isOnLine) {
//                [_dismiss addDidDismissBlock:^(PSTAlertAction * _Nonnull action) {
//                    [NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
//                                                     target:self
//                                                   selector:@selector(timerSuicideTick:)
//                                                   userInfo:nil
//                                                    repeats:NO];
//                }];
//
//            }
//            else{
//                [NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
//                                                 target:self
//                                               selector:@selector(timerSuicideTick:)
//                                               userInfo:nil
//                                                repeats:NO];
//            }
//
//
//            break;
//        }
//    }
//
//    switch (eargs.otherInCallstate) {
//        case OTHER_DEFAULT:{
//
//            break;
//        }
//
//        case OTHER_ANSWER_NOT:{
//            //"对方没有接听";
//            [self buttonHangupClick];
//            [self closeView];
//            break;
//        }
//
//        case OTHER_ANSWER_OR_REJECT:{
//            //"对方接听或拒绝";
//
//            break;
//        }
//
//        case OTHER_REJECT:{
//            //"对方拒接";
//            [self buttonHangupClick];
//            [self closeView];
//        }
//    }
//}
//
//-(void)timerInCallTick:(NSTimer*)timer{
//    // to be implemented for the call time display
//}
//
//-(void)timerQoSTick:(NSTimer*)timer{
//    if (videoSession && videoSession.connected) {
//        NgnQoS* ngnQoS = [videoSession videoQoS];
//        if (ngnQoS) {
//        }
//    }
//}

-(void)timerSuicideTick:(NSTimer*)timer{
    [self performSelectorOnMainThread:@selector(closeView) withObject:nil waitUntilDone:NO];
}

@end
