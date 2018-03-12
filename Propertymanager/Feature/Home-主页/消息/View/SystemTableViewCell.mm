//
//  SystemTableViewCell.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "SystemTableViewCell.h"

@interface SystemTableViewCell()

@property (nonatomic,strong) UIButton * photoBtn;
@property (nonatomic,strong) UILabel * titleLabel;
@property (nonatomic,strong) UILabel * timeLabel;
@property (nonatomic,strong) UILabel * desLabel;
@property (nonatomic,strong) UILabel * statusLabel;


@end

@implementation SystemTableViewCell

+(instancetype)cellWithTableview:(UITableView *)tableview{
    
    return [[self alloc]initWithTableview:tableview];
}

-(instancetype)initWithTableview:(UITableView *)tableview{
    
    static NSString * identify = @"SystemNewsCell";
    SystemTableViewCell * cell = [tableview dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[SystemTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
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
    [self.photoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.contentView addSubview:self.photoBtn];
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.textColor = mainTextColor;
    self.titleLabel.font = [UIFont systemFontOfSize:20];
    [self.contentView addSubview:self.titleLabel];
    
    self.timeLabel = [[UILabel alloc]init];
    self.timeLabel.textColor = lineColor;
    self.timeLabel.font = SmallFont;
    [self.contentView addSubview:self.timeLabel];
    
    self.desLabel = [[UILabel alloc]init];
    self.desLabel.textColor = mainTextColor;
    self.desLabel.font = [UIFont systemFontOfSize:13];
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
        make.left.equalTo(self.photoBtn.mas_right).with.offset(15);
        make.right.equalTo(self.contentView).with.offset(-15);
        make.top.equalTo(self.contentView).with.offset(20);
        make.height.equalTo(@30);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.photoBtn).with.offset(7);
        make.top.equalTo(self.photoBtn).with.offset(-7);
        make.height.equalTo(@15);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-10);
        make.top.equalTo(self.titleLabel).with.offset(5);
        make.height.equalTo(@15);
    }];
    
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.contentView).with.offset(-35);
        make.top.equalTo(self.titleLabel.mas_bottom);
    }];
    

}

-(void)setModel:(PlotModel *)model
{
    // 在此处理赋值问题
    [self.photoBtn setTitle:@"系统" forState:UIControlStateNormal];
    self.titleLabel.text = model.title;
    self.timeLabel.text = model.time;
    self.desLabel.text = model.content;
    self.statusLabel.text = model.state?@"":@"新";
    
}


@end
