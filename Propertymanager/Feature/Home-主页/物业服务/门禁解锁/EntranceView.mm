//
//  EntranceView.m
//  PropertyManager
//
//  Created by Momo on 16/9/13.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "EntranceView.h"
#import "SliderScroView.h"
@interface EntranceView ()<SliderScroViewDelegate>
{
    SliderScroView * _slideScr;
}
@property (nonatomic,strong) SliderScroView * slideScr;

@property (nonatomic,assign) NSInteger rowHeight;
@end

@implementation EntranceView
-(instancetype)initWithFrame:(CGRect)frame withDomain:(NSString *)domain_sn sipNum:(NSString *)sipNum{
    if (self = [super initWithFrame:frame]) {
        self.domain_sn = domain_sn;
        self.sipNum = sipNum;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8;
        self.layer.borderColor = lineColor.CGColor;
        self.layer.borderWidth = 1;
        
        self.rowHeight = frame.size.height / 4;
        [self createSubviews];
    }
    return self;
}

-(void)createSubviews{
    NSArray * titles = @[@"",@"查看门口监控视频",@"点击打开门锁",@"取消"];
    NSArray * colors = @[mainTextColor,mainColor,lineColor,ITextColor];
    CGFloat height = self.rowHeight;
    CGFloat space = (height - 30) / 2;
    for (int i = 0; i < 4; i ++) {
        if (i != 2) {
            UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(0, height * i + space , self.frame.size.width, 30)];
            btn.tag = 100 + i;
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitleColor:colors[i] forState:UIControlStateNormal];
            [self addSubview:btn];
            
        }
        else{
            
            self.slideScr = [[SliderScroView alloc]initWithFrame:CGRectMake(10, height * i + space , self.frame.size.width - 20, 30) withSn_Domain:self.domain_sn type:@"0" sipNum:self.sipNum];
            self.slideScr.myDelegate = self;
            self.slideScr.contentOffset = CGPointMake(self.slideScr.frame.size.width, 0);
            [self addSubview:self.slideScr];
        }
        
        if (i != 0) {
            UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(0, height * i - 1, self.frame.size.width, 1)];
            line.backgroundColor = lineColor;
            [self addSubview:line];
        }
        
    }
}

-(void)setDomain_sn:(NSString *)domain_sn{
    _domain_sn = domain_sn;
    _slideScr.domain_sn = domain_sn;
}

-(void)setPlotName:(NSString *)plotName{
    UIButton * btn = (UIButton *)[self viewWithTag:100];
    [btn setTitle:plotName forState:UIControlStateNormal];
}

-(void)btnClick:(UIButton *)btn{
    if (btn.tag != 100) {
        if (self.block) {
            self.block(btn.tag - 100);
        }
    }
}

-(void)returnSelectIndex:(ReturnSelectIndex)block{
    if (!self.block) {
        self.block = block;
    }
}

-(void)RequestFinish{
    self.slideScr.contentOffset = CGPointMake(self.slideScr.frame.size.width, 0);
    
    if (self.block) {
        self.block(3);
    }
}

@end
