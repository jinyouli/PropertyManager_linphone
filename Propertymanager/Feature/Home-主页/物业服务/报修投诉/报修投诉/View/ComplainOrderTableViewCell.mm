//
//  ComplainOrderTableViewCell.m
//  idoubs
//
//  Created by Momo on 16/6/30.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "ComplainOrderTableViewCell.h"

@interface ComplainOrderTableViewCell()

/** 头像 */
@property (nonatomic,strong) UIImageView * iconView;
/** 回复名 */
@property (nonatomic,strong) UILabel * fnameLabel;
/** 头像名 */
@property (nonatomic,strong) UILabel * nameIcon;
/** 回复时间 */
@property (nonatomic,strong) UILabel * timeLabel;
/** 回复内容 */
@property (nonatomic,strong) UILabel * desLabel;



@end

@implementation ComplainOrderTableViewCell

+(instancetype)cellWithTableview:(UITableView *)tableview{
    
    return [[self alloc]initWithTableview:tableview];
}

-(instancetype)initWithTableview:(UITableView *)tableview{
    
    static NSString * identify = @"ComplainOrderCell";
    ComplainOrderTableViewCell * cell = [tableview dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[ComplainOrderTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.backgroundColor = sBGColor;
    }
    return cell;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self defaultSubViews];//这里初始化各个子视图，不要给frame赋值
    }
    return self;
}
-(void)defaultSubViews{
    
    
    // 1.头像
    self.iconView = [[UIImageView alloc] init];
    [self addSubview:self.iconView];

    // 1.2名字
    self.nameIcon = [[UILabel alloc]init];
    self.nameIcon.font = SmallFont;
    self.nameIcon.textAlignment = NSTextAlignmentCenter;
    self.nameIcon.textColor = [UIColor whiteColor];
    [self.iconView addSubview:self.nameIcon];
    
    // 2.回复时间
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = SmallFont;
    self.timeLabel.textColor = lineColor;
    [self addSubview:self.timeLabel];
    
    // 3.回复名
    self.fnameLabel = [[UILabel alloc] init];
    self.fnameLabel.font = MiddleFont;
    self.fnameLabel.textColor = mainTextColor;
    [self addSubview:self.fnameLabel];
    
    // 4.回复内容
    self.desLabel = [[UILabel alloc] init];
    self.desLabel.font = MiddleFont;
    self.desLabel.numberOfLines = 0;
    self.desLabel.textColor = mainTextColor;
    [self addSubview:self.desLabel];
    
    // 5.图片列表
    self.photo1 = [[UIButton alloc]init];
    self.photo1.tag = 500;
    [self.photo1 addTarget:self action:@selector(photoTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.photo1];
    
    self.photo2 = [[UIButton alloc]init];
    self.photo2.tag = 501;
    [self.photo2 addTarget:self action:@selector(photoTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.photo2];
    
    self.photo3 = [[UIButton alloc]init];
    self.photo3.tag = 502;
    [self.photo3 addTarget:self action:@selector(photoTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.photo3];
    
}

#pragma mark - 查看大图
-(void)photoTap:(UIButton *)btn{
    SYLog(@"点击详情图片");

    if (self.block) {
        self.block(self.indexPath,btn.tag - 500);
    }
}

/**
 *  在这个方法中设置子控件的frame和显示数据
 */
-(void)setReplyFrame:(ComplainReplyFrame *)replyFrame{
    _replyFrame = replyFrame;
    
    // 1.设置数据
    [self settingData];
    
    // 2.设置frame
    [self settingFrame];
}
/**
 *  设置数据
 */
- (void)settingData
{
    // 数据
    self.replyDataModel = self.replyFrame.replyDataModel;
    
    // 1.头像
    self.iconView.backgroundColor = mainColor;
    
    // 1.2 回复名
    self.nameIcon.text = [PMTools subStringFromString:self.replyDataModel.name isFrom:NO];
    
    // 2.回复时间
    self.timeLabel.text = self.replyDataModel.fcreatetime;
    self.timeLabel.backgroundColor = [UIColor whiteColor];
    
    // 3.回复名
    self.fnameLabel.text = [NSString stringWithFormat:@"%@:",self.replyDataModel.name];
    self.fnameLabel.backgroundColor = [UIColor whiteColor];
    
    // 4.回复内容
    NSInteger type = [self.replyDataModel.ftype integerValue];
    
    NSString * replyDataModelName = @"";
    if (![PMTools isNullOrEmpty:_replyDataModel.name]) {
        replyDataModelName = _replyDataModel.name;
    }
    
    if (type == 1 || type == 2) {
        
        self.desLabel.text = self.replyDataModel.fcontent;
        
    }
    else if (type == 3){
        if ([PMTools isNullOrEmpty:self.replyDataModel.fcontent]) {
            self.desLabel.text = @"提醒转派工单申请。";
        }
        else{
            self.desLabel.text = [NSString stringWithFormat:@"提醒转派工单申请,原因:%@。",_replyDataModel.fcontent];
        }
    }
    else if (type == 4){
        self.nameIcon.text = @"系统";
        self.fnameLabel.text = @"工单动态:";
        if ([PMTools isNullOrEmpty:self.replyDataModel.fcontent]) {
            self.desLabel.text = [NSString stringWithFormat:@"该工单(%@号)处理人已由[%@]变更为[%@]",_replyDataModel.ID,_replyDataModel.old_name,_replyDataModel.nMyName1];
        }
        else{
            self.desLabel.text = [NSString stringWithFormat:@"该工单(%@号)处理人已由[%@]变更为[%@],原因%@",_replyDataModel.ID,_replyDataModel.old_name,_replyDataModel.nMyName1,self.replyDataModel.fcontent];
        }
    }
    else if (type == 5){
        self.nameIcon.text = @"系统";
        self.fnameLabel.text = @"工单动态:";
        if ([PMTools isNullOrEmpty:self.replyDataModel.fcontent]) {
            self.desLabel.text = [NSString stringWithFormat:@"工单已由[%@]完成。",replyDataModelName];
        }
        else{
            self.desLabel.text = [NSString stringWithFormat:@"工单已由[%@]完成，完成原因:%@",replyDataModelName,_replyDataModel.fcontent];
        }
    }
    else if (type == 6){
    
        self.nameIcon.text = @"系统";
        self.fnameLabel.text = @"工单动态:";
        if ([PMTools isNullOrEmpty:self.replyDataModel.fcontent]) {
            self.desLabel.text = [NSString stringWithFormat:@"工单(%@号)已由[%@]返回。",_replyDataModel.ID,replyDataModelName];
        }
        else{
            self.desLabel.text = [NSString stringWithFormat:@"工单(%@号)已由[%@]返回，返回原因%@",_replyDataModel.ID,replyDataModelName,_replyDataModel.fcontent];
        }
    }
    else if (type == 7){
        self.nameIcon.text = @"系统";
        self.fnameLabel.text = @"工单动态:";
        
        if ([PMTools isNullOrEmpty:self.replyDataModel.fcontent]) {
            self.desLabel.text = [NSString stringWithFormat:@"工单(%@号)已由业主[%@]取消。",_replyDataModel.ID,replyDataModelName];
        }
        else{
            self.desLabel.text = [NSString stringWithFormat:@"工单(%@号)已由业主[%@]取消，取消原因%@",_replyDataModel.ID,replyDataModelName,_replyDataModel.fcontent];
        }
        
    }
    

    
    // 5.图片列表
    NSArray * arr = self.replyDataModel.reply_imag_list;
    if (arr.count != 0) {
        switch (arr.count) {
            case 6:
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
    
}
/**
 *  设置frame
 */
- (void)settingFrame
{
    
    // 1.头像
    self.iconView.frame = self.replyFrame.iconF;
    self.iconView.layer.cornerRadius = self.replyFrame.iconF.size.width/2;
    
    //1.2 头像名
    self.nameIcon.frame = self.iconView.bounds;
    
    // 2.回复时间
    self.timeLabel.frame = self.replyFrame.timeF;
    
    
    // 3.回复名
    self.fnameLabel.frame = self.replyFrame.nameF;
    
    // 4.回复内容
    self.desLabel.frame = self.replyFrame.desF;
    
    
    // 5.图片列表
    NSArray * arr = self.replyDataModel.reply_imag_list;
    if (arr.count != 0) {
        switch (arr.count) {
            case 3:
            {
                self.photo3.frame = self.replyFrame.image3ListF;
            }
                
            case 2:
            {
                self.photo2.frame = self.replyFrame.image2ListF;
            }
                
            case 1:
            {
                self.photo1.frame = self.replyFrame.image1ListF;
            }
                break;
        }
    }
    
    
}

-(void)myReplyImageBlock:(ReplyImageBlock)block{
    
    
    if (!self.block) {
        self.block = block;
    }
}

@end
