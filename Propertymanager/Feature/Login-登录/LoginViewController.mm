//
//  LoginViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/16.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "LoginViewController.h"
#import "TextFieldCustom.h"
#import "Nei_IPModel.h"

@interface LoginViewController ()<UITableViewDelegate,UITableViewDataSource>

/** 用户名输入框*/
@property (nonatomic,strong) TextFieldCustom *phoneTextField;
/** 密码输入框*/
@property (nonatomic,strong) TextFieldCustom *passTextField;
/** 选择社区输入框*/
@property (nonatomic,strong) TextFieldCustom * mySelectPlot;
/** 登录按钮*/
@property (nonatomic,strong) UIButton *LoginBtn;
/** 忘记密码按钮*/
@property (nonatomic,strong) UIButton *forgetBtn;
/** 选择社区*/
@property (nonatomic,strong) UITableView * selectPlotTableView;
@property (nonatomic,strong) MBProgressHUD *hub;
@end

@implementation LoginViewController
#pragma mark - 初始化
#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        self.selectPlotArr = [NSMutableArray arrayWithObject:@"请选择所在物业"];
    }
    return self;
}

-(instancetype)init{
    if (self = [super init]) {
        self.selectPlotArr = [NSMutableArray arrayWithObject:@"请选择所在物业"];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [PMSipTools sipUnRegister];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BGColor;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    [self getPlotIPData];
    [self setWhiteTitle:@"登陆"];
    [self createSubviews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideHub) name:@"hideHub" object:nil];
    
    self.hub = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hub];
    self.hub.label.text = @"正在加载";
}

- (void)hideHub
{
    [self.hub hideAnimated:YES afterDelay:0.8f];
}

-(void)createSubviews{

    self.view.backgroundColor = BGColor;
    
    UIImageView * logoImageView = [[UIImageView alloc]init];
    logoImageView.image = [UIImage imageNamed:@"login_logo1"];
    logoImageView.userInteractionEnabled = YES;
    [self.view addSubview:logoImageView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeIP)];
    tap.numberOfTapsRequired = 6;
    [logoImageView addGestureRecognizer:tap];

    [self.view addSubview:self.phoneTextField];
    [self.view addSubview:self.passTextField];
    [self.view addSubview:self.mySelectPlot];
    
    self.phoneTextField.contentTextField.text = userLoginUsername;
    self.passTextField.contentTextField.text = userPassword;
 
    [self.view addSubview:self.LoginBtn];
    [self.view addSubview:self.forgetBtn];
    [self.view addSubview:self.selectPlotTableView];
    
    
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@220);
        make.top.equalTo(self.view).with.offset(25);
        make.height.equalTo(@120);
    }];
    
    [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.width.equalTo(@(ScreenWidth));
        make.top.equalTo(logoImageView.mas_bottom).with.offset(10);
        make.height.equalTo(@50);
    }];
    
    [self.passTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.width.equalTo(@(ScreenWidth));
        make.top.equalTo(self.phoneTextField.mas_bottom);
        make.height.equalTo(@50);
    }];
    
    [self.mySelectPlot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.width.equalTo(@(ScreenWidth));
        make.top.equalTo(self.passTextField.mas_bottom);
        make.height.equalTo(@50);
    }];
    
    [self.LoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(20);
        make.width.equalTo(@(ScreenWidth - 40));
        make.top.equalTo(self.mySelectPlot.mas_bottom).with.offset(25);
        make.height.equalTo(@40);
    }];
    
    [self.forgetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@80);
        make.top.equalTo(self.LoginBtn.mas_bottom).with.offset(20);
        make.height.equalTo(@40);
    }];
    
    [self.selectPlotTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(40);
        make.width.equalTo(@(ScreenWidth - 60));
        make.top.equalTo(self.mySelectPlot.mas_bottom);
        make.height.equalTo(@120);
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    self.selectPlotTableView.hidden = YES;
}


