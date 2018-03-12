//
//  ProportyTableViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "ProportyTableViewController.h"
#import "PropertyTableViewCell.h"
#import "PropertyModel.h"

@interface ProportyTableViewController ()
@end

@implementation ProportyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.mj_footer.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickBtnGetData) name:@"requestData1" object:nil];
    
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
        NSString * worker_id = user.worker_id;
        NSDictionary * paraDic = @{@"worker_id":worker_id};
    
        [DetailRequest SYGet_push_msg_listWithParms:paraDic SuccessBlock:^(NSArray *value) {
            [self endRefresh];
            NSArray * arr = [PropertyModel mj_objectArrayWithKeyValuesArray:value];
            self.models = [NSMutableArray arrayWithArray:arr];
            [self cheakDataCount:self.models];
            [self reloadView];
            
        } FailureBlock:^{
            [self cheakDataCount:self.models];
            [self endRefresh];
        }];
        
    }
    [self endRefresh];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PropertyTableViewCell *cell = [PropertyTableViewCell cellWithTableview:tableView];

    [cell setModel:self.models[indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.clipsToBounds = YES;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [[Routable sharedRouter] open:PROORDERNEWS_VIEWCONTROLLER animated:YES extraParams:@{@"frepairs_id":((PropertyModel *)self.models[indexPath.row]).frepairs_id}];
    
    [self.tableView reloadData];
    
}

@end
