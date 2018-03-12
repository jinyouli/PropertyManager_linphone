//
//  ComplainReplyDataModel.m
//  idoubs
//
//  Created by Momo on 16/6/30.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "ComplainReplyDataModel.h"

@implementation ComplainReplyDataModel


@synthesize reply_id = _id;
@synthesize nMyName1 = _new_name;

-(NSString *)reply_id{
    if (_id == nil) {
        _id = @"";
    }
    return _id;
}

-(NSString *)ftype{
    if (_ftype == nil) {
        _ftype = @"";
    }
    return _ftype;
}

-(NSString *)fcreatetime{
    if (_fcreatetime == nil) {
        _fcreatetime = @"";
    }
    return _fcreatetime;
}

-(NSString *)name{
    if (_name == nil) {
        _name = @"";
    }
    return _name;
}

-(NSString *)old_name{
    if (_old_name == nil) {
        _old_name = @"";
    }
    return _old_name;
}

-(NSString *)nMyName1{
    if (_new_name == nil) {
        _new_name = @"";
    }
    return _new_name;
}

-(NSString *)fcontent{
    if (_fcontent == nil) {
        _fcontent = @"";
    }
    return _fcontent;
}

-(NSArray *)reply_imag_list{
    if (_reply_imag_list == nil) {
        _reply_imag_list = @[];
    }
    return _reply_imag_list;
}

-(NSString *)ID{
    if(_ID == nil){
        _ID = @"";
    }
    return _ID;
}

@end
