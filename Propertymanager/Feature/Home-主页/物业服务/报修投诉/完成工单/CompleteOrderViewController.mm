//
//  CompleteOrderViewController.m
//  idoubs
//
//  Created by Momo on 16/6/29.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "CompleteOrderViewController.h"
#import "BottomChatToolView.h"
//文本框
#import "TextViewCustom.h"

#import "AppDelegate.h"

@interface CompleteOrderViewController ()

//回复文本内容
@property (nonatomic,strong) TextViewCustom * descriptionTextView;
//底部工具选项
@property (nonatomic,strong) BottomChatToolView * bottomView;

@property (nonatomic,assign) NSInteger isRequest;

@property (nonatomic,strong) UIView * showView;
@property (nonatomic,strong) UIImageView * showVoiceView;
@property (nonatomic,strong) UILabel * showVoiceLabel;
@property (nonatomic,strong) MBProgressHUD *hub;
@end

@implementation CompleteOrderViewController

#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        
        if (![PMTools isNullOrEmpty:params[@"isFirstSendMgr"]]) {
            self.isFirstSendMgr = params[@"isFirstSendMgr"];
        }
        
        if (![PMTools isNullOrEmpty:params[@"repairs_id"]]) {
            self.repairs_id = params[@"repairs_id"];
        }
        
        if (![PMTools isNullOrEmpty:params[@"section"]]) {
            self.section = [params[@"section"] integerValue];
        }
        
        if (![PMTools isNullOrEmpty:params[@"isProOrderPush"]]) {
            self.isProOrderPush = [params[@"isProOrderPush"] boolValue];
        }
        
    }
    return self;
}




-(void)dealloc{
    SYLog(@"CompleteOrderViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[AppDelegate sharedInstance].photosSelectedViewController removeFromParentViewController];
    [AppDelegate sharedInstance].photosSelectedViewController.view = nil;
    [AppDelegate sharedInstance].photosSelectedViewController = nil;

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
 
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createLeftBarButtonItemWithTitle:@"工单处理结果确认"];
    
    [PMTools removeSelectsPhotos];
    
    //注册键盘监听事件
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardUP:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDown:) name:UIKeyboardWillHideNotification object:nil];
    
    self.isRequest = 0;
    
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
  
    [self createSubviews];
    self.hub = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hub];
    self.hub.label.text = @"正在提交";
}

-(void)ViewTapClick{
    
    [self.view endEditing:YES];
    CGRect newframe = self.bottomView.frame;
    newframe.size.height = 50;
    newframe.origin.y = ScreenHeight - 50 - 64;
    [UIView animateWithDuration:0.2 animations:^{
        self.bottomView.frame = newframe;
    }];
    
    self.bottomView.voiceBtn.selected = NO;
    self.bottomView.talkBtn.enabled = NO;
    self.bottomView.talkBtn.layer.borderColor = lineColor.CGColor;
    [self.bottomView.talkBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.view bringSubviewToFront:self.bottomView];
}

