//
//  ComplainHeaderDataModel.m
//  idoubs
//
//  Created by Momo on 16/6/30.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "ComplainHeaderDataModel.h"

@implementation ComplainHeaderDataModel

-(NSNumber *)power_do{
    if (_power_do == nil) {
        _power_do = @(0);
    }
    return _power_do;
}

-(NSString *)fstatus{
    if (_fstatus == nil) {
        _fstatus = @"";
    }
    return _fstatus;
}

-(NSNumber *)normal_do{
    if (_normal_do == nil) {
        _normal_do = @(0);
    }
    return _normal_do;
}

-(NSString *)deal_worker_id{
    if (_deal_worker_id == nil) {
        _deal_worker_id = @"";
    }
    return _deal_worker_id;
}

-(NSString *)fscore{
    if (_fscore == nil) {
        _fscore = @"0";
    }
    return _fscore;
}

-(NSNumber *)record_num{
    if (_record_num == nil) {
        _record_num = @(0);
    }
    return _record_num;
}

-(NSString *)repair_id{
    if (_repair_id == nil) {
        _repair_id = @"";
    }
    return _repair_id;
}

-(NSString *)faddress{
    if (_faddress == nil) {
        _faddress = @"";
    }
    return _faddress;
}

-(NSString *)fservicecontent{
    if (_fservicecontent == nil) {
        _fservicecontent = @"";
    }
    return _fservicecontent;
}

-(NSString *)frealname{
    if (_frealname == nil) {
        _frealname = @"";
    }
    return _frealname;
}

-(NSString *)fcreatetime{
    if (_fcreatetime == nil) {
        _fcreatetime = @"";
    }
    return _fcreatetime;
}

-(NSString *)fordernum{
    if (_fordernum == nil) {
        _fordernum = @"";
    }
    return _fordernum;
}

-(NSString *)fworkername{
    if (_fworkername == nil) {
        _fworkername = @"";
    }
    return _fworkername;
}

-(NSString *)fusername{
    if (_fusername == nil) {
        _fusername = @"";
    }
    return _fusername;
}

-(NSArray *)repairs_imag_list{
    if (_repairs_imag_list == nil) {
        _repairs_imag_list = @[];
    }
    return _repairs_imag_list;
}

-(NSString *)fheadurl{
    if (_fheadurl == nil) {
        _fheadurl = @"";
    }
    return _fheadurl;
}
-(NSString *)fremindercount{
    if (_fremindercount == nil) {
        _fremindercount = @"";
    }
    return _fremindercount;
}
-(NSString *)flinkman_phone{
    if (_flinkman_phone == nil) {
        _flinkman_phone = @"";
    }
    return _flinkman_phone;
}
-(NSString *)flinkman{
    if (_flinkman == nil) {
        _flinkman = @"";
    }
    return _flinkman;
}

-(BOOL)isOpenDetail{
    if (_isOpenDetail == NULL) {
        _isOpenDetail = NO;
    }
    return _isOpenDetail;
}
@end
