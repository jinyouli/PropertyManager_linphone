//
//  PlotTableViewCell.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "PlotTableViewCell.h"

@interface PlotTableViewCell()

@property (nonatomic,strong) UIButton * photoBtn;
@property (nonatomic,strong) UILabel * titleLabel;
@property (nonatomic,strong) UILabel * timeLabel;


@end


@implementation PlotTableViewCell
+(instancetype)cellWithTableview:(UITableView *)tableview{
    
    return [[self alloc]initWithTableview:tableview];
}

-(instancetype)initWithTableview:(UITableView *)tableview{
    
    static NSString * identify = @"PlotNewsCell";
    PlotTableViewCell * cell = [tableview dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[PlotTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        
    }
    
    return cell;
    
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
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
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.numberOfLines = 0;
    [self.contentView addSubview:self.titleLabel];
    
    self.timeLabel = [[UILabel alloc]init];
    self.timeLabel.textColor = lineColor;
    self.timeLabel.font = SmallFont;
    [self.contentView addSubview:self.timeLabel];
    
    
    self.statusLabel = [[UILabel alloc]init];
    self.statusLabel.textColor = ITextColor;
    self.statusLabel.font = SmallFont;
    [self.contentView addSubview:self.statusLabel];
    
    
    [self.photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(15);
        make.top.equalTo(self.contentView).with.offset(25);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
    
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.photoBtn.mas_right).with.offset(20);
        make.right.equalTo(self.contentView).with.offset(-15);
        make.top.equalTo(self.photoBtn);
        make.height.equalTo(self.photoBtn);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.photoBtn).with.offset(7);
        make.top.equalTo(self.photoBtn).with.offset(-7);
        make.height.equalTo(@15);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-10);
        make.top.equalTo(self.contentView).with.offset(15);
        make.height.equalTo(@15);
    }];
    
    

}

-(void)setModel:(PlotModel *)model
{
    _model = model;
    // 在此处理赋值问题
    [self.photoBtn setTitle:@"公告" forState:UIControlStateNormal];
    self.titleLabel.text = model.title;
    self.timeLabel.text = model.time;
    self.statusLabel.text = model.state?@"":@"新";
    
}

@end
