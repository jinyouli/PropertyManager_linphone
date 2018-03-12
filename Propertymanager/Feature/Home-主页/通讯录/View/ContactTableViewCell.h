//
//  ContactTableViewCell.h
//  WeChatContacts-demo
//
//  Created by shen_gh on 16/3/12.
//  Copyright © 2016年 com.joinup(Beijing). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactTableViewCell : UITableViewCell

@property (nonatomic,strong) UIImageView *headImageView;//头像
@property (nonatomic,strong) UILabel *nameLabel;//姓名
@property (nonatomic,strong) UILabel *nameL;//姓名小
@property (nonatomic,strong) UILabel *departmentLabel;//部门
@property (nonatomic,strong) UILabel *letterLabel;//索引

-(void)contactName:(NSString *)name department:(NSString *)department letter:(NSString *)letter;
@end
