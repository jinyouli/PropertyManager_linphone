//
//  ContactModel.m
//  WeChatContacts-demo
//
//  Created by shen_gh on 16/3/12.
//  Copyright © 2016年 com.joinup(Beijing). All rights reserved.
//

#import "ContactModel.h"
#import "NSString+Utils.h"//category

@implementation ContactModel

@synthesize pingyin = _first_py;


-(NSString *)fusername{
    if (_fusername == nil) {
        _fusername = @"";
    }
    return _fusername;
}

-(NSString *)pingyin{
    if (_first_py == nil) {
        _first_py = @"";
    }
    return _first_py;
}

-(NSString *)fdepartmentname{
    if (_fdepartmentname == nil) {
        _fdepartmentname = @"";
    }
    return _fdepartmentname;
}

-(NSString *)fworkername{
    if (_fworkername == nil) {
        _fworkername = @"";
    }
    return _fworkername;
}

-(NSString *)worker_id{
    if (_worker_id == nil) {
        _worker_id = @"";
    }
    return _worker_id;
}
-(NSString *)user_sip{
    if (_user_sip == nil) {
        _user_sip = @"";
    }
    return _user_sip;
}

-(NSString *)fgroup_name{
    if (_fgroup_name == nil) {
        _fgroup_name = @"";
    }
    return _fgroup_name;
}



@end
