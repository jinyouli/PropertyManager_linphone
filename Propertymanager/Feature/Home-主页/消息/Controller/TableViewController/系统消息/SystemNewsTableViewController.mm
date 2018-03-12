//
//  SystemNewsTableViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "SystemNewsTableViewController.h"
#import "SystemTableViewCell.h"
#import "PlotModel.h"

@interface SystemNewsTableViewController ()

@end

@implementation SystemNewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickBtnGetData) name:@"requestData4" object:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getDataFromNetWork];
    });
}

-(void)clickBtnGetData{
    
    [self.tableView.mj_header beginRefreshing];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getDataFromNetWork];
    });
    
}

-(void)getDataFromNetWork{
    
    if ([self checkNetWork]) {
        
        UserManager * user = [UserManagerTool userManager];
        NSString * department_id = user.department_id;
        NSDictionary * paraDic = @{@"notice_type":@"3",@"department_id":department_id,@"current_page":@(self.page),@"page_size":@"5"};
        
        [DetailRequest SYGet_notice_by_pagerWithParms:paraDic SuccessBlock:^(NSArray *value) {
            [self endRefresh];
            if (self.page == 1) {
                [self.models removeAllObjects];
            }
            [self.models addObjectsFromArray:[PlotModel mj_objectArrayWithKeyValuesArray:value]];
            [self cheakDataCount:self.models];
            [self reloadView];
        } FailureBlock:^{
            [self cheakDataCount:self.models];
            [self endRefresh];
        }];
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SystemTableViewCell *cell = [SystemTableViewCell cellWithTableview:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PlotModel * model = self.models[indexPath.row];
    model.state = YES;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [[Routable sharedRouter] open:PLOTCELLDETAIL_VIEWCONTROLLER animated:YES extraParams:@{@"isPloy":@(NO),@"myTitle":model.title,@"myTime":model.time,@"myContent":model.content}];

}
@end
