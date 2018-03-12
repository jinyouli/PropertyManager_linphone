//
//  OwnerViewController.m
//  idoubs
//
//  Created by Momo on 16/6/24.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "OwnerViewController.h"
#import <MessageUI/MessageUI.h>
#import "CallViewController.h"
#import "ContactInfoView.h"
#import "ContactModel.h"

@interface OwnerViewController ()<MFMessageComposeViewControllerDelegate>
{
    CGFloat btnWidth;
}
@property (nonatomic,strong) UIView * topView;
@property (nonatomic,strong) UIView * bottomView;
@property (nonatomic,strong) NSArray * contentArr;
@property (nonatomic,strong) NSArray * contentImgArr;

@property (nonatomic,assign) NSInteger sipRegCount;
@property (nonatomic,assign) NSInteger type;


@end

@implementation OwnerViewController

#pragma mark - life cycle
#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        
        if (![PMTools isNullOrEmpty:params[@"isOwner"]]) {
            self.isOwner = [params[@"isOwner"] boolValue];
        }
        
        if (![PMTools isNullOrEmpty:params[@"contactModel"]]) {
            self.contactModel = (ContactModel *)params[@"contactModel"];
        }
        
        if (![PMTools isNullOrEmpty:params[@"ownerName"]]) {
            self.ownerName = params[@"ownerName"];
        }
        
        if (![PMTools isNullOrEmpty:params[@"ownerPhone"]]) {
            self.ownerPhone = params[@"ownerPhone"];
        }
        
        if (![PMTools isNullOrEmpty:params[@"ownerAddr"]]) {
            self.ownerAddr = params[@"ownerAddr"];
        }
        
        if (self.isOwner) {
            self.contentArr = @[@"电话",@"短信"];
            self.contentImgArr = @[@"cDail",@"cmessage"];
        }else{
            self.contentArr = @[@"消息",@"语音",@"视频",@"电话",@"添加"];
            self.contentImgArr = @[@"cmessage",@"cAudio",@"cVideo",@"cDail",@"home_add"];
        }
        
        self.sipRegCount = 0;
        btnWidth = (ScreenWidth - 20 * 2 - 30 * 3) * 0.25;
        self.view.backgroundColor = [PMTools colorFromHexRGB:@"fafafa"];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.sipRegCount = 0;
    self.type = -1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createLeftBarButtonItemWithTitle:self.isOwner?self.ownerName:self.contactModel.fworkername];
    
    [self.view addSubview:self.topView];
    [self.view addSubview:self.bottomView];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
    
}

#pragma mark - Delegate 实现方法
#pragma mark - MFMessageComposeViewControllerDelegate
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultSent:
            //信息传送成功
            
            break;
        case MessageComposeResultFailed:
            //信息传送失败
            
            break;
        case MessageComposeResultCancelled:
            //信息被用户取消传送
            
            break;
        default:
            break;
    }
}


