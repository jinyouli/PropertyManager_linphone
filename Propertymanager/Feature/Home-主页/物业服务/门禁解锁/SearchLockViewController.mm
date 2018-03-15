//
//  SearchLockViewController.m
//  PropertyManager
//
//  Created by Momo on 16/9/13.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "SearchLockViewController.h"
#import "EntranceView.h"
#import "CallViewController.h"
#import "UMMobClick/MobClick.h"


#define EntranceViewHeight iPhone4s || iPhone5s ? 160 : 210

@interface SearchLockViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSMutableArray * items;
@property (nonatomic,strong) NSArray * lockArr;
@property (nonatomic,strong) UISearchBar * searchBar;
@property (nonatomic,strong) NSMutableArray * searchResults; // 接收数据结果
@property (nonatomic,strong) NSMutableArray * searchResultArrs; // 接收数据结果-存字典
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) NSDictionary * selectedDic;
@property (nonatomic,assign) NSInteger count;

@property (nonatomic,strong) EntranceView * entranceView;
@property (nonatomic,strong) UIImageView * sImageView;

@property (nonatomic,assign) NSInteger sipRegCount;
@end


@implementation SearchLockViewController
#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
    }
    return self;
}


-(void)dealloc{
    
    SYLog(@"entrance dealloc");
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNgnRegistrationEventArgs_Name object:nil];
}

- (UIImageView *)sImageView{
    if (!_sImageView) {
        _sImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _sImageView.userInteractionEnabled = YES;
        _sImageView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:_sImageView];
        _sImageView.hidden = YES;
        
    }
    return _sImageView;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _sImageView.hidden = YES;
    self.tableView.userInteractionEnabled = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _sImageView.hidden = YES;
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNgnRegistrationEventArgs_Name object:nil];
}



- (EntranceView *)entranceView{
    if (!_entranceView) {
        _entranceView = [[EntranceView alloc]initWithFrame:CGRectMake(10, ScreenHeight, ScreenWidth - 20, EntranceViewHeight) withDomain:self.selectedDic[@"domain_sn"] sipNum:self.selectedDic[@"sip_number"]];
        
        [_entranceView returnSelectIndex:^(NSInteger tag) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                _entranceView.frame = CGRectMake(10, ScreenHeight, ScreenWidth - 20, EntranceViewHeight);
            } completion:^(BOOL finished) {
                self.tableView.userInteractionEnabled = YES;
                self.sImageView.hidden = YES;
            }];
            
            if (tag == 1) {
                //查看门口监控
                self.entranceView.hidden = YES;
                self.sImageView.hidden = YES;

                NSString * sipNum = [NSString stringWithFormat:@"%@",self.selectedDic[@"sip_number"]];
                
//                [CallViewController makeEntranceAudioVideoCallWithRemoteParty:sipNum andSipStack:[[NgnEngine sharedInstance].sipService getSipStack] withDomain_sn:self.selectedDic[@"domain_sn"]];
                
//                SYLockListModel *model = [[SYLockListModel alloc] init];
//                model.sip_number = sipNum;
//                VideoCallViewController *videoVC = [[VideoCallViewController alloc] initWithCall:nil GuardInfo:model InComingCall:NO];

                LookEntranceVedioViewController *lookVC = [[LookEntranceVedioViewController alloc] init];
                lookVC.sipnum = sipNum;
                lookVC.domain_sn = self.selectedDic[@"domain_sn"];
                
                AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate ;
                [delegate.window.rootViewController presentViewController:lookVC animated:YES completion:nil];
                
//                if ([PMSipTools sipIsRegister]) {
//                    // 可以拨打门口视频
//
////                    [CallViewController makeEntranceAudioVideoCallWithRemoteParty:sipNum andSipStack:[[NgnEngine sharedInstance].sipService getSipStack] withDomain_sn:self.selectedDic[@"domain_sn"]];
//
//                }
//                else{
//                    //未注册上
//                    [PMSipTools sipRegister];
//                }
            }
            else if (tag == 2){
                //开门-网络请求
   
            }
            else if (tag == 3){
                //取消
                [UIView animateWithDuration:0.5 animations:^{
                    self.tableView.userInteractionEnabled = YES;
                    self.entranceView.frame = CGRectMake(10, ScreenHeight, ScreenWidth - 20, EntranceViewHeight);
                } completion:^(BOOL finished) {
                    if (finished == YES) {
                        
                        
                    }
                }];
                
            }
            
            
            
        }];
        [self.sImageView addSubview:_entranceView];
    }
    return _entranceView;
}

