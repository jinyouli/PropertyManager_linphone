//
//  ComplainHeaderView.m
//  idoubs
//
//  Created by Momo on 16/6/30.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "ComplainHeaderView.h"

@interface ComplainHeaderView ()
/** 顶部点击区域 （增加手势） */
@property (nonatomic,strong) UIView * topView;
/** 业主名 */
@property (nonatomic,strong) UILabel * fnameLabel;
/** 订单时间 */
@property (nonatomic,strong) UILabel * timeLabel;
/** 服务内容  fservicecontent */
@property (nonatomic,strong) UILabel * desLabel;
/** 订单地址  faddress */
@property (nonatomic,strong) UILabel * addLabel;
/** 工单号码 fordernum */
@property (nonatomic,strong) UILabel * orderNumLabel;
/** 加急状态 fremindercount */
@property (nonatomic,strong) UILabel * urgentLabel;
/** 图片列表 repairs_imag_list */
@property (nonatomic,strong) UIView * imagesListView;
/** 派单按钮 */
@property (nonatomic,strong) UIButton * sendOrdersBtn;
@property (nonatomic,strong) UIButton * sendOrdersBtnLarge;

/** 派单状态 */
@property (nonatomic,strong) UILabel * sendStateLabel;
/** 接受按钮 */
@property (nonatomic,strong) UIButton * acceptBtn;
/** 评论按钮 */
@property (nonatomic,strong) UIButton * commandBtn;
/** 评论数量 */
@property (nonatomic,strong) UILabel * countLabel;
/** 联系人 */
@property (nonatomic,strong) UIButton * linkPhone;
/** 星星 */
@property (nonatomic,strong) UIView * starView;

@end

@implementation ComplainHeaderView

-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
        [self defaultSubViews];//这里初始化各个子视图，不要给frame赋值
        self.contentView.backgroundColor = [UIColor whiteColor];
    
    }
    return self;
}

