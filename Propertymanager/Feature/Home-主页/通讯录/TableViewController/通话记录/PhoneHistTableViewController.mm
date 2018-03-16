//
//  PhoneHistTableViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "PhoneHistTableViewController.h"
#import "ContactModel.h"
#import "RecentTableViewCell.h"
//#import "SQLiteManager.h"

@interface PhoneHistTableViewController (Private)

-(void) refreshData;
-(void) refreshDataAndReload;
-(void) onHistoryEvent:(NSNotification*)notification;

@end

@implementation PhoneHistTableViewController(Private)

-(void) refreshData{
    
//    @synchronized(mEvents){
//        [mEvents removeAllObjects];
//        NSArray* events = [[[mHistoryService events] allValues] sortedArrayUsingSelector:@selector(compareHistoryEventByDateASC:)];
//        for (NgnHistoryEvent* event in events) {
//            
//            if(!event || !(event.mediaType & MediaType_AudioVideo) || !(event.status & mStatusFilter)){
//                continue;
//            }
//            [mEvents addObject:event];
//            
//            // 去联系人数据库中获取
//        }
//        //结束刷新
//        [self endRefresh];
//        if (mEvents.count == 0) {
//            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstGet"]) {
////                [SVProgressHUD showErrorWithStatus:@"没有数据"];
//            }
//            else{
//                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"isFirstGet"];
//            }
//        }
//        else{
//            [self.tableView reloadData];
//        }
//        
//        SYLog(@"通话记录 ==== %@",mEvents);
//    }
}

-(void) refreshDataAndReload{
    [self refreshData];
    [self.tableView reloadData];
}

-(void) onHistoryEvent:(NSNotification*)notification{
    
}

//-(void) onHistoryEvent:(NSNotification*)notification{
//    NgnHistoryEventArgs* eargs = [notification object];
//
//    //[[NgnEngine sharedInstance].historyService start];
//
//    switch (eargs.eventType) {
//        case HISTORY_EVENT_ITEM_ADDED:
//        {
//            if((eargs.mediaType & MediaType_AudioVideo)){
//                NgnHistoryEvent* event = [[mHistoryService events] objectForKey: [NSNumber numberWithLongLong: eargs.eventId]];
//                if(event){
//                    [mEvents insertObject:event atIndex:0];
//                    [self.tableView reloadData];
//                   // [[NgnEngine sharedInstance].historyService addEvent:event];
//                }
//            }
//            break;
//        }
//
//        case HISTORY_EVENT_ITEM_MOVED:
//        case HISTORY_EVENT_ITEM_UPDATED:
//        {
//            [self.tableView reloadData];
//            break;
//        }
//
//        case HISTORY_EVENT_ITEM_REMOVED:
//        {
//            if((eargs.mediaType & MediaType_AudioVideo)){
//                for (NgnHistoryEvent* event in mEvents) {
//                    if(event.id == eargs.eventId){
//                        [mEvents removeObject: event];
//                        [self.tableView reloadData];
//                        break;
//                    }
//                }
//            }
//            break;
//        }
//
//        case HISTORY_EVENT_RESET:
//             [[NgnEngine sharedInstance].historyService deleteEventWithId:eargs.eventId];
//        default:
//        {
//            [self refreshDataAndReload];
//            break;
//        }
//    }
//}
@end

@interface PhoneHistTableViewController ()
@property (nonatomic,strong)NSMutableArray *secDataArr;
@property (nonatomic,strong)NSMutableArray *dataAToZArr;
@property (nonatomic,strong)NSMutableArray *arrayData;

@end

@implementation PhoneHistTableViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   // [self cheakDataCount:mEvents];
    
    [self getDataFromDB];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isFirstGet"];
    self.secDataArr = [NSMutableArray array];
    self.dataAToZArr = [NSMutableArray array];
    self.arrayData = [NSMutableArray array];
    
