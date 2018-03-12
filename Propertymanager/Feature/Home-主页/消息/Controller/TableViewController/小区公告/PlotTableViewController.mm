//
//  PlotTableViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "PlotTableViewController.h"
#import "PlotTableViewCell.h"
#import "PlotModel.h"

@interface PlotTableViewController ()
@property(nonatomic,strong) NSMutableDictionary * readDic;
@end

@implementation PlotTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDataFromNetWork) name:@"refreshNet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickBtnGetData) name:@"requestData3" object:nil];
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
        NSString * url = MyUrl(SYGet_notice_by_pager);
        SYLog(@"小区公告列表 ==== %@",url);
        NSString * department_id = user.department_id;
        NSDictionary * paraDic = @{@"notice_type":@"2",@"department_id":department_id,@"current_page":@(self.page),@"page_size":@"100"};
        
        [DetailRequest SYGet_notice_by_pagerWithParms:paraDic SuccessBlock:^(NSArray *value) {
            [self endRefresh];
            if (self.page == 1) {
                [self.models removeAllObjects];
            }
            NSLog(@"结果==%@",value);
            NSArray * modelArr = [PlotModel mj_objectArrayWithKeyValuesArray:value];
            
            for (PlotModel * model in modelArr) {

                NSInteger res = [self compareOneDay:model.expdate];
                if (res == 1) {
                    BOOL res2 = [self isReadFromDBWithNoticeID:model.id];
                    model.state = res2;
                    [self.models addObject:model];
                }
                
            }
            
            [self cheakDataCount:self.models];
            [self reloadView];

        } FailureBlock:^{
            [self cheakDataCount:self.models];
            [self endRefresh];
        }];
        [self endRefresh];
    }
}

// 比较过期时间
-(int)compareOneDay:(NSString  *)oneDayStr
{
    if (oneDayStr.length > 10) {
        oneDayStr = [oneDayStr substringToIndex:10];
    }
    
    NSDateFormatter *matt = [[NSDateFormatter alloc] init];
    [matt setDateFormat:@"yyyy-MM-dd"];
    NSString *todayDayStr = [matt stringFromDate:[NSDate date]];
    
    NSDate *dateA = [matt dateFromString:oneDayStr];
    //dateA = [NSDate dateWithTimeInterval:24*60*60 sinceDate:dateA];
    NSDate *dateB = [matt dateFromString:todayDayStr];
    NSComparisonResult result = [dateA compare:dateB];
    
    if (result == NSOrderedDescending) {
        //dateA大
        return 1;
    }
    else if (result == NSOrderedAscending){
        //dateA小
        return -1;
    }
    //相等
    return 0;
}
// 比较是否已读
-(BOOL)isReadFromDBWithNoticeID:(NSString *)noticeID{
    NSLog(@"成本==%@",noticeID);
    MyFMDataBase * database = [MyFMDataBase shareMyFMDataBase];
    NSArray * arr = [database selectDataWithTableName:PlotNewsInfo withDic:@{@"fusername":[UserManagerTool userManager].username,@"noticeID":noticeID}];
    return arr.count > 0 ? YES : NO;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlotTableViewCell *cell = [PlotTableViewCell cellWithTableview:tableView];
    PlotModel * model = self.models[indexPath.row];
    [cell setModel:model];
    if (model.state) {
        cell.statusLabel.hidden = YES;
    }
    else{
        cell.statusLabel.hidden = NO;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PlotModel * model = self.models[indexPath.row];

    MyFMDataBase * database = [MyFMDataBase shareMyFMDataBase];
    NSDictionary * params = @{@"fusername":[UserManagerTool userManager].username,@"noticeID":model.id};
    [database deleteDataWithTableName:PlotNewsInfo delegeteDic:params];
    [database insertDataWithTableName:PlotNewsInfo insertDictionary:params];
    model.state = YES;
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

    [[Routable sharedRouter] open:PLOTCELLDETAIL_VIEWCONTROLLER animated:YES extraParams:@{@"isPloy":@(YES),@"myTitle":model.title,@"myTime":model.time,@"myContent":model.content}];

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

@end
