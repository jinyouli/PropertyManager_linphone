//
//  SYUserInfoModel.m
//  YLB
//
//  Created by YAYA on 2017/4/10.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYUserInfoModel.h"
#import "MJExtension.h"

@implementation SYUserInfoModel

//MJExtension
+(NSDictionary *)mj_objectClassInArray{
    return @{
             @"neibor_id_list" : @"SYNeiborIDListModel"
             };
}
@end
