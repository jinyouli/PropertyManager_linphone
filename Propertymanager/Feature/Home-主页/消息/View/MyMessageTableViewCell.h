//
//  MyMessageTableViewCell.h
//  idoubs
//
//  Created by Momo on 16/7/12.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyMessageHistoryEntry.h"
#import "ContactModel.h"
//#import "iOSNgnStack.h"

@interface MyMessageTableViewCell : UITableViewCell

@property (nonatomic,strong) MyMessageHistoryEntry *entry;
@property (nonatomic,strong) ContactModel * contactModel;

@property (nonatomic,strong) UIButton * photoBtn;
@property (nonatomic,strong) UILabel * titleLabel;
@property (nonatomic,strong) UILabel * timeLabel;
@property (nonatomic,strong) UILabel * desLabel;
@property (nonatomic,strong) UILabel * statusLabel;

-(instancetype)initWithTableview:(UITableView *)tableview;
+(instancetype)cellWithTableview:(UITableView *)tableview;

@end
