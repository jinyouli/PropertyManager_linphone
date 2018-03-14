//
//  DetailRequest.m
//  PropertyManager
//
//  Created by Momo on 17/3/3.
//  Copyright © 2017年 Momo. All rights reserved.
//

#import "DetailRequest.h"
#import "PMRequest.h"
#import "AppDelegate.h"
@implementation DetailRequest

static bool isSecondLogin = NO;

#pragma mark - 获取七牛token
+ (void) getQiNiuToken{
    //QinniuToken
    UserManager * user = [UserManagerTool userManager];
    
    NSString * name = user.username;
    if ([PMTools isNullOrEmpty:user.username]) {
        user = [UserManager manager];
        
        if ([PMTools isNullOrEmpty:user.username]) {
            NSLog(@"物业的username为空");
            
            if ([PMTools isNullOrEmpty:userLoginUsername]) {
                //[PMRequest loginBtnClickWithPhone:userLoginUsername password:userPassword isFirstLogin:NO];
                NSLog(@"物业的userLoginUsername为空");
                return;
            }
            else{
                name = userLoginUsername;
            }
            
        }
        else{
            name = user.username;
        }
        
        
    }
    
    [PMRequest getRequestURL:MyUrl(SYGet_upload_token) withHeaderDic:@{@"username":name,@"token":userToken} parameters:nil withBlock:^(id dict) {
        
        if ([dict[@"code"] integerValue] == 0) {
            //成功
            NSString * str = dict[@"result"][@"upload_token"];
            [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"QNToken"];
            NSLog(@"获取七牛凭证成功");
        }
        else{
            SYLog(@"获取七牛凭证失败 %@",dict[@"msg"]);
            //[PMRequest loginBtnClickWithPhone:userLoginUsername password:userPassword isFirstLogin:NO];
        }
        
        
    } andFailure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SYLog(@"获取七牛凭证失败");
    }];
    
}

