//
//  UserManagerTool.h
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "UserManager.h"

@interface UserManagerTool : NSObject

+ (void)saveUserManager:(UserManager *)userManager;

+ (UserManager *)userManager;

@end
