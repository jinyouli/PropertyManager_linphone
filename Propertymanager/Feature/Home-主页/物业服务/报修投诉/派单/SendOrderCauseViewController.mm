//
//  SendOrderCauseViewController.m
//  idoubs
//
//  Created by Momo on 16/7/2.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "SendOrderCauseViewController.h"
#import "TextViewCustom.h"
@interface SendOrderCauseViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSString * content;
@property (nonatomic,strong) NSArray * causeTitleArr;
@property (nonatomic,strong) NSArray * causeContentArr;
@property (nonatomic,strong) UITableView * tableview;
@property (nonatomic,strong) UIButton * currentBtn;
@property (nonatomic,strong) TextViewCustom * textView;

@end

@implementation SendOrderCauseViewController

#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        
        if (![PMTools isNullOrEmpty:params[@"repairs_id"]]) {
            self.repairs_id = params[@"repairs_id"];
        }
        
        if (![PMTools isNullOrEmpty:params[@"deal_worker_id"]]) {
            self.deal_worker_id = params[@"deal_worker_id"];
        }
        
        if (![PMTools isNullOrEmpty:params[@"worker_id"]]) {
            self.worker_id = params[@"worker_id"];
        }
    }
    return self;
}


-(void)dealloc{
    SYLog(@"SendOrderCauseViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createLeftBarButtonItemWithTitle:@"选择派往原因"];
    [self createRightBarButtonItemWithImage:nil WithTitle:@"发布" withMethod:@selector(sendBtnClick)];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [self.rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.rightBtn.enabled = NO;
    self.rightBtn.selected = NO;
    
    [self createSubviews];
}

-(void)createSubviews{
    self.causeTitleArr = @[@"协作原因：",@"个人原因：",@"用户原因:",@"其他原因："];
    self.causeContentArr = @[@"工单需要多人协作",@"前处理人员个人原因导致工单未处理",@"用户投诉需换人处理",@""];
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.view addSubview:self.tableview];
}

-(void)sendBtnClick{
    // 状态改变
    UserManager * user = [UserManagerTool userManager];
    // 状态
    NSDictionary * stateParaDic = @{@"do_type":@"4",@"repairs_id":self.repairs_id,@"worker_id":user.worker_id,@"change_worker_id":self.worker_id,@"deal_worker_id":self.deal_worker_id};

    NSLog(@"发布==%@",stateParaDic);
    if ([self checkNetWork]) {
        [SVProgressHUD showWithStatus:@"请稍等" maskType:SVProgressHUDMaskTypeGradient];
        [DetailRequest SYUpdate_order_statusWithParms:stateParaDic SuccessBlock:^{
            //上传记录
            [self repairs_record];
        } FailureBlock:^{
            [SVProgressHUD dismiss];
        }];
    
    }

}

-(void)repairs_record{
    
    NSString * url = MyUrl(SYSave_repairs_record);
    SYLog(@"保存工单路径 ---- 记录 ==== %@",url);
    
    if (self.currentBtn.tag != 1003) {
        self.content = self.causeContentArr[self.currentBtn.tag - 1000];
    }
    else{
        self.content = self.textView.textView.text;
    }

    NSDictionary * paraDic = @{@"worker_id":[UserManagerTool userManager].worker_id,
                               @"repairs_id":self.repairs_id,
                               @"owner":@"2",
                               @"type":@"4",
                               @"old_worker_id":self.deal_worker_id,
                               @"new_worker_id":self.worker_id,
                               @"content":self.content,
                               @"image":@""};
    
    
    if ([self checkNetWork]) {
        
        
        [DetailRequest SYSave_repairs_recordWithParms:paraDic SuccessBlock:^{
            [SVProgressHUD dismiss];
            //[SVProgressHUD showSuccessWithStatus:@"转单成功"];
            [SYCommon addAlertWithTitle:@"转单成功"];
            // 返回上上页
            [[NSNotificationCenter defaultCenter]postNotificationName:@"getDataFromMyDoing" object:nil];
            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
            
        } FailureBlock:^{
            [SVProgressHUD dismiss];
        }];

    }
    else{
         [SVProgressHUD dismiss];
    }
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.causeContentArr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 3) {
        return 150;
    }
    else{
        return 60;
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"原因选择（必选）";
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identify = @"causeCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for (UIView * view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 25, 25)];
    [btn setImage:[UIImage imageNamed:@"icon_payment_off"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"icon_payment_on"] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = indexPath.row + 1000;
    [cell.contentView addSubview:btn];
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, ScreenWidth - 50 , 30)];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = LargeFont;
    titleLabel.text = self.causeTitleArr[indexPath.row];;
    [cell.contentView addSubview:titleLabel];
    if (indexPath.row == 3) {
        //创建textView
        UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(50, 30, ScreenWidth - 50 - 20, 100)];
        bgView.layer.cornerRadius = 8;
        bgView.layer.borderWidth = 1;
        bgView.layer.borderColor = lineColor.CGColor;
        [cell.contentView addSubview:bgView];
        
        self.textView = [[TextViewCustom alloc]initWithFrame:CGRectMake(2, 2, ScreenWidth - 50 - 20 - 4 , 100 - 4 )];
        self.textView.placehLab.text = @"在此填写其他原因";
        [bgView addSubview:self.textView];
        
    }else{
        UILabel * desLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 30, ScreenWidth - 50, 25)];
        desLabel.textAlignment = NSTextAlignmentLeft;
        desLabel.font = MiddleFont;
        desLabel.textColor = lineColor;
        desLabel.text = self.causeContentArr[indexPath.row];;
        [cell.contentView addSubview:desLabel];
    }
    

    return cell;
}

-(void)btnClick:(UIButton *)btn{
    self.rightBtn.enabled = YES;
    self.rightBtn.selected = YES;
    
    self.currentBtn.selected = NO;
    self.currentBtn = btn;
    self.currentBtn.selected = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