#pragma mark - 登陆(自动登录)
+(void)loginBtnClickWithPhone:(NSString *)phone password:(NSString *)password isFirstLogin:(BOOL)ret{

    if (ret) {

        //[SVProgressHUD showWithStatus:@"正在登陆" maskType:SVProgressHUDMaskTypeNone];
        //[SVProgressHUD showWithStatus:@"正在登陆"];
    }
//
//    if ([PMTools isNullOrEmpty:userLoginUsername]) {
//        NSLog(@"物业的userLoginUsername为空");
//        return;
//    }
    
    if (!phone) {
        return;
    }

    //检查是否有网络
    if ([PMTools connectedToNetwork]) {

        NSDate *date = [NSDate date];
        NSTimeInterval firstTime = (long)[date timeIntervalSince1970];
        
        NSDictionary * headerDic1 = @{@"uuid":[PMTools getUUID],
                                      @"username":phone};
        NSDictionary * paradict1 = @{@"username":phone,
                                     @"tick":[NSNumber numberWithInteger:firstTime]};

        NSString * url = MyUrl(SYLoginURL);

        NSLog(@"调用接口==%@,%@,%@",url,headerDic1,paradict1);

        [PMRequest postRequestURL:url withHeaderDic:headerDic1 parameters:paradict1 withBlock:^(NSDictionary *dict) {
            SYLog(@"登录① ==== %@",dict);


            if ([dict[@"code"] intValue] == 0) {

                NSString *random = dict[@"result"][@"random_num"];
                NSString *timeStr = [NSString stringWithFormat:@"%d", (int)firstTime];

                NSString *MD5Str = [random stringByAppendingFormat:@"%@%@", timeStr, [SYCommon md5:password]];

                NSDictionary * paradict2 = @{@"username":phone,
                                             @"tick":[NSNumber numberWithInteger:firstTime],
                                             @"password":[SYCommon md5:MD5Str],
                                             @"client_type":@"4",
                                             @"client_id": [PMTools isNullOrEmpty:clientID]?@"":clientID};

                [PMRequest postRequestURL:url withHeaderDic:headerDic1 parameters:paradict2 withBlock:^(NSDictionary *dict) {
                   // [SVProgressHUD dismiss];


                NSString *msgError = [dict[@"msg"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

                    SYLog(@"登录② ====%@",dict);
                    SYLog(@"错误==%@",msgError);

                    if ([dict[@"code"] intValue] == 0) {


                        //检查更新时使用 0表示显示检查更新 1表示不显示
                        NSString * isCheak = dict[@"result"][@"tenementIsShow"];
                        if (![PMTools isNullOrEmpty:isCheak]) {
                            if ([isCheak integerValue] == 0) {
                                isCheak = @"0";
                            }
                            else{
                                isCheak = @"1";
                            }
                        }
                        else{
                            isCheak = @"1";
                        }
                        [[NSUserDefaults standardUserDefaults] setObject:isCheak forKey:@"tenementIsShow"];

                        //token(根视图有用到)
                        [[NSUserDefaults standardUserDefaults] setObject:dict[@"result"][@"token"] forKey:@"token"];

                        [[NSUserDefaults standardUserDefaults] synchronize];

                        if (ret) {
                            //username
                            [[NSUserDefaults standardUserDefaults] setObject:phone forKey:@"loginUsername"];
                            [[NSUserDefaults standardUserDefaults] synchronize];

                            //密码保存
                            [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }

                        //用户单例
                        UserManager *userManager = [UserManager userManagerWithDict:dict[@"result"]];
                        [UserManagerTool saveUserManager:userManager];


                        //设置一下勿扰模式
                        [[DontDisturbManager shareManager] getDisturbStatusWithUsername:phone];

                        //[PMSipTools sipRegister];
                        //[[NgnEngine sharedInstance].soundService setSpeakerEnabled:YES];
                        // 开启重新获取token
                        //[PMTokenTools getTokenByOldToken];
                        
                        SYUserInfoModel *model = [[SYUserInfoModel alloc] init];
                        model.user_sip = dict[@"result"][@"user_sip"];
                        model.user_password = dict[@"result"][@"user_password"];
                        model.username = dict[@"result"][@"username"];
                        model.fs_ip = dict[@"result"][@"sip_host_addr"];
                        model.fs_port = dict[@"result"][@"sip_host_port"];
                        model.transport = dict[@"result"][@"transport"];
                        
                        NSLog(@"注册信息==%@,%@,%@,%@,%@,%@",model.user_sip,model.user_password,model.username,model.fs_ip,model.fs_port,model.transport);
                        
                        [[SYLinphoneManager instance] addProxyConfig:model.user_sip password:model.user_password displayName:model.username domain:model.fs_ip port:model.fs_port withTransport:model.transport];
                        
                        if (ret) {
                            //切换根视图
                            [[AppDelegate sharedInstance] setmanagerRootVC];
                        }

                    }
                    else{

                        // 如果code ： 8  并且包含密码两个字 就是密码错误,身份验证失败
                        // code : 3 是身份验证失败 （token失效）
                        NSString * str = dict[@"msg"];


                        BOOL isContain = NO;
                        if([str rangeOfString:@"密码"].location != NSNotFound)//_roaldSearchText
                        {
                            isContain = YES;
                        }

                        if ([dict[@"code"] integerValue] == 3 && isContain) {
                            [DetailRequest loginBtnClickWithPhone:userLoginUsername password:userPassword isFirstLogin:NO];
                        }
                        else if ([dict[@"code"] integerValue] == 8 && isContain) {

                            if (!ret) {

                                //[SYCommon showAlert:str];
                                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"token"];
                                //切换根视图
                                //[[AppDelegate sharedInstance] setmanagerRootVC];
                            }
                            else{
                                //[SVProgressHUD showErrorWithStatus:str];
                                [SYCommon showAlert:str];
                            }
                        }
                    }

                } andFailure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"错误的东西2==%@",error);
                }];
            }
            else{
                //[SVProgressHUD showErrorWithStatus:dict[@"msg"]];
                [SYCommon showAlert:dict[@"msg"]];

                if ([dict[@"code"] integerValue] == 2002) {

                    if (!ret) {
                        //退回登录页面
                        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"token"];
                        //切换根视图
                        [[AppDelegate sharedInstance] setmanagerRootVC];
                    }
                }
            }

        } andFailure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"错误的东西1==%@",error);

        }];
    }else{

        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideHub" object:nil];
    }
}



