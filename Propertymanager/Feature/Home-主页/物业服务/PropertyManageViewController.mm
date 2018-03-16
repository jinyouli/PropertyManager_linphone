//
//  PropertyManageViewController.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "PropertyManageViewController.h"
#import "ContactModel.h"//联系人字典

const NSInteger contactBtnTag = 5000;
const NSInteger contactLabelTag = 6000;

@interface PropertyManageViewController ()
{
    /**按钮的宽度*/
    NSInteger btnWidth;
}
@property (nonatomic,strong) UIScrollView * scrollview;
/**联系人数组*/
@property (nonatomic,strong) NSMutableArray * contactArr;
/**联系人按钮数组*/
@property (nonatomic,strong) NSMutableArray *cBtnArr;
/**联系人名字Label数组*/
@property (nonatomic,strong) NSMutableArray *cLabelArr;

@end

@implementation PropertyManageViewController

#pragma mark - life cycle

- (instancetype)init{
    if (self = [super init]) {
        
        self.cBtnArr = [NSMutableArray array];
        self.cLabelArr = [NSMutableArray array];
        self.contactArr = [NSMutableArray array];
        btnWidth = (ScreenWidth - 20 * 2 - 30 * 3) * 0.25;
        self.view.backgroundColor = BGColor;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.scrollview];
    
    [self createContactView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeContact:) name:@"updateContact" object:nil];
    
}

#pragma mark - event response
-(void)btnClick:(UIButton *)btn{
    
    switch (btn.tag) {
        case 4000:
        {
            //报修
            [[Routable sharedRouter] open:REPAIRS_VIEWCONTROLLER animated:YES extraParams:@{@"isRepair":@(YES)}];
        }
            break;
        case 4001:
        {
            //投诉
            [[Routable sharedRouter] open:REPAIRS_VIEWCONTROLLER animated:YES extraParams:@{@"isRepair":@(NO)}];
        }
            break;
        case 4002:
        {
            //小区
            [[Routable sharedRouter] open:PLOT_VIEWCONTROLLER];
        }
            break;
        case 4003:
        {
            //门禁
            [[Routable sharedRouter] open:SEARCHLOCK_VIEWCONTROLLER];
        }
            break;
        case 4004:
        {
            //应用
            [[Routable sharedRouter] open:APPLY_VIEWCONTROLLER];
        }
            break;
            
        default:
            //添加联系人
            NSInteger index = btn.tag - contactBtnTag;
            if (index < self.contactArr.count) {
                //
                ContactModel * model = self.contactArr[index];
                
                [[Routable sharedRouter] open:OWNER_VIEWCONTROLLER animated:YES extraParams:@{@"isOwner":@(false),@"contactModel":model}];
            }
            else{
                
                [[Routable sharedRouter] open:A_ZTABLE_VIEWCONTROLLER];
                
            }

            
            break;
    }
}
#pragma mark - notify
// 改变联系人 增加/删除
-(void)changeContact:(NSNotification *)noti{
    MyFMDataBase * database = [MyFMDataBase shareMyFMDataBase];
    ContactModel * notimModel = [noti object];
    BOOL isAdd = YES;
    int i = 0;
    for ( i = 0; i < self.contactArr.count; i ++) {
        ContactModel * contactModel = self.contactArr[i];
        if ([notimModel.worker_id isEqualToString:contactModel.worker_id]) {
            //有相同 减少一个联系人
            // 在数组中减少一个数据
            [self.contactArr removeObjectAtIndex:i];
            // 在数据库中减少一个数据
            [database deleteDataWithTableName:StorageInfo delegeteDic:@{@"worker_id":notimModel.worker_id}];
            // 按钮减少一个
            UIButton * btn = [self.scrollview viewWithTag:contactBtnTag + i];
            [btn removeFromSuperview];
            UILabel * label = [self.scrollview viewWithTag:contactLabelTag + i];
            [label removeFromSuperview];
            [self.cBtnArr removeObject:btn];
            [self.cLabelArr removeObject:label];
            //更新i以后的坐标
            [self uploadCBtnFrame];
            
            isAdd = NO;
            break;
        }
        
    }
    
    if (isAdd) {
        
        // 增加 则在单例中增加一个数据
        [self.contactArr insertObject:notimModel atIndex:0];
        // 在数据库中增加一个数据
        NSDictionary * dic = @{@"fusername":notimModel.fusername,
                               @"first_py":notimModel.first_py,
                               @"fdepartmentname":notimModel.fdepartmentname,
                               @"fworkername":notimModel.fworkername,
                               @"worker_id":notimModel.worker_id,
                               @"user_sip":notimModel.user_sip};
        [database insertDataWithTableName:StorageInfo insertDictionary:dic];
        // 按钮增加一个
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(20, (90 + btnWidth), btnWidth, btnWidth)];
        btn.layer.cornerRadius = btnWidth / 2;
        btn.backgroundColor = mainColor;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString * btnName = [PMTools subStringFromString:notimModel.fworkername isFrom:NO];
        [btn setTitle:btnName forState:UIControlStateNormal];
        [self.scrollview addSubview:btn];
        [self.cBtnArr insertObject:btn atIndex:0];
        
        
        CGRect frame = btn.frame;
        frame.origin.y += btnWidth + 5;
        frame.size.height = 30;
        UILabel * label = [[UILabel alloc]initWithFrame:frame];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = btn.titleLabel.text;
        [self.scrollview addSubview:label];
        [self.cLabelArr insertObject:label atIndex:0];
        
        
        //更新大小
        [self uploadCBtnFrame];
    }
    
}
#pragma mark - private methods
#pragma mark - 更新Frame和Tag
-(void)uploadCBtnFrame{
    
    for (int i = 0; i < self.cBtnArr.count; i ++) {
        UIButton * btn = self.cBtnArr[i];
        btn.tag = contactBtnTag + i;
        btn.frame = CGRectMake(20 + (btnWidth + 30) * (i % 4), (90 + btnWidth) + (btnWidth + 30 + 10) * (i/4), btnWidth, btnWidth);
        
        UILabel * label = self.cLabelArr[i];
        label.tag = contactLabelTag + i;
        CGRect frame = btn.frame;
        frame.origin.y += btnWidth + 5;
        frame.size.height = 30;
        label.frame = frame;
        
        if (i == self.cBtnArr.count - 1) {
            if (CGRectGetMaxY(btn.frame) < ScreenHeight - 64 - 40) {
                self.scrollview.frame = CGRectMake(0, 0, ScreenWidth, CGRectGetMaxY(label.frame) + 40);
            }
            else{
                self.scrollview.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64 - 40);
            }
            
            UIImageView * line = (UIImageView *)[self.scrollview viewWithTag:3004];
            line.frame = CGRectMake(0, CGRectGetMaxY(label.frame) +10, ScreenWidth, 1);
            
            UIButton * btn = (UIButton *)[self.scrollview viewWithTag:4004];
            btn.frame = CGRectMake(0, CGRectGetMaxY(line.frame), ScreenWidth, 30);
            self.scrollview.contentSize = CGSizeMake(ScreenWidth, CGRectGetMaxY(label.frame) + 40);
        }
    }
}

