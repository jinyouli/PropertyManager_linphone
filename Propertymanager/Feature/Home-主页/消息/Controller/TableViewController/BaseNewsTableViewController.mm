//
//  BaseNewsTableViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "BaseNewsTableViewController.h"

@interface BaseNewsTableViewController ()



@end

@implementation BaseNewsTableViewController

#pragma mark - life cycle

-(instancetype)init{
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (instancetype) initWithStyle:(UITableViewStyle)style{
    if (self = [super initWithStyle:style]) {
        self.models = [NSMutableArray array];
        self.tableView.rowHeight = 85;
        self.tableView.showsVerticalScrollIndicator = YES;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundColor = BGColor;
        self.tableView.mj_footer.hidden = YES;
        self.page = 1;
        
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 11.0) {
            self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
        }
        
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self headerGetData];
            });
        }];
        
        
        self.tableView.mj_footer = [MJRefreshFooter footerWithRefreshingBlock:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self footerGetData];
            });
        }];

    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView addSubview:self.noDataCountView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endRefresh) name:@"NotReachable" object:nil];
}


#pragma mark - Delegate 实现方法
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.models.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}


#pragma mark - event response
#pragma mark - private methods
-(void)cheakDataCount:(NSArray *)arr{
    if (arr.count == 0) {
        self.noDataCountView.hidden = NO;
    }
    else{
        self.noDataCountView.hidden = YES;
    }
}

-(void)headerGetData{
    self.page = 1;
    [self getDataFromNetWork];
}

-(void)footerGetData{
    self.page ++;
    [self getDataFromNetWork];
}

-(void)getDataFromNetWork{
    [self.tableView.mj_header endRefreshing];
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
                //Update UI in UI thread here
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
        [self.tableView reloadData];
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            //Update UI in UI thread here
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
            //Update UI in UI thread here
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            
        });
    }
}


#pragma mark - getters and setters
- (NoDataCountView *)noDataCountView{
    if (!_noDataCountView) {
        _noDataCountView = [[NoDataCountView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 160)];
        _noDataCountView.hidden = YES;
    }
    return _noDataCountView;
}

@end
