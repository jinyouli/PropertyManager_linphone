//
//  BaseRepairsTableViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/16.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "BaseRepairsTableViewController.h"
@interface BaseRepairsTableViewController ()<UIScrollViewDelegate>

@property (nonatomic,assign) BOOL isFirstRequest;

@end

@implementation BaseRepairsTableViewController

-(void)dealloc{
    SYLog(@"BaseRepairsTableViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotReachable" object:nil];
}

-(instancetype)initWithIsRepairType:(BOOL)isRepairType status:(NSString *)status is_get_my:(NSString *)is_get_my dBType:(NSString *)dBType{
    
    self.framesArr = [NSMutableArray array];
    self.detailDic = [[NSMutableDictionary alloc]init];
    self.isRepairType = isRepairType;
    self.status = status;
    self.is_get_my = is_get_my;
    self.dBType = dBType;

    return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.backgroundColor = BGColor;
    self.tableView.showsVerticalScrollIndicator = YES;
    self.framesArr = [NSMutableArray array];
    self.isFirstRequest = YES;
    
    self.noDataCountView = [[NoDataCountView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 160)];
    self.noDataCountView.hidden = YES;
    [self.tableView addSubview:self.noDataCountView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getDataFromDB];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getDataFromNetWork];
    });

    [self createTableviewRefresh];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endRefresh) name:@"NotReachable" object:nil];
}

