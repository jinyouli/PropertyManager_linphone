//
//  AcceptOrderViewController.m
//  idoubs
//
//  Created by Momo on 16/6/29.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "AcceptOrderViewController.h"
#import "ComplainHeaderDataModel.h"//数据模型
#import "ComplainHeaderFrame.h"//Frame模型
#import "FGalleryViewController.h" //图片展示
@interface AcceptOrderViewController ()<FGalleryViewControllerDelegate>

@property (nonatomic,strong) UIView * topView;
@property (nonatomic,strong) UIImageView * iconView; //图标
@property (nullable,strong) UILabel * nameIcon;
@property (nonatomic,strong) UILabel * fnameLabel; //业主名
@property (nonatomic,strong) UILabel * timeLabel;  //订单时间
@property (nonatomic,strong) UILabel * desLabel;   //服务内容
@property (nonatomic,strong) UILabel * addLabel;  //订单地址  faddress
@property (nonatomic,strong) UILabel * orderNumLabel;  //工单号码 fordernum
@property (nonatomic,strong) UILabel * urgentLabel;  //加急状态 fremindercount
@property (nonatomic,strong) UIView * imagesListView;  //图片列表
@property (nonatomic,strong) UIImageView * photo1;
@property (nonatomic,strong) UIImageView * photo2;
@property (nonatomic,strong) UIImageView * photo3;

@property (nonatomic,strong) UIButton * acceptBtn;
@property (nonatomic,strong) UIButton * cancelBtn;
@property (nonatomic,strong) MBProgressHUD *hub;
@end

@implementation AcceptOrderViewController


#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        
        if (![PMTools isNullOrEmpty:params[@"dataModel"]]) {
            self.dataModel = (ComplainHeaderDataModel *)params[@"dataModel"];
        }
        
        if (![PMTools isNullOrEmpty:params[@"frameModel"]]) {
            self.frameModel = (ComplainHeaderFrame *)params[@"frameModel"];
        }
        
        if (![PMTools isNullOrEmpty:params[@"section"]]) {
            self.section = [params[@"section"] integerValue];
        }
        
        if (![PMTools isNullOrEmpty:params[@"isOrderDetail"]]) {
            self.isOrderDetail = [params[@"isOrderDetail"] boolValue];
        }
        
        if (![PMTools isNullOrEmpty:params[@"isRepair"]]) {
            self.isRepair = [params[@"isRepair"] boolValue];
        }
        
    }
    return self;
}




-(void)dealloc{
    SYLog(@"AcceptOrderViewController dealloc");
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BGColor;
    [self createLeftBarButtonItemWithTitle:self.isRepair? @"报修单处理确认":@"投诉单处理确认"];
    [self defaultSubViews];
    
    self.hub = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hub];
    self.hub.label.text = @"正在加载";
}

- (void)defaultSubViews
{
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, ScreenWidth, self.frameModel.cellHeight - 50)];
    self.topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.topView];
    
    UILabel * tLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.topView.frame) + 30, ScreenWidth - 20, 60)];
    tLabel.font = LargeFont;
    tLabel.numberOfLines = 0;
    tLabel.text = @"    接收后其他人员无法再次接单，保修单状态将改为正在处理，接受后请及时联系业主完成报修。";
    [self.view addSubview:tLabel];
    
    // 1.头像
    self.iconView = [[UIImageView alloc] init];
    [self.topView addSubview:self.iconView];
    self.nameIcon = [[UILabel alloc]init];
    [self.iconView addSubview:self.nameIcon];
    
    // 2.业主名
    self.fnameLabel = [[UILabel alloc] init];
    self.fnameLabel.font = LargeFont;
    [self.topView addSubview:self.fnameLabel];
    
    // 3.日期
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = SmallFont;
    [self.topView addSubview:self.timeLabel];
    
    // 4. 地址
    self.addLabel = [[UILabel alloc] init];
    self.addLabel.font = LargeFont;
    [self.topView addSubview:self.addLabel];
    
    //5.单号
    self.orderNumLabel = [[UILabel alloc] init];
    self.orderNumLabel.font = SmallFont;
    [self.topView addSubview:self.orderNumLabel];
    
    // 6.加急
    self.urgentLabel = [[UILabel alloc] init];
    self.urgentLabel.font = MiddleFont;
    [self.topView addSubview:self.urgentLabel];
    
    // 7.服务内容
    self.desLabel = [[UILabel alloc] init];
    self.desLabel.font = MiddleFont;
    [self.topView addSubview:self.desLabel];
    
    // 8.图片列表
    self.photo1 = [[UIImageView alloc]init];
    self.photo1.userInteractionEnabled = YES;
    [self.topView addSubview:self.photo1];
    self.photo2 = [[UIImageView alloc]init];
    self.photo2.userInteractionEnabled = YES;
    [self.topView addSubview:self.photo2];
    self.photo3 = [[UIImageView alloc]init];
    self.photo3.userInteractionEnabled = YES;
    [self.topView addSubview:self.photo3];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoTap)];
    [self.photo1 addGestureRecognizer:tap];
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoTap)];
    [self.photo2 addGestureRecognizer:tap2];
    UITapGestureRecognizer * tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoTap)];
    [self.photo3 addGestureRecognizer:tap3];
    
    
    // 1.设置数据
    [self settingData];
    
    // 2.设置frame
    [self settingFrame];
    
    
    [self createBtn];
    
}