-(void)selectBtnClick{
    if (self.selectPlotArr.count != 1) {
        self.selectPlotTableView.hidden = NO;
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"暂无小区，请稍后重试"];
    }
    
}

-(void)changeIP{

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"切换IP" message:@"输入IP地址和端口号" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"在此输入IP地址";
        textField.text = @"gdsayee.cn";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"在此输入端口号";
        textField.text = @"28084";
    }];
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField * textF = alertController.textFields.firstObject;
        UITextField * textF_2 = alertController.textFields.lastObject;
        
        if ([PMTools isNullOrEmpty:textF.text]) {
            [SVProgressHUD showErrorWithStatus:@"您没有输入IP地址"];
            return ;
        }
        
        if ([PMTools isNullOrEmpty:textF_2.text]) {
            [SVProgressHUD showErrorWithStatus:@"您没有输入端口号"];
            return ;
        }
    
        NSString * str = [NSString stringWithFormat:@"%@:%@",textF.text,textF_2.text];
        [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"firLocalhost"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        SYLog(@"一级 firLocalhost === %@",str);
        //[SVProgressHUD showSuccessWithStatus:@"切换IP成功"];
        [SYCommon addAlertWithTitle:@"切换IP成功"];
        
        [self getPlotIPData];

    }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
}

-(void)loginBtnClick{
    [self.view endEditing:YES];
    
    SYLog(@"登录按钮点击");
    
    [self loginBtnClickWithPhone:self.phoneTextField.contentTextField.text password:self.passTextField.contentTextField.text isFirstLogin:YES];
}

-(void)loginBtnClickWithPhone:(NSString *)phone password:(NSString *)password isFirstLogin:(BOOL)ret{
    
    //判断是否输入为空
    if ([PMTools isNullOrEmpty:phone]||[PMTools isNullOrEmpty:password]) {
        [self createAlertWithMessage:@"手机或密码不能为空！"];
        return;
    }
    
    //判断是否有非法字符
    if ([PMTools isHaveIllegalChar:password]) {
        [self createAlertWithMessage:@"您输入的密码含有非法字符"];
        return;
    }
    //判断是否为手机号
    if (![PMTools isPhoneNumber:phone] ) {
        [self createAlertWithMessage:@"请输入正确手机号"];
        return;
    }
    //判断密码是否小于6位
    if (password.length < 6) {
        [self createAlertWithMessage:@"密码不能小于6位"];
        return;
    }
    
    //判断是否选择了小区
    if ([self.mySelectPlot.contentTextField.text isEqualToString:@"请选择所在物业"] ||[self.mySelectPlot.contentTextField.text isEqualToString:@""]) {
        [self createAlertWithMessage:@"请选择所在物业"];
        return;
    }
    
    [self.hub showAnimated:YES];
    [DetailRequest loginBtnClickWithPhone:phone password:password isFirstLogin:YES];
    
}

-(void)forgetBtnClick{
    [[Routable sharedRouter] open:FORGETPASSWORD_VIEWCONTROLLER];
}



#pragma mark - tableviewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.selectPlotArr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identify = @"selectPlotCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = self.selectPlotArr[indexPath.row];
    }
    else{
        Nei_IPModel * model = self.selectPlotArr[indexPath.row];
        cell.textLabel.text = model.fneib_name;
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.row == 0) {
        self.mySelectPlot.contentTextField.text = self.selectPlotArr[indexPath.row];
    }
    else{
        Nei_IPModel * model = self.selectPlotArr[indexPath.row];
        self.mySelectPlot.contentTextField.text = model.fneib_name;
        NSString * sLocalhost = [NSString stringWithFormat:@"%@:%@",model.fip,model.fport];
        [[NSUserDefaults standardUserDefaults] setObject:sLocalhost forKey:@"scoendLocalhost"];
        SYLog(@"二级 ScoendLocalhost === %@",ScoendLocalhost);
    }
    
    self.selectPlotTableView.hidden = YES;

}

