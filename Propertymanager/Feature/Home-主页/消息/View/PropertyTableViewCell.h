//
//  PropertyTableViewCell.h
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PropertyModel.h"
@interface PropertyTableViewCell : UITableViewCell

@property (nonatomic,strong) PropertyModel * model;
-(instancetype)initWithTableview:(UITableView *)tableview;
+(instancetype)cellWithTableview:(UITableView *)tableview;

@end