//    mStatusFilter = HistoryEventStatus_All;
//
//    // get contact service instance
//    mContactService = [NgnEngine sharedInstance].contactService;
//    mHistoryService = [NgnEngine sharedInstance].historyService;
//
//    [mContactService load:YES];
//    [mHistoryService load];
//    // refresh data
//    [self refreshData];
//
//    [self cheakDataCount:mEvents];

    self.navigationItem.title = @"History";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(getDataFromDB) name:@"alreadyCalled" object:nil];
    
    [self getPersonList];
    [self getAToZList];
}

- (void)getDataFromDB
{
    [self.arrayData removeAllObjects];
    NSArray *result = [[MyFMDataBase shareMyFMDataBase] selectDataWithTableName:@"PeopleCalled" withDic:nil];
    
    for (int i=0; i<result.count; i++) {
        ContactModel *model = [[ContactModel alloc] init];
        model.fusername = [result objectAtIndex:i][@"fusername"];
        model.first_py = [result objectAtIndex:i][@"first_py"];
        model.fdepartmentname = [result objectAtIndex:i][@"fdepartmentname"];
        model.fworkername = [result objectAtIndex:i][@"fworkername"];
        model.worker_id = [result objectAtIndex:i][@"worker_id"];
        model.user_sip = [result objectAtIndex:i][@"user_sip"];
        model.fgroup_name = [result objectAtIndex:i][@"fgroup_name"];
        [self.arrayData insertObject:model atIndex:0];
    }
    
    [self.tableView reloadData];
}

- (void)getPersonList{
    if (![self checkNetWork]) {
        return;
    }
    
    UserManager * user = [UserManagerTool userManager];
    NSString * department_id = user.department_id;
    NSDictionary *paraDic = @{@"department_id":department_id,@"get_type":@"3"};
    
    NSMutableArray *arrayData = [NSMutableArray array];
    [DetailRequest SYGet_worker_listWithParms:paraDic SuccessBlock:^(NSArray *workers) {
        [self.secDataArr removeAllObjects];
        
        NSMutableArray * groupNameArr = [NSMutableArray array];
        for (int i = 0; i < workers.count; i ++) {
            
            NSMutableDictionary * mdic = [[NSMutableDictionary alloc]initWithDictionary:workers[i]];
            
            NSString * str = workers[i][@"fgroup_name"];
            [groupNameArr addObject:str];
            
            NSMutableArray * workList = [[NSMutableArray alloc]initWithArray:workers[i][@"worker_list"]];
            NSArray * arr = workers[i][@"worker_list"];
            for (int j = 0; j < arr.count; j ++) {
                NSDictionary * dic = arr[j];
                if (![PMTools isNullOrEmpty:dic[@"user_sip"]] ) {
                    NSInteger dicSip = [dic[@"user_sip"] integerValue];
                    NSInteger userSip = [user.user_sip integerValue];
                    if (dicSip == userSip) {
                        //去掉自己
                        [workList removeObject:dic];
                    }
                }
            }
            [mdic setObject:workList forKey:@"worker_list"];
            [arrayData addObject:mdic];
        }
        
        for (int i=0; i<arrayData.count; i++) {
            
            NSArray *array = arrayData[i][@"worker_list"];
            
            for (int j=0; j<array.count; j++) {
                
                NSDictionary * worker_listDic = arrayData[i][@"worker_list"][j];
                
                ContactModel * model = [[ContactModel alloc]init];
                model.fworkername = worker_listDic[@"fworkername"];
                model.fdepartmentname = worker_listDic[@"fdepartmentname"];
                model.user_sip = worker_listDic[@"user_sip"];
                model.worker_id = worker_listDic[@"worker_id"];
                model.fusername = worker_listDic[@"fusername"];
                
                [self.secDataArr addObject:model];
            }
        }
        [self.tableView reloadData];
    } FailureBlock:^{

    }];
    
}

