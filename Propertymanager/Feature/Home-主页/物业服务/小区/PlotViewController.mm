//
//  PlotViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/16.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "PlotViewController.h"
#import "PlotHtmlIem.h"
#import "PlotNeighborMsgModel.h"
#import "FGalleryViewController.h"
/**轮播图宽度*/
const CGFloat BannerWidth = ScreenWidth * 7 / 8;
/**轮播小图的Y值*/
const CGFloat SmallBannerY = 20.0;
/**轮播大图的Y值*/
const CGFloat LargeBannerY = 10.0;
/**顶部高度*/
const CGFloat topHight = 150.0;
/**左边出界Frame*/
const CGRect OutLeftBannerFrame = CGRectMake((ScreenWidth - BannerWidth)/2 - 10 - 2 * BannerWidth, SmallBannerY, BannerWidth, topHight - 2 * SmallBannerY);
/**右边出界Frame*/
const CGRect OutRightBannerFrame = CGRectMake((ScreenWidth + BannerWidth)/2 + 10 + BannerWidth, SmallBannerY, BannerWidth, topHight - 2 * SmallBannerY);
/**左边轮播图的Frame*/
const CGRect LeftBannerFrame = CGRectMake((ScreenWidth - BannerWidth)/2 - 10 - BannerWidth, SmallBannerY, BannerWidth, topHight - 2 * SmallBannerY);
/**中间轮播图的Frame*/
const CGRect CenterBannerFrame = CGRectMake((ScreenWidth - BannerWidth)/2, 10, BannerWidth, topHight - 20);
/**右边轮播图的Frame*/
const CGRect RightBannerFrame = CGRectMake((ScreenWidth + BannerWidth)/2 + 10, SmallBannerY, BannerWidth, topHight - 2 * SmallBannerY);


@interface PlotViewController ()<FGalleryViewControllerDelegate>
{
    NSInteger btnWidth;
    NSInteger myBtnPadding;
    NSInteger currentTag;
}
/** 图片轮播图连接数组*/
@property (nonatomic,strong) NSArray <PlotHtmlIem *> * html_list;
/** 小区内容模型数组*/
@property (nonatomic,strong) NSArray <PlotNeighborMsgModel *>* neighbor_msg_list;

@property (nonatomic,strong) NSMutableArray * imag_list;

@property (nonatomic,strong) NSArray * colorArr;
@property(nonatomic,strong)NSTimer *timer;

@property (nonatomic,strong) NSArray * imagListArr;

@property (nonatomic,strong) UIScrollView * scrollview;
@property (nonatomic,strong) UIView * topView;
@end

@implementation PlotViewController
#pragma mark - life cycle
#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        
        self.colorArr = @[@"e4507a",@"f16e5e",@"fea200",@"35b87e",@"5ab4d8",@"66cbcb"];
        myBtnPadding = iPhone4s || iPhone5s ? 10 : 20;
        btnWidth = (ScreenWidth - myBtnPadding  * 5) * 0.25;
        self.imag_list = [NSMutableArray array];
        self.navigationController.navigationBar.translucent = NO;
        self.view.backgroundColor = sBGColor;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createLeftBarButtonItemWithTitle:@"小区"];
    [self.view addSubview:self.topView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self gainDataFromNetWork];
    });
 
}

#pragma mark - Delegate 实现方法
#pragma mark - FGalleryViewControllerDelegate
//图片数量
- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController*)gallery
{
    return (int)self.imagListArr.count;
}
//图片资源来源 类型
- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController*)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
    return FGalleryPhotoSourceTypeNetwork;
}
//图片url
- (NSString*)photoGallery:(FGalleryViewController*)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index
{
    NSDictionary * dic = self.imagListArr[index];
    return dic[@"imagpath"];
}

#pragma mark - event response
#pragma mark - private methods
- (void)backAction
{
    [self.timer invalidate];
    self.timer = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
    });
}
-(void)timerChange{
    
    [self fromRightToLeft:currentTag];
    
}
-(void)gainDataFromNetWork{
    
    if ([self checkNetWork]) {
        
        UserManager * user = [UserManagerTool userManager];
        NSDictionary *paraDic = @{@"department_id":user.department_id};
        [DetailRequest SYGet_neibor_msgWithParms:paraDic SuccessBlock:^(NSDictionary *result) {
            
            self.imagListArr = result[@"imag_list"];
            
            for (int i = 0; i < self.imagListArr.count; i ++) {
                [self.imag_list addObject:self.imagListArr[i][@"imagpath"]];
            }
            
            switch (self.imagListArr.count) {
                case 0:
                {
                    [SVProgressHUD showErrorWithStatus:@"暂无相关数据"];
                    break;
                }
                case 1:
                {
                    [self.imag_list addObject:self.imag_list[0]];
                }
                case 2:
                {
                    NSInteger tag = self.imagListArr.count == 1 ? 0 : 1;
                    [self.imag_list addObject:self.imag_list[tag]];
                }
                case 3:
                {
                    [self.imag_list addObject:self.imag_list[0]];
                }
                    
                default:
                    break;
            }
            
            self.neighbor_msg_list = [PlotNeighborMsgModel mj_objectArrayWithKeyValuesArray:result[@"neighbor_msg_list"]];
            self.html_list = [PlotHtmlIem mj_objectArrayWithKeyValuesArray:result[@"html_list"]];
            
            [self reloadView];
            
        }];
        
    }
}

