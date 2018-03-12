//
//  NewsNoticeSettingViewController.m
//  PropertyManager
//
//  Created by Momo on 16/12/23.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "NewsNoticeSettingViewController.h"

@interface NewsNoticeSettingViewController ()

@property (nonatomic,strong) NSArray * titleArr;
@property (nonatomic,strong) NSArray * switchKeyArr;
@end

@implementation NewsNoticeSettingViewController

#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createLeftBarButtonItemWithTitle:@"消息通知"];
    
    NSArray * titleArr1 = @[@"声音",@"消息声音",@"工单动态声音"];
    NSArray * titleArr2 = @[@"震动",@"消息震动",@"工单动态震动"];
    self.titleArr = @[titleArr1,titleArr2];
    
    NSArray * switchKeyArr1 = @[AllSoundOpen,NewsSoundOpen,OrdersSoundOpen];
    NSArray * switchKeyArr2 = @[AllShakeOpen,NewsShakeOpen,OrdersShakeOpen];
    self.switchKeyArr = @[switchKeyArr1,switchKeyArr2];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        BOOL isAllsoundOpen = [[[NSUserDefaults standardUserDefaults] objectForKey:AllSoundOpen] boolValue];
        if (isAllsoundOpen) {
            return 3;
        }
        else{
            return 1;
        }
    }
    else{
        BOOL isAllShakeOpen = [[[NSUserDefaults standardUserDefaults] objectForKey:AllShakeOpen] boolValue];
        if (isAllShakeOpen) {

            return 3;
        }
        else{
            
            return 1;
        }
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identify = @"SettingNewsCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = self.titleArr[indexPath.section][indexPath.row];
    cell.textLabel.textColor = mainTextColor;
    
    
    for (UIView * view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    UISwitch * cellSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(ScreenWidth - 80, 10, 0, 0)];
   
    NSString * key = self.switchKeyArr[indexPath.section][indexPath.row];
    BOOL ret = BoolFromKey(key);
    cellSwitch.tag = indexPath.section  * 100 + indexPath.row * 10;
    cellSwitch.on = ret;
    [cellSwitch addTarget:self action:@selector(mySwitchClick:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:cellSwitch];
    
    return cell;
}

-(void)mySwitchClick:(UISwitch *)cellSwitch{
    NSInteger tag = cellSwitch.tag;
    NSInteger section = tag / 100;
    NSInteger row = tag % 100 / 10;
    
    BOOL ret = cellSwitch.on;
    NSString * key = self.switchKeyArr[section][row];
    
    NSLog(@"key===%@",key);
    SetBoolDefaults(ret, key);
    [MyUserDefaults synchronize];
    
    if ([key isEqualToString:AllSoundOpen] ){
        
        SetBoolDefaults(ret,NewsSoundOpen);
        [MyUserDefaults synchronize];
        SetBoolDefaults(ret,OrdersSoundOpen);
        [MyUserDefaults synchronize];
        
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
        [self.tableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else if ([key isEqualToString:NewsSoundOpen] ){
        
        SetBoolDefaults(ret,NewsSoundOpen);
        [MyUserDefaults synchronize];
        SetBoolDefaults(ret,OrdersSoundOpen);
        [MyUserDefaults synchronize];
        
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
        [self.tableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else if ([key isEqualToString:OrdersSoundOpen] ){

        SetBoolDefaults(ret,OrdersSoundOpen);
        [MyUserDefaults synchronize];
        
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
        [self.tableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    }
    
    else if ([key isEqualToString:AllShakeOpen]) {
        
        SetBoolDefaults(ret,NewsShakeOpen);
        [MyUserDefaults synchronize];
        SetBoolDefaults(ret,OrdersShakeOpen);
        [MyUserDefaults synchronize];
        
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
        [self.tableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    }
    else if ([key isEqualToString:NewsShakeOpen]) {
        
        SetBoolDefaults(ret,NewsShakeOpen);
        [MyUserDefaults synchronize];
        SetBoolDefaults(ret,OrdersShakeOpen);
        [MyUserDefaults synchronize];
        
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
        [self.tableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    }
    else if ([key isEqualToString:OrdersShakeOpen]) {

        SetBoolDefaults(ret,OrdersShakeOpen);
        [MyUserDefaults synchronize];
        
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
        [self.tableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


@end
