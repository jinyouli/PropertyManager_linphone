//
//  SendOrderViewController.m
//  idoubs
//
//  Created by Momo on 16/6/28.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "SendOrderViewController.h"

@interface SendOrderViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray * worker_listArr;
@property (nonatomic,strong) UITableView * tableview;
@property (nonatomic,strong) NSMutableArray * sWorker_idArr;
@property (nonatomic,strong) NSMutableArray * selected_tag;
@property (nonatomic,strong) UIButton * currentBtn;
@property (nonatomic,strong) MBProgressHUD *hub;
@end

@implementation SendOrderViewController

#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        
        if (![PMTools isNullOrEmpty:params[@"do_type"]]) {
            self.do_type = params[@"do_type"];
        }
        
        if (![PMTools isNullOrEmpty:params[@"repairs_id"]]) {
            self.repairs_id = params[@"repairs_id"];
        }
        
        if (![PMTools isNullOrEmpty:params[@"deal_worker_id"]]) {
            self.deal_worker_id = params[@"deal_worker_id"];
        }

    }
    return self;
}



-(void)dealloc{
    SYLog(@"SendOrderViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createLeftBarButtonItemWithTitle:@"选择派往人员"];
    
    
    [self createSubviews];
    self.sWorker_idArr = [NSMutableArray array];
    self.selected_tag = [NSMutableArray array];
    
    if ([self.do_type isEqualToString:@"1"]) {
        //派单
        [self createRightBarButtonItemWithImage:nil WithTitle:@"派发" withMethod:@selector(sendBtnClick)];
        [self getData:@"1"];

    }
    else if ([self.do_type isEqualToString:@"2"]) {
        //转单
        [self createRightBarButtonItemWithImage:nil WithTitle:@"转派" withMethod:@selector(sendBtnClick)];
        [self getData:@"2"];
        
    }
    
    self.hub = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hub];
    self.hub.label.text = @"正在加载";
}

-(void)createSubviews{
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStyleGrouped];
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableview];
    
}

#pragma Mark - 获取派单工单组
-(void)getData:(NSString *)type{
    if ([self checkNetWork]) {
        
        UserManager * user = [UserManagerTool userManager];
        NSDictionary * paraDic = @{@"get_type":type,@"repairs_id":self.repairs_id,@"department_id":user.department_id};

        [DetailRequest SYGet_worker_listWithParms:paraDic SuccessBlock:^(NSArray *workers) {
            self.worker_listArr = workers;
            [self.tableview reloadData];
        } FailureBlock:nil];
    }
}

