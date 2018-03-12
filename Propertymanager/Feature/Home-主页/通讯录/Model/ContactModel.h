//
//  ContactModel.h
//  WeChatContacts-demo
//
//  Created by shen_gh on 16/3/12.
//  Copyright © 2016年 com.joinup(Beijing). All rights reserved.
//

//#import "JSONModel.h"
#import <Foundation/Foundation.h>

@interface ContactModel : NSObject
{
    NSString * _first_py;
}

@property (nonatomic,strong) NSString *fusername;
@property (nonatomic,strong) NSString *pingyin;
@property (nonatomic,strong) NSString *fdepartmentname;
@property (nonatomic,strong) NSString *fworkername;
@property (nonatomic,strong) NSString *worker_id;
@property (nonatomic,strong) NSString *user_sip;

//分组名称 （分组用到）
@property (nonatomic,strong) NSString *fgroup_name;

@end
