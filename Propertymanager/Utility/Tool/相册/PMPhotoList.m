//
//  PMPhotoList.m
//  idoubs
//
//  Created by Momo on 16/6/27.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "PMPhotoList.h"

@implementation PMPhotoList

+(PMPhotoList *)photoManager {
    static PMPhotoList * _manager;
    if (_manager == nil) {
        _manager = [[PMPhotoList alloc]init];
    }
    
    return _manager;
}

-(NSMutableArray *)photoArr{
    if (_photoArr == nil) {
        _photoArr = [NSMutableArray array];
    }
    
    //刷新 看看
    
    return _photoArr;
}


@end
