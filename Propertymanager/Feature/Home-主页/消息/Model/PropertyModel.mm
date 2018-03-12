//
//  PropertyModel.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "PropertyModel.h"

@implementation PropertyModel



-(NSString *)fname{
    if (_fname == nil) {
        _fname = @"";
    }
    return _fname;
}

-(NSString *)fcreatetime{
    if (_fcreatetime == nil) {
        _fcreatetime = @"";
    }
    return _fcreatetime;
}
-(NSString *)frepairs_id{
    if (_frepairs_id == nil) {
        _frepairs_id = @"";
    }
    return _frepairs_id;
}

-(NSString *)fpush_type{
    if (_fpush_type == nil) {
        _fpush_type = @"";
    }
    return _fpush_type;
}

-(NSString *)fcontent{
    if (_fcontent == nil) {
        _fcontent = @"";
    }
    return _fcontent;
}

-(BOOL)state{
    if (_state == NULL) {
        _state = NO;
    }
    return _state;
}


@end
