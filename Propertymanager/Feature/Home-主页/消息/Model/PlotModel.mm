//
//  PlotModel.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "PlotModel.h"

@implementation PlotModel
//@synthesize noticeID = _id;

-(NSString *)id{
    if (_id == nil) {
        _id = @"";
    }
    return _id;
}

-(NSString *)type{
    if (_type == nil) {
        _type = @"";
    }
    return _type;
}

-(NSString *)title{
    if (_title == nil) {
        _title = @"";
    }
    return _title;
}

-(NSString *)issuer{
    if (_issuer == nil) {
        _issuer = @"";
    }
    return _issuer;
}

-(NSString *)time{
    if (_time == nil) {
        _time = @"";
    }
    return _time;
}
-(NSString *)content{
    if (_content == nil) {
        _content = @"";
    }
    return _content;
}

-(NSString *)expdate{
    if (_expdate == nil) {
        _expdate = @"";
    }
    return _expdate;
}

-(NSString *)fcreatetime{
    if (_fcreatetime == nil) {
        _fcreatetime = @"";
    }
    return _fcreatetime;
}

-(BOOL)state{
    if (_state == NULL) {
        _state = NO;
    }
    return _state;
}

@end