-(void)cheakDataCount{
    if (self.framesArr.count == 0) {
        self.noDataCountView.hidden = NO;
    }
    else{
        self.noDataCountView.hidden = YES;
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [[SDImageCache sharedImageCache] clearMemory];
}

-(void)updateDataByDate{
    self.page = 1;
    [self getDataFromNetWork];
}

-(void)getDataFromNetWork{
    
    AFHTTPSessionManager * manager = [PMRequest gainAFNManager];
    [manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    NSString * url = MyUrl(SYGet_work_order_list);
    UserManager * user = [UserManagerTool userManager];
    NSString * time_flag = @"1";
    
    if ([self.status isEqualToString:@"1"]) {
        time_flag = [MyUserDefaults objectForKey:@"untreatedDate"];
    }
    else if ([self.status isEqualToString:@"2"]) {
        time_flag = [MyUserDefaults objectForKey:@"processingDate"];
    }
    else if ([self.status isEqualToString:@"3"]) {
        time_flag = [MyUserDefaults objectForKey:@"completedDate"];
    }
    
    NSDictionary *paraDic = @{@"status":self.status,
                              @"time_flag":time_flag,
                              @"department_id":user.department_id,
                              @"worker_id":user.worker_id,
                              @"is_get_my":self.is_get_my,
                              @"power_type":user.power_type,
                              @"current_page":@(self.page),
                              @"page_size":@"20",
                              @"order_type":self.isRepairType?@"1":@"2"};
    
    [self getDataWithURl:url withHeader:HeadDic withParaDic:paraDic withType:self.dBType];
}

-(void)getDataFromDB{
    
    UserManager * user = [UserManagerTool userManager];
    MyFMDataBase * database = [MyFMDataBase shareMyFMDataBase];
    BOOL ret = [database createDataBaseWithDataBaseName:user.worker_id];
    [self.framesArr removeAllObjects];
    
    if (ret) {
        self.ordelsArr = [database selectDataWithTableName:OrderInfo withDic:@{@"orderType":self.dBType,@"isRepair":self.isRepairType?@"1":@"2"}];
        for (int i = 0; i < self.ordelsArr.count; i ++) {
            ComplainHeaderFrame * frame = [[ComplainHeaderFrame alloc]init];
            frame.headerDataModel = self.ordelsArr[i];
            frame.headerDataModel.isOpenDetail = NO;
            [self.framesArr addObject:frame];
        }
        [self cheakDataCount];
        [self reloadView];
    }
}

-(void)getDataWithURl:(NSString *)url withHeader:(NSDictionary *)headDic withParaDic:(NSDictionary *)paraDic withType:(NSString *)type{
    self.isFirstRequest = NO;
    //请求工单
    if (![self checkNetWork]) {
        [self endRefresh];
        return;
    }
    
    [DetailRequest SYGet_work_order_listWithParms:paraDic isFirstRequest:self.isFirstRequest SuccessBlock:^(NSArray *list) {
        if (list .count != 0) {
            //数据库管理者
            MyFMDataBase * database = [MyFMDataBase shareMyFMDataBase];
            
            if (self.page == 1) {
                // 移除数据
                [self.framesArr removeAllObjects];
                // 清空此type数据
                [database deleteDataWithTableName:OrderInfo delegeteDic:@{@"orderType":type}];
            }

            self.ordelsArr = [ComplainHeaderDataModel mj_objectArrayWithKeyValuesArray:list];
            
            for (int i = 0 ; i < self.ordelsArr.count; i ++) {
                
                ComplainHeaderFrame * frame = [[ComplainHeaderFrame alloc]init];
                frame.headerDataModel = self.ordelsArr[i];
                frame.headerDataModel.isOpenDetail = NO;
                [self.framesArr addObject:frame];
                
                // 写入数据库
                NSMutableDictionary * mDic = [[NSMutableDictionary alloc]initWithDictionary:list[i]];
                [mDic removeObjectForKey:@"repairs_imag_list"];
                [mDic setObject:@"0" forKey:@"isOpenDetail"];
                [mDic setObject:type forKey:@"orderType"];
                [mDic setObject:self.isRepairType?@"1":@"2" forKey:@"isRepair"];
                
                // 将图片写入数据库
                NSArray * imgArr = list[i][@"repairs_imag_list"];
                for (int i = 0; i < imgArr.count; i ++) {
                    NSString * str = [NSString stringWithFormat:@"fimagpath%d",i + 1];
                    [mDic setObject:imgArr[i][@"fimagpath"] forKey:str];
                    
                    //图片下载缓存
                    SDWebImageManager *manager = [SDWebImageManager sharedManager];

                    [manager loadImageWithURL:imgArr[i][@"fimagpath"] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                        
                        if (!error) {
                            
                            [[SDImageCache sharedImageCache] storeImage:image forKey:imgArr[i][@"fimagpath"] toDisk:YES completion:nil];
                            
                        }
                    }];
                }
                
                /*
                NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@／：；（）¥「」＂、[]{}#%-*+=_//|~＜＞$€^•'@#$%^&*()_+'/"];
                mDic[@"fservicecontent"] = [mDic[@"fservicecontent"] stringByTrimmingCharactersInSet:set];
                */
                
                //sql语句特殊字符处理
                mDic[@"fservicecontent"] = [PMTools FilteSQLStr:mDic[@"fservicecontent"]];
                
                [database insertDataWithTableName:OrderInfo insertDictionary:mDic];
            }
        }
        else{
            if (self.page == 1) {
                // 移除数据
                [self.framesArr removeAllObjects];
            }
        }
        [self cheakDataCount];
        [self reloadView];
        [self endRefresh];
    } FailureBlock:^{
        [self cheakDataCount];
        [self endRefresh];
    }];
    
    [self endRefresh];
}
#pragma mark - 获取工单详情
-(void)getOrder_details:(NSString *)repairs_id withSecion:(NSInteger)secion{
    //请求工单
    if (![self checkNetWork]) {
        return;
    }
    
    NSDictionary *paraDic = @{@"repairs_id":repairs_id,@"current_page":@"1",@"page_size":@"5"};
    [DetailRequest SYGet_work_order_detailsWithParms:paraDic SuccessBlock:^(NSArray *details) {
        if (details.count != 0) {
            
            NSLog(@"结果详情==%@",details);
            MyFMDataBase * database = [MyFMDataBase shareMyFMDataBase];
            [database deleteDataWithTableName:OrderInfo delegeteDic:@{@"repair_id":repairs_id}];
            
            NSMutableArray * replyArr = [NSMutableArray array];
            NSArray * arr = [ComplainReplyDataModel mj_objectArrayWithKeyValuesArray:details];
            
            //更新数量
            ComplainHeaderFrame * frameModel = self.framesArr[secion];
            
            for (int i = 0 ; i < arr.count; i ++) {
                ComplainReplyDataModel * replyModel = arr[i];
                replyModel.ID = frameModel.headerDataModel.fordernum;
                replyModel.reply_imag_list = details[i][@"record_imag_list"];
                replyModel.old_name = details[i][@"old_name"];
                replyModel.nMyName1 = details[i][@"new_name"];
                
                ComplainReplyFrame * frame = [[ComplainReplyFrame alloc]init];
                frame.replyDataModel = replyModel;
                [replyArr addObject:frame];
                
                
                // 写入数据库
                NSMutableDictionary * mDic = [[NSMutableDictionary alloc]initWithDictionary:details[i]];
                mDic[@"repair_id"] = repairs_id;
                mDic[@"nMyName1"] = [PMTools isNullOrEmpty:mDic[@"new_name"]]?@"无名":mDic[@"new_name"];
                mDic[@"reply_id"] = mDic[@"id"];
                
                [mDic removeObjectForKey:@"id"];
                [mDic removeObjectForKey:@"record_imag_list"];
                [mDic removeObjectForKey:@"new_name"];
                
                // 将图片写入数据库
                NSArray * imgArr = details[i][@"record_imag_list"];
                for (int i = 0; i < imgArr.count; i ++) {
                    NSString * str = [NSString stringWithFormat:@"fimagpath%d",i + 1];
                    [mDic setObject:imgArr[i][@"fimagpath"] forKey:str];
                }
                [database insertDataWithTableName:DetailInfo insertDictionary:mDic];
            }
            [self.detailDic setObject:replyArr forKey:repairs_id];
            [self reloadViewSecion:secion];

        }
    }];
}
#pragma mark - 获取数据库详情列表
-(NSInteger)getReplyDetailDataFromDataBase:(NSString *)repair_id{
    //数据库管理者
    MyFMDataBase * database = [MyFMDataBase shareMyFMDataBase];

    NSArray * replyArr = [database selectDataWithTableName:DetailInfo withDic:@{@"repair_id":repair_id}];
    NSMutableArray * mArr = [NSMutableArray array];
    for (int i = 0; i < replyArr.count; i ++) {
        ComplainReplyFrame * frame = [[ComplainReplyFrame alloc]init];
        frame.replyDataModel = replyArr[i];
        [mArr addObject:frame];
    }
    [self.detailDic setObject:mArr forKey:repair_id];
    
    return replyArr.count;
    
}


#pragma mark - 点击详情
-(void)openDetailWithModel:(ComplainHeaderDataModel *)dataModel andSection:(NSInteger)section{
    
    if (dataModel.isOpenDetail) {
  
        //显示数据库数据
        [self reloadViewSecion:section];
        
        //有网络 请求
        if ([self checkNetWork]) {
            [self getOrder_details:dataModel.repair_id withSecion:section];
        }

    }
    else{
        //关闭详情
        [self reloadViewSecion:section];
    }

}


#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.framesArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    ComplainHeaderFrame * frameModel = self.framesArr[section];
    NSString * repair_id = frameModel.headerDataModel.repair_id;
    NSArray * replyArr = self.detailDic[repair_id];
    
    NSInteger num = 0;
    if (frameModel.headerDataModel.isOpenDetail) {
        num = replyArr.count  + 1;
    }
    
    return num;
    
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        return 44;
    }
    else{
        ComplainHeaderFrame * frameModel = self.framesArr[indexPath.section];
        NSString * repair_id = frameModel.headerDataModel.repair_id;
        NSArray * replyArr = self.detailDic[repair_id];
        ComplainReplyFrame * replyFrame = replyArr[indexPath.row -1];
        return replyFrame.replyCellHeight + 10;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        //查看更多历史记录
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"lookMoreCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"lookMoreCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for (UIView * view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
        btn.backgroundColor = sBGColor;
        [btn setTitle:@"更多历史评论" forState:UIControlStateNormal];
        [btn setTitleColor:mainTextColor forState:UIControlStateNormal];
        btn.titleLabel.font = MiddleFont;
        btn.tag = indexPath.section + 300;
        [btn addTarget:self action:@selector(btnMoreClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
        
        UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(15, 43, ScreenWidth - 30, 1)];
        line.backgroundColor = lineColor;
        [cell.contentView addSubview:line];
        
        return cell;
    }
    else{
        ComplainOrderTableViewCell * cell = [ComplainOrderTableViewCell cellWithTableview:tableView];
        cell.indexPath = indexPath;
        
        //1.清空配图
        cell.photo1.hidden = YES;
        cell.photo2.hidden = YES;
        cell.photo3.hidden = YES;
        
        [cell.photo1 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [cell.photo2 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [cell.photo3 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        
        //2.设置Frame模型数据
        ComplainHeaderFrame * frameModel = self.framesArr[indexPath.section];
        NSString * repair_id = frameModel.headerDataModel.repair_id;
        NSArray * replyArr = self.detailDic[repair_id];
        ComplainReplyFrame * replyFrame = replyArr[indexPath.row - 1];
        cell.replyFrame = replyFrame;
        
        //3.处理cell的回调事件 （查看图片）
        [cell myReplyImageBlock:^(NSIndexPath *indexPath, NSInteger imageIndex) {
            ComplainHeaderFrame * frameModel = self.framesArr[indexPath.section];
            NSString * repair_id = frameModel.headerDataModel.repair_id;
            NSArray * replyArr = self.detailDic[repair_id];
            ComplainReplyFrame * replyFrame = replyArr[indexPath.row - 1];
            ComplainReplyDataModel * replyData = replyFrame.replyDataModel;
            replyData.ID = frameModel.headerDataModel.fordernum;;
            
            self.lookImageList = replyData.reply_imag_list;
            FGalleryViewController * fvc = [[FGalleryViewController alloc]initWithPhotoSource:self];
            if (imageIndex < self.lookImageList.count) {
                fvc.myImageIndex = imageIndex;
            }
            [self.navigationController pushViewController:fvc animated:YES];
        }];
        return cell;
    }
}

#pragma mark - 查看更多历史评论
-(void)btnMoreClick:(UIButton *)btn{
    SYLog(@"查看更多");
    
    NSInteger section = btn.tag - 300;
    
    ComplainHeaderFrame * frameModel = self.framesArr[section];
    NSString * repair_id = frameModel.headerDataModel.repair_id;

    NSMutableArray * sReplyArr = self.detailDic[repair_id];
    
    [[Routable sharedRouter] open:MOREHISTORY_VIEWCONTROLLER animated:YES extraParams:@{@"sReplyArr":sReplyArr,@"repairs_id":repair_id,@"fordernum":frameModel.headerDataModel.fordernum}];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    ComplainHeaderFrame * frameModel = self.framesArr[section];
    return frameModel.cellHeight;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    static NSString * identy = @"myHeaderView";
    ComplainHeaderView * headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identy];
    if (!headerView) {
        headerView = [[ComplainHeaderView alloc]initWithReuseIdentifier:identy];
    }
    
    headerView.photo1.hidden = YES;
    headerView.photo2.hidden = YES;
    headerView.photo3.hidden = YES;
    headerView.iconView.image = [UIImage imageNamed:@""];
    headerView.nameIcon.text = @"";
    
    headerView.detailBtn.imageView.transform = CGAffineTransformMakeRotation(0);
    
    ComplainHeaderFrame * frameModel = self.framesArr[section];
    headerView.frame = CGRectMake(0, 10, ScreenWidth, frameModel.cellHeight);
    headerView.section = section;
    [headerView returnComplainHeaderBlock:^(NSInteger section, NSInteger flag, NSInteger imagePos) {
        [self myBlock:section withFlag:flag withImageIndex:imagePos];
    }];
    headerView.headerFrame = frameModel;
    
    if (frameModel.headerDataModel.isOpenDetail) {
        headerView.detailBtn.imageView.transform = CGAffineTransformMakeRotation(0);
        [UIView animateWithDuration:1.0 animations:^{
            headerView.detailBtn.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    }
 
    return headerView;
}


#pragma mark - 检查网络
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
//    if (![self checkNetWork]) {
//        return FGalleryPhotoSourceTypeLocal;
//    }

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

#pragma mark - 刷新加载
-(void)createTableviewRefresh{
    self.page = 1;
    
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        if ([self checkNetWork]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                self.page = 1;
                
                [self getDataFromNetWork];
            });
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self getDataFromDB];
            });
        }

    }];
    
    return;
    self.tableView.mj_footer = [MJRefreshFooter footerWithRefreshingBlock:^{
        
        if ([self checkNetWork]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                self.page ++;
                
                [self getDataFromNetWork];
            });
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self getDataFromDB];
            });
        }
    
    }];
}

