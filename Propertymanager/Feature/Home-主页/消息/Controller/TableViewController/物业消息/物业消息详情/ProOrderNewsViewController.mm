//
//  ProOrderNewsViewController.m
//  idoubs
//
//  Created by Momo on 16/6/22.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "ProOrderNewsViewController.h"
#import "ComplainHeaderDataModel.h"
#import "ComplainReplyDataModel.h"
#import "ComplainHeaderFrame.h"
#import "ComplainReplyFrame.h"
#import "ComplainOrderTableViewCell.h"
#import "ComplainHeaderView.h"

#import "FGalleryViewController.h" //图片展示

@interface ProOrderNewsViewController ()<UITableViewDelegate,UITableViewDataSource,FGalleryViewControllerDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) NSArray * lookImageList;
@property (nonatomic,strong) UITableView * tableview;
@property (nonatomic,strong) ComplainHeaderFrame * frameModel;
@property (nonatomic,strong) ComplainHeaderDataModel * dataModel;
@property (nonatomic,strong) NSMutableArray * replyArr; // 回复数组

@end

@implementation ProOrderNewsViewController
#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        
        self.frepairs_id = params[@"frepairs_id"];
    }
    return self;
}




-(void)dealloc{
    SYLog(@"ProOrderNewsViewController dealloc");
    self.view = nil;
    self.lookImageList = nil;
    self.tableview = nil;
    self.frameModel = nil;
    self.dataModel = nil;
    self.replyArr = nil;
}

-(ComplainHeaderFrame *)frameModel{
    if (!_frameModel) {
        _frameModel = [[ComplainHeaderFrame alloc]init];
    }
    return _frameModel;
}
-(ComplainHeaderDataModel *)dataModel{
    if (!_dataModel) {
        _dataModel = [[ComplainHeaderDataModel alloc]init];
    }
    return _dataModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createLeftBarButtonItemWithTitle:@"工单动态"];
    self.replyArr = [NSMutableArray array];
    
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self checkNetWork]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getDataFromNetWork];
        });
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"requestData1" object:nil];
}

-(void)createSubviews{
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 11.0) {
        self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];
    }else{
        self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, -32, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];
    }
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.view addSubview:self.tableview];
    
    
    
}

-(void)getDataFromNetWork{
    
    UserManager * user = [UserManagerTool userManager];
    NSDictionary *paraDic = @{@"worker_id":user.worker_id,@"power_type":user.power_type,@"repairs_id":self.frepairs_id,@"type":@"2"};
    
    [DetailRequest SYGet_work_order_by_idWithParms:paraDic SuccessBlock:^(NSDictionary * result,NSArray * details_list) {
        self.dataModel = [ComplainHeaderDataModel mj_objectWithKeyValues:result];
        NSArray * replyArray = [ComplainReplyDataModel mj_objectArrayWithKeyValuesArray:details_list];
        
        for (int i = 0; i < replyArray.count; i ++) {
            ComplainReplyDataModel * replyModel = replyArray[i];
            replyModel.ID = self.frameModel.headerDataModel.fordernum;;
            
            replyModel.reply_imag_list = details_list[i][@"record_imag_list"];
            ComplainReplyFrame * frame = [[ComplainReplyFrame alloc]init];
            frame.replyDataModel = replyModel;
            [self.replyArr addObject:frame];
        }
        
        self.frameModel = [[ComplainHeaderFrame alloc]init];
        self.frameModel.headerDataModel = self.dataModel;
        
        // 刷新数据
        [self reloadView];
        
        // 更新物业动态为已读
        [DetailRequest SYUpdate_push_msg_to_readWithParms:@{@"worker_id":user.worker_id,@"repairs_id":self.frepairs_id}];
    }];
}

