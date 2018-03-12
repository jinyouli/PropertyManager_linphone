//
//  RecentTableViewCell.h
//  idoubs
//
//  Created by Momo on 16/7/12.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSNgnStack.h"
#import "ContactModel.h"
@interface RecentTableViewCell : UITableViewCell

@property (nonatomic,strong) UIImageView *headImageView;//头像
@property (nonatomic,strong) UILabel *nameLabel;//姓名
@property (nonatomic,strong) UILabel *nameL;//姓名小
@property (nonatomic,strong) UIImageView *callTypeImageView;//呼叫类型
@property (nonatomic,strong) UILabel *callTimeLabel;//呼叫时间

@property (retain, nonatomic) NgnHistoryEvent* event;
@property (retain, nonatomic) ContactModel* contactModel;
@end
