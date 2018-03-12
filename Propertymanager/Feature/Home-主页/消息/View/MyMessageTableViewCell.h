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
#import "iOSNgnStack.h"

@interface MyMessageTableViewCell : UITableViewCell

@property (nonatomic,strong) MyMessageHistoryEntry *entry;
@property (nonatomic,strong) ContactModel * contactModel;

-(instancetype)initWithTableview:(UITableView *)tableview;
+(instancetype)cellWithTableview:(UITableView *)tableview;

@end