#pragma mark - tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.worker_listArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray * arr = self.worker_listArr[section][@"worker_list"];
    return arr.count + 1; //多出来1为整组！
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identify = @"SendOrderCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    for (UIView * view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSDictionary * dic = self.worker_listArr[indexPath.section];
    NSArray * workArr = self.worker_listArr[indexPath.section][@"worker_list"];
    
    UIButton * iconView = [[UIButton alloc]init];
    iconView.titleLabel.font = MiddleFont;
    iconView.backgroundColor = mainColor;
    [cell.contentView addSubview:iconView];
    
    
    UILabel * nameLabel  = [[UILabel alloc]init];
    [cell.contentView addSubview:nameLabel];
    
    UILabel * selectLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 110, 15, 40, 30)];
    selectLabel.textAlignment = NSTextAlignmentRight;
    selectLabel.font = LargeFont;
    selectLabel.textColor = mainTextColor;
    [cell.contentView addSubview:selectLabel];
    
 
    UIButton * rowbtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - 60, 17.5, 25, 25)];
    rowbtn.layer.cornerRadius = rowbtn.frame.size.width / 2;
    [rowbtn setImage:[UIImage imageNamed:@"icon_payment_off"] forState:UIControlStateNormal];
    [rowbtn setImage:[UIImage imageNamed:@"icon_payment_on"] forState:UIControlStateSelected];
    [rowbtn addTarget:self action:@selector(rowBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    rowbtn.tag = 10000 + indexPath.section * 1000 + indexPath.row;
    [cell.contentView addSubview:rowbtn];
    
    if (indexPath.row == 0) {
        
        iconView.frame = CGRectMake(20, 10, 40, 40);
        iconView.layer.cornerRadius = iconView.frame.size.width / 2;
        
        nameLabel.frame = CGRectMake(CGRectGetMaxX(iconView.frame)+10, 15, 100, 30);
        nameLabel.font = [UIFont boldSystemFontOfSize:16];
        if (![PMTools isNullOrEmpty:dic[@"fgroup_name"]]) {
             nameLabel.text = dic[@"fgroup_name"];
            [iconView setTitle:[PMTools subStringFromString:nameLabel.text isFrom:NO] forState:UIControlStateNormal];
        }
       
        
        selectLabel.text = @"整组";
        
         if ([self.do_type isEqualToString:@"2"]) {
            //转单
             rowbtn.hidden = YES;
             selectLabel.hidden = YES;
        }


    }
    else{
        iconView.frame = CGRectMake(60, 5, 40, 40);
        iconView.layer.cornerRadius = iconView.frame.size.width / 2;
        
        nameLabel.frame  = CGRectMake(CGRectGetMaxX(iconView.frame)+10, 5, 100, 25);
        nameLabel.font = LargeFont;
        if (![PMTools isNullOrEmpty:workArr[indexPath.row - 1][@"fworkername"]]) {
            nameLabel.text = workArr[indexPath.row - 1][@"fworkername"];
            [iconView setTitle:[PMTools subStringFromString:nameLabel.text isFrom:NO] forState:UIControlStateNormal];
        }
        
        CGFloat deY = CGRectGetMaxX(iconView.frame)+10;
        UILabel * departmentLabel  = [[UILabel alloc]initWithFrame:CGRectMake(deY, 30, ScreenWidth - deY - 50, 20)];
        departmentLabel.font = SmallFont;
        if (![PMTools isNullOrEmpty:workArr[indexPath.row - 1][@"fdepartmentname"]]) {
            departmentLabel.text = workArr[indexPath.row - 1][@"fdepartmentname"];
        }
        
        [cell.contentView addSubview:departmentLabel];
        
        
        NSString * str = workArr[indexPath.row - 1][@"no_receiving"];
        //1表示未接单，0表示正常显示
        if ([str integerValue] == 0) {
            str = @"";
        }
        else{
            str = @"未接";
        }
        selectLabel.text = str;
        selectLabel.textColor = TImageColor;
        
        // 1派单 2转单（派单时显示是否接单，转单时不显示）
        if ([self.do_type isEqualToString:@"2"]){
            selectLabel.hidden = YES;
        }else{
            selectLabel.hidden = NO;
        }

    }
    
    for (int i=0; i<self.selected_tag.count; i++) {
        NSNumber *selected_tag = [self.selected_tag objectAtIndex:i];
        NSInteger selectedTag = [selected_tag integerValue];
        
        NSLog(@"%ld,%d",selectedTag,rowbtn.tag);
        if (selectedTag == rowbtn.tag) {
            rowbtn.selected = YES;
        }
    }
    return cell;
}

#pragma mark - 选择派单按钮
-(void)rowBtnClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    
    // 第几组的第几个按钮 （ row == 0 第一个按钮都是整组 其余按钮是个人）
    NSInteger section = (btn.tag - 10000) / 1000;
    NSInteger row = (btn.tag - 10000) % 100;
    
    NSArray * workArr = self.worker_listArr[section][@"worker_list"];
    NSInteger count = workArr.count;
    
    if (row == 0) {
        //整组点击
//        SYLog(@"选中整组 第%d组",section);
        
        //遍历 将整个组的btn选中
        if (btn.selected) {
            
            //增加整组人数
            for (int i = 0; i < count; i ++) {
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i+1 inSection:section];
                UITableViewCell * cell = [self.tableview cellForRowAtIndexPath:indexPath];
                UIButton * cellBtn = (UIButton *)[cell.contentView viewWithTag:btn.tag + i + 1];
                cellBtn.selected = YES;
                [self.sWorker_idArr addObject:workArr[i][@"worker_id"]];
                
                if (cellBtn.tag == 0) {
                    [self.selected_tag addObject:[NSNumber numberWithInteger:10000 + section * 1000 + i]];
                }
                else{
                    [self.selected_tag addObject:[NSNumber numberWithInteger:cellBtn.tag]];
                }
                
                if (i == count - 1) {
                    if (cellBtn.tag == 0) {
                        [self.selected_tag addObject:[NSNumber numberWithInteger:10000 + section * 1000 + i + 1]];
                    }
                }
            }
            [self.selected_tag addObject:[NSNumber numberWithInteger:btn.tag]];
        }
        else{
            // 减少整组人数
            for (int i = 0; i < count; i ++) {
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i+1 inSection:section];
                UITableViewCell * cell = [self.tableview cellForRowAtIndexPath:indexPath];
                UIButton * cellBtn = (UIButton *)[cell.contentView viewWithTag:btn.tag + i + 1];
                cellBtn.selected = NO;
                [self.sWorker_idArr removeObject:workArr[i][@"worker_id"]];
                
                if (cellBtn.tag == 0) {
                    [self.selected_tag removeObject:[NSNumber numberWithInteger:10000 + section * 1000 + i]];
                }
                else{
                    [self.selected_tag removeObject:[NSNumber numberWithInteger:cellBtn.tag]];
                }
                
                if (i == count - 1) {
                    if (cellBtn.tag == 0) {
                        [self.selected_tag removeObject:[NSNumber numberWithInteger:10000 + section * 1000 + i + 1]];
                    }
                }
            }
        }
    }
    else{
        //个人点击
        
        UITableViewCell * cell = [self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        for (UIButton *btn in cell.contentView.subviews) {
            if (btn.tag == 10000 + section * 1000) {
                btn.selected = NO;
                
            }
        }
        
        if (btn.selected) {
            
            
            if ([self.do_type isEqualToString:@"2"]) {
                //转派
                self.currentBtn.selected = NO;
                self.currentBtn = btn;
                self.currentBtn.selected = YES;
                
                // 如果被派过的人不能选
#pragma mark - 如果被派过的人不能选
                NSString * selectWork_id = workArr[row - 1][@"worker_id"];
                if ([selectWork_id isEqualToString:self.deal_worker_id]) {
                    btn.selected = NO;
                    
                    [self createAlertWithMessage:@"不能选上一次操作的人"];
                    return;
                }
                //转派只能选一人
                if (self.sWorker_idArr.count >= 1) {
                    [self.sWorker_idArr removeAllObjects];
                    [self.selected_tag removeAllObjects];
                }
                //增加
                [self.sWorker_idArr addObject:selectWork_id];
                [self.selected_tag addObject:[NSNumber numberWithInteger:btn.tag]];
            }
            else{
                //增加
                [self.sWorker_idArr addObject:workArr[row - 1][@"worker_id"]];
                [self.selected_tag addObject:[NSNumber numberWithInteger:btn.tag]];
            }
            
            
        }
        else{
            //减少
            [self.sWorker_idArr removeObject:workArr[row - 1][@"worker_id"]];
            [self.selected_tag removeObject:[NSNumber numberWithInteger:btn.tag]];
        }
    }
}


