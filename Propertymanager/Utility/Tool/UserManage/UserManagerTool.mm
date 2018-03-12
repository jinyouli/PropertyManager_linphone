//
//  UserManagerTool.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "UserManagerTool.h"

#define saveFilePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]  stringByAppendingPathComponent:@"userManager.data"]

@implementation UserManagerTool

+ (UserManager *)userManager
{
    return (UserManager *)[NSKeyedUnarchiver unarchiveObjectWithFile:saveFilePath];
}

+ (void)saveUserManager:(UserManager *)userManager
{
    [NSKeyedArchiver archiveRootObject:userManager toFile:saveFilePath];
}

@end