- (void)defaultSubViews
{
    // 1.头像
    self.iconView = [[UIImageView alloc] init];
    self.iconView.clipsToBounds = YES;
    [self.contentView addSubview:self.iconView];
    
    // 1.2名字
    self.nameIcon = [[UILabel alloc]init];
    [self.iconView addSubview:self.nameIcon];

    // 2.业主名
    self.fnameLabel = [[UILabel alloc] init];
    self.fnameLabel.font = LargeFont;
    self.fnameLabel.textColor = mainTextColor;
    [self.contentView addSubview:self.fnameLabel];
    
    // 3.日期
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = SmallFont;
    self.timeLabel.textColor = lineColor;
    [self.contentView addSubview:self.timeLabel];
    
    // 4. 地址
    self.addLabel = [[UILabel alloc] init];
    self.addLabel.font = LargeFont;
    self.addLabel.textColor = mainTextColor;
    [self.contentView addSubview:self.addLabel];
    
    //5.单号
    self.orderNumLabel = [[UILabel alloc] init];
    self.orderNumLabel.font = SmallFont;
    self.orderNumLabel.textColor = lineColor;
    [self.contentView addSubview:self.orderNumLabel];
    
    // 6.加急
    self.urgentLabel = [[UILabel alloc] init];
    self.urgentLabel.font = SmallFont;
    self.urgentLabel.textColor = ITextColor;
    self.urgentLabel.textAlignment = NSTextAlignmentCenter;
    self.urgentLabel.layer.borderColor = ITextColor.CGColor;
    self.urgentLabel.layer.borderWidth = 1;
    self.urgentLabel.layer.cornerRadius = 2;
    [self.contentView addSubview:self.urgentLabel];
    
    // 7.服务内容
    self.desLabel = [[UILabel alloc] init];
    self.desLabel.font = MiddleFont;
    self.desLabel.textColor = mainTextColor;
    self.desLabel.numberOfLines = 0;
    [self.contentView addSubview:self.desLabel];
    
    // 7.1 电话号码
    self.linkPhone = [[UIButton alloc]init];
    self.linkPhone.titleLabel.font = MiddleFont;
    [self.linkPhone setTitleColor:mainColor forState:UIControlStateNormal];
    [self.contentView addSubview:self.linkPhone];
    
    // 8.图片列表
    self.photo1 = [[UIButton alloc]init];
    [self.photo1 addTarget:self action:@selector(photoTap:) forControlEvents:UIControlEventTouchUpInside];
    self.photo1.tag = 600;
    [self.contentView addSubview:self.photo1];
    
    self.photo2 = [[UIButton alloc]init];
    self.photo2.tag = 601;
    [self.photo2 addTarget:self action:@selector(photoTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.photo2];
    
    self.photo3 = [[UIButton alloc]init];
    self.photo3.tag = 602;
    [self.photo3 addTarget:self action:@selector(photoTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.photo3];
    
    // 9.派单按钮
    self.sendOrdersBtn = [[UIButton alloc] init];
    self.sendOrdersBtn.backgroundColor = MYColor(203, 203, 203);
    //[self.sendOrdersBtn addTarget:self action:@selector(SndSendOrdersBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.sendOrdersBtn];
    [self.sendOrdersBtn setTitle:@"系统" forState:UIControlStateNormal];
    
    self.sendOrdersBtnLarge = [[UIButton alloc] init];
    self.sendOrdersBtnLarge.backgroundColor = [UIColor redColor];
    self.sendOrdersBtnLarge.backgroundColor = [UIColor clearColor];
    [self.sendOrdersBtnLarge addTarget:self action:@selector(SndSendOrdersBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.sendOrdersBtnLarge];
    [self.sendOrdersBtnLarge setTitle:@"" forState:UIControlStateNormal];
    
    
    // 10.派单状态
    self.sendStateLabel = [[UILabel alloc] init];
    self.sendStateLabel.font = MiddleFont;
    self.sendStateLabel.textColor = TImageColor;
    [self.contentView addSubview:self.sendStateLabel];
   
    // 11.接受按钮
    self.acceptBtn = [[UIButton alloc] init];
    self.acceptBtn.layer.cornerRadius = 3;
    self.acceptBtn.layer.borderWidth = 1;
    [self.acceptBtn setTitleColor:lineColor forState:UIControlStateNormal];
    self.acceptBtn.titleLabel.font = SmallFont;
    [self.acceptBtn addTarget:self action:@selector(acceptBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.acceptBtn];
    
    //星星
    self.starView = [[UIView alloc]init];
    [self.contentView addSubview:self.starView];
    
    // 12.评论按钮
    self.commandBtn = [[UIButton alloc] init];
    self.commandBtn.backgroundColor = mainColor;
    [self.contentView addSubview:self.commandBtn];
    
    // 13.评论数量
    self.countLabel = [[UILabel alloc] init];
    self.countLabel.font = SmallFont;
    self.countLabel.textColor = mainTextColor;
    [self.contentView addSubview:self.countLabel];
    
    // 14.详情按钮
    self.detailBtn = [[UIButton alloc] init];
    [self.detailBtn setTitleColor:mainTextColor forState:UIControlStateNormal];
    [self.contentView addSubview:self.detailBtn];
    [self.detailBtn setImage:[UIImage imageNamed:@"lightGrayDown"] forState:UIControlStateNormal];
    self.detailBtn.titleLabel.font = SmallFont;
    [self.detailBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -40, 0, 0)];
    [self.detailBtn setImageEdgeInsets:UIEdgeInsetsMake(7.5, 7.5, 7.5, -32.5)];
    [self.detailBtn addTarget:self action:@selector(replyDetail) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 16.顶部点击事件
    self.topView = [[UIView alloc]init];
    [self.contentView addSubview:self.topView];
    self.topView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer * topViewClickTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(topViewClick)];
    [self.topView addGestureRecognizer:topViewClickTap];
    
}

-(void)setHeaderFrame:(ComplainHeaderFrame *)headerFrame{
    _headerFrame = headerFrame;
    
    // 1.设置数据
    [self settingData];
    
    // 2.设置frame
    [self settingFrame];
}

- (void)settingData
{
    // 微博数据
    self.headerDataModel = self.headerFrame.headerDataModel;
    
    
    // 2.业主名
    NSString * frealnameStr = @"";
    if ([PMTools isNullOrEmpty:self.headerDataModel.frealname]) {
        if ([PMTools isNullOrEmpty:self.headerDataModel.flinkman]) {
            
            frealnameStr = @"业主";
        }
        else{
            frealnameStr = self.headerDataModel.flinkman;
        }
    }
    else{
        frealnameStr = self.headerDataModel.frealname;
    }
    self.fnameLabel.text = frealnameStr;
//    SYLog(@"frealnameStr === %@",frealnameStr);
    
    // 1.头像
    if (![PMTools isNullOrEmpty:self.headerDataModel.fheadurl]) {
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:self.headerDataModel.fheadurl] placeholderImage:[UIImage imageNamed:@"logo80"]];
        self.nameIcon.text = @"";
    }
    else{
        // 1.2
        self.iconView.backgroundColor = mainColor;
        self.nameIcon.text = [PMTools subStringFromString:self.fnameLabel.text isFrom:NO];
    }
    
    
    // 3.日期
    if ([PMTools isNullOrEmpty:self.headerDataModel.fcreatetime]) {
        self.headerDataModel.fcreatetime = @"";
    }
    self.timeLabel.text = self.headerDataModel.fcreatetime;
    
    
    // 4. 地址
    if ([PMTools isNullOrEmpty:self.headerDataModel.faddress]) {
        self.headerDataModel.faddress = @"";
    }
    self.addLabel.text = self.headerDataModel.faddress;
    
    
    //5.单号
    if ([PMTools isNullOrEmpty:self.headerDataModel.fordernum]) {
        self.headerDataModel.fordernum = @"";
    }
    self.orderNumLabel.text = [NSString stringWithFormat:@"单号:%@",self.headerDataModel.fordernum];
    
    
    // 6.加急
    self.urgentLabel.text = @"加急";
    
    
    // 7.服务内容
    if ([PMTools isNullOrEmpty:self.headerDataModel.fservicecontent]) {
        self.headerDataModel.fservicecontent = @"";
    }
    self.desLabel.text = self.headerDataModel.fservicecontent;
    
    // 7.1拨打电话
    if ([PMTools isNullOrEmpty:self.headerDataModel.flinkman]) {
        self.headerDataModel.fservicecontent = @"";
    }
    if ([PMTools isNullOrEmpty:self.headerDataModel.flinkman_phone]) {
        self.headerDataModel.fservicecontent = @"";
    }
    NSString * linkStr = [NSString stringWithFormat:@"%@:%@",self.headerDataModel.flinkman,self.headerDataModel.flinkman_phone];
    [self.linkPhone setTitle:linkStr forState:UIControlStateNormal];
    [self.linkPhone addTarget:self action:@selector(linkPhoneClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 8.图片列表
    if (self.headerDataModel.repairs_imag_list == nil || self.headerDataModel.repairs_imag_list==(id)[NSNull null]) {
        self.headerDataModel.repairs_imag_list = @[];
    }
    NSArray * arr = self.headerDataModel.repairs_imag_list;
    if (arr.count != 0) {
        switch (arr.count) {
            case 5:
            case 4:
            case 3:
            {
                self.photo3.hidden = NO;
                [self.photo3 sd_setBackgroundImageWithURL:[NSURL URLWithString:arr[2][@"fimagpath"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"logo80"]];
            }
                
            case 2:
            {
                self.photo2.hidden = NO;
                [self.photo2 sd_setBackgroundImageWithURL:[NSURL URLWithString:arr[1][@"fimagpath"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"logo80"]];
            }
                
            case 1:
            {   self.photo1.hidden = NO;
                [self.photo1 sd_setBackgroundImageWithURL:[NSURL URLWithString:arr[0][@"fimagpath"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"logo80"]];
            }
                break;
        }
    }
    else{
        self.photo1.hidden = YES;
        self.photo2.hidden = YES;
        self.photo3.hidden = YES;
    }
    

    
    // 10.派单状态Label
    if ([PMTools isNullOrEmpty:self.headerDataModel.fworkername]) {
        self.headerDataModel.fworkername = @"";
    }
    
    NSString * status = @"";
    NSInteger fstatus = [self.headerDataModel.fstatus integerValue];
//    NSInteger power_type = [[UserManagerTool userManager].power_type integerValue];
    NSInteger power_do = [self.headerDataModel.power_do integerValue];
    NSInteger normal_do = [self.headerDataModel.normal_do integerValue];
    if ([PMTools isNullOrEmpty:self.headerDataModel.deal_worker_id]) {
        self.headerDataModel.deal_worker_id = @"";
    }
    BOOL isMine = [self.headerDataModel.deal_worker_id isEqualToString:[UserManagerTool userManager].worker_id]?YES:NO;
 
    self.starView.hidden = YES;
    
    // 10.状态文字
    self.sendStateLabel.textColor = TImageColor;
    self.sendStateLabel.hidden = NO;

    
    //如果登陆者具备派单权限，为0表示不可以对该工单操作，1为派单，2为转单（已派）
    switch (power_do) {
        case 0:
            status = @"";
            self.sendOrdersBtn.enabled = NO;
            self.sendOrdersBtnLarge.enabled = NO;
            break;
            
        case 1:
            status = @"派单";
            self.sendOrdersBtn.tag = 501;
            self.sendOrdersBtnLarge.tag = 501;
            self.sendOrdersBtn.enabled = YES;
            self.sendOrdersBtnLarge.enabled = YES;
            
            break;
            
        case 2:
            status = @"已派";
            self.sendOrdersBtn.tag = 502;
            self.sendOrdersBtnLarge.tag = 502;
            self.sendOrdersBtn.enabled = YES;
            self.sendOrdersBtnLarge.enabled = YES;
            break;
            
        default:
            break;
    }
    
    self.acceptBtn.hidden = NO;
    self.acceptBtn.enabled = YES;
    
    //所有登陆者，包括派单人，0表示不可操作，1表示可接单，2表示可完成（注：派单人可能同时具备转单以及点击完成两个操作）
    switch (normal_do) {
        case 0:

            self.acceptBtn.hidden = YES;
            self.acceptBtn.enabled = NO;
            break;
            
        case 1:
            

            [self.acceptBtn setTitle:@"接受" forState:UIControlStateNormal];
            self.acceptBtn.tag = 601;
            self.acceptBtn.layer.borderColor = TImageColor.CGColor;
            [self.acceptBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            
            break;
            
        case 2:

            [self.acceptBtn setTitle:@"完成" forState:UIControlStateNormal];
            self.acceptBtn.tag = 602;
            self.acceptBtn.layer.borderColor = mainTextColor.CGColor;
            [self.acceptBtn setTitleColor:mainTextColor forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    
    //工单状态 1未处理 2待接单 3正在处理 4处理完成（维修人员） 5结束
    switch (fstatus) {
        case 1:
        
            status = @"派单";
            break;
            
        case 2:
            status = @"已派";
            break;
            
        case 3:
            
            status = isMine ? @"我正在处理":@"正在处理";
            
            if (!isMine) {
                self.acceptBtn.hidden = YES;
            }
            break;
            
        case 4:
            status = isMine ? @"我等待评价":@"等待评价";
            
            self.acceptBtn.hidden = NO;
            self.acceptBtn.enabled = NO;
            [self.acceptBtn setTitle:@"业主确认中" forState:UIControlStateNormal];
            self.acceptBtn.layer.borderColor = TImageColor.CGColor;
            self.acceptBtn.layer.borderWidth = 1;
            [self.acceptBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            
            break;
        case 5:
            status = isMine ? @"我已完成":@"已完成";
            
            [self showStar];
            break;

        case 6:
            
            self.acceptBtn.hidden = NO;
            self.acceptBtn.enabled = NO;
            [self.acceptBtn setTitle:@"业主已取消" forState:UIControlStateNormal];
            self.acceptBtn.layer.borderColor = TImageColor.CGColor;
            self.acceptBtn.layer.borderWidth = 1;
            [self.acceptBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    if (fstatus == 1 || fstatus == 2) {
        [self.sendOrdersBtn setBackgroundImage:[UIImage imageNamed:@"plane"] forState:UIControlStateNormal];
        [self.sendOrdersBtn setTitle:@"" forState:UIControlStateNormal];
    }
    else{
        NSString * myTitle;
        if (!isMine) {
            self.acceptBtn.hidden = YES;
            myTitle = [PMTools subStringFromString:self.headerDataModel.fworkername isFrom:YES];
        }
        else{
            myTitle = [PMTools subStringFromString:[UserManagerTool userManager].worker_name isFrom:YES];
        }
        [self.sendOrdersBtn setBackgroundImage:[UIImage imageNamed:@"orderIconBack"] forState:UIControlStateNormal];
        [self.sendOrdersBtn setTitle:myTitle forState:UIControlStateNormal];
    }
    
    self.sendStateLabel.text = status;
    
    // 12.评论按钮
    [self.commandBtn addTarget:self action:@selector(pushCommand) forControlEvents:UIControlEventTouchUpInside];
    
    // 13.评论数量
    if (self.headerDataModel.record_num == nil || self.headerDataModel.record_num ==(id)[NSNull null] || [self.headerDataModel.record_num isEqual:@0]) {
        self.countLabel.text = @"";
    }
    else{
        self.countLabel.text = [NSString stringWithFormat:@"%@",self.headerDataModel.record_num];
    }
    // 14.详情按钮
    [self.detailBtn setTitle:@"详情" forState:UIControlStateNormal];
}

-(void)showStar{
    self.acceptBtn.hidden = YES;
    self.acceptBtn.enabled = NO;
    self.starView.hidden = NO;
    [self.acceptBtn setTitle:@"" forState:UIControlStateNormal];
    
    //星星
    self.starView.frame = CGRectMake(ScreenWidth*0.5 - 50, self.headerFrame.cellHeight - 40, 100, 20);
    
    self.acceptBtn.layer.borderWidth = 0;
    if (![PMTools isNullOrEmpty:self.headerDataModel.fscore]) {
        NSInteger num = [self.headerDataModel.fscore integerValue];
        
        for (UIView * view in self.starView.subviews) {
            [view removeFromSuperview];
        }
        
        for (int i = 0; i < 5; i ++) {
            UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i * 20, 0, 20, 20)];
            if (i < num) {
                //黄色星星
                imageView.image = [UIImage imageNamed:@"star_on"];
            }
            else{
                //黑色星星
                imageView.image = [UIImage imageNamed:@"star_off"];
            }
            [self.starView addSubview:imageView];
        }
    }
}

#pragma mark - (派单501)（已派502  为了转单）
-(void)SndSendOrdersBtnClick:(UIButton *)btn{
    
    if (self.block) {
        
        if (btn.tag == 502) {
            SYLog(@"点击已派");
            self.block(self.section,9,0);
        }
        else if (btn.tag == 501){
            SYLog(@"点击派单");
            self.block(self.section,1,0);
        }
    }
}

#pragma mark - 转单
-(void)thirdSendOrdersBtnClick{
    if (self.block) {
        self.block(self.section,9,0);
    }
}

#pragma mark - 接受按钮
#pragma mark - 完成按钮
-(void)acceptBtnClick:(UIButton *)btn{
    
    
    if (self.block) {
        if (btn.tag == 601) {
            SYLog(@"接受按钮");
            self.block(self.section,3,0);
        }
        else if (btn.tag == 602) {
            SYLog(@"完成按钮");
            self.block(self.section,4,0);
        }
        
        
    }
}


#pragma mark - 详情按钮
-(void)replyDetail{
    SYLog(@"点击详情");
    if (self.headerDataModel.record_num == nil || self.headerDataModel.record_num ==(id)[NSNull null] || [self.headerDataModel.record_num isEqual:@0]) {
        [SVProgressHUD showErrorWithStatus:@"评论数量为0，无法打开"];
        return;
    }
    
    if (self.block) {
        self.block(self.section,5,0);
    }
}


#pragma mark - 点击评论
-(void)pushCommand{
    SYLog(@"点击评论");
    if (self.block) {
        self.block(self.section,6,0);
    }
}

#pragma mark - 点击照片
-(void)photoTap:(UIButton *)btn{
    NSInteger index = btn.tag - 600;
    if (self.block) {
        self.block(self.section,7,index);
    }
}

#pragma mark - 头部点击事件 查看业主
-(void)topViewClick{
    SYLog(@"查看业主");
    if (self.block) {
        self.block(self.section,8,0);
    }
}

#pragma mark - 拨打电话号码
-(void)linkPhoneClick{
    SYLog(@"拨打电话");
    if (self.block) {
        self.block(self.section,10,0);
    }
}

-(void)returnComplainHeaderBlock:(ComplainHeaderBlock)block{
    if (!self.block) {
        self.block = block;
    }
}

/**
 *  设置frame
 */
- (void)settingFrame
{
    
    // 1.头像
    self.iconView.frame = self.headerFrame.iconF;
    self.iconView.layer.cornerRadius = self.headerFrame.iconF.size.width/2;
    self.iconView.clipsToBounds = YES;
    // 1.2
    self.nameIcon.frame = self.iconView.bounds;
    self.nameIcon.font = MiddleFont;
    self.nameIcon.textAlignment = NSTextAlignmentCenter;
    self.nameIcon.textColor = [UIColor whiteColor];
    
    // 2.业主名
    self.fnameLabel.frame = self.headerFrame.nameF;
    
    // 3.日期
    self.timeLabel.frame = self.headerFrame.timeF;
    
    
    // 4. 地址
    self.addLabel.frame = self.headerFrame.addF;
    
    
    //5.单号
    self.orderNumLabel.frame = self.headerFrame.orderNumF;
    
    
    // 6.加急
    self.urgentLabel.frame = self.headerFrame.urgentF;
    
    
    // 7.服务内容
    self.desLabel.frame = self.headerFrame.desF;
    
    //7.1 拨打电话
    self.linkPhone.frame = self.headerFrame.linkPhoneBtnF;
    
    
    // 8.图片列表
    if (self.headerDataModel.repairs_imag_list.count != 0) {
        switch (self.headerDataModel.repairs_imag_list.count) {
            case 3:
                self.photo3.frame = self.headerFrame.image3ListF;
            case 2:
                self.photo2.frame = self.headerFrame.image2ListF;
            case 1:
                self.photo1.frame = self.headerFrame.image1ListF;
                break;
        }
    }
    // 9.派单按钮
    self.sendOrdersBtn.frame = self.headerFrame.sendOrdersBtnF;
    self.sendOrdersBtn.layer.cornerRadius = self.headerFrame.sendOrdersBtnF.size.width/2;
    self.sendOrdersBtn.titleLabel.font = SmallFont;
    self.sendOrdersBtn.clipsToBounds = YES;
    
    self.sendOrdersBtnLarge.frame = CGRectMake(self.sendOrdersBtn.frame.origin.x, self.sendOrdersBtn.frame.origin.y, 100, self.sendOrdersBtn.frame.size.height);
    
    // 10.派单状态
    self.sendStateLabel.frame = self.headerFrame.sendStateF;
    CGFloat width = self.sendStateLabel.frame.size.width;
    if (width == 0) {
        self.sendStateLabel.frame = CGRectMake(CGRectGetMaxX(self.sendOrdersBtn.frame) + 10, CGRectGetMidY(self.sendOrdersBtn.frame) - 10, 60, 20);
    }
    
    if ([self.sendStateLabel.text isEqualToString:@""]) {
        self.sendStateLabel.text = @"处理完成";
        [self.sendOrdersBtn setTitle:@"系统" forState:UIControlStateNormal];
        
    }
    
    // 11.接受按钮
    self.acceptBtn.frame = CGRectMake(CGRectGetMaxX(self.sendStateLabel.frame) + 7, self.headerFrame.acceptBtnF.origin.y, self.headerFrame.acceptBtnF.size.width, self.headerFrame.acceptBtnF.size.height);

    // 12.评论按钮
    self.commandBtn.frame = self.headerFrame.commandBtnF;
    self.commandBtn.layer.cornerRadius = self.headerFrame.commandBtnF.size.width/2;
    [self.commandBtn setImage:[UIImage imageNamed:@"comman"] forState:UIControlStateNormal];
    self.commandBtn.clipsToBounds = YES;
    
    // 13.评论数量
    self.countLabel.frame = self.headerFrame.countLabelF;
    
    
    // 14.详情按钮
    self.detailBtn.frame = self.headerFrame.detailBtnF;
    
    
    // 16.增加顶部点击事件：
    self.topView.frame = CGRectMake(0, 0, ScreenWidth, CGRectGetMaxY(self.iconView.frame));
 
}

@end