/**
 *  设置数据
 */
- (void)settingData
{
    // 微博数据
    ComplainHeaderDataModel *dataModel = self.frameModel.headerDataModel;
    
    // 2.业主名
    NSString * frealnameStr = @"";
    if ([PMTools isNullOrEmpty:dataModel.frealname]) {
        if ([PMTools isNullOrEmpty:dataModel.flinkman]) {
            
            frealnameStr = @"业主";
        }
        else{
            frealnameStr = dataModel.flinkman;
        }
    }
    else{
        frealnameStr = dataModel.frealname;
    }
    self.fnameLabel.text = frealnameStr;

    
    // 1.头像
    self.iconView.backgroundColor = mainColor;
    if (![PMTools isNullOrEmpty:dataModel.fheadurl]) {
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:dataModel.fheadurl]];
        self.nameIcon.text = @"";
    }
    else{
        // 1.2
        self.nameIcon.text = [PMTools subStringFromString:self.fnameLabel.text isFrom:NO];
    }



    
    // 3.日期
    self.timeLabel.text = dataModel.fcreatetime;
    
    
    // 4. 地址
    self.addLabel.text = dataModel.faddress;
    
    
    //5.单号
    self.orderNumLabel.text = [NSString stringWithFormat:@"单号:%@",dataModel.fordernum];
    
    
    // 6.加急
    self.urgentLabel.text = @"加急";
    
    
    // 7.服务内容
    self.desLabel.text = dataModel.fservicecontent;
    
    
    // 8.图片列表
    NSArray * arr = dataModel.repairs_imag_list;
    if (arr.count != 0) {
        switch (arr.count) {
            case 3:
            {
                self.photo3.hidden = NO;
                
                
                [self.photo3 sd_setImageWithURL:[NSURL URLWithString:arr[2][@"fimagpath"]]];
            }
                
            case 2:
            {
                self.photo2.hidden = NO;

                [self.photo2 sd_setImageWithURL:[NSURL URLWithString:arr[1][@"fimagpath"]]];
            }
                
            case 1:
            {   self.photo1.hidden = NO;

                [self.photo1 sd_setImageWithURL:[NSURL URLWithString:arr[0][@"fimagpath"]]];
            }
                break;
        }
    }
    else{
        self.photo1.hidden = YES;
        self.photo2.hidden = YES;
        self.photo3.hidden = YES;
    }
}

/**
 *  计算文字尺寸
 *
 *  @param text    需要计算尺寸的文字
 *  @param font    文字的字体
 *  @param maxSize 文字的最大尺寸
 */
- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}
/**
 *  设置frame
 */
