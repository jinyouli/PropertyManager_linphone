//
//  TimePickerView.h
//  idoubs
//
//  Created by 乔香彬 on 16/5/24.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimePickerView : UIView<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIPickerView *timePickerView;

@property (nonatomic, strong) NSArray *timeSlotArr;                  //上午、下午数组

@property (nonatomic, strong) NSDictionary *hourDic;                //value是小时的字典 key是上午、下午数组
@property (nonatomic, strong) NSDictionary *minDic;                 //value是分钟的字典 key是小时数组

@property (nonatomic, strong) NSString *didSelectedTimeSlotStr;       //选中的时段（上、下午）
@property (nonatomic, strong) NSArray *didSelectedHourArr;            //选中的小时数组
@property (nonatomic, strong) NSArray *didSelectedMinuteArr;          //选中的分钟数组
@property (nonatomic, strong) NSString *didSelectedHourStr;           //选中的小时
@property (nonatomic, strong) NSString *didSelectedMinuteStr;         //选中的分钟

@property (nonatomic, assign) int isStart;                            //区分 点击的开始或结束时间
@property (nonatomic, strong) UIViewController *VC;

-(id)initWithFrame:(CGRect)frame WithIsStart:(int)isStart WithVC:(UIViewController *)vc;

@end
