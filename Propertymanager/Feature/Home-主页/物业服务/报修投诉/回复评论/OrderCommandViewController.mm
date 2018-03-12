//
//  OrderCommandViewController.m
//  idoubs
//
//  Created by Momo on 16/6/22.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "OrderCommandViewController.h"
#import "BottomChatToolView.h"
//文本框
#import "TextViewCustom.h"

#import "AppDelegate.h"

@interface OrderCommandViewController ()

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

@implementation OrderCommandViewController


#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        
        if (![PMTools isNullOrEmpty:params[@"type"]]) {
            self.type = [params[@"isOwner"] integerValue];
        }
        
        if (![PMTools isNullOrEmpty:params[@"section"]]) {
            self.section = [params[@"section"] integerValue];
        }
        
        if (![PMTools isNullOrEmpty:params[@"repairs_id"]]) {
            self.repairs_id = params[@"repairs_id"];
        }
        
        if (![PMTools isNullOrEmpty:params[@"fname"]]) {
            self.fname = params[@"fname"];
        }

    }
    return self;
}



-(void)dealloc{
    SYLog(@"OrderCommandViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    self.view = nil;
    [[AppDelegate sharedInstance].photosSelectedViewController removeFromParentViewController];
    [AppDelegate sharedInstance].photosSelectedViewController.view = nil;
    [AppDelegate sharedInstance].photosSelectedViewController = nil;
    
    self.descriptionTextView = nil;
    self.bottomView = nil;
    self.showView = nil;
    self.showVoiceView = nil;
    self.showVoiceLabel = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    self.isRequest = 0;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isRequest = 0;
    [PMTools removeSelectsPhotos];
    
    [self createLeftBarButtonItemWithTitle:self.fname];
    [self createRightBarButtonItemWithImage:nil WithTitle:@"提交" withMethod:@selector(commitCommand)];
    
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [self createSubviews];
    
    
    //注册键盘监听事件
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardUP:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDown:) name:UIKeyboardWillHideNotification object:nil];
    
    self.hub = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hub];
    self.hub.label.text = @"正在提交";
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
    [self.bottomView.talkBtn setTitleColor:lineColor forState:UIControlStateNormal];
    [self.view bringSubviewToFront:self.bottomView];
}
#pragma mark - 键盘下降
-(void)keyboardDown:(NSNotification *)noti{
    SYLog(@"键盘下降");
    float time = [[noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect newframe = self.bottomView.frame;
    newframe.origin.y = ScreenHeight - newframe.size.height - 64;
    [UIView animateWithDuration:time animations:^{
        self.bottomView.frame = newframe;
    }];
}

-(void)createSubviews{
    
    UIView * topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 110)];
    [self.view addSubview:topView];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ViewTapClick)];
    [topView addGestureRecognizer:tap];
    
    // 创建文本框
    self.descriptionTextView = [[TextViewCustom alloc] initWithFrame:CGRectMake(10, 10, ScreenWidth - 35, 110)];
    self.descriptionTextView.placehText = @"点击这里输入内容";
    [topView addSubview:self.descriptionTextView];
    
    //相片
    PhotosSelectedViewController * photosVC = [AppDelegate sharedInstance].photosSelectedViewController;
    photosVC.view.frame = CGRectMake(0, CGRectGetMaxY(self.descriptionTextView.frame) + 5, ScreenWidth, 120);
    [self.view addSubview:photosVC.view];
    [self addChildViewController:photosVC];
    
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
            //单点按钮 隐藏  /  取消
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
            //子视图图片相册选择添加图片  ---- 打开相册
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


#pragma mark - 提交评论
-(void)commitCommand{
    
    [self.view endEditing:YES];
    SYLog(@"评论提交");
    self.isRequest ++;
    if (self.isRequest == 1) {
        SYLog(@"%@",[AppDelegate sharedInstance].photosSelectedViewController.selectedPhotos);
        if ([PMTools isNullOrEmpty:self.descriptionTextView.textView.text] && [AppDelegate sharedInstance].photosSelectedViewController.selectedPhotos.count == 0 ) {
            self.isRequest = 0;
            [self createAlertWithMessage:@"评论或图片其中一项必须有内容"];
            return;
        }
        
        if ([self checkNetWork]) {
            //[SVProgressHUD showWithStatus:@"正在提交"];
            [self.hub showAnimated:YES];
            
            NSString * imageParms = @"";
            NSArray * images = [AppDelegate sharedInstance].photosSelectedViewController.selectedPhotos;
            if (images.count > 0) {
                imageParms = [SYQiniuUpload QiniuPutImageArray:images complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                    NSLog(@"info == %@ \n resp === %@",info,resp);
                }];
            }
           

            
            
            UserManager * mgr = [UserManagerTool userManager];
            NSDictionary * paraDic = @{@"worker_id":mgr.worker_id,
                                       @"repairs_id":self.repairs_id,
                                       @"content":self.descriptionTextView.textView.text,
                                       @"owner":@"2",
                                       @"type":@"1",
                                       @"image":imageParms};
            
            [DetailRequest SYSave_repairs_recordWithParms:paraDic SuccessBlock:^{
                //[SVProgressHUD showSuccessWithStatus:@"上传成功"];
                [SYCommon addAlertWithTitle:@"上传成功"];
                //[SVProgressHUD dismiss];
                [self.hub hideAnimated:YES];
                
                // 需要逆向传递数据
                if ([self.delegate respondsToSelector:@selector(reverseValue:)]) {
                    [self.delegate reverseValue:@{@"type":COMMANDORDERTYPE,@"repairs_id":self.repairs_id,@"section":@(self.section)}];
                }
                
                
                [[AppDelegate sharedInstance].photosSelectedViewController.selectedPhotos removeAllObjects];
                [[AppDelegate sharedInstance].photosSelectedViewController.selectedAssets removeAllObjects];
                [self.navigationController popViewControllerAnimated:YES];

            } FailureBlock:^{
                //[SVProgressHUD dismiss];
                [self.hub hideAnimated:YES];
                self.isRequest = 0;
            }];
            
        }
        
    }
    
}

@end
