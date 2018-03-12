//
//  PropertyTableViewCell.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "PropertyTableViewCell.h"


@interface PropertyTableViewCell()

@property (nonatomic,strong) UIButton * photoBtn;
@property (nonatomic,strong) UILabel * titleLabel;
@property (nonatomic,strong) UILabel * timeLabel;
@property (nonatomic,strong) UILabel * desLabel;
@property (nonatomic,strong) UILabel * statusLabel;

@end


@implementation PropertyTableViewCell

+(instancetype)cellWithTableview:(UITableView *)tableview{
    
    return [[self alloc]initWithTableview:tableview];
}

-(instancetype)initWithTableview:(UITableView *)tableview{
    
    static NSString * identify = @"PropertyNewsCell";
    PropertyTableViewCell * cell = [tableview dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[PropertyTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    return cell;
    
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self createSubviews];
    }
    
    return self;
}

-(void)createSubviews{
    
    self.photoBtn = [[UIButton alloc]init];
    self.photoBtn.backgroundColor = mainColor;
    self.photoBtn.layer.cornerRadius = 20;
    self.photoBtn.titleLabel.font = LargeFont;
    [self.photoBtn setTitle:@"系统" forState:UIControlStateNormal];
    [self.photoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.contentView addSubview:self.photoBtn];
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.textColor = mainTextColor;
    self.titleLabel.font = LargeFont;
    [self.contentView addSubview:self.titleLabel];
    
    self.timeLabel = [[UILabel alloc]init];
    self.timeLabel.textColor = lineColor;
    self.timeLabel.font = SmallFont;
    [self.contentView addSubview:self.timeLabel];
    
    self.desLabel = [[UILabel alloc]init];
    self.desLabel.textColor = mainTextColor;
    self.desLabel.font = MiddleFont;
    [self.contentView addSubview:self.desLabel];
    
    self.statusLabel = [[UILabel alloc]init];
    self.statusLabel.textColor = ITextColor;
    self.statusLabel.font = SmallFont;
    [self.contentView addSubview:self.statusLabel];
    
    
    [self.photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(15);
        make.top.equalTo(self.contentView).with.offset(15);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
    
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.photoBtn.mas_right).with.offset(20);
        make.right.equalTo(self.contentView).with.offset(-15);
        make.top.equalTo(self.contentView).with.offset(20);
        make.height.equalTo(@20);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.height.equalTo(@10);
    }];
    
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.titleLabel);
        make.top.equalTo(self.timeLabel.mas_bottom);
        make.bottom.equalTo(self.contentView);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.photoBtn).with.offset(7);
        make.top.equalTo(self.photoBtn).with.offset(-7);
        make.height.equalTo(@15);
    }];
}

-(void)setModel:(PropertyModel *)model
{
    // 在此处理赋值问题
   
    //标题
    NSString * titleStr = @"";
    if ([model.fpush_type isEqualToString:@"0910"]) {
        titleStr = @"派单";
    }
    else if ([model.fpush_type isEqualToString:@"0911"]){
        titleStr = @"接单";
    }else if ([model.fpush_type isEqualToString:@"0912"]){
        titleStr = @"完成工单";
    }else if ([model.fpush_type isEqualToString:@"0913"]){
        titleStr = @"转单";
    }else if ([model.fpush_type isEqualToString:@"0914"]){
        titleStr = @"工单有新回复";
    }else if ([model.fpush_type isEqualToString:@"0915"]){
        titleStr = @"工单有新评论";
    }else if ([model.fpush_type isEqualToString:@"0916"]){
        titleStr = @"提醒转单";
    }else if ([model.fpush_type isEqualToString:@"0917"]){
        titleStr = @"系统结束工单";
    }else if ([model.fpush_type isEqualToString:@"0918"]){
        titleStr = @"业主催单";
    }else if ([model.fpush_type isEqualToString:@"0919"]){
        titleStr = @"新建工单";
    }else if ([model.fpush_type isEqualToString:@"0920"]){
        titleStr = @"返回工单";
    }else if ([model.fpush_type isEqualToString:@"0921"]){
        titleStr = @"取消工单";
    }
    self.titleLabel.text = titleStr;
    
    if (![PMTools isNullOrEmpty:model.fcreatetime]) {
        self.timeLabel.text = model.fcreatetime;
    }
    if (![PMTools isNullOrEmpty:model.fcontent]) {
        self.desLabel.text = model.fcontent;
    }
    self.statusLabel.text = @"新";

}


@end