#pragma mark - 网络请求
#pragma mark - 获取小区列表
-(void)getPlotIPData{
    
    [DetailRequest SYGet_nei_list_of_tenementWithSuccessBlock:^(NSArray * value) {
        NSArray * modelArr = [Nei_IPModel mj_objectArrayWithKeyValuesArray:value];
        
        self.selectPlotArr = [NSMutableArray arrayWithObject:@"请选择所在物业"];
        for (Nei_IPModel * model in modelArr) {
            if (model.fmanagement) {
                [self.selectPlotArr addObject:model];
            }
        }
        
        
        self.selectPlotTableView.hidden = YES;
        
        CGRect rect = self.selectPlotTableView.frame;
        if (self.selectPlotArr.count < 3) {
            rect.size.height = self.selectPlotArr.count * 40 + 20;
        }
        else{
            rect.size.height = 130;
        }
        self.selectPlotTableView.frame = rect;
        [self.selectPlotTableView reloadData];
    }];
    
}


#pragma mark - 懒加载
- (TextFieldCustom *)phoneTextField{
    if (!_phoneTextField) {
        _phoneTextField = [[TextFieldCustom alloc]initWithPreLeftImageName:@"login_phone" withPlaceholder: @"手机号（账号）" isSecure:NO];
        _phoneTextField.contentTextField.keyboardType = UIKeyboardTypePhonePad;
        [_phoneTextField createTopLineIsLong:YES];
        [_phoneTextField createBottomLineIsLong:NO];
    }
    return _phoneTextField;
}

- (TextFieldCustom *)passTextField{
    if (!_passTextField) {
        _passTextField = [[TextFieldCustom alloc]initWithPreLeftImageName:@"login_password" withPlaceholder:@"密码" isSecure:YES];
        [_passTextField createLookPasswordRightBtn];
        [_passTextField createBottomLineIsLong:NO];
    }
    return _passTextField;
}

- (TextFieldCustom *)mySelectPlot{
    if (!_mySelectPlot) {
        _mySelectPlot = [[TextFieldCustom alloc]initWithPreLeftImageName:@"login_password" withPlaceholder:@"请选择所在物业" isSecure:NO];
        _mySelectPlot.contentTextField.textColor = lineColor;
        [_mySelectPlot createBottomLineIsLong:YES];
        
        _mySelectPlot.contentTextField.backgroundColor = MYColor(238, 238, 238);
        _mySelectPlot.contentTextField.alpha = 0.7;
        _mySelectPlot.contentTextField.layer.cornerRadius = 4;

        UIButton * selectBtn = [[UIButton alloc]initWithFrame:CGRectMake(40, 0, ScreenWidth - 60, 50)];
        selectBtn.backgroundColor = [UIColor clearColor];
        [selectBtn addTarget:self action:@selector(selectBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_mySelectPlot addSubview:selectBtn];

    }
    return _mySelectPlot;
}

- (UITableView *)selectPlotTableView{
    if (!_selectPlotTableView) {
        _selectPlotTableView = [[UITableView alloc] init];
        _selectPlotTableView.backgroundColor = sBGColor;
        _selectPlotTableView.delegate = self;
        _selectPlotTableView.dataSource = self;
        _selectPlotTableView.hidden = YES;
    }
    return _selectPlotTableView;
}

- (UIButton *)LoginBtn{
    if (!_LoginBtn) {
        _LoginBtn = [[UIButton alloc]init];
        [_LoginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [_LoginBtn addTarget:self action:@selector(loginBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _LoginBtn.backgroundColor = mainColor;
    }
    return _LoginBtn;
}

- (UIButton *)forgetBtn{
    if (!_forgetBtn) {
        _forgetBtn = [[UIButton alloc]init];
        [_forgetBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
        [_forgetBtn addTarget:self action:@selector(forgetBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_forgetBtn setTitleColor:mainColor forState:UIControlStateNormal];
    }
    return _forgetBtn;
}


@end