/** 获取IP地址*/
+ (void)SYGet_nei_list_of_tenementWithSuccessBlock:(void(^)(NSArray * value)) success{
    NSString * url = FirstUrl(SYGet_nei_list_of_tenement);
    [PMRequest getRequestURL:url withHeaderDic:nil parameters:nil withBlock:^(id dict) {
        
        if ([dict[@"code"]intValue] == 0) {
            NSArray * arr = dict[@"result"];
            if (arr.count != 0) {
                if (success) {
                    success(arr);
                }
                
            }
            else{
                [SVProgressHUD showErrorWithStatus:@"没有社区可以选择"];
            }
        }
        else{
            [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
        }
    } andFailure:nil];
}

/** 获取验证码*/
+ (void)SYGet_verify_code_messageWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)()) success{
    
    NSString * url = MyUrl(SYGet_verify_code_message);
    
    [PMRequest getRequestURL:url withHeaderDic:nil parameters:parmas withBlock:^(id dict) {
        
        if ([dict[@"code"] integerValue] == 0) {
            if (success) {
                success();
            }
            
        }
        else{
            [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
            
        }

    } andFailure:nil];
}

/** 验证短信验证码*/
+ (void)SYValidate_mobile_phoneWithHeader:(NSDictionary *)header WithParms:(NSDictionary *)parmas SuccessBlock:(void(^)()) success{
    NSString * url = MyUrl(SYValidate_mobile_phone);
    [PMRequest getRequestURL:url withHeaderDic:header parameters:parmas withBlock:^(id dict) {
        
        if ([dict[@"code"] integerValue] == 0) {
            if (success) {
                success();
            }
            
        }
        else{
            [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
            
        }
        
    } andFailure:nil];
}

/** 修改密码*/
+ (void)SYChange_pwd_by_verify_codeWithHeader:(NSDictionary *)header WithParms:(NSDictionary *)parmas SuccessBlock:(void(^)()) success{
    NSString * url = MyUrl(SYChange_pwd_by_verify_code);
    [PMRequest postRequestURL:url withHeaderDic:header parameters:parmas withBlock:^(id dict) {
        
        if ([dict[@"code"] integerValue] == 0) {
            if (success) {
                success();
            }
            
        }
        else{
            [SVProgressHUD showErrorWithStatus:@"密码修改失败"];
            
        }
        
    } andFailure:nil];
}

/** 获取小区公告*/
+ (void)SYGet_notice_by_pagerWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)(NSArray * value)) success FailureBlock:(void(^)()) failure{
    NSString * url = MyUrl(SYGet_notice_by_pager);
    [PMRequest getRequestURL:url withHeaderDic:HeadDic parameters:parmas withBlock:^(id dict) {
        if ([dict[@"code"]intValue] == 0) {
            NSArray * arr = dict[@"result"];
            if (arr.count == 0) {
                arr = @[];
            }
            success(arr);
        }
        else{
            [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
        }
    } andFailure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure();
        }
        
    }];
}

/** 获取物业消息*/
+ (void)SYGet_push_msg_listWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)(NSArray * value)) success FailureBlock:(void(^)()) failure{
    NSString * url = MyUrl(SYGet_push_msg_list);
    [PMRequest getRequestURL:url withHeaderDic:HeadDic parameters:parmas withBlock:^(id dict) {
        if ([dict[@"code"]intValue] == 0) {
            NSArray * arr = dict[@"result"];
            if (arr.count == 0) {
                arr = @[];
            }
            success(arr);
        }
        else{
            [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
        }
    } andFailure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure();
        }
        
    }];

}

/** 小区简介*/
+ (void)SYGet_neibor_msgWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)(NSDictionary * result)) success{
    NSString * url = MyUrl(SYGet_neibor_msg);
    [PMRequest getRequestURL:url withHeaderDic:HeadDic parameters:parmas withBlock:^(id dict) {
        if ([dict[@"code"] integerValue] == 0) {
        
            NSDictionary * result = dict[@"result"];
            success(result);
        }
        else{
            [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
        }
    } andFailure:nil];
}

/** 完成工单状态*/
+ (void)SYUpdate_order_statusWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)()) success FailureBlock:(void(^)()) failure{
    NSString * url = MyUrl(SYUpdate_order_status);
    [PMRequest postRequestURL:url withHeaderDic:HeadDic parameters:parmas withBlock:^(NSDictionary *dict) {
        if ([dict[@"code"] integerValue] == 0) {
            success();
        }else{
            [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
            if (failure) {
                failure();
            }
            
        }
    } andFailure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [SVProgressHUD dismiss];
        NSLog(@"错误提示==%@",[NSString stringWithFormat:@"%@",error]);
        if (failure) {
            failure();
        }
    }];
}

/** 保存工单相关信息记录*/
+ (void)SYSave_repairs_recordWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)()) success FailureBlock:(void(^)()) failure{
    NSString * url = MyUrl(SYSave_repairs_record);
    [PMRequest postRequestURL:url withHeaderDic:HeadDic parameters:parmas withBlock:^(NSDictionary *dict) {
        if ([dict[@"code"] integerValue] == 0) {
            success();
        }
        else{
            [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
            if (failure) {
                failure();
            }
            
        }
        
    } andFailure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure();
        }
    }];
    
}

