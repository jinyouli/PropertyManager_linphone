//
//  ComplainHeaderView.h
//  idoubs
//
//  Created by Momo on 16/6/30.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComplainHeaderFrame.h"
#import "ComplainHeaderDataModel.h"

typedef void(^ComplainHeaderBlock)(NSInteger section,NSInteger flag,NSInteger imagePos);
@interface ComplainHeaderView : UITableViewHeaderFooterView

@property (nonatomic,strong) UIButton * photo1;
@property (nonatomic,strong) UIButton * photo2;
@property (nonatomic,strong) UIButton * photo3;
@property (nonatomic,strong) UIImageView * iconView; //图标
@property (nonatomic,strong) UILabel * nameIcon; //业主名
@property (nonatomic,strong) UIButton * detailBtn;  //详情按钮

@property (nonatomic,assign) NSInteger section;
@property (nonatomic,strong)  ComplainHeaderDataModel * headerDataModel;
@property (nonatomic, strong) ComplainHeaderFrame *headerFrame;

@property (nonatomic, copy) ComplainHeaderBlock block;
-(void)returnComplainHeaderBlock:(ComplainHeaderBlock)block;
@end
