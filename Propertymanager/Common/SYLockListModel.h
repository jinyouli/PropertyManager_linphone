//
//  SYLockListModel.h
//  YLB
//
//  Created by sayee on 17/4/1.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYLockListModel : NSObject

//请求锁列表(全部门禁)
@property (nonatomic,copy) NSString *lock_name;    // "碧桂园-别名21",
@property (nonatomic,copy) NSString *domain_sn;    // "10000025",
@property (nonatomic,copy) NSString *sip_number;    // "1000000031",
@property (nonatomic,copy) NSString *lock_parent_name;    // "碧桂园别名21"
@property (nonatomic,copy) NSString *bt_uuid;   ///蓝牙模块uuid
@end