-(void)reloadView{
    if ([NSThread isMainThread])
    {
        [self.tableView reloadData];
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
        });
    }
}

-(void)endRefresh{
    if ([NSThread isMainThread])
    {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
         
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        });
    }
}

-(void)reloadViewSecion:(NSInteger)secion{
    [self cheakDataCount];
    NSIndexSet * set = [NSIndexSet indexSetWithIndex:secion];
    if ([NSThread isMainThread])
    {
        [self.tableView reloadData];
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
     
            [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
            
        });
    }
}

#pragma mark - 处理回调
-(void)myBlock:(NSInteger)section withFlag:(NSInteger)flag withImageIndex:(NSInteger)imageIndex{
    ComplainHeaderFrame * frameModel = self.framesArr[section];
    ComplainHeaderDataModel * dataModel = frameModel.headerDataModel;
    switch (flag) {
        case 1:
            
        case 9:
            
        case 2:
        {

            NSMutableDictionary * params = [NSMutableDictionary dictionary];
            NSString * do_type = flag == 9 ? @"2":@"1";
            params[@"do_type"] = do_type;
            params[@"repairs_id"] = dataModel.repair_id;
            if (flag == 9) {
                params[@"deal_worker_id"] = dataModel.deal_worker_id;
            }
            [[Routable sharedRouter] open:SENDORDER_VIEWCONTROLLER animated:YES extraParams:params];
        }
            break;
            
        case 3:
        {
            
            SYLog(@"接受按钮");
            [[Routable sharedRouter] open:ACCEPTORDER_VIEWCONTROLLER animated:YES extraParams:@{@"dataModel":dataModel,@"frameModel":frameModel,@"section":@(section),@"isOrderDetail":@(NO),@"isRepair":@(self.isRepairType)}];
        }
            break;
        case 4:
        {
            SYLog(@"完成按钮");
            
            [[Routable sharedRouter] open:COMPLETEORDER_VIEWCONTROLLER animated:YES extraParams:@{@"isFirstSendMgr":dataModel.power_do,@"repairs_id":dataModel.repair_id,@"section":@(section),@"isProOrderPush":@(NO)} reverseValueProtocol:YES withViewController:self];
           
        }
            break;
        case 5:
        {
            SYLog(@"点击详情 加载数据");
            dataModel.isOpenDetail = !dataModel.isOpenDetail;
            [self openDetailWithModel:dataModel andSection:section];
        }
            break;
        case 6:
        {
            SYLog(@"点击评论返回的回调");
            NSMutableDictionary * parmas = [NSMutableDictionary dictionary];
            parmas[@"repairs_id"] = dataModel.repair_id;
            parmas[@"section"] = @(section);
            if (![PMTools isNullOrEmpty:dataModel.frealname]) {
                parmas[@"fname"] = dataModel.frealname;
                
                
            }
            else{
                if (![PMTools isNullOrEmpty:dataModel.flinkman]) {
                    parmas[@"fname"] = dataModel.flinkman;
                    
                }
                else{
                    parmas[@"fname"] = dataModel.flinkman_phone;
                }

            }
            
            [[Routable sharedRouter] open:ORDERCOMMAND_VIEWCONTROLLER animated:YES extraParams:parmas reverseValueProtocol:YES withViewController:self];
            
        }
            break;
        case 7:
        {
            self.lookImageList = dataModel.repairs_imag_list;
            FGalleryViewController * fvc = [[FGalleryViewController alloc]initWithPhotoSource:self];
            if (imageIndex < self.lookImageList.count) {
                fvc.myImageIndex = imageIndex;
            }
            [self.navigationController pushViewController:fvc animated:YES];
        }
            break;
        case 8:
        {
            SYLog(@"查看业主");
            
            NSMutableDictionary * parmas = [NSMutableDictionary dictionary];
            parmas[@"isOwner"] = @(YES);
            
            NSString * frealnameStr = @"";
            if ([PMTools isNullOrEmpty:dataModel.frealname]) {
                if ([PMTools isNullOrEmpty:dataModel.flinkman]) {
                    
                    frealnameStr = @"业主";
                }
                else{
                    frealnameStr = dataModel.flinkman;
                }
            }
            else{
                frealnameStr = dataModel.frealname;

            }
            parmas[@"ownerName"] = frealnameStr;
            
            NSString * ownerPhone = @"";
            if (![PMTools isNullOrEmpty:dataModel.fusername]) {
                ownerPhone = dataModel.fusername;
            }
            else{
                
                if (![PMTools isNullOrEmpty:dataModel.flinkman_phone]) {
                    ownerPhone = dataModel.flinkman_phone;
                }
            }
            parmas[@"ownerPhone"] = ownerPhone;

            
            NSString * addr = @"";
            if (![PMTools isNullOrEmpty:dataModel.faddress]) {
                addr = dataModel.faddress;
            }
            parmas[@"ownerAddr"] = addr;
            
            [[Routable sharedRouter] open:OWNER_VIEWCONTROLLER animated:YES extraParams:parmas];
            
        }
            break;
            
        case 10:
        {
            SYLog(@"拨打电话");
            [PMTools callPhoneNumber:dataModel.flinkman_phone inView:self.tableView];
            
        }
            break;
            
        default:
            break;
    }
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [[SDImageCache sharedImageCache] clearMemory];
}

#pragma mark - ReverseValueProtocol

- (void)reverseValue:(id)value {
    NSLog(@"%s:%@", __FUNCTION__, value);
    
    NSDictionary * info = (NSDictionary *)value;
    NSString * type = info[@"type"];
    
    NSInteger section = [info[@"section"] integerValue];
    ComplainHeaderFrame * frameModel = self.framesArr[section];
    ComplainHeaderDataModel * dataModel = frameModel.headerDataModel;
    dataModel.isOpenDetail = YES;
    
    if ([type isEqualToString:COMPLETEORDERTYPE]) {
        
    
        [self openDetailWithModel:dataModel andSection:section];
        

    }
    else if ([type isEqualToString:COMMANDORDERTYPE]){
        NSInteger num = [dataModel.record_num integerValue];
        dataModel.record_num = @(num + 1);
        [self openDetailWithModel:dataModel andSection:section];
    }
    
    
}



@end