#pragma mark - event response
-(void)contentBtnClick:(UIButton *)btn{
    
    NSInteger index = btn.tag - 5000;
    
    switch (index) {
        case 0:
        {
            if (self.isOwner) {
                // 给业主拨打电话
                [PMTools callPhoneNumber:self.ownerPhone inView:self.view];
            }
            else{
                // 联系人sip-短信
                self.type = 0;
                
                if (![PMTools isNullOrEmpty:self.contactModel.user_sip]) {
                    
                    if(![self cheakSip])
                        return;
                    
                    [[NgnEngine sharedInstance].historyService load];
                    NSString * strSip = [NSString stringWithFormat:@"%@",self.contactModel.user_sip];
                    
                    [[Routable sharedRouter] open:MYNEWSCHAT_VIEWCONTROLLER animated:YES extraParams:@{@"myRemoteParty":strSip,@"name":self.contactModel.fworkername}];
                }
                else{
                    [self createAlertWithMessage:@"未查询到该联系人相关信息"];
                }
                
            }
        }
            break;
        case 1:
        {
            
            if (self.isOwner) {
                // 给业主发手机短信
                [self showMessageView:@[self.ownerPhone] title:@"" body:@""];
            }
            else{
                // 联系人sip-语音
                self.type = 1;
                if (![PMTools isNullOrEmpty:self.contactModel.user_sip]) {
                    if(![self cheakSip])
                        return;
                    NSString * sipNum = [NSString stringWithFormat:@"%@",self.contactModel.user_sip];
                    [CallViewController makeAudioCallWithRemoteParty:sipNum andSipStack:[[NgnEngine sharedInstance].sipService getSipStack] withName:self.contactModel.fworkername];
                }
                else{
                    [self createAlertWithMessage:@"未查询到该联系人相关信息"];
                }
                
            }
        }
            break;
        case 2:
        {
            // 联系人sip-视频
            self.type = 2;
            if (![PMTools isNullOrEmpty:self.contactModel.user_sip]) {
                
                if(![self cheakSip])
                    return;
                
                NSString * sipNum = [NSString stringWithFormat:@"%@",self.contactModel.user_sip];
                [CallViewController makeAudioVideoCallWithRemoteParty:sipNum  andSipStack: [[NgnEngine sharedInstance].sipService getSipStack] withName:self.contactModel.fworkername];
            }
            else{
                [self createAlertWithMessage:@"未查询到该联系人相关信息"];
            }
            
            
            
        }
            break;
        case 3:
        {
            // 联系人拨打电话
            [PMTools callPhoneNumber:self.contactModel.fusername inView:self.view];
        }
            break;
        case 4:
        {
            // 联系人增加
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateContact" object:self.contactModel];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - notify 注册事件
-(void) onRegistrationEvent:(NSNotification*)notification {
    
    NgnRegistrationEventArgs* eargs = [notification object];
    SYLog(@"entrance ---- 注册事件 ----  %@",[[NgnEngine sharedInstance].sipService isRegistered]?@"YES":@"NO");
    switch (eargs.eventType) {
        case REGISTRATION_NOK:
            //注册失败
            break;
        case UNREGISTRATION_OK:
            //未注册 （掉线)
            if ([self checkNetWork]) {
                self.sipRegCount ++;
                if (self.sipRegCount <= 5) {
                    [PMSipTools sipRegister];
                }
                else{
                    [self createAlert];
                }
            }
            else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ([self checkNetWork]) {
                        self.sipRegCount ++;
                        if (self.sipRegCount <= 5) {
                            //去注册
                            [PMSipTools sipRegister];
                        }
                        else{
                            [self createAlert];
                        }
                    }
                    
                });
            }
            
            break;
        case REGISTRATION_OK:
            //已注册
            self.sipRegCount = 0;
            SYLog(@"注册后短信  语音  或  视频");
            switch (self.type) {
                case 0:
                {
                    //短信
                    [[NgnEngine sharedInstance].historyService load];
                    NSString * strSip = [NSString stringWithFormat:@"%@",self.contactModel.user_sip];
                    
                    [[Routable sharedRouter] open:MYNEWSCHAT_VIEWCONTROLLER animated:YES extraParams:@{@"myRemoteParty":strSip,@"name":self.contactModel.fworkername}];
                }
                    break;
                case 1:
                {
                    //语音
                    NSString * sipNum = [NSString stringWithFormat:@"%@",self.contactModel.user_sip];
                    [CallViewController makeAudioCallWithRemoteParty:sipNum andSipStack:[[NgnEngine sharedInstance].sipService getSipStack] withName:self.contactModel.fworkername];
                }
                    break;
                    
                case 2:
                {
                    //视频
                    NSString * sipNum = [NSString stringWithFormat:@"%@",self.contactModel.user_sip];
                    [CallViewController makeAudioVideoCallWithRemoteParty:sipNum  andSipStack: [[NgnEngine sharedInstance].sipService getSipStack] withName:self.contactModel.fworkername];
                }
                    break;

            }

            break;
        case REGISTRATION_INPROGRESS:
            //正在注册
            break;
        case UNREGISTRATION_INPROGRESS:
            //正在注销
            break;
        case UNREGISTRATION_NOK:
            //未注销失败
            break;
    }
    
}