-(void)reloadView{
    
    if ([NSThread isMainThread])
    {
        [self reloadSubViews];
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self reloadSubViews];
        });
    }
}

-(void)reloadSubViews{
    
    [self createBanner];
    
    if (self.neighbor_msg_list.count != 0) {
        //小区信息
        PlotNeighborMsgModel * model = self.neighbor_msg_list[0];
        [self createLeftBarButtonItemWithTitle:model.fneibname];
    }
    
    if (self.html_list.count > 0 ) {
        
        CGFloat sY = CGRectGetMaxY(self.topView.frame);
        self.scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, sY, ScreenWidth, ScreenHeight - sY - 64)];
        self.scrollview.showsVerticalScrollIndicator = NO;
        [self.view addSubview:self.scrollview];
        self.scrollview.contentSize = self.scrollview.frame.size;
        
        for (int i = 0; i < self.html_list.count; i ++) {
            PlotHtmlIem * model = self.html_list[i];
            NSString * fheadline = model.fheadline;
            
            UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(myBtnPadding  + (btnWidth + myBtnPadding ) * (i%4), 30 + (btnWidth + myBtnPadding) * (i / 4), btnWidth, btnWidth)];
            btn.layer.cornerRadius = btnWidth / 2;
            btn.clipsToBounds = YES;
            btn.backgroundColor = [PMTools colorFromHexRGB:self.colorArr[i % 6]];
            btn.titleLabel.font = MiddleFont;
            [btn addTarget:self action:@selector(contactBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 4000 + i;
            [self.scrollview addSubview:btn];
            
            UILabel * label = [[UILabel alloc]initWithFrame:btn.bounds];
            label.font = MiddleFont;
            label.numberOfLines = 0;
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            [btn addSubview:label];
            
            if (fheadline.length > 4) {
                fheadline = [fheadline substringToIndex:4];
            }
            switch (fheadline.length) {
                case 4:
                {
                    NSString * sub1 = [fheadline substringToIndex:2];
                    NSString * sub2 = [fheadline substringFromIndex:2];
                    fheadline = [NSString stringWithFormat:@"%@\n%@",sub1,sub2];
                }
                    break;
                case 2:
                case 1:
                    label.font = LargeFont;
                    break;
            }
            label.text = fheadline;
            
            if (i == self.html_list.count - 1) {
                //最后一个 更改scrollview的内容大小
                self.scrollview.contentSize = CGSizeMake(ScreenWidth, CGRectGetMaxY(btn.frame) + 10);
            }
        }
        
        
    }
}

#pragma mark 服务内容的图片点击处理
- (void)photoTap
{
    FGalleryViewController *gallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
    
    [self.navigationController pushViewController:gallery animated:NO];
    
}

#pragma mark - getters and setters

-(void)createBanner{
    for (int i = 0; i < self.imag_list.count; i ++) {
        UIImageView * imageView = [[UIImageView alloc]init];
        imageView.layer.cornerRadius = 2;
        imageView.clipsToBounds = YES;
        imageView.tag = 100 + i;
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.imag_list[i]] placeholderImage:[UIImage imageNamed:@""]];
        imageView.userInteractionEnabled = YES;
        [self.topView addSubview:imageView];
        if (i == 0) {
            imageView.frame = LeftBannerFrame;
        }
        else if (i == 1){
            imageView.frame = CenterBannerFrame;
            currentTag = 101;
        }
        else if (i == 2){
            imageView.frame = RightBannerFrame;
        }
        else{
            imageView.frame = OutRightBannerFrame;
        }
        
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panHandle:)];
        pan.minimumNumberOfTouches = 1;
        pan.maximumNumberOfTouches = 1;
        [imageView addGestureRecognizer:pan];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoTap)];
        [imageView addGestureRecognizer:tap];
    }
    
    //做一个计时器去改变scrollView
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timerChange) userInfo:nil repeats:YES];

}

-(void)panHandle:(UIPanGestureRecognizer *)pan{
    NSInteger tag = pan.view.tag;
    currentTag = tag;
    if (pan.state == UIGestureRecognizerStateEnded && pan.state != UIGestureRecognizerStateFailed) {
        CGPoint location = [pan locationInView:pan.view.superview];
        if (location.x < ScreenWidth/2) {
            //向左
            [self fromRightToLeft:tag];
            
        }
        else{
            [self fromLeftToRight:tag];
        }
    }
}

