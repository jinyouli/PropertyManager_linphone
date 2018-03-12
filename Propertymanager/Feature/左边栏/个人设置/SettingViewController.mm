//
//  SettingViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/16.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "SettingViewController.h"


@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView * tableview;

@property (nonatomic,strong) NSArray * titleArr;

@end

@implementation SettingViewController


#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ClickLeftBarButtonAction" object:nil];
    [self createLeftBarButtonItemWithImage:@"backArrow" WithTitle:@"个人设置" withMethod:@selector(returnBtnClick)];
 
    self.titleArr = @[@"修改密码",@"勿扰模式",@"消息通知",];
    
    [self createSubviews];
}

-(void)createSubviews{
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.view addSubview:self.tableview];
}

#pragma mark - tableview
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titleArr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    return 1;
 
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identify = @"settingCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = self.titleArr[indexPath.section];
    cell.textLabel.textColor = mainTextColor;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        // 修改密码
        [[Routable sharedRouter] open:RESETPASSWORD_VIEWCONTROLLER];
    }
    else if (indexPath.section == 1){

        // 勿扰模式
        [[Routable sharedRouter] open:DONDISTRUB_VIEWCONTROLLER];
    }
    else if (indexPath.section == 2){
        
        // 消息通知
        [[Routable sharedRouter] open:NEWSNOTICE_VIEWCONTROLLER];
    }

}

-(void)returnBtnClick{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ClickLeftBarButtonAction" object:nil];
    [self.navigationController popViewControllerAnimated:NO];
}


@end
