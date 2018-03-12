//
//  MoreHistroyCommandViewController.m
//  PropertyManager
//
//  Created by Momo on 16/9/22.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "MoreHistroyCommandViewController.h"

//model
#import "ComplainReplyDataModel.h"
#import "ComplainReplyFrame.h"

//cell
#import "ComplainOrderTableViewCell.h"

//图片展示
#import "FGalleryViewController.h"


@interface MoreHistroyCommandViewController ()<UITableViewDelegate,UITableViewDataSource,FGalleryViewControllerDelegate>

@property (nonatomic,strong) NSArray * lookImageList;
@property (nonatomic,strong) UITableView * tableview;
@property (nonatomic,strong) NSMutableArray * replyArr;
@property (nonatomic,assign) NSInteger page;
@end

@implementation MoreHistroyCommandViewController

#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        
        if (![PMTools isNullOrEmpty:params[@"sReplyArr"]]) {
            NSArray * arr = params[@"sReplyArr"];
            self.sReplyArr = [NSMutableArray arrayWithArray:arr];
        }
        else{
            self.sReplyArr = [NSMutableArray array];
        }
        
        if (![PMTools isNullOrEmpty:params[@"repairs_id"]]) {
            self.repairs_id = params[@"repairs_id"];
        }
        
        if (![PMTools isNullOrEmpty:params[@"fordernum"]]) {
            self.fordernum = params[@"fordernum"];
        }

        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createLeftBarButtonItemWithTitle:@"更多历史评论"];

    self.page = 1;
    self.replyArr = [[NSMutableArray alloc]initWithArray:self.sReplyArr];
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableview.mj_header beginRefreshing];
}

-(void)createSubviews{
    
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.view addSubview:self.tableview];
    
    self.tableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 1;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getOrder_details];
        });
    }];
    
    self.tableview.mj_footer = [MJRefreshFooter footerWithRefreshingBlock:^{
        self.page ++;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getOrder_details];
        });
    }];
    
    
    
}

#pragma mark - 下拉刷新
-(void)refreshData{
    SYLog(@"下拉刷新");
    [self.tableview.mj_header endRefreshing];
}

-(void)addAppendData{
    SYLog(@"上拉加载");
    [self.tableview.mj_footer endRefreshing];
}

#pragma mark - 获取工单详情
-(void)getOrder_details{
    //请求工单
    if (![self checkNetWork]) {
        return;
    }

    NSString * pageStr = [NSString stringWithFormat:@"%d",self.page];
    NSDictionary *paraDic = @{@"repairs_id":self.repairs_id,@"current_page":pageStr,@"page_size":@"10"};
    
    [DetailRequest MoreVCSYGet_work_order_detailsWithParms:paraDic SuccessBlock:^(NSArray *details) {
        
        if (details.count != 0) {
            
            if (self.page == 1) {
                [self.replyArr removeAllObjects];
            }
            
            NSArray * arr = [ComplainReplyDataModel mj_objectArrayWithKeyValuesArray:details];
            for (int i = 0 ; i < arr.count; i ++) {
                ComplainReplyDataModel * replyModel = arr[i];
                replyModel.ID = _fordernum;
                replyModel.reply_imag_list = details[i][@"record_imag_list"];
                ComplainReplyFrame * frame = [[ComplainReplyFrame alloc]init];
                frame.replyDataModel = replyModel;
                [self.replyArr addObject:frame];
                
            }
            
            [self reloadView];
        }
       
    } FailureBlock:^{
        if (self.page != 1) {
            self.page --;
        }
        [self.tableview.mj_header endRefreshing];
        [self.tableview.mj_footer endRefreshing];
    }];
}


