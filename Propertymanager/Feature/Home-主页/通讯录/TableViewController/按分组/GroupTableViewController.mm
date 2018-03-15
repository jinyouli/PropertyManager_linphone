//
//  GroupTableViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "GroupTableViewController.h"
#import "ContactModel.h"
#import "ContactTableViewCell.h"
#import "ContactDataHelper.h"//根据拼音A~Z~#进行排序的tool
#import "NSString+Utils.h"


@interface GroupTableViewController ()
{
    /** 字母索引*/
    NSArray *_sectionPYArr;
}
@property (nonatomic,strong) NSMutableArray *dataArr; /** 所有数据*/
@property (nonatomic,strong) NSMutableArray *secDataArr;
@end

@implementation GroupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [self.tableView setSectionIndexColor:mainColor];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.secDataArr = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getDataFromNetWork];
    });
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

- (void)getDataFromNetWork{
    if (![self checkNetWork]) {
        [self endRefresh];
        return;
    }
    
    UserManager * user = [UserManagerTool userManager];
    NSString * department_id = user.department_id;
    NSDictionary *paraDic = @{@"department_id":department_id,@"get_type":@"3"};
    self.dataArr = [NSMutableArray array];
    
    [DetailRequest SYGet_worker_listWithParms:paraDic SuccessBlock:^(NSArray *workers) {
        [self endRefresh];
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
            [self.secDataArr addObject:mdic];
            
        }
        //初始化拼音首字母数组
        //[self initSectionPingYinArr:groupNameArr];
        [self reloadView];
    } FailureBlock:^{
        [self cheakDataCount:self.secDataArr];
        [self endRefresh];
    }];
    
    [self endRefresh];
}

-(void)initSectionPingYinArr:(NSArray *)grounpNameArr{
    
    NSMutableArray *section = [[NSMutableArray alloc] init];
    [section addObject:UITableViewIndexSearch];
    
    
    for (NSString * string in grounpNameArr) {
        char c = [string.pinyin characterAtIndex:0];
        if (!isalpha(c)) {
            c = '#';
        }
        
        NSString * cStr = [NSString stringWithFormat:@"%c", toupper(c)];
        BOOL ret = YES;
        for (NSString * str in section) {
            if ([str isEqualToString:cStr]) {
                ret = NO;
                break;
            }
        }
        if (ret) {
            [section addObject:cStr];
        }
        
        
    }
    _sectionPYArr = section;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //section
    return _secDataArr.count;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //row
    if (self.secDataArr.count == 0) {
        return 0;
    }
    else{
        NSArray * workList = self.secDataArr[section][@"worker_list"];
        return workList.count;
    }
    
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return _sectionPYArr;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index-1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 65.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

#pragma mark - UITableView dataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIde=@"groupCell";
    ContactTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIde];
    if (cell==nil) {
        cell=[[ContactTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIde];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    cell.letterLabel.text = @"";
    cell.headImageView.backgroundColor = mainColor;
    NSDictionary * worker_listDic = self.secDataArr[indexPath.section][@"worker_list"][indexPath.row];
    if (![PMTools isNullOrEmpty:worker_listDic[@"fworkername"]]) {
        cell.nameLabel.text = worker_listDic[@"fworkername"];
    }
    else{
        cell.nameLabel.text = @"";
    }

    cell.nameL.text = [PMTools subStringFromString:cell.nameLabel.text isFrom:NO];
    
    if (![PMTools isNullOrEmpty:worker_listDic[@"fdepartmentname"]]) {
        cell.departmentLabel.text = worker_listDic[@"fdepartmentname"];
    }
    
    
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    //viewforHeader
    
    UIImageView * iconView = (UIImageView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"headerView"];
    if (!iconView) {
        
        iconView = [[UIImageView alloc] init];
        iconView.frame = CGRectMake(10, 0, ScreenWidth, 65.0);
        iconView.backgroundColor = [UIColor whiteColor];
        
        UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
        line.backgroundColor = lineColor;
        [iconView addSubview:line];
        
        
        UIImageView * iconV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10.0, 40.0, 40.0)];
        iconV.layer.cornerRadius = 20;
        iconV.backgroundColor = mainColor;
        iconV.clipsToBounds = YES;
        iconV.tag = 1500;
        [iconV setContentMode:UIViewContentModeScaleAspectFill];
        [iconView addSubview:iconV];
        
        UILabel * nameL = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 40, 20)];
        nameL.tag = 1501;
        nameL.font = MiddleFont;
        nameL.textAlignment = NSTextAlignmentCenter;
        nameL.textColor = [UIColor whiteColor];
        [iconV addSubview:nameL];
        
        UILabel * nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(60.0, 20.0, ScreenWidth-60.0, 25.0)];
        nameLabel.tag = 1502;
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.font = LargeFont;
        nameLabel.textColor = mainTextColor;
        [iconView addSubview:nameLabel];
        
    }
    UILabel * nameLabel1 = (UILabel *)[iconView viewWithTag:1502];
    nameLabel1.text = self.secDataArr[section][@"fgroup_name"];
    
    UIImageView * iconV1 = (UIImageView *)[iconView viewWithTag:1500];
    
    UILabel * nameL1 = (UILabel *)[iconV1 viewWithTag:1501];
    nameL1.text = [PMTools subStringFromString:nameLabel1.text isFrom:YES];
    
    return iconView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    ContactModel * model = [[ContactModel alloc]init];
    NSDictionary * worker_listDic = self.secDataArr[indexPath.section][@"worker_list"][indexPath.row];
    model.fworkername = worker_listDic[@"fworkername"];
    model.fdepartmentname = worker_listDic[@"fdepartmentname"];
    model.user_sip = worker_listDic[@"user_sip"];
    model.worker_id = worker_listDic[@"worker_id"];
    model.fusername = worker_listDic[@"fusername"];
    
    [[Routable sharedRouter] open:OWNER_VIEWCONTROLLER animated:YES extraParams:@{@"contactModel":model,@"isOwner":@(NO)}];

}


@end