#pragma mark - private methods
-(void)createAlert{
    NSString * content = @"";
    if (self.type == 0) {
        // 短信
        content = @"出了点小状况，改用短信联系吧~";
    }
    else{
        content = @"出了点小状况，改用电话联系吧~";
    }
    
    [self.view endEditing:YES];
    [WJYAlertView showTwoButtonsWithTitle:@"提示" Message:content ButtonType:WJYAlertViewButtonTypeNone ButtonTitle:@"确定" Click:^{
        
        if (self.type == 0) {
            [self showMessageView:@[self.contactModel.fusername] title:@"" body:@""];
        }
        else{
            [PMTools callPhoneNumber:self.contactModel.fusername inView:self.view];
        }
        
        
    } ButtonType:WJYAlertViewButtonTypeNone ButtonTitle:@"取消" Click:^{
        
    }];
}


-(BOOL)cheakSip{
    
    if (![self checkNetWork]) {
        self.type = -1;
        return NO;
    }
    
    if ([[NgnEngine sharedInstance].sipService isRegistered]){
        
        return YES;
    }
    else{
        [PMSipTools sipRegister];
        
        return NO;
    }
    
    
}

#pragma mark - 发送短信
-(void)showMessageView:(NSArray *)phones title:(NSString *)title body:(NSString *)body
{
    if( [MFMessageComposeViewController canSendText] )
    {
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
        controller.recipients = phones;
        controller.navigationBar.tintColor = ITextColor;
        controller.body = body;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:title];//修改短信界面标题
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"该设备不支持短信功能"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}


#pragma mark - getters and setters
- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 170)];
        _topView.backgroundColor = mainColor;
        
        CGFloat contactY = self.isOwner?_topView.frame.size.height - 60 : _topView.frame.size.height - 80;
        NSString * workName = self.isOwner?@"业主":self.contactModel.fworkername;
        NSString * department = self.isOwner?self.ownerPhone:self.contactModel.fdepartmentname;
        ContactInfoView * contactView = [[ContactInfoView alloc]initWithPoint:CGPointMake(0, contactY) withWorkName:workName department:department colorArr:@[[UIColor cyanColor],[UIColor whiteColor],[UIColor whiteColor]]];
        [_topView addSubview:contactView];
        
        UILabel * userLabel = [[UILabel alloc]init];
        if (self.isOwner) {
            userLabel.frame = CGRectMake(20, 30, ScreenWidth - 40, 20);
            userLabel.font = [UIFont systemFontOfSize:20];
            userLabel.text = self.ownerAddr;
            userLabel.textAlignment = NSTextAlignmentCenter;
        }
        else{
            userLabel.frame = CGRectMake(70, CGRectGetMaxY(contactView.frame) + 5, 120, 20);
            userLabel.font = LargeFont;
            userLabel.text = self.contactModel.fusername;
            userLabel.textAlignment = NSTextAlignmentLeft;
        }
        userLabel.textColor = [UIColor whiteColor];
        [_topView addSubview:userLabel];
    }
    return _topView;
}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 170, ScreenWidth, ScreenHeight - 64 - 170)];
        CGFloat padding = 30;
        if (iPhone4s) {
            padding = 15;
        }
        for (int i = 0; i < self.contentArr.count; i ++) {
            UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(20 + (btnWidth + 30) * (i % 4),padding + (btnWidth + 30 + 10) * (i/4), btnWidth, btnWidth)];
            btn.layer.cornerRadius = btnWidth / 2;
            btn.backgroundColor = mainColor;
            [btn setBackgroundImage:[UIImage imageNamed:self.contentImgArr[i]] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(contentBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 5000 + i;
            [_bottomView addSubview:btn];
            
            CGRect frame = btn.frame;
            frame.origin.y += btnWidth + 5;
            frame.size.height = 30;
            UILabel * label = [[UILabel alloc]initWithFrame:frame];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = self.contentArr[i];
            label.textColor = mainTextColor;
            [_bottomView addSubview:label];
            if (!self.isOwner && i == self.contentArr.count - 1) {
                MyFMDataBase * database = [MyFMDataBase shareMyFMDataBase];
                NSArray * arr = [database selectDataWithTableName:StorageInfo withDic:@{@"worker_id":self.contactModel.worker_id}];
                SYLog(@"%@",arr);
                if (arr.count > 0) {
                    //表明已经被添加 此时显示删除
                    [btn setBackgroundImage:[UIImage imageNamed:@"cDelete"] forState:UIControlStateNormal];
                    label.text = @"删除";
                }
            }
            
        }

    }
    return _bottomView;
}


@end