#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.replyArr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ComplainReplyFrame * replyFrame = self.replyArr[indexPath.row];
    return replyFrame.replyCellHeight + 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ComplainOrderTableViewCell * cell = [ComplainOrderTableViewCell cellWithTableview:tableView];
    ComplainReplyFrame * replyFrame = self.replyArr[indexPath.row];
    cell.replyFrame = replyFrame;
    SYLog(@"replyFrame.image3ListF.origin.x === %f",replyFrame.image3ListF.origin.x);
    
    cell.indexPath = indexPath;
    
    //1.清空配图
    
    [cell.photo1 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [cell.photo2 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [cell.photo3 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    
    NSArray * arr = replyFrame.replyDataModel.reply_imag_list;
    SYLog(@"cell中的图片arr === %@",arr);
    if (arr.count != 0) {
        switch (arr.count) {
            case 6:
            case 5:
            case 4:
            case 3:
            {
                cell.photo3.hidden = NO;
                [cell.photo3 sd_setBackgroundImageWithURL:[NSURL URLWithString:arr[2][@"fimagpath"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"logo80"]];
            }
                
            case 2:
            {
                cell.photo2.hidden = NO;
                [cell.photo2 sd_setBackgroundImageWithURL:[NSURL URLWithString:arr[1][@"fimagpath"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"logo80"]];
                
            }
                
            case 1:
            {   cell.photo1.hidden = NO;
                [cell.photo1 sd_setBackgroundImageWithURL:[NSURL URLWithString:arr[0][@"fimagpath"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"logo80"]];
            }
                break;
        }
    }
    else{
        cell.photo1.hidden = YES;
        cell.photo2.hidden = YES;
        cell.photo3.hidden = YES;
    }
    
    
    //3.处理cell的回调事件 （查看图片）
    [cell myReplyImageBlock:^(NSIndexPath *indexPath, NSInteger imageIndex) {
        ComplainReplyFrame * replyFrame = self.replyArr[indexPath.row];
        ComplainReplyDataModel * replyData = replyFrame.replyDataModel;
        replyData.ID = _fordernum;
        
        self.lookImageList = replyData.reply_imag_list;
        FGalleryViewController * fvc = [[FGalleryViewController alloc]initWithPhotoSource:self];
        if (imageIndex < self.lookImageList.count) {
            fvc.myImageIndex = imageIndex;
        }
        [self.navigationController pushViewController:fvc animated:YES];
    }];
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

#pragma mark FGalleryViewControllerDelegate 5个方法
//图片数量
- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController*)gallery
{
    return (int)self.lookImageList.count;
}

//图片资源来源 类型
- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController*)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
    return FGalleryPhotoSourceTypeNetwork;
}

//图片url
- (NSString*)photoGallery:(FGalleryViewController*)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index
{
    NSDictionary * dic = self.lookImageList[index];
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




- (BOOL)checkNetWork{
    
    if (![PMTools connectedToNetwork]) {
        
        
        if ([NSThread isMainThread])
        {
            [SVProgressHUD showWithStatus:@"网络异常,请检查网络连接" maskType:SVProgressHUDMaskTypeGradient];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NotReachable" object:nil];
            [self dismissAction];
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [SVProgressHUD showWithStatus:@"网络异常,请检查网络连接" maskType:SVProgressHUDMaskTypeGradient];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NotReachable" object:nil];
                [self dismissAction];
                
            });
        }
        return NO;
    }
    return YES;
}

- (void)dismissAction {
    [self performSelector:@selector(disappear) withObject:nil afterDelay:1.5f];
}

- (void)disappear {
    
    [SVProgressHUD dismiss];
}

-(void)reloadView{
    
    if ([NSThread isMainThread])
    {
         [self.tableview.mj_header endRefreshing];
         [self.tableview.mj_footer endRefreshing];
        [self.tableview reloadData];
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableview.mj_header endRefreshing];
            [self.tableview.mj_footer endRefreshing];
            [self.tableview reloadData];
            
        });
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)dealloc{
    SYLog(@"MoreHistroyCommandViewController dealloc ");
    self.view = nil;
    self.tableview = nil;
}


@end