- (void)settingFrame
{
    
    // 1.头像
    self.iconView.frame = self.frameModel.iconF;
    self.iconView.layer.cornerRadius = self.frameModel.iconF.size.width/2;
    self.iconView.clipsToBounds = YES;
    self.nameIcon.frame = self.iconView.bounds;
    self.nameIcon.textColor = [UIColor whiteColor];
    self.nameIcon.textAlignment = NSTextAlignmentCenter;
    
    // 2.业主名
    self.fnameLabel.frame = self.frameModel.nameF;
    
    // 3.日期
    self.timeLabel.frame = self.frameModel.timeF;
    
    
    // 4. 地址
    self.addLabel.frame = self.frameModel.addF;
    
    
    //5.单号
    self.orderNumLabel.frame = self.frameModel.orderNumF;
    
    
    // 6.加急
    self.urgentLabel.frame = self.frameModel.urgentF;
    
    
    // 7.服务内容
    self.desLabel.frame = self.frameModel.desF;
    
    
    // 8.图片列表
    if (self.frameModel.headerDataModel.repairs_imag_list.count != 0) {
        switch (self.frameModel.headerDataModel.repairs_imag_list.count) {
            case 3:
            {
                self.photo3.frame = self.frameModel.image3ListF;
            }
                
            case 2:
            {
                self.photo2.frame = self.frameModel.image2ListF;
            }
                
            case 1:
            {
                self.photo1.frame = self.frameModel.image1ListF;
            }
                break;
        }
    }
}


-(void)createBtn{
  
    
    self.cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, ScreenHeight - 64 - 30 - 30, 100, 30)];
    self.cancelBtn.layer.cornerRadius = 8;
    self.cancelBtn.backgroundColor = mainColor;
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    self.cancelBtn.tag = 1001;
    [self.cancelBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelBtn];
    
    self.acceptBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - 120, ScreenHeight - 64 - 30 - 30, 100, 30)];
    self.acceptBtn.layer.cornerRadius = 8;
    self.acceptBtn.backgroundColor = mainColor;
    [self.acceptBtn setTitle:@"接受" forState:UIControlStateNormal];
    self.acceptBtn.tag = 1002;
    self.acceptBtn.enabled = YES;
    [self.acceptBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.acceptBtn];
}

-(void)btnClick:(UIButton *)btn{
    
    if (btn.tag == 1001) {
        //取消
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        //接受 并跳转到正在处理 我的 页面
        
        if ([self checkNetWork]) {
            
            self.acceptBtn.enabled = NO;
            
            UserManager * user = [UserManagerTool userManager];
            NSString * url = MyUrl(SYUpdate_order_status);
            SYLog(@"接单Url ==== %@",url);
            
            NSDictionary * paraDic = @{@"do_type":@"2",@"repairs_id":self.dataModel.repair_id,@"worker_id":user.worker_id};
            
            [self.hub showAnimated:YES];
            [DetailRequest SYUpdate_order_statusWithParms:paraDic SuccessBlock:^{
                
                [self.hub hideAnimated:YES];
                [self createSVProgressMessage:@"操作成功" withMethod:@selector(backLastVC)];
            } FailureBlock:^{
                [self.hub hideAnimated:YES];
                self.acceptBtn.enabled = YES ;
            }];
            
        }

    }
    
}
#pragma mark - 返回上一页
-(void)backLastVC{
    // 关闭SVP
    [SVProgressHUD dismiss];
    
    if (self.isOrderDetail) {
        // 返回根
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
    else{
        
        // 1.定位x
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeScrollerViewX" object:@"1"];
        // 2.发通知更新数据
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getDataFromMyDoing" object:nil];
        // 3.发通知移除数据
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteOneDataFromUnStar" object:@(self.section)];

        // 返回上一页
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark 服务内容的图片点击处理
- (void)photoTap
{
    FGalleryViewController *gallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
    
    [self.navigationController pushViewController:gallery animated:NO];
    
    
}

#pragma mark FGalleryViewControllerDelegate 5个方法
//图片数量
- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController*)gallery
{
    return self.dataModel.repairs_imag_list.count;
}

//图片资源来源 类型
- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController*)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
    return FGalleryPhotoSourceTypeNetwork;
}

//图片url
- (NSString*)photoGallery:(FGalleryViewController*)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index
{
    NSDictionary * dic = self.dataModel.repairs_imag_list[index];
    return dic[@"fimagpath"];
}

//图片标题
- (NSString *)photoGallery:(FGalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
    return nil;
}

//图片描述
- (NSString *)photoGallery:(FGalleryViewController *)gallery descriptionForPhotoAtIndex:(NSUInteger)index
{
    
    return nil;
}



@end