#pragma mark - 键盘上升
-(void)keyboardUP:(NSNotification *)noti{
    SYLog(@"键盘上升");
    
    //获取键盘的高度
    NSDictionary *userInfo = [noti userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    // textView 上升
    CGRect newframe = self.bottomView.frame;
    newframe.size.height = 50;
    newframe.origin.y = ScreenHeight - height - 50 - 64;
    float time = [[noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:time animations:^{
        self.bottomView.frame = newframe;
    }];
    self.bottomView.voiceBtn.selected = NO;
    self.bottomView.talkBtn.enabled = NO;
    self.bottomView.talkBtn.layer.borderColor = lineColor.CGColor;
    [self.bottomView.talkBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.view bringSubviewToFront:self.bottomView];
    
    
}
#pragma mark - 键盘下降
-(void)keyboardDown:(NSNotification *)noti{
    SYLog(@"键盘下降");
    CGRect newframe = self.bottomView.frame;
    newframe.origin.y = ScreenHeight - newframe.size.height - 64;
    float time = [[noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:time animations:^{
        self.bottomView.frame = newframe;
    }];
}


-(void)createSubviews{
    
    UIView * topView = [[UIView alloc]init];
    [self.view addSubview:topView];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ViewTapClick)];
    [topView addGestureRecognizer:tap];
    
    
    // 创建文本框
    if (!iPhone4s) {
        topView.frame = CGRectMake(0, 0, ScreenWidth, 170);
        self.descriptionTextView = [[TextViewCustom alloc] initWithFrame:CGRectMake(10, 10, ScreenWidth - 20, 150)];
    }
    else{
        topView.frame = CGRectMake(0, 0, ScreenWidth, 100);
        self.descriptionTextView = [[TextViewCustom alloc] initWithFrame:CGRectMake(10, 10, ScreenWidth - 20, 80)];
    }
    
    self.descriptionTextView.placehText = @"点击这里输入内容";
    self.descriptionTextView.layer.cornerRadius = 8;
    self.descriptionTextView.layer.borderWidth = 1;
    self.descriptionTextView.layer.borderColor = mainTextColor.CGColor;
    [self.view addSubview:self.descriptionTextView];
    
    
    //相片
    PhotosSelectedViewController * photosVC = [AppDelegate sharedInstance].photosSelectedViewController;
    photosVC.view.frame = CGRectMake(0, CGRectGetMaxY(self.descriptionTextView.frame) + 5, ScreenWidth, 120);
    [self.view addSubview:photosVC.view];
    [self addChildViewController:photosVC];
  
    NSArray * btnTitleArr = @[@"转单",@"完成"];
    NSArray * tLabelArr = @[@"订单需要多人协作 提醒管理员报修单需转派",@"请确保完成后点击确认 订单会交由业主确认"];
    for (int i = 0; i < 2; i ++) {
        
        UILabel * tlabel = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(photosVC.view.frame) + 20 + i * 70, ScreenWidth - 40, 30)];
        tlabel.font = SmallFont;
        tlabel.text = tLabelArr[i];
        tlabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:tlabel];
        
        UIButton * btn1 = [[UIButton alloc]initWithFrame:CGRectMake(20, CGRectGetMidY(tlabel.frame) + 10, ScreenWidth - 40, 30)];
        btn1.layer.cornerRadius = 8;
        btn1.backgroundColor = mainColor;
        btn1.titleLabel.font = LargeFont;
        [btn1 setTitle:btnTitleArr[i] forState:UIControlStateNormal];
        btn1.tag = 1001 + i;
        [btn1 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn1];
    }
    
    
    self.bottomView = [[BottomChatToolView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 64 - 50, ScreenWidth, 50)];
    [self.bottomView myBtnClickBlock:^(NSInteger index, BOOL isUp, NSInteger volume, NSString *myVoiceStr) {
        [self bottomBtnClickWithIndex:index isUp:isUp withVolume:volume withMyVoiceStr:myVoiceStr];
    }];
    
    [self.view addSubview:self.bottomView];
    
    
    self.showView = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth/ 2 - 75, 50, 150, 140)];
    self.showView.backgroundColor = [UIColor grayColor];
    self.showView.alpha = 0.7;
    self.showView.hidden = YES;
    self.showView.layer.cornerRadius = 8;
    [self.view addSubview:self.showView];
    
    self.showVoiceView = [[UIImageView alloc]initWithFrame:CGRectMake(43, 10, 63, 90)];
    self.showVoiceView.image = [UIImage imageNamed:@"1"];
    [self.showView addSubview:self.showVoiceView];
    
    self.showVoiceLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, self.showView.frame.size.height - 25, self.showView.frame.size.width - 40, 25)];
    self.showVoiceLabel.textColor = [UIColor whiteColor];
    self.showVoiceLabel.font = SmallFont;
    self.showVoiceLabel.textAlignment = NSTextAlignmentCenter;
    self.showVoiceLabel.text = @"手指上滑,取消发送";
    [self.showView addSubview:self.showVoiceLabel];
    
    
}

-(void)bottomBtnClickWithIndex:(NSInteger)index isUp:(BOOL)isUp withVolume:(NSInteger)volume withMyVoiceStr:(NSString *)str{
    switch (index) {
        case 1:
        {
            self.showView.hidden = NO;
            self.showVoiceLabel.backgroundColor = [UIColor grayColor];
            self.showVoiceLabel.text = @"手指上滑,取消发送";
            self.showVoiceView.image = [UIImage imageNamed:@"1"];
        }
            break;
            
        case 2:
        {
            self.showView.hidden = YES;
            
            self.descriptionTextView.textView.text = [NSString stringWithFormat:@"%@%@",self.descriptionTextView.textView.text,str];
            if (self.descriptionTextView.textView.text.length == 0) {
                self.descriptionTextView.placehLab.hidden = NO;
            }else{
                self.descriptionTextView.placehLab.hidden = YES;
            }
        }
            break;
            
        case 3:
        {
            self.showView.hidden = YES;
        }
            break;
            
        case 4:
        {
            self.showVoiceLabel.text = @"松开手指，取消发送";
            self.showVoiceLabel.backgroundColor = [UIColor redColor];
            self.showVoiceView.image = [UIImage imageNamed:@"redVoice"];
        }
            break;
            
        case 5:
        {
            self.showVoiceLabel.backgroundColor = [UIColor grayColor];
            self.showVoiceLabel.text = @"手指上滑,取消发送";
            self.showVoiceView.image = [UIImage imageNamed:@"1"];
        }
            break;
            
        case 6:
        {
            //文本获得第一响应 NO键盘弹出  YES键盘收回
            if (isUp) {
                [self.view endEditing:YES];
            }
            else{
                [self.descriptionTextView becomeFirstResponder];
            }
            
        }
            break;
            
        case 7:
        {
            // 收回键盘
            [self.view endEditing:YES];
        }
            break;
            
        case 8:
        {
            //子视图图片相册选择添加图片
            [[AppDelegate sharedInstance].photosSelectedViewController pushImagePickerController];
        }
            break;
            
        case 9:
        {
            //声音检测
            NSString * volumeStr = [NSString stringWithFormat:@"%d",volume/2];
            self.showVoiceView.image = [UIImage imageNamed:volumeStr];
            
        }
            break;
            
        default:
            break;
    }
}

