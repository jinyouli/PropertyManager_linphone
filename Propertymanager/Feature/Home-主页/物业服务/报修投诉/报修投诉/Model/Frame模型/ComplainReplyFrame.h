//
//  ComplainReplyFrame.h
//  idoubs
//
//  Created by Momo on 16/6/30.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ComplainReplyDataModel.h"
@interface ComplainReplyFrame : NSObject

/**
 *  头像的frame  ,结构体用assin
 */
@property (nonatomic, assign, readonly) CGRect iconF;
/**
 *  回复时间的frame
 */
@property (nonatomic, assign, readonly) CGRect timeF;
/**
 *  回复名的frame
 */
@property (nonatomic, assign, readonly) CGRect nameF;
/**
 *  回复内容的frame
 */
@property (nonatomic, assign, readonly) CGRect desF;
/**
 *  配图1的frame
 */
@property (nonatomic, assign, readonly) CGRect image1ListF;
/**
 *  配图2的frame
 */
@property (nonatomic, assign, readonly) CGRect image2ListF;
/**
 *  配图3的frame
 */
@property (nonatomic, assign, readonly) CGRect image3ListF;

/**
 *  子view的高度
 */
@property (nonatomic, assign, readonly) CGFloat replyCellHeight;

/**
 *  数据内容
 */
@property (nonatomic, strong) ComplainReplyDataModel * replyDataModel;

@end
