//
//  NoDataCountView.m
//  PropertyManager
//
//  Created by Momo on 16/12/29.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "NoDataCountView.h"

@interface NoDataCountView ()

@property (nonatomic,strong) UIImageView * imageView;
@property (nonatomic,strong) UILabel * textLabel;


@end

@implementation NoDataCountView

- (instancetype) initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self createSubviews];
        
    }
    return self;
}

-(void)createSubviews{
    
    self.imageView = [[UIImageView alloc]init];
    self.imageView.image = [UIImage imageNamed:@"ic_error_page"];
    [self addSubview:self.imageView];
    
    self.textLabel = [[UILabel alloc]init];
    self.textLabel.text = @"没有更多数据";
    self.textLabel.textColor = mainTextColor;
    [self addSubview:self.textLabel];
    
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(@160);
        make.height.equalTo(@200);
    }];
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).with.offset(10);
        make.centerX.equalTo(self);
        make.height.equalTo(@30);
    }];
}

@end