+ (void)SYGet_work_order_listWithParms:(NSDictionary *)parmas isFirstRequest:(BOOL)first SuccessBlock:(void(^)(NSArray * list)) success FailureBlock:(void(^)()) failure{
    
    NSString * url = MyUrl(SYGet_work_order_list);
    [PMRequest getRequestURL:url withHeaderDic:HeadDic parameters:parmas withBlock:^(id dict) {
        SYLog(@"返回参数 === %@",dict);
        if ([dict[@"code"] integerValue] == 0) {
            NSArray * resArr = dict[@"result"];
            if (resArr.count != 0) {
                success(resArr);
            }
            else{
                success(@[]);
                
            }
        }
        else{
            
            if (failure) {
                failure();
            }
            if (!first) {
                [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
            }
        }
      
    } andFailure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure();
        }
    }];

}

/** 获取工单详情(评论)*/
+ (void)SYGet_work_order_detailsWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)(NSArray * details)) success{
    
    NSString * url = MyUrl(SYGet_work_order_details);
    
    [PMRequest getRequestURL:url withHeaderDic:HeadDic parameters:parmas withBlock:^(id dict) {
        SYLog(@"工单请求详情 ==== %@",dict);
        if ([dict[@"code"] integerValue] == 0) {
            NSArray * resArr = dict[@"result"];
            if (resArr.count != 0) {
                
                success(resArr);
            }
            else{
                success(@[]);
            }
            
        }
        else{

            [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
        }
        
    } andFailure:nil];

}

/** 获取工单详情(更多评论中评论获取)*/
+ (void)MoreVCSYGet_work_order_detailsWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)(NSArray * details)) success FailureBlock:(void(^)()) failure{
    
    NSString * url = MyUrl(SYGet_work_order_details);
    
    [PMRequest getRequestURL:url withHeaderDic:HeadDic parameters:parmas withBlock:^(id dict) {
        SYLog(@"工单请求详情 ==== %@",dict);
        if ([dict[@"code"] integerValue] == 0) {
            NSArray * resArr = dict[@"result"];
            if (resArr.count != 0) {
                
                success(resArr);
            }
            else{
                [SVProgressHUD showErrorWithStatus:dict[@"没有更多历史数据"]];
                if (failure) {
                    failure();
                }
            }
        }
        else{
            
            [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
            if (failure) {
                failure();
            }
        }
        
    } andFailure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure();
        }
    }];
    
}

/** 获取派单工单组*/
+ (void)SYGet_worker_listWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)(NSArray * workers)) success FailureBlock:(void(^)()) failure{
    NSString * url = MyUrl(SYGet_worker_list);
    [PMRequest getRequestURL:url withHeaderDic:HeadDic parameters:parmas withBlock:^(id dict) {
        if ([dict[@"code"] integerValue] == 0) {
            NSArray * arr = dict[@"result"];
            if (arr.count != 0) {
                
                success(arr);
            }
            else{
                success(@[]);
            }
        }
        else{
            [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
            if (failure) {
                failure();
            }
        }
    } andFailure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure();
        }
    }];
}

/** 获取联系人列表*/
+ (void)SYGet_communicate_listWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)(NSArray * arr)) success FailureBlock:(void(^)()) failure{
    NSString * url = MyUrl(SYGet_communicate_list);
    [PMRequest getRequestURL:url withHeaderDic:HeadDic parameters:parmas withBlock:^(id dict) {
        
        if ([dict[@"code"] integerValue] == 0) {
            NSArray * result = dict[@"result"];
        
            if (result.count != 0) {
                success(result);
            }
            else{
                success(@[]);
            }
        }
        else{
            [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
            if (failure) {
                failure();
            }
        }
        
    } andFailure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure();
        }
    }];

}