-(void)fromRightToLeft:(NSInteger)tag{
    if ((tag - 100) != self.imag_list.count - 1) {
        //不是最后一张
        UIImageView * leftImageView = (UIImageView *)[self.topView viewWithTag:tag - 1];
        if (tag == 100) {
            leftImageView = (UIImageView *)[self.topView viewWithTag:100 + self.imag_list.count - 1];
        }
        UIImageView * centerImageView = (UIImageView *)[self.topView viewWithTag:tag];
        UIImageView * rightImageView = (UIImageView *)[self.topView viewWithTag:tag + 1];
        UIImageView * outRightImageView = (UIImageView *)[self.topView viewWithTag:tag + 2];
        if ((tag - 100) == self.imag_list.count - 2) {
            outRightImageView = (UIImageView *)[self.topView viewWithTag:100];
        }
        outRightImageView.frame = OutRightBannerFrame;
        
        [UIView animateWithDuration:0.2 animations:^{
            leftImageView.frame = OutLeftBannerFrame;
            centerImageView.frame = LeftBannerFrame;
            rightImageView.frame = CenterBannerFrame;
            outRightImageView.frame = RightBannerFrame;
            currentTag = tag + 1;
        }];
        
        
    }
    else{
        UIImageView * leftImageView = (UIImageView *)[self.topView viewWithTag:tag - 1];
        UIImageView * centerImageView = (UIImageView *)[self.topView viewWithTag:tag];
        UIImageView * rightImageView = (UIImageView *)[self.topView viewWithTag:100];
        UIImageView * outRightImageView = (UIImageView *)[self.topView viewWithTag:101];
        outRightImageView.frame = OutRightBannerFrame;
        
        [UIView animateWithDuration:0.2 animations:^{
            leftImageView.frame = OutLeftBannerFrame;
            centerImageView.frame = LeftBannerFrame;
            rightImageView.frame = CenterBannerFrame;
            outRightImageView.frame = RightBannerFrame;
            currentTag = 100;
        }];
        
    }

}


-(void)fromLeftToRight:(NSInteger)tag{
    //向右
    if ((tag - 100) != 0) {
        //不是第一张
        UIImageView * outLeftImageView = (UIImageView *)[self.topView viewWithTag:tag - 2];
        
        UIImageView * leftImageView = (UIImageView *)[self.topView viewWithTag:tag - 1];
        //                leftImageView.frame = LeftBannerFrame;
        if (tag == 101) {
            outLeftImageView = (UIImageView *)[self.topView viewWithTag:100 + self.imag_list.count - 1];
            
        }
        
        
        UIImageView * centerImageView = (UIImageView *)[self.topView viewWithTag:tag];
        UIImageView * rightImageView = (UIImageView *)[self.topView viewWithTag:tag + 1];
        
        
        
        outLeftImageView.frame = OutLeftBannerFrame;
        
        [UIView animateWithDuration:0.2 animations:^{
            
            outLeftImageView.frame = LeftBannerFrame;
            leftImageView.frame = CenterBannerFrame;
            centerImageView.frame = RightBannerFrame;
            rightImageView.frame = OutRightBannerFrame;
            currentTag = tag - 1;
            
        }];
    }
    else{
        //是第一张
        
        UIImageView * outLeftImageView = (UIImageView *)[self.topView viewWithTag:tag + self.imag_list.count - 2];
        outLeftImageView.frame = OutLeftBannerFrame;
        
        UIImageView * leftImageView = (UIImageView *)[self.topView viewWithTag:100 + self.imag_list.count - 1];
        leftImageView.frame = LeftBannerFrame;
        
        UIImageView * centerImageView = (UIImageView *)[self.topView viewWithTag:tag];
        UIImageView * rightImageView = (UIImageView *)[self.topView viewWithTag:tag + 1];
        
        
        [UIView animateWithDuration:0.2 animations:^{
            
            outLeftImageView.frame = LeftBannerFrame;
            leftImageView.frame = CenterBannerFrame;
            centerImageView.frame = RightBannerFrame;
            rightImageView.frame = OutRightBannerFrame;
            currentTag = 100 + self.imag_list.count - 1;
            
        }];
        
    }
}


-(void)contactBtnClick:(UIButton *)btn{
    
    NSInteger index = btn.tag - 4000;
    PlotHtmlIem * model = self.html_list[index];
    NSString * fhtml_url = model.fhtml_url;
    NSString * fheadline = model.fheadline;
    [[Routable sharedRouter] open:PLOTWEB_VIEWCONTROLLER animated:YES extraParams:@{@"myTitle":fheadline,@"myURLStr":fhtml_url}];
    
}



- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, topHight)];
    }
    return _topView;
}



@end
