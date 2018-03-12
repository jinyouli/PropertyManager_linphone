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
#import "AudioCallViewController.h"
#import <QuartzCore/QuartzCore.h>

/*=== AudioCallViewController (Private) ===*/
@interface AudioCallViewController(Private)
-(void) closeView;
-(void) updateViewAndState;
@end
/*=== AudioCallViewController (Timers) ===*/
@interface AudioCallViewController (Timers)
-(void)timerInCallTick:(NSTimer*)timer;
-(void)timerSuicideTick:(NSTimer*)timer;

@end
/*=== AudioCallViewController (SipCallbackEvents) ===*/
@interface AudioCallViewController(SipCallbackEvents)
-(void) onInviteEvent:(NSNotification*)notification;
@end

// private properties
@interface AudioCallViewController()
/** 是否获取事件*/
@property (nonatomic,strong) ContactModel * ContactModel;


@end

//
//	AudioCallViewController(Private)
//
@implementation AudioCallViewController(Private)

-(void) closeView{
    [[NgnEngine sharedInstance].soundService stopRingBackTone];
    [[NgnEngine sharedInstance].soundService stopRingTone];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) setupDisturb{
    // 勿扰模式
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

-(void) updateViewAndState{
    
    //[self setupDisturb];
    
    if(audioSession){
        switch (audioSession.state) {
            case INVITE_STATE_INPROGRESS:
            {
                self.labelStatus.text = @"语音请求中...";
                
                self.buttonAccept.hidden = YES;
                self.buttonHangup.hidden = NO;
                
                [self.buttonHangup setTitle:@"结束" forState:kButtonStateAll];
                
                break;
            }
            case INVITE_STATE_INCOMING:
            {
                self.labelStatus.text = @"语音来电...";
                
                
                [self.buttonHangup setTitle:@"挂断" forState:kButtonStateAll];
                self.buttonHangup.hidden = NO;
                
                
                [self.buttonAccept setTitle:@"接受" forState:kButtonStateAll];
                self.buttonAccept.hidden = NO;

                [self.buttonHangup setTitle:@"挂断" forState:UIControlStateNormal];
                
                self.buttonAccept.hidden = NO;
                
                
                [self setupDisturb];

                
                break;
            }
            case INVITE_STATE_REMOTE_RINGING:
            {
                self.labelStatus.text = @"正在语音通话...";
                
                self.buttonAccept.hidden = YES;
                
                [self.buttonHangup setTitle:@"结束" forState:kButtonStateAll];
                self.buttonHangup.hidden = NO;
                
                [audioSession setSpeakerEnabled:YES];
                [[[NgnEngine sharedInstance] getSoundService] stopRingTone];
                [[[NgnEngine sharedInstance] getSoundService] stopRingBackTone];
                break;
            }
            case INVITE_STATE_INCALL:
            {
                self.labelStatus.text = @"正在语音通话...";
                
                self.buttonAccept.hidden = YES;
                self.buttonHangup.hidden = NO;
                
                [[NgnEngine sharedInstance].soundService setSpeakerEnabled:[audioSession isSpeakerEnabled]];
                [[NgnEngine sharedInstance].soundService stopRingBackTone];
                [[NgnEngine sharedInstance].soundService stopRingTone];
                
                break;
            }
            case INVITE_STATE_TERMINATED:
            case INVITE_STATE_TERMINATING:
            {
                self.labelStatus.text = @"语音结束中...";
                
                self.buttonAccept.hidden = YES;
                self.buttonHangup.hidden = YES;
                
                [[NgnEngine sharedInstance].soundService stopRingBackTone];
                [[NgnEngine sharedInstance].soundService stopRingTone];
                break;
            }

            default:
                break;
        }
        
        
    }
}


@end


//
// AudioCallViewController (SipCallbackEvents)
//
@implementation AudioCallViewController(SipCallbackEvents)

-(void) onInviteEvent:(NSNotification*)notification {
    
    NgnInviteEventArgs* eargs = [notification object];
    
    if(!audioSession || audioSession.id != eargs.sessionId){
    }

    if (!eargs.otherIsOnLine) {
        self.labelStatus.text = @"对方不在线...";
        isOnLine = NO;
        self.dismiss = [PSTAlertController presentDismissableAlertWithTitle:@"⚠️\n" message:@"对方不在线，请稍后尝试！" controller:self];
    }
    
    if (eargs.otherNotAnswer) {
         self.labelStatus.text = @"无人接听...";
    }
    
    
    switch (eargs.otherInCallstate) {
        case OTHER_DEFAULT:{
            break;
        }
            
        case OTHER_ANSWER_NOT:{
            self.labelStatus.text = @"无人接听...";
            NSLog(@"~~~~~对方没有接听");
            break;
        }
            
        case OTHER_ANSWER_OR_REJECT:{
            self.labelStatus.text = @"对方接听或拒绝...";
            NSLog(@"~~~~~对方接听或拒绝");
            
            break;
        }
            
        case OTHER_REJECT:{
            self.labelStatus.text = @"对方已挂断...";
            break;
        }
    }
    
    
    
    
    switch (eargs.eventType) {
        case INVITE_EVENT_INPROGRESS:
        case INVITE_EVENT_INCOMING:
        case INVITE_EVENT_RINGING:
        case INVITE_EVENT_LOCAL_HOLD_OK:
        case INVITE_EVENT_REMOTE_HOLD:
        default:
        {
            // updates view and state
            [self updateViewAndState];
            break;
        }
            
            // transilient events
        case INVITE_EVENT_MEDIA_UPDATING:
        {
            [audioSession setSpeakerEnabled:YES];
            self.labelStatus.text = @"语音来电..";
            break;
        }
            
        case INVITE_EVENT_MEDIA_UPDATED:
        {
            self.labelStatus.text = @"语音结束中..";
            break;
        }
            
        case INVITE_EVENT_TERMINATED:
        case INVITE_EVENT_TERMWAIT:
        {
            // updates view and state
            [self updateViewAndState];
            // releases session
            [NgnAVSession releaseSession: &audioSession];
            // starts timer suicide
            
            
            if (!isOnLine) {
                [self.dismiss addDidDismissBlock:^(PSTAlertAction * _Nonnull action) {
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

@end


//
// AudioCallViewController (Timers)
//
@implementation AudioCallViewController (Timers)

-(void)timerInCallTick:(NSTimer*)timer{
    // to be implemented for the call time display
}

-(void)timerSuicideTick:(NSTimer*)timer{
    [self performSelectorOnMainThread:@selector(closeView) withObject:nil waitUntilDone:NO];
}

@end

//
//	AudioCallViewController
//

@implementation AudioCallViewController

-(instancetype)init{
    if (self = [super init]) {
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        [self createDefaultSubviews];
        
        
        isOnLine = YES;
    }
    return self;
}

-(void)createDefaultSubviews{
    
    _bgImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    _bgImageView.userInteractionEnabled = YES;
    _bgImageView.image = [UIImage imageNamed:@"dailBG"];
    [self.view addSubview:_bgImageView];
    
    _myIconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth/2 - 45, 100, 90, 90)];
    _myIconImageView.layer.cornerRadius = _myIconImageView.frame.size.width / 2;
    _myIconImageView.backgroundColor = [UIColor greenColor];
    [_bgImageView addSubview:_myIconImageView];
    
    
    _nameL = [[UILabel alloc]initWithFrame:_myIconImageView.bounds];
    _nameL.textAlignment = NSTextAlignmentCenter;
    _nameL.textColor = [UIColor whiteColor];
    [_myIconImageView addSubview:_nameL];
    
    
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.frame = CGRectMake(0, CGRectGetMaxY(_myIconImageView.frame) + 20, ScreenWidth, 30);
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.font = MiddleFont;
    [_bgImageView addSubview:_nameLabel];
    
    
    _labelStatus = [[UILabel alloc]init];
    _labelStatus.frame = CGRectMake(0, CGRectGetMaxY(_nameLabel.frame) + 30, ScreenWidth, 30);
    _labelStatus.text = @"语音请求中...";
    _labelStatus.textAlignment = NSTextAlignmentCenter;
    _labelStatus.textColor = [UIColor whiteColor];
    _labelStatus.font = LargeFont;
    [_bgImageView addSubview:_labelStatus];
    
    //免提
    _handsFreeBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, ScreenHeight - 60, 45, 30)];
    [_handsFreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_handsFreeBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    _handsFreeBtn.titleLabel.font = MiddleFont;
    [_handsFreeBtn setTitle:@"免提" forState:UIControlStateNormal];
    [_handsFreeBtn addTarget:self action:@selector(handsFreeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bgImageView addSubview:_handsFreeBtn];
    
    
    //静音
    _muteBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - 15 - 45, ScreenHeight - 60, 45, 30)];
    [_muteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_muteBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    _muteBtn.titleLabel.font = MiddleFont;
    [_muteBtn setTitle:@"静音" forState:UIControlStateNormal];
    [_muteBtn addTarget:self action:@selector(muteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bgImageView addSubview:_muteBtn];
    
    
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
    [_bgImageView addSubview:_buttonHangup];
    
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
    [_bgImageView addSubview:_buttonAccept];
    
}

//挂断
- (void) buttonHangupClick{
    
    //挂断
    if(audioSession && [audioSession isConnected]) {
        SYLog(@"videoSession 存在  连接");
        [audioSession hangUpCall];
        // releases session
        [NgnAVSession releaseSession:&audioSession];
        // starts timer suicide
        [NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
                                         target:self
                                       selector:@selector(timerSuicideTick:)
                                       userInfo:nil
                                        repeats:NO];
        
    }
    else if (audioSession && ![audioSession isConnected]){
        SYLog(@"videoSession 存在  但未连接");
        [audioSession hangUpCall];
        [NgnAVSession releaseSession:&audioSession];
        [NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
                                         target:self
                                       selector:@selector(timerSuicideTick:)
                                       userInfo:nil
                                        repeats:NO];
    }
    else{
        SYLog(@"videoSession 为空  挂断不起作用");
        [NSTimer scheduledTimerWithTimeInterval:kCallTimerSuicide
                                         target:self
                                       selector:@selector(timerSuicideTick:)
                                       userInfo:nil
                                        repeats:NO];
    }

}
//接受
- (void) buttonAcceptClick{
    if(audioSession){
        [audioSession acceptCall];
    }
}

//免提
- (void)handsFreeBtnClick:(UIButton *)sender {
    
    [audioSession setSpeakerEnabled:![audioSession isSpeakerEnabled]];
    if([[NgnEngine sharedInstance].soundService setSpeakerEnabled:[audioSession isSpeakerEnabled]]){
        self.handsFreeBtn.selected = [audioSession isSpeakerEnabled];
    }
}

//静音
- (void)muteBtnClick:(UIButton *)sender {
    
//    self.muteBtn.selected = !self.muteBtn.selected;
    
    if([audioSession setMute:![audioSession isMuted]]){
        self.muteBtn.selected = [audioSession isMuted];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
    //监听占线
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(LineISBusy) name:@"LineISBusy" object:nil];
    
}

-(void)LineISBusy{
    NSLog(@"占线");
    
    _dismiss = [PSTAlertController presentDismissableAlertWithTitle:@"⚠️\n" message:@"对方已占线，请稍后尝试！" controller:self];
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
    [audioSession release];
    audioSession = [[NgnAVSession getSessionWithId: self.sessionId] retain];
    if(audioSession){
        [audioSession setSpeakerEnabled:YES];
        [[NgnEngine sharedInstance].soundService setSpeakerEnabled:YES];
    }
    if (audioSession.historyEvent) {
        self.ContactModel = [PMSipTools gainContactModelFromSipNum:audioSession.historyEvent.remoteParty];
    }
    
    isOnLine = YES;
    
    //默认打开免提
    self.handsFreeBtn.selected = YES;
    self.muteBtn.selected = NO;
    
    self.nameLabel.text = _workname;
    self.nameL.text = [PMTools subStringFromString:_workname isFrom:NO];
    
    if (audioSession.state == INVITE_STATE_INCOMING)
    {
        self.labelStatus.text = @"语音来电...";
        
        
        [self.buttonHangup setTitle:@"挂断" forState:kButtonStateAll];
        self.buttonHangup.hidden = NO;
        
        
        [self.buttonAccept setTitle:@"接受" forState:kButtonStateAll];
        self.buttonAccept.hidden = NO;
        
        [self.buttonHangup setTitle:@"挂断" forState:UIControlStateNormal];
        
        self.buttonAccept.hidden = NO;
        
        [self setupDisturb];
    }
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    self.isDail = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [NgnAVSession releaseSession: &audioSession];

    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    SYLog(@"语音通话界面 内存警告");
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {	
    [_labelStatus release];
    [_buttonHangup release];
    [_buttonAccept release];
    [_ContactModel release];
    [_bgImageView release];
    [_dismiss release];
    [_handsFreeBtn release];
    [_muteBtn release];
    [_myIconImageView release];
    [_nameL release];
    [_nameLabel release];
    [_workname release];
    
    [super dealloc];
}


@end
