//
//  BaseContactTableViewController.m
//  idoubs
//
//  Created by Momo on 16/7/6.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "BaseContactTableViewController.h"

@interface BaseContactTableViewController ()<UIScrollViewDelegate>

@end

@implementation BaseContactTableViewController
- (void)dealloc{
    SYLog(@"BaseContactTableViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotReachable" object:nil];
}
- (instancetype)init{
    return [self initWithStyle:UITableViewStyleGrouped];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 85;
    self.tableView.showsVerticalScrollIndicator = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.backgroundColor = BGColor;
    
    self.noDataCountView = [[NoDataCountView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 160)];
    self.noDataCountView.hidden = YES;
    [self.tableView addSubview:self.noDataCountView];
    

    self.tableView.mj_header = [MJRefreshNormalHeader  headerWithRefreshingBlock:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getDataFromNetWork];
        });
    }];
    
    
    self.tableView.mj_footer.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endRefresh) name:@"NotReachable" object:nil];
}

-(void)cheakDataCount:(NSArray *)arr{
    if (arr.count == 0) {
        self.noDataCountView.hidden = NO;
    }
    else{
        self.noDataCountView.hidden = YES;
    }
}


-(void)getDataFromNetWork{
    
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

-(NSMutableArray *)dataModel{
    if (!_dataModel) {
        _dataModel = [NSMutableArray array];
    }
    return _dataModel;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65.0;
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [[SDImageCache sharedImageCache] clearMemory];
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [[SDImageCache sharedImageCache] clearMemory];
}

@end
