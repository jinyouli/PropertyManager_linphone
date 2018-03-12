//
//  OrderPushItem.h
//  PropertyManager
//
//  Created by Momo on 17/2/28.
//  Copyright © 2017年 Momo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OrderPushInfoItem;

@interface OrderPushItem : NSObject

/** "ver":"1.0" */
@property (strong, nonatomic) NSString *ver;
/** "typ":"req" */
@property (strong, nonatomic) NSString *typ;
/** "cmd":"0910" */
@property (strong, nonatomic) NSString *cmd;
/** cnt */
@property (strong, nonatomic) OrderPushInfoItem *cnt;

@end

@interface OrderPushInfoItem : NSObject

/** 工单id */
@property (strong, nonatomic) NSString *repairs_id;
/** 工单内容 */
@property (strong, nonatomic) NSString *content;
/** 工单号 */
@property (strong, nonatomic) NSString *ordernum;
/** 时间 */
@property (strong, nonatomic) NSString *time;

@end