-(void)getAToZList{

    UserManager * user = [UserManagerTool userManager];
    NSString * department_id = user.department_id;
    NSDictionary *paraDic = @{@"department_id":department_id};
    
    [DetailRequest SYGet_communicate_listWithParms:paraDic SuccessBlock:^(NSArray *arr) {
        
        [self.dataAToZArr removeAllObjects];
        // 清空A_Z数据
        NSArray * modelArr = [ContactModel mj_objectArrayWithKeyValuesArray:arr];
        
        for (int i = 0; i < modelArr.count; i ++) {
            
            ContactModel * model = modelArr[i];
            if (![PMTools isNullOrEmpty:model.user_sip] && ![PMTools isNullOrEmpty:user.user_sip]) {
                NSInteger modelSip = [model.user_sip integerValue];
                NSInteger uesrSip = [user.user_sip integerValue];
                if (modelSip != uesrSip) {
                    [self.dataAToZArr addObject:model];
                }
            }
        }
        
        [self.tableView reloadData];
    } FailureBlock:^{

    }];
    
}

// 下拉刷新实现
-(void)getDataFromNetWork{
    // refresh data
    [self refreshData];
    [self endRefresh];
}


//
//	UITableViewDelegate
//

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.arrayData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identify = @"RecentCell";
    RecentTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identify];
    if (cell==nil) {
        cell=[[RecentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    ContactModel * model = [self.arrayData objectAtIndex:indexPath.section];
    if (model) {
        [cell setContactModel:model];
    }
    
//    @synchronized(mEvents){
//        NgnHistoryEvent* event;
//        if (indexPath.row >= mEvents.count) {
//            event = [mEvents lastObject];
//        }
//        else{
//            event = [mEvents objectAtIndex: indexPath.row];
//        }
//
//        [cell setEvent:event];
//
////        ContactModel * model = [PMSipTools gainContactModelFromSipNum:event.remoteParty];
////        if (model) {
////            [cell setContactModel:model];
////        }

        BOOL isHasName = NO;
        for (int i=0; i<self.secDataArr.count; i++) {
            ContactModel * personModel = (ContactModel *)[self.secDataArr objectAtIndex:i];

            if ([[NSString stringWithFormat:@"%@",personModel.user_sip] isEqualToString:model.user_sip]) {
                //cell.nameLabel.text = personModel.fworkername;
                [cell setContactModel:personModel];
                isHasName = YES;
            }
        }

        if (!isHasName) {
            for (int i=0; i<self.dataAToZArr.count; i++) {
                ContactModel * personModel = (ContactModel *)[self.dataAToZArr objectAtIndex:i];

                if ([[NSString stringWithFormat:@"%@",personModel.user_sip] isEqualToString:model.user_sip]) {
                    [cell setContactModel:personModel];
                    isHasName = YES;
                }
            }
        }

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactModel * model = [self.arrayData objectAtIndex:indexPath.section];
    if (model) {
        BOOL hasModel = NO;
        for (int i=0; i<self.secDataArr.count; i++) {
            
            ContactModel * personModel = (ContactModel *)[self.secDataArr objectAtIndex:i];
            if ([[NSString stringWithFormat:@"%@",personModel.user_sip] isEqualToString:[NSString stringWithFormat:@"%@",model.user_sip]]) {
                hasModel = YES;
                [[Routable sharedRouter] open:OWNER_VIEWCONTROLLER animated:YES extraParams:@{@"isOwner":@(NO),@"contactModel":personModel}];
            }
        }
        
        if (!hasModel) {
            for (int i=0; i<self.dataAToZArr.count; i++) {
                
                ContactModel * personModel = (ContactModel *)[self.dataAToZArr objectAtIndex:i];
                NSLog(@"检测2==%@,%@",personModel.user_sip,model.user_sip);
                if ([[NSString stringWithFormat:@"%@",personModel.user_sip] isEqualToString:[NSString stringWithFormat:@"%@",model.user_sip]]) {
                    hasModel = YES;
                    [[Routable sharedRouter] open:OWNER_VIEWCONTROLLER animated:YES extraParams:@{@"isOwner":@(NO),@"contactModel":personModel}];
                }
            }
        }
        
        if (!hasModel) {
            [SVProgressHUD showErrorWithStatus:@"未查询到该联系人相关信息"];
        }
    }
}
@end
