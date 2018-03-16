//
//  A_ZTableViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "A_ZTableViewController.h"

#import "ContactModel.h"
#import "ContactTableViewCell.h"
#import "ContactDataHelper.h"//根据拼音A~Z~#进行排序的tool

@interface A_ZTableViewController ()
{
    NSArray *_rowArr;//row arr
    NSArray *_sectionArr;//section arr
    NSArray *_searchArr;//section arr
}
@property (nonatomic,strong) NSMutableArray *dataArr;
@end

@implementation A_ZTableViewController
#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [self.tableView setSectionIndexColor:mainColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.dataArr = [NSMutableArray array];
    _searchArr = [NSArray arrayWithObjects:@"{search}",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
    [self resetMyNav];

    NSArray *userArray = [NSArray arrayWithObjects:@"fusername",@"first_py",@"fdepartmentname",@"fworkername",@"worker_id",@"user_sip", nil];
    [[MyFMDataBase shareMyFMDataBase] createDataBaseWithDataBaseName:@"A_ZInfo"];
    [[MyFMDataBase shareMyFMDataBase] createTableWithTableName:@"A_ZInfo" tableArray:userArray];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getDataFromDB];
    });
}

// 下拉刷新实现
-(void)getDataFromNetWork{
    // refresh data
    [self getDataFromDB];
    [self endRefresh];
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

- (void)getDataFromDB{
    UserManager * user = [UserManagerTool userManager];
    //数据库管理者
    MyFMDataBase * database = [MyFMDataBase shareMyFMDataBase];
    //打开数据库
    [database createDataBaseWithDataBaseName:user.worker_id];
    
    NSArray * replyArr = [database selectDataWithTableName:A_ZInfo withDic:nil];
    if (replyArr.count != 0) {
        self.dataArr = [NSMutableArray arrayWithArray:replyArr];
        _rowArr=[ContactDataHelper getFriendListDataBy:self.dataArr];
        _sectionArr=[ContactDataHelper getFriendListSectionBy:[_rowArr mutableCopy]];
        
        [self reloadView];
    }
    else{
        [self getFromNetWork];
    }
}

-(void)getFromNetWork{
    if (![self checkNetWork]) {
        [self endRefresh];
        return;
    }
    
    UserManager * user = [UserManagerTool userManager];
    NSString * department_id = user.department_id;
    NSDictionary *paraDic = @{@"department_id":department_id};
    
    [DetailRequest SYGet_communicate_listWithParms:paraDic SuccessBlock:^(NSArray *arr) {
         [self endRefresh];
        
        MyFMDataBase * database = [MyFMDataBase shareMyFMDataBase];
        [self.dataArr removeAllObjects];
        // 清空A_Z数据
        //[database deleteDataWithTableName:A_ZInfo delegeteDic:nil];
        NSArray * modelArr = [ContactModel mj_objectArrayWithKeyValuesArray:arr];
        
        for (int i = 0; i < modelArr.count; i ++) {
            
            ContactModel * model = modelArr[i];
            if (![PMTools isNullOrEmpty:model.user_sip] && ![PMTools isNullOrEmpty:user.user_sip]) {
                NSInteger modelSip = [model.user_sip integerValue];
                NSInteger uesrSip = [user.user_sip integerValue];
                if (modelSip != uesrSip) {
                    [self.dataArr addObject:model];
                    
                    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:arr[i]];
                    //插入数据
                    [database insertDataWithTableName:A_ZInfo insertDictionary:dic];
                }
                else{
                    SYLog(@"相同不增加联系人模型");
                }
            }
        }
        
        _rowArr=[ContactDataHelper getFriendListDataBy:self.dataArr];
        _sectionArr=[ContactDataHelper getFriendListSectionBy:[_rowArr mutableCopy]];
        
        if (_rowArr.count > 0 && _sectionArr.count > 0) {
            [self reloadView];
        }
        [self reloadView];
    } FailureBlock:^{
        [self cheakDataCount:self.dataArr];
        [self endRefresh];
    }];
    
    [self endRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //section
    return _rowArr.count;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //row
    return [_rowArr[section] count];
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return _searchArr;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    //NSString *key = [_searchArr objectAtIndex:index];
    
    for (int i=0; i<_sectionArr.count; i++) {
        NSString *letter = _sectionArr[i];
        
        if ([title isEqualToString:letter]) {
//            [tableView
//             scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]
//             atScrollPosition:UITableViewScrollPositionTop animated:YES];
            return i-1;
            break;
        }
    }
    
    return index;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
   
    return 2.0;
}

#pragma mark - UITableView dataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIde=@"A_ZCell";
    ContactTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIde];
    if (cell==nil) {
        cell=[[ContactTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIde];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    ContactModel *model=_rowArr[indexPath.section][indexPath.row];
    cell.letterLabel.text = @"";
    if (indexPath.row == 0) {
        cell.letterLabel.text = _sectionArr[indexPath.section+1];
    }

    cell.headImageView.backgroundColor = mainColor;
    cell.nameL.text = [PMTools subStringFromString:model.fworkername isFrom:NO];
    [cell.nameLabel setText:model.fworkername];
    cell.departmentLabel.text = model.fdepartmentname;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ContactModel *model=_rowArr[indexPath.section][indexPath.row];
    
    [[Routable sharedRouter] open:OWNER_VIEWCONTROLLER animated:YES extraParams:@{@"contactModel":model,@"isOwner":@(NO)}];
    
}


#pragma mark - 添加快捷联系人的导航栏
-(void)resetMyNav{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImageView * imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 8, 25, 25)];
    imageview.userInteractionEnabled = YES;
    imageview.image = [UIImage imageNamed:@"backArrow"];
    [button addSubview:imageview];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backAction)];
    [imageview addGestureRecognizer:tap];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, 165, 30)];
    label.text = @"添加快捷联系人";
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor whiteColor];
    label.font = LargeFont;
    [button addSubview:label];
    
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftItem;
    
}

-(void)backAction{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}
@end
