//
//  NotificationBtn.h
//  PropertyManager
//
//  Created by Momo on 16/8/9.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationBtn : UIButton

+ (void)toast:(NSString*)msg withRepair:(NSString *)repair_id;
@end
