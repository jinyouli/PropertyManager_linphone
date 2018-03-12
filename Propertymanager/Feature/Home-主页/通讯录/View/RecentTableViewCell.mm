//
//  RecentTableViewCell.m
//  idoubs
//
//  Created by Momo on 16/7/12.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "RecentTableViewCell.h"

@implementation RecentTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //布局View
        [self setUpView];
    }
    return self;
}


#pragma mark - setUpView
- (void)setUpView{
    //头像
    [self.contentView addSubview:self.headImageView];
    [self.headImageView addSubview:self.nameL];
    //姓名
    [self.contentView addSubview:self.nameLabel];
    //呼叫类型
    [self.contentView addSubview:self.callTypeImageView];
    //呼叫时间
    [self.contentView addSubview:self.callTimeLabel];
}

-(void)setEvent:(NgnHistoryEvent *)event{
    _event = event;
    if((event.mediaType & MediaType_Audio)){
        self.callTypeImageView.image = [UIImage imageNamed:@"dail_audio"];
    }
    if((event.mediaType & MediaType_Video)){
        self.callTypeImageView.image = [UIImage imageNamed:@"dail_video"];
    }
    
    if ([PMTools isNullOrEmpty:event.remotePartyDisplayName]) {
        self.nameLabel.text = event.remoteParty;
    }
    else{
        
        if (![PMTools isNullOrEmpty:event.remotePartyDisplayName]) {
            self.nameLabel.text = event.remotePartyDisplayName;
            self.nameL.text = [PMTools subStringFromString:event.remotePartyDisplayName isFrom:NO];
        }
        
        
        
    }
    
    
    self.headImageView.backgroundColor = mainColor;
    
    
    NSString * myTimeStr = @"";
    //比较播出时间的日期
    NSDate *eventDate = [NSDate dateWithTimeIntervalSince1970: event.start];
    NSInteger eventYear = [[[NgnDateTimeUtils chatYear] stringFromDate:
                            eventDate] integerValue];
    NSInteger eventMonth = [[[NgnDateTimeUtils chatMonth] stringFromDate:
                            eventDate] integerValue];
    NSInteger eventDay = [[[NgnDateTimeUtils chatDay] stringFromDate:
                            eventDate] integerValue];
    
    NSDate *currentDate = [NSDate date];
    NSInteger currentYear = [[[NgnDateTimeUtils chatYear] stringFromDate:
                            currentDate] integerValue];
    NSInteger currentMonth = [[[NgnDateTimeUtils chatMonth] stringFromDate:
                             currentDate] integerValue];
    NSInteger currentDay = [[[NgnDateTimeUtils chatDay] stringFromDate:
                           currentDate] integerValue];
    
    NSString * timeStr = @"";
    
    //今天
    if (currentYear == eventYear &&
        currentMonth == eventMonth &&
        currentDay == eventDay) {
        
        timeStr = [[NgnDateTimeUtils historyEventTime] stringFromDate:
                   eventDate];
        
    }//昨天
    else if(currentYear == eventYear &&
            currentMonth == eventMonth &&
             currentDay - eventDay == 1){
        
        NSString * str = [[NgnDateTimeUtils historyEventTime] stringFromDate:
                                    eventDate];
        timeStr = [NSString stringWithFormat:@"昨天 %@",str];
       
    } //前天
    else if(currentYear == eventYear &&
            currentMonth == eventMonth &&
            currentDay - eventDay == 2){
        NSString * str = [[NgnDateTimeUtils historyEventTime] stringFromDate:
                          eventDate];
        timeStr = [NSString stringWithFormat:@"前天 %@",str];
        
    }
    else{
        NSString * str1 = [[NgnDateTimeUtils historyEventDate] stringFromDate:
                              eventDate];
        NSString * str2 = [[NgnDateTimeUtils historyEventTime] stringFromDate:
                           eventDate];
        timeStr = [NSString stringWithFormat:@"%@ %@",str1,str2];
    }
    
    
    switch (event.status) {
        case HistoryEventStatus_Missed:
            //未接
            myTimeStr = [NSString stringWithFormat:@"未接 %@",timeStr];
            self.callTimeLabel.textColor = ITextColor;
            break;
        case HistoryEventStatus_Failed:
        {   //拨号失败
            self.callTypeImageView.backgroundColor = ITextColor;
            myTimeStr = [NSString stringWithFormat:@"失败 %@",timeStr];
            break;
        }
        case HistoryEventStatus_Outgoing:
            //呼出
        case HistoryEventStatus_Incoming:
            //呼入
        default:
        {
            if (event.status == HistoryEventStatus_Outgoing) {
                myTimeStr = [NSString stringWithFormat:@"呼出 %@",timeStr];
                
            }
            else{
                myTimeStr = [NSString stringWithFormat:@"呼入 %@",timeStr];
            }
            self.callTimeLabel.textColor = mainTextColor;
            break;
        }
    }
    
    self.callTimeLabel.text = myTimeStr;
    
}

-(void)setContactModel:(ContactModel *)contactModel{
    _contactModel = contactModel;
    if (contactModel) {
        if ([PMTools isNullOrEmpty:contactModel.fworkername]) {
            self.nameLabel.text = _event.remoteParty;
        }
        else{
            
            if (![PMTools isNullOrEmpty:contactModel.fworkername]) {
                
                self.nameLabel.text = contactModel.fworkername;
                self.nameL.text = [PMTools subStringFromString:contactModel.fworkername isFrom:NO];

            }
        }
    }
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}


- (UIImageView *)headImageView{
    if (!_headImageView) {
        _headImageView=[[UIImageView alloc]initWithFrame:CGRectMake(20, 10.0, 40.0, 40.0)];
        _headImageView.layer.cornerRadius = 20;
        _headImageView.clipsToBounds = YES;
        [_headImageView setContentMode:UIViewContentModeScaleAspectFill];
    }
    return _headImageView;
}

-(UILabel *)nameL{
    if (!_nameL) {
        _nameL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        _nameL.font = LargeFont;
        _nameL.textAlignment = NSTextAlignmentCenter;
        _nameL.textColor = [UIColor whiteColor];
    }
    return _nameL;
}
- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(80.0, 10.0,ScreenWidth-60.0, 25.0)];
        _nameLabel.font = LargeFont;
        _nameLabel.textColor = mainTextColor;
    }
    return _nameLabel;
}
-(UIImageView *)callTypeImageView{
    if (!_callTypeImageView) {
        _callTypeImageView=[[UIImageView alloc]initWithFrame:CGRectMake(80.0, 30, 20.0, 20.0)];
    }
    return _callTypeImageView;
}
-(UILabel *)callTimeLabel{
    if (!_callTimeLabel) {
        _callTimeLabel=[[UILabel alloc]initWithFrame:CGRectMake(110.0, 30, 150.0, 20.0)];
        _callTimeLabel.font = SmallFont;
        _callTimeLabel.textColor = lineColor;
    }
    return _callTimeLabel;
}

@end