/** 获取app版本信息 */
+ (void)SYGet_app_versionSuccessBlock:(void(^)(NSDictionary * VersionInfo)) success{
    NSString * url = MyUrl(SYGet_app_version);
    NSDictionary * headDic = @{@"uuid":[PMTools getUUID]};
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDic objectForKey:@"CFBundleDisplayName"];
    NSString *appNameStr = [appName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *editionNum = [infoDic objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *paraDic = @{@"name":appNameStr,@"version":editionNum};
    [PMRequest getRequestURL:url withHeaderDic:headDic parameters:paraDic withBlock:^(id dict) {
        
        if ([dict[@"code"] integerValue] == 0) {
            success(dict[@"result"]);
        }
    } andFailure:nil];
}

/** 旧token换取新token（物管、用户端) */
+ (void)SYGet_token_by_old_tokenSuccessBlock:(void(^)(NSDictionary * result)) success{

    NSDictionary * params = @{
                              @"username":userLoginUsername,
                              @"token":userToken
                              };
    NSString * url = MyUrl(SYGet_token_by_old_token);
    [PMRequest getRequestURL:url withHeaderDic:nil parameters:params withBlock:^(id dict) {
        
        if ([dict[@"code"] integerValue] == 0) {
            success(dict[@"result"]);
        }
        else if ([dict[@"code"] integerValue] == 3) {
            //身份验证失败
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:dict[@"msg"] delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
//            [alertView show];
            
            [DetailRequest loginBtnClickWithPhone:userLoginUsername password:userPassword isFirstLogin:NO];
            
//            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"token"];
//            [PMSipTools sipUnRegister];
//            [UserManager cancelManage];
//            [UserManagerTool saveUserManager:[UserManager manager]];
//            [GeTuiSdk setPushModeForOff:YES];
//            [[AppDelegate sharedInstance] setmanagerRootVC];
        }
        else{
            NSLog(@"%@",dict[@"msg"]);
        }
    } andFailure:nil];
}

/** 通过工单号获取工单详情 */
+ (void)SYGet_work_order_by_idWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)(NSDictionary * result,NSArray * details_list)) success{
    
    NSString * url = MyUrl(SYGet_work_order_by_id);
    
    [PMRequest getRequestURL:url withHeaderDic:HeadDic parameters:parmas withBlock:^(id dict) {
        if ([dict[@"code"] integerValue] == 0) {
            
            //设置模型
            NSDictionary * result = dict[@"result"];
            NSArray * details_list = result[@"details_list"];
            
            success(result,details_list);
        }
        else{
            [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
        }
        
    } andFailure:nil];
}

/** 更新物业动态为已读*/
+ (void)SYUpdate_push_msg_to_readWithParms:(NSDictionary *)parmas{
    // 更新物业动态为已读
    [PMRequest getRequestURL:MyUrl(SYUpdate_push_msg_to_read) withHeaderDic:HeadDic parameters:parmas withBlock:nil andFailure:nil];

}

/** 通过旧密码修改新密码 */
+ (void)SYChange_pwd_by_old_pwdWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)()) success FailureBlock:(void(^)(NSString * msg)) failure{
    
    NSString * url = MyUrl(SYChange_pwd_by_old_pwd);
    [PMRequest postRequestURL:url withHeaderDic:HeadDic parameters:parmas withBlock:^(NSDictionary *dict) {
        if ([dict[@"code"] integerValue] == 0) {
            
            //[SVProgressHUD showSuccessWithStatus:@"修改密码成功"];
            [SYCommon addAlertWithTitle:@"修改密码成功"];
            success();
            
        }
        else{
            if (failure) {
                failure(dict[@"msg"]);
            }
            
        }
        
    } andFailure:nil];

}

/** 物管端–开锁权限列表 */
+ (void)SYGet_department_lock_listWithParms:(NSDictionary *)parmas SuccessBlock:(void(^)(NSArray * result)) success FailureBlock:(void(^)()) failure{
    [PMRequest getRequestURL:MyUrl(SYGet_department_lock_list) withHeaderDic:HeadDic parameters:parmas withBlock:^(id dict) {
        
        if ([dict[@"code"] intValue] == 0) {
            
            NSArray * arr = dict[@"result"];
            
            if (arr.count != 0) {
                
                success(arr);
            }
            else{
                //[SVProgressHUD showSuccessWithStatus:@"没有数据"];
                [SYCommon addAlertWithTitle:@"没有数据"];
            }
        }
        else{
            [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
            if (failure) {
                failure();
            }
        }
        
    } andFailure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure();
        }
    }];

}


/** 门禁解锁(app请求门口机开锁) */
+ (void)SYRemote_unlockWithParms:(NSDictionary *)parmas{
    [PMRequest postRequestURL:MyUrl(SYRemote_unlock) withHeaderDic:HeadDic parameters:parmas withBlock:^(NSDictionary *dict) {
        if ([dict[@"code"] integerValue] == 0) {
            //[SVProgressHUD showSuccessWithStatus:@"开锁成功"];
            [SYCommon addAlertWithTitle:@"开锁成功"];
        }
        else{
            [SVProgressHUD showErrorWithStatus:dict[@"msg"]];
        }
    } andFailure:nil];
}



@end