-(void)createContactView{
    
    MyFMDataBase * database = [MyFMDataBase shareMyFMDataBase];
    NSArray * arr = [database selectDataWithTableName:StorageInfo withDic:nil];
    
    [self.contactArr addObjectsFromArray:arr];
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_apply(self.contactArr.count + 1, queue, ^(size_t i) {

        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(20 + (btnWidth + 30) * (i % 4), (90 + btnWidth) + (btnWidth + 30 + 10) * (i / 4), btnWidth, btnWidth)];
        btn.layer.cornerRadius = btnWidth / 2;
        btn.backgroundColor = mainColor;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = contactBtnTag + i;
        [self.scrollview addSubview:btn];
        
        CGRect frame = btn.frame;
        frame.origin.y += btnWidth + 5;
        frame.size.height = 30;
        ZYLabel * label = [[ZYLabel alloc] initWithText:@"" font:LargeFont color:mainTextColor];
        label.frame = frame;
        label.tag = contactLabelTag +i;
        [self.scrollview addSubview:label];
        
        if (i != self.contactArr.count) {
            ContactModel * model = self.contactArr[i];
            NSString * btnName = [PMTools subStringFromString:model.fworkername isFrom:NO];
            [btn setTitle:btnName forState:UIControlStateNormal];
            label.text = btn.titleLabel.text;
        }
        else{
            [btn setBackgroundImage:[UIImage imageNamed:@"home_add"] forState:UIControlStateNormal];
            btn.backgroundColor = lineColor;
            label.text = @"添加";
            //线
            UIImageView * line = [[UIImageView alloc]init];
            line.frame = CGRectMake(0, CGRectGetMaxY(label.frame) +10, ScreenWidth, 1);
            line.backgroundColor = lineColor;
            line.tag = 3004;
            [self.scrollview addSubview:line];
  
            // 应用市场
            UIButton * appBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame), ScreenWidth, 30)];
            [appBtn setTitle:@"应用市场" forState:UIControlStateNormal];
            [appBtn setTitleColor:lineColor forState:UIControlStateNormal];
            [appBtn setImage:[UIImage imageNamed:@"home_myapp"] forState:UIControlStateNormal];
            appBtn.titleLabel.font = SmallFont;
            appBtn.tag = 4004;
            [appBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            //[self.scrollview addSubview:appBtn];
            
            if (CGRectGetMaxY(appBtn.frame) < ScreenHeight - 64 - 40) {
                self.scrollview.frame = CGRectMake(0, 0, ScreenWidth, CGRectGetMaxY(appBtn.frame));
            }
            else{
                self.scrollview.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64 - 40);
            }
            
            self.scrollview.contentSize = CGSizeMake(ScreenWidth, CGRectGetMaxY(appBtn.frame));
        }
        
        [self.cBtnArr addObject:btn];
        [self.cLabelArr addObject:label];
    });
}


#pragma mark - getters and setters
- (UIScrollView *)scrollview{
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64 - 44)];
        _scrollview.backgroundColor = [UIColor whiteColor];
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.bounces = NO;
        _scrollview.contentSize = self.view.frame.size;
        
        NSArray * btnImageArr = @[@"home_repair",@"home_complaine",@"home_plot",@"home_entrance"];
        NSArray * btnTitleArr = @[@"报修",@"投诉",@"小区",@"门禁"];
        for (int i = 0; i < btnImageArr.count; i ++) {
            UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(20 + btnWidth * i + 30 * i, 30, btnWidth, btnWidth)];
            btn.layer.cornerRadius = btnWidth / 2;
            btn.clipsToBounds = YES;
            [btn setBackgroundImage:[UIImage imageNamed:btnImageArr[i]] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 4000 + i;
            [_scrollview addSubview:btn];
            
            CGRect frame = btn.frame;
            frame.origin.y += btnWidth + 5;
            frame.size.height = 30;
            UILabel * label = [[UILabel alloc]initWithFrame:frame];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = btnTitleArr[i];
            label.textColor = mainTextColor;
            [_scrollview addSubview:label];
            
        }
        
        UIImageView * line = [[UIImageView alloc]init];
        line.frame = CGRectMake(20, 30 + btnWidth + 35 + 15, ScreenWidth - 40, 1);
        line.backgroundColor = lineColor;
        [_scrollview addSubview:line];
        
    }
    return _scrollview;
}

@end
