//
//  ComplainOrderTableViewCell.h
//  idoubs
//
//  Created by Momo on 16/6/30.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComplainReplyDataModel.h"
#import "ComplainReplyFrame.h"

typedef void(^ReplyImageBlock)(NSIndexPath *indexPath,NSInteger imageIndex);
@interface ComplainOrderTableViewCell : UITableViewCell

@property (nonatomic,strong) NSIndexPath * indexPath;
@property (nonatomic,strong) ComplainReplyFrame * replyFrame;
@property (nonatomic,strong) ComplainReplyDataModel * replyDataModel;

-(instancetype)initWithTableview:(UITableView *)tableview;
+(instancetype)cellWithTableview:(UITableView *)tableview;


@property (nonatomic,copy) ReplyImageBlock block;
-(void)myReplyImageBlock:(ReplyImageBlock)block;



//配图
@property (nonatomic,strong) UIButton * photo1;
@property (nonatomic,strong) UIButton * photo2;
@property (nonatomic,strong) UIButton * photo3;

@end
