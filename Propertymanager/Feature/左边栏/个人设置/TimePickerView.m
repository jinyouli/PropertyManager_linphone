//
//  TimePickerView.m
//  idoubs
//
//  Created by 乔香彬 on 16/5/24.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "TimePickerView.h"

@implementation TimePickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame WithIsStart:(int)isStart WithVC:(UIViewController *)vc
{
    if(self = [super initWithFrame:frame])
    {
        _isStart = isStart;
        _VC = vc;
        
        //建立上、下午字典映射
        NSMutableArray *amArr = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *pmArr = [[NSMutableArray alloc] initWithCapacity:0];
        _timeSlotArr = [NSArray arrayWithObjects:@"上午", @"下午", nil];
        for(int i = 0; i < 12; i++)
        {
            if(i < 10)
            {
                [amArr addObject:[NSString stringWithFormat:@"%d%d", 0, i]];
            }
            else if(i < 12)
            {
                [amArr addObject:[NSString stringWithFormat:@"%d", i]];
            }
        }
        for(int i = 12; i < 24; i++)
        {
            [pmArr addObject:[NSString stringWithFormat:@"%d", i]];
        }
        
        
        NSArray *hourArr = [NSArray arrayWithObjects:amArr, pmArr, nil];
        _hourDic = [NSDictionary dictionaryWithObjects:hourArr forKeys:_timeSlotArr];    //注意这里是objects forKeys方法（加s）
        
        //建立小时字典映射
        NSMutableArray *minGatherArr = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *minArr = nil;
        for(int i = 0; i < 24; i++)
        {
            minArr = [[NSMutableArray alloc] init];
            for(int i = 0; i < 60; i++)
            {
                if(i < 10)
                {
                    [minArr addObject:[NSString stringWithFormat:@"%d%d", 0, i]];
                }
                else if(i < 60)
                {
                    [minArr addObject:[NSString stringWithFormat:@"%d", i]];
                }
            }
            [minGatherArr addObject:minArr];
        }
        
        NSMutableArray *hourGatherArr = [[NSMutableArray alloc] initWithCapacity:0];
        for(int i = 0; i < 24; i++)
        {
            if(i < 9)
            {
                [hourGatherArr addObject:[NSString stringWithFormat:@"%d%d", 0, i]];
            }
            else if(i < 24)
            {
                [hourGatherArr addObject:[NSString stringWithFormat:@"%d",i]];
            }
        }
        _minDic = [NSDictionary dictionaryWithObjects:minGatherArr forKeys:hourGatherArr];
        
        //初始显示的数组
        _didSelectedHourArr = amArr;
        _didSelectedMinuteArr = minArr;
        
        //默认初始选中时间
        _didSelectedTimeSlotStr = [_timeSlotArr objectAtIndex:0];
        _didSelectedHourStr = [_didSelectedHourArr objectAtIndex:0];
        _didSelectedMinuteStr = [_didSelectedMinuteArr objectAtIndex:0];
        
        _timePickerView = [[UIPickerView alloc] init];
        _timePickerView.delegate = self;
        _timePickerView.dataSource = self;
        
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            SYLog(@"没有选取时间");
        }];
        UIAlertAction *queueAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            SYLog(@"已经选取时间");
            
            NSString *timeStr = [NSString stringWithFormat:@"%@  %@:%@", _didSelectedTimeSlotStr, _didSelectedHourStr, _didSelectedMinuteStr];
            SYLog(@"timeStr = %@",timeStr);
            if(_isStart == 1)
            {

                [DontDisturbManager shareManager].statTime = timeStr;
                MyFMDataBase * database = [MyFMDataBase shareMyFMDataBase];
                [database updateDataWithTableName:DontDisturbInfo updateDictionary:@{@"statTime":timeStr} whereArray:@{@"fusername":[UserManagerTool userManager].username}];
            }
            if(_isStart == 0)
            {
                
                [DontDisturbManager shareManager].endTime = timeStr;
                MyFMDataBase * database = [MyFMDataBase shareMyFMDataBase];
                [database updateDataWithTableName:DontDisturbInfo updateDictionary:@{@"endTime":timeStr} whereArray:@{@"fusername":[UserManagerTool userManager].username}];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectedTime" object:[NSNumber numberWithInt:_isStart]];
        }];
        
        [alertVC addAction:cancelAction];
        [alertVC addAction:queueAction];
        [alertVC.view addSubview:_timePickerView];
        
        _timePickerView.frame = CGRectMake(0, 0, 270, 126);
        [_VC presentViewController:alertVC animated:YES completion:nil];
    }
    return self;
}

//UIPickerViewDateSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger x = 0;
    if(component == 0)
    {
        x = 2;
    }
    if(component == 1)
    {
        x = 12;
    }
    if(component == 2)
    {
        x = 60;
    }
    return x;
}

//UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 65.0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 42.0;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *titleStr;
    if(component == 0)
    {
        titleStr = [_timeSlotArr objectAtIndex:row];
    }
    if(component == 1)
    {
        titleStr = [_didSelectedHourArr objectAtIndex:row];
    }
    if(component == 2)
    {
        titleStr = [_didSelectedMinuteArr objectAtIndex:row];
    }
    return titleStr;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //取上一列的选中值，在对应的字典中映射这一列的显示数组，后面一列默认显示第一个。
    if(component == 0)
    {
        _didSelectedTimeSlotStr = [_timeSlotArr objectAtIndex:row];
        
        _didSelectedHourArr = [_hourDic objectForKey:_didSelectedTimeSlotStr];
        _didSelectedHourStr = [_didSelectedHourArr objectAtIndex:0];
        _didSelectedMinuteArr = [_minDic objectForKey:_didSelectedHourStr];
        
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
        
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView selectRow:0 inComponent:2 animated:YES];
    }
    if(component == 1)
    {
        _didSelectedHourStr = [_didSelectedHourArr objectAtIndex:row];
        _didSelectedMinuteArr = [_minDic objectForKey:_didSelectedHourStr];
        
        [pickerView reloadComponent:2];
        
        [pickerView selectRow:0 inComponent:2 animated:YES];
    }
    if(component == 2)
    {
        _didSelectedMinuteStr = [_didSelectedMinuteArr objectAtIndex:row];
    }
    
}

@end