#pragma mark - 派单按钮确认点击
-(void)sendBtnClick{
    SYLog(@"派发");
    NSString * workerStr = [self.sWorker_idArr componentsJoinedByString:@","];
    
    if ([self checkNetWork]) {
        
        UserManager * user = [UserManagerTool userManager];
    
        if ([self.do_type isEqualToString:@"1"]) {
            //派单
            //[SVProgressHUD showWithStatus:@"请稍等"];
            
            if ([workerStr isEqualToString:@""]) {
                [SYCommon addAlertWithTitle:@"请选择派往人员"];
                return;
            }
            
            NSDictionary * paraDic = @{@"do_type":self.do_type,
                       @"repairs_id":self.repairs_id,
                       @"worker_id":user.worker_id,
                       @"receive_worker_ids":workerStr};
            
            NSLog(@"转派==%@",paraDic);
            [self.hub showAnimated:YES];
            [DetailRequest SYUpdate_order_statusWithParms:paraDic SuccessBlock:^{
                //[SVProgressHUD showSuccessWithStatus:@"派单成功"];
                [SYCommon addAlertWithTitle:@"派单成功"];
                [self.hub hideAnimated:YES];
                //发通知刷新数据
                [[NSNotificationCenter defaultCenter]postNotificationName:@"RepairUpdateUnDoing" object:nil];
                [self.navigationController popViewControllerAnimated:YES];

            } FailureBlock:^{
                [self.hub hideAnimated:YES];
            }];
        }
        else if ([self.do_type isEqualToString:@"2"]) {
            //转单
            SYLog(@"进入转派原因");
            // 要选择原因 然后上传
            [[Routable sharedRouter] open:SENDORDERCAUSE_VIEWCONTROLLER animated:YES extraParams:@{@"repairs_id":self.repairs_id,@"deal_worker_id":self.deal_worker_id,@"worker_id":workerStr}];
        }
    }
    
    
}

@end
