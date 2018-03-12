//
//  ComplainHeaderFrame.h
//  idoubs
//
//  Created by Momo on 16/6/30.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ComplainHeaderDataModel.h" // 数据Header模型
#import "ComplainReplyFrame.h"      // 回复Frame模型
@interface ComplainHeaderFrame : NSObject

/**
 *  头像的frame  ,结构体用assin
 */
@property (nonatomic, assign, readonly) CGRect iconF;
/**
 *  业主名的frame
 */
@property (nonatomic, assign, readonly) CGRect nameF;
/**
 *  订单时间的frame
 */
@property (nonatomic, assign, readonly) CGRect timeF;
/**
 *  订单内容的frame
 */
@property (nonatomic, assign, readonly) CGRect desF;
/**
 *  业主地址的frame
 */
@property (nonatomic, assign, readonly) CGRect addF;
/**
 *  订单号码的frame
 */
@property (nonatomic, assign, readonly) CGRect orderNumF;
/**
 *  加急状态的frame
 */
@property (nonatomic, assign, readonly) CGRect urgentF;
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
 *  派单按钮的frame
 */
@property (nonatomic, assign, readonly) CGRect sendOrdersBtnF;
/**
 *  派单状态的frame
 */
@property (nonatomic, assign, readonly) CGRect sendStateF;
/**
 *  接受按钮的frame
 */
@property (nonatomic, assign, readonly) CGRect acceptBtnF;
/**
 *  评论按钮的frame
 */
@property (nonatomic, assign, readonly) CGRect commandBtnF;
/**
 *  评论数量的frame
 */
@property (nonatomic, assign, readonly) CGRect countLabelF;
/**
 *  详情按钮的frame
 */
@property (nonatomic, assign, readonly) CGRect detailBtnF;
/** 拨打电话*/
@property (nonatomic,assign,readonly) CGRect linkPhoneBtnF;

/**
 *  cell的Header高度
 */
@property (nonatomic, assign, readonly) CGFloat cellHeight;


@property (nonatomic, strong) ComplainHeaderDataModel * headerDataModel;    //只有拿到模型数据才能算这些属性的frame，readonly：在这个模型里面的frame属性别人不能乱改，只能访问

@end