-(void) onRegistrationEvent:(NSNotification*)notification {
    
//    NgnRegistrationEventArgs* eargs = [notification object];
//
//    switch (eargs.eventType) {
//        case REGISTRATION_NOK:
//            //注册失败
//            break;
//        case UNREGISTRATION_OK:
//            //未注册 （掉线)
//            if ([self checkNetWork]) {
//                self.sipRegCount ++;
//                if (self.sipRegCount <= 5) {
//                    [PMSipTools sipRegister];
//                }
//                else{
//                    [SVProgressHUD showErrorWithStatus:@"网络状态不佳，无法查看门口视频"];
//                }
//            }
//            else{
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    if ([self checkNetWork]) {
//                        self.sipRegCount ++;
//                        if (self.sipRegCount <= 5) {
//                            //去注册
//                            [PMSipTools sipRegister];
//                        }
//                        else{
//                            [SVProgressHUD showErrorWithStatus:@"网络状态不佳，无法查看门口视频"];
//                        }
//                    }
//
//                });
//            }
//
//            break;
//        case REGISTRATION_OK:
//            //已注册
//            self.sipRegCount = 0;
//             SYLog(@"注册后拨打门口视频");
//
//            [CallViewController makeEntranceAudioVideoCallWithRemoteParty:[NSString stringWithFormat:@"%@",self.selectedDic[@"sip_number"]] andSipStack:[[NgnEngine sharedInstance].sipService getSipStack] withDomain_sn:self.selectedDic[@"domain_sn"]];
//            break;
//        case REGISTRATION_INPROGRESS:
//            //正在注册
//            break;
//        case UNREGISTRATION_INPROGRESS:
//            //正在注销
//            break;
//        case UNREGISTRATION_NOK:
//            //未注销失败
//            break;
//    }

}




- (void)viewDidLoad {
    [super viewDidLoad];
    [self createLeftBarButtonItemWithTitle:@"门禁开锁"];
    
    self.items = [NSMutableArray array];
    self.searchResultArrs = [NSMutableArray array];
    self.count = 0;
    self.sipRegCount = 0;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self requestLockData];
    });
    
    [self createSubviews];
    
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
    
}


-(void)requestLockData{

    if (![self checkNetWork]) {
        [self.tableView.mj_header endRefreshing];
        return;
    }
    
    UserManager * user = [UserManagerTool userManager];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时的操作
        
        [DetailRequest SYGet_department_lock_listWithParms:@{@"department_id":user.department_id} SuccessBlock:^(NSArray *result) {
            
            [self.tableView.mj_header endRefreshing];
            self.lockArr = result;
            if (result.count != 0) {
                [self.items removeAllObjects];
                for (int i = 0; i < self.lockArr.count; i ++) {
                    NSDictionary * dic = self.lockArr[i];
                    [self.items addObject:dic[@"lock_parent_name"]];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 更新界面
                    [self.tableView reloadData];
                });

            }
        } FailureBlock:^{
            [self.tableView.mj_header endRefreshing];
        }];
        
    });
}


- (void)createSubviews{
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    self.searchBar.backgroundColor = [UIColor yellowColor];
    self.searchBar.placeholder = @"搜索框";
    self.searchBar.delegate = self;
    self.searchBar.barStyle=UIBarStyleDefault;
    [self.view addSubview:self.searchBar];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, ScreenWidth, ScreenHeight - 64) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.count = 0;
        [self requestLockData];
    }];
}


#pragma mark 协议中的方法

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.searchResults removeAllObjects];
    //NSPredicate 谓词
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"self contains[cd] %@",self.searchBar.text];
    self.searchResults = [[self.items filteredArrayUsingPredicate:searchPredicate]mutableCopy];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if ([self.searchBar.text isEqualToString:@""]) {
        return self.lockArr.count;
    }
    else{
        return self.searchResults.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mySearchCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"mySearchCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.userInteractionEnabled = YES;
    if (indexPath.row == 0) {
        self.count = 0;
        [self.searchResultArrs removeAllObjects];
    }
    NSDictionary * dic = self.lockArr[indexPath.row];
    if (![self.searchBar.text isEqualToString:@""]) {
        NSString * indexStr = self.searchResults[indexPath.row];
        for (NSInteger i = self.count; i < self.items.count; i ++,self.count ++) {
            
            NSString * str = self.items[i];
            if ([indexStr isEqualToString:str]) {
                dic = self.lockArr[i];
                [self.searchResultArrs addObject:self.lockArr[i]];
                break;
            }
        }
    }

    cell.imageView.image = [UIImage imageNamed:@"home_sip_on"];
    cell.textLabel.text = dic[@"lock_parent_name"];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.selectedDic = self.lockArr[indexPath.row];
    if (self.searchResults.count != 0) {
        self.selectedDic = self.searchResultArrs[indexPath.row];
    }
    SYLog(@"选择的门锁信息 === %@",self.selectedDic);
    
    self.entranceView.plotName = self.selectedDic[@"lock_parent_name"];
    self.entranceView.domain_sn = self.selectedDic[@"domain_sn"];
    self.entranceView.hidden = NO;
    self.sImageView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        
        self.tableView.userInteractionEnabled = NO;
        self.entranceView.center = self.sImageView.center;
//        self.entranceView.frame = CGRectMake(10, ScreenHeight / 2 - EntranceViewHeight / 2, ScreenWidth - 20, EntranceViewHeight);
    }];

}

@end