#pragma mark - 处理回调
-(void)myBlock:(NSInteger)section withFlag:(NSInteger)flag withImageIndex:(NSInteger)imageIndex{

    switch (flag) {
        case 1:
            
        case 2:
            
        case 9:
        {
            NSMutableDictionary * params = [NSMutableDictionary dictionary];
            NSString * do_type = flag == 9 ? @"2":@"1";
            params[@"do_type"] = do_type;
            params[@"repairs_id"] = self.dataModel.repair_id;
            if (flag == 9) {
                params[@"deal_worker_id"] = self.dataModel.deal_worker_id;
            }
            [[Routable sharedRouter] open:SENDORDER_VIEWCONTROLLER animated:YES extraParams:params];
            
        }
            break;
            
        case 3:
        {
            SYLog(@"接受按钮");
            [[Routable sharedRouter] open:ACCEPTORDER_VIEWCONTROLLER animated:YES extraParams:@{@"dataModel":self.dataModel,@"frameModel":self.frameModel,@"section":@(section),@"isOrderDetail":@(YES)}];
        }
            break;
        case 4:
        {
            SYLog(@"完成按钮");
            
            [[Routable sharedRouter] open:COMPLETEORDER_VIEWCONTROLLER animated:YES extraParams:@{@"isFirstSendMgr":self.dataModel.power_do,@"repairs_id":self.dataModel.repair_id,@"section":@(section),@"isProOrderPush":@(YES)}];
        }
            break;
        case 5:
        {
            SYLog(@"点击详情 加载数据");
        }
            break;
        case 6:
        {
            SYLog(@"点击评论");
            [[Routable sharedRouter] open:ORDERCOMMAND_VIEWCONTROLLER animated:YES extraParams:@{@"repairs_id":self.dataModel.repair_id,@"fname":self.dataModel.frealname}];
        }
            break;
        case 7:
        {
            if (!imageIndex) {
                imageIndex = 0;
            }
            
            self.lookImageList = self.dataModel.repairs_imag_list;
            NSLog(@"打印图片==%@",self.lookImageList);
            FGalleryViewController * fvc = [[FGalleryViewController alloc]initWithPhotoSource:self];
            
            if (imageIndex < self.lookImageList.count) {
                [fvc gotoImageByIndex:imageIndex animated:NO];
            }
            
            [self.navigationController pushViewController:fvc animated:YES];
            
        }
            break;
        case 8:
        {
            SYLog(@"查看业主");
            [[Routable sharedRouter] open:OWNER_VIEWCONTROLLER animated:YES extraParams:@{@"isOwner":@(YES),@"ownerName":self.dataModel.frealname,@"ownerPhone":self.dataModel.fusername,@"ownerAddr":self.dataModel.faddress}];
        }
            break;
            
        case 10:
        {
            SYLog(@"拨打电话");
            [PMTools callPhoneNumber:self.dataModel.flinkman_phone inView:self.tableview];
            
        }
            break;
            
        default:
            break;
    }
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

                [cell.photo3 sd_setBackgroundImageWithURL:[NSURL URLWithString:arr[1][@"fimagpath"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"logo80"]];
                
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
        replyData.ID = self.frameModel.headerDataModel.fordernum;;
        
        
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
    return self.frameModel.cellHeight;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    static NSString * identy = @"myDetailHeaderView";
    ComplainHeaderView * headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identy];
    if (!headerView) {
        headerView = [[ComplainHeaderView alloc]initWithReuseIdentifier:identy];
    }
    
    headerView.photo1.hidden = YES;
    headerView.photo2.hidden = YES;
    headerView.photo3.hidden = YES;
    
    headerView.frame = CGRectMake(0, 10, ScreenWidth, self.frameModel.cellHeight);
    headerView.section = section;
    [headerView returnComplainHeaderBlock:^(NSInteger section, NSInteger flag, NSInteger imagePos) {
        [self myBlock:section withFlag:flag withImageIndex:imagePos];
    }];
    headerView.headerFrame = self.frameModel;
    
    return headerView;

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
        [self.tableview reloadData];
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableview reloadData];
            
        });
    }
}

#pragma mark 服务内容的图片点击处理
- (void)photoTap
{
    FGalleryViewController *gallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
    
    [self.navigationController pushViewController:gallery animated:NO];
    
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [[SDImageCache sharedImageCache] clearMemory];
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [[SDImageCache sharedImageCache] clearMemory];
}

@end
