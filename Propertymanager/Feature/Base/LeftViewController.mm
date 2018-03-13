//
//  LeftViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/16.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "LeftViewController.h"
#import "AppDelegate.h"
@interface LeftViewController ()<UITableViewDelegate,UITableViewDataSource>


@property(nonatomic,strong) UIView * topView;

@property (nonatomic,strong) NSArray * imageArr;
@property (nonatomic,strong) NSArray * titleArr;
@end

@implementation LeftViewController

-(instancetype)init{
    if (self = [super init]) {

        [self createSubviews];
    }
    return self;
}

-(void)dealloc{
    SYLog(@"LeftViewController dealloc");

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageArr = @[@"MySetting",@"MyShare",@"MyAbout",@"login_out"];
    self.titleArr = @[@"个人设置",@"分享应用",@"关于",@"退出登录"];

}

-(void)createSubviews{
    
    UserManager * user = [UserManagerTool userManager];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight * 0.3)];
    self.topView.backgroundColor = mainColor;
    self.tableView.tableHeaderView = self.topView;

    
    ZYButton * iconBtn = [[ZYButton alloc] initWithTitle:[PMTools subStringFromString:user.worker_name isFrom:NO] font:LargeFont color:[UIColor whiteColor] selectColor:nil];
    [iconBtn layerCornerRadius:20 borderWidth:0.0f borderColor:nil];
    iconBtn.backgroundColor = [UIColor cyanColor];
    [self.topView addSubview:iconBtn];

    
    ZYLabel * nameLabel = [[ZYLabel alloc] initWithText:user.worker_name font:LargeFont color:[UIColor whiteColor]];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    [self.topView addSubview:nameLabel];
    
    
    ZYLabel * departmentLabel = [[ZYLabel alloc] initWithText:user.department_name font:SmallFont color:[UIColor whiteColor]];
    departmentLabel.textAlignment = NSTextAlignmentLeft;
    [self.topView addSubview:departmentLabel];
    
    
    [iconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).with.offset(10);
        make.width.equalTo(@40);
        make.top.equalTo(self.topView.mas_bottom).with.offset(-60);
        make.height.equalTo(@40);
    }];
    
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).with.offset(80);
        make.width.equalTo(@120);
        make.top.equalTo(iconBtn);
        make.height.equalTo(@25);
    }];

    [departmentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).with.offset(80);
        make.right.equalTo(self.topView);
        make.top.equalTo(nameLabel.mas_bottom);
        make.height.equalTo(@15);
    }];

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.titleArr.count - 1;
    }
    else{
        return 1;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 2;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identify = @"profileCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    

    if (indexPath.section == 0) {
        
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(17, 17.5, 25, 25)];
        imageView.image = [UIImage imageNamed:self.imageArr[indexPath.row]];
        [cell.contentView addSubview:imageView];
        
        UILabel * tLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 15, 120, 30)];
        tLabel.text = self.titleArr[indexPath.row];
        tLabel.textColor = mainTextColor;
        [cell.contentView addSubview:tLabel];
    }
    else{
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(17, 17.5, 25, 25)];
        imageView.image = [UIImage imageNamed:[self.imageArr lastObject]];
        [cell.contentView addSubview:imageView];
        
        UILabel * tLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 15, 120, 30)];
        tLabel.text = [self.titleArr lastObject];
        tLabel.textColor = mainTextColor;
        [cell.contentView addSubview:tLabel];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.tableView.userInteractionEnabled = NO;
    
    if (indexPath.section == 0) {
 
        //发通知跳转页面
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoOtherPage" object:@(indexPath.row)];

    }
    else{
        //退出登录
        [self.view endEditing:YES];
//        [WJYAlertView showTwoButtonsWithTitle:@"提示" Message:@"确认要退出登录吗？" ButtonType:WJYAlertViewButtonTypeNone ButtonTitle:@"确定" Click:^{
//            
//            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"token"];
//            [PMSipTools sipUnRegister];
//            [UserManager cancelManage];
//            [UserManagerTool saveUserManager:[UserManager manager]];
//            [GeTuiSdk setPushModeForOff:YES];
//            [[AppDelegate sharedInstance] setmanagerRootVC];
//
//            
//        } ButtonType:WJYAlertViewButtonTypeNone ButtonTitle:@"取消" Click:^{
//            
//        }];
        
        
    }
    
    [self performSelector:@selector(tableViewCellClick) withObject:nil afterDelay:2.0f];
    
}

-(void)tableViewCellClick{
    self.tableView.userInteractionEnabled = YES;
}


@end
