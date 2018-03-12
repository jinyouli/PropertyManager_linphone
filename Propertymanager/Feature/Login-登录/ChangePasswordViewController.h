//
//  ChangePasswordViewController.h
//  idoubs
//
//  Created by Momo on 16/6/22.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "BaseViewController.h"

@interface ChangePasswordViewController : BaseViewController

/** 验证码*/
@property (nonatomic,strong) NSString * verify_code;
/** 用户名*/
@property (nonatomic,strong) NSString * username;

@end