-(void)btnClick:(UIButton *)btn{
    
    NSString * title;
    if (btn.tag == 1001) {
        title = @"确认要转单吗？";
    }
    else{
        title = @"确认完成吗？";
    }
    
    [WJYAlertView showTwoButtonsWithTitle:@"提示" Message:title ButtonType:WJYAlertViewButtonTypeNone ButtonTitle:@"确定" Click:^{

        self.isRequest ++;
        if (self.isRequest == 1) {
            if (btn.tag == 1001) {
                //提醒派单人转单记录
                //保存工单相关信息记录
                [self backLastVCWithType:@"3"];

            }
            else{
                //完成
                if ([self checkNetWork]) {

                    // 状态改变
                    UserManager * user = [UserManagerTool userManager];
                    NSString * url = MyUrl(SYUpdate_order_status);
                    SYLog(@"完成工单状态Url ==== %@",url);

                    NSDictionary * paraDic = @{@"do_type":@"3",@"repairs_id":self.repairs_id,@"worker_id":user.worker_id};
                    //[SVProgressHUD showWithStatus:@"保存记录中"];
                    [self.hub showAnimated:YES];

                    [DetailRequest SYUpdate_order_statusWithParms:paraDic SuccessBlock:^{
                        //保存工单相关信息记录
                        //[SVProgressHUD dismiss];
                        [self.hub hideAnimated:YES];
                        if ([PMTools isNullOrEmpty:self.descriptionTextView.textView.text] && [AppDelegate sharedInstance].photosSelectedViewController.selectedPhotos.count == 0) {
                            //没有内容可以上传
                            //[SVProgressHUD showSuccessWithStatus:@"完成成功"];
                            [SYCommon addAlertWithTitle:@"完成成功"];
                            //返回上一页
                            [self backMyLastVC:@"5"];
                        }
                        else{
                            //[SVProgressHUD showWithStatus:@"上传评论中"];
                            [self.hub showAnimated:YES];
                            [self backLastVCWithType:@"5"];
                        }

                    } FailureBlock:^{
                        //[SVProgressHUD dismiss];
                        [self.hub hideAnimated:YES];
                        self.isRequest = 0;
                    }];

                }

            }

        }


    } ButtonType:WJYAlertViewButtonTypeNone ButtonTitle:@"取消" Click:^{

    }];
    
}

#pragma mark - 上传评论
-(void)backLastVCWithType:(NSString *)type{
    
    if ([self checkNetWork]) {
        
        NSString * imageParms = @"";
        NSArray * images = [AppDelegate sharedInstance].photosSelectedViewController.selectedPhotos;
        if (images.count > 0) {
            imageParms = [SYQiniuUpload QiniuPutImageArray:images complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                NSLog(@"info == %@ \n resp === %@",info,resp);
            }];
        }
        
        // 状态改变
        UserManager * user = [UserManagerTool userManager];
        NSDictionary * paraDic = @{@"repairs_id":self.repairs_id,
                                   @"worker_id":user.worker_id,
                                   @"content":self.descriptionTextView.textView.text,
                                   @"owner":@"2",
                                   @"type":type,
                                   @"image":imageParms};
        
        [DetailRequest SYSave_repairs_recordWithParms:paraDic SuccessBlock:^{
            if ([type isEqualToString:@"3"]) {
                //[SVProgressHUD showSuccessWithStatus:@"转单成功"];
                [SYCommon addAlertWithTitle:@"转单成功"];
            }
            else{
                //[SVProgressHUD showSuccessWithStatus:@"完成成功"];
                [SYCommon addAlertWithTitle:@"完成成功"];
            }
            //返回上一页
            [self backMyLastVC:type];
            
        } FailureBlock:^{
            self.isRequest = 0;
        }];
        
    }
    
    
}


-(void)backMyLastVC:(NSString *)type{
    
    
    if (self.isProOrderPush == YES) {
        //由工单动态进入  成功后返回根页面
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else{
        //由报修单进入 返回上一页
        if ([type integerValue] == 3) {
            //转单

            // 需要逆向传递数据
            if ([self.delegate respondsToSelector:@selector(reverseValue:)]) {
                [self.delegate reverseValue:@{@"type":COMPLETEORDERTYPE,@"repairs_id":self.repairs_id,@"section":@(self.section)}];
            }
            
        }
        else{
            // 返回前发通知跳转到完成
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeScrollerViewX" object:@"2"];
            //删除已完成我的订单一条信息
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteOneDataFromMyDoing" object:@(self.section)];
            //发通知 -- 刷新数据并打开第一条
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getDataFromMyFinish" object:nil];
            
        }
        
        // 返回上一页
        [self.navigationController popViewControllerAnimated:YES];
        
    }

}

@end
