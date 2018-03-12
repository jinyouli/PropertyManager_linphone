//
//  PlotCellDetailViewController.m
//  idoubs
//
//  Created by Momo on 16/6/22.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "PlotCellDetailViewController.h"

@interface PlotCellDetailViewController ()

@property (nonatomic,strong) UIScrollView * backView;
@property (nonatomic,strong) UIButton * photoBtn;
@property (nonatomic,strong) UILabel * titleLabel;
@property (nonatomic,strong) UILabel * timeLabel;
@property (nonatomic,strong) UILabel * contentLabel;

@end

@implementation PlotCellDetailViewController

#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        
        if (![PMTools isNullOrEmpty:params[@"isPloy"]]) {
            self.isPloy = [params[@"isPloy"] boolValue];
        }
        
        if (![PMTools isNullOrEmpty:params[@"myTitle"]]) {
            self.myTitle = params[@"myTitle"];
        }
        
        if (![PMTools isNullOrEmpty:params[@"myTime"]]) {
            self.myTime = params[@"myTime"];
        }
        
        if (![PMTools isNullOrEmpty:params[@"myContent"]]) {
            self.myContent = params[@"myContent"];
        }
        
    }
    return self;
}


-(void)dealloc{
    SYLog(@"PlotCellDetailViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * title = self.isPloy?@"公告详情":@"系统消息";
    self.view.backgroundColor = BGColor;
    [self createLeftBarButtonItemWithTitle:title];
    
    [self createSubviews];
    [self subviewsData];
}


-(void)createSubviews{
    
    CGSize contenSize = [PMTools sizeWithText:self.myContent font:[UIFont systemFontOfSize:18] maxSize:CGSizeMake(ScreenWidth - 40, 1000)];
    CGFloat heightS = contenSize.height + 100 > (ScreenHeight - 64)?(ScreenHeight - 64):contenSize.height + 100;
    self.backView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, heightS)];
    self.backView.backgroundColor = sBGColor;
    [self.view addSubview:self.backView];
    self.backView.contentSize = CGSizeMake(ScreenWidth, contenSize.height + 100);
    self.backView.showsVerticalScrollIndicator = NO;
    
    
    self.photoBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, 15, 40, 40)];
    self.photoBtn.backgroundColor = mainColor;
    self.photoBtn.layer.cornerRadius = 20;
    self.photoBtn.titleLabel.font = LargeFont;
    [self.photoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.backView addSubview:self.photoBtn];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 15, ScreenWidth - 95, 40)];
    self.titleLabel.textColor = mainTextColor;
    self.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    self.titleLabel.numberOfLines = 0;
    [self.backView addSubview:self.titleLabel];
    
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, CGRectGetMaxY(self.titleLabel.frame), ScreenWidth - 95, 15)];
    self.timeLabel.textColor = lineColor;
    self.timeLabel.font = SmallFont;
    [self.backView addSubview:self.timeLabel];
    
    
    self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(self.timeLabel.frame) + 10, contenSize.width, contenSize.height)];
    self.contentLabel.font = [UIFont systemFontOfSize:18];
    self.contentLabel.textColor = mainTextColor;
    self.contentLabel.numberOfLines = 0;
    [self.backView addSubview:self.contentLabel];
    
    
}

-(void)subviewsData{
    [self.photoBtn setTitle:self.isPloy?@"公告":@"系统" forState:UIControlStateNormal];
    self.titleLabel.text = self.myTitle;
    self.timeLabel.text = self.myTime;
    self.contentLabel.text = self.myContent;
}


@end
