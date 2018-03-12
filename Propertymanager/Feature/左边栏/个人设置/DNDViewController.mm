//
//  DNDViewController.m
//  idoubs
//
//  Created by Momo on 16/7/14.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "DNDViewController.h"
#import "TimePickerView.h"
@interface DNDViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView * tableview;
@property (nonatomic,strong) UISwitch * mySwitch;

@property (nonatomic, strong) TimePickerView *timePickerView;
@property (nonatomic,strong) UILabel * startTimeLab;
@property (nonatomic,strong) UILabel * endTimeLab;
@end

@implementation DNDViewController

#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
    }
    return self;
}


static int choiceNum = 0;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createLeftBarButtonItemWithTitle:@"勿扰模式"];
    self.view.backgroundColor = BGColor;
    //选中时间通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DidSelectedTime:) name:@"DidSelectedTime" object:nil];
    [self createSubviews];
    
    self.mySwitch.on = [[DontDisturbManager shareManager] getDisturbStatusWithUsername:[UserManagerTool userManager].username];
    isOpenDnd = self.mySwitch.on;
}

-(void)createSubviews{
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.view addSubview:self.tableview];

    self.mySwitch = [[UISwitch alloc]init];
    [self.mySwitch addTarget:self action:@selector(switchChange) forControlEvents:UIControlEventValueChanged];
    
    
    self.startTimeLab = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 100, 7.5, 100, 30)];
    self.startTimeLab.textColor = mainTextColor;
    self.endTimeLab = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 100, 7.5, 100, 30)];
    self.endTimeLab.textColor = mainTextColor;
    
    BOOL isOpen = isOpenDnd;
    if (isOpen) {
        self.mySwitch.on = YES;
    }
}

-(void)switchChange{

    [DontDisturbManager shareManager].isDontDisturb = self.mySwitch.on;
    
    MyFMDataBase * database = [MyFMDataBase shareMyFMDataBase];
    if ([DontDisturbManager shareManager].isDontDisturb) {
        //[database updateDataWithTableName:DontDisturbInfo updateDictionary:@{@"isDontDisturb":self.mySwitch.on?@"1":@"0"} whereArray:@{@"fusername":[UserManagerTool userManager].username}];
        
        [database insertDataWithTableName:DontDisturbInfo insertDictionary:@{@"fusername":[UserManagerTool userManager].username,@"isDontDisturb":@"0",@"statTime":@"上午 00:00",@"endTime":@"上午 00:00"}];
        
        self.startTimeLab.text = [DontDisturbManager shareManager].statTime;
        self.endTimeLab.text = [DontDisturbManager shareManager].endTime;
    }else{
        [database deleteDataWithTableName:DontDisturbInfo delegeteDic:nil];
    }
    
    [self.tableview reloadData];
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.mySwitch.isOn) {
        return 2;
    }
    else{
        return 0;
    }
 
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 100;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 100)];
    view.backgroundColor = sBGColor;
    
    UIView * contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, ScreenWidth, 90)];
    [view addSubview:contentView];
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 100, 30)];
    titleLabel.text = @"勿扰模式";
    titleLabel.textColor = mainTextColor;
    [view addSubview:titleLabel];
    
    UILabel * desLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 45, ScreenWidth - 20, 45)];
    desLabel.font = MiddleFont;
    desLabel.textColor = lineColor;
    desLabel.numberOfLines = 0;
    desLabel.text = @"开启后，在设定时间段内接到呼叫不会响铃或震动";
    [view addSubview:desLabel];
    
    self.mySwitch.frame = CGRectMake(ScreenWidth - 70, 15, 0, 0);
    [view addSubview:self.mySwitch];
    
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identify = @"settingCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    for (UIView * view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"开始时间";
        [cell.contentView addSubview:self.startTimeLab];
        self.startTimeLab.text = [DontDisturbManager shareManager].statTime;
    }
    else{
        
        cell.textLabel.text = @"结束时间";
        [cell.contentView addSubview:self.endTimeLab];
        self.endTimeLab.text = [DontDisturbManager shareManager].endTime;
        
    }
    cell.textLabel.textColor = mainTextColor;
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0)
    {
       self.timePickerView = [[TimePickerView alloc]initWithFrame:CGRectZero WithIsStart:1 WithVC:self];
    }
    if(indexPath.row == 1)
    {
       self.timePickerView = [[TimePickerView alloc]initWithFrame:CGRectZero WithIsStart:0 WithVC:self];

    }

}

//通知 获取时间字符串
-(void)DidSelectedTime:(NSNotification *)notification
{
 
    int isStart = [notification.object intValue];
    if(isStart == 1)
    {
        self.startTimeLab.text = [DontDisturbManager shareManager].statTime;
    }
    if(isStart == 0)
    {
        self.endTimeLab.text = [DontDisturbManager shareManager].endTime;
    }
 
}
@end
