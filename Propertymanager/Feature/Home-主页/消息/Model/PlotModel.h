//
//  PlotModel.h
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlotModel : NSObject
//{
//    NSString * _id;
//}

@property (nonatomic,strong) NSString * id;
@property (nonatomic,strong) NSString * noticeID;
@property (nonatomic,strong) NSString * type;
@property (nonatomic,strong) NSString * title;
@property (nonatomic,strong) NSString * issuer;
@property (nonatomic,strong) NSString * time;
@property (nonatomic,strong) NSString * content;
@property (nonatomic,strong) NSString * expdate;
@property (nonatomic,strong) NSString * fcreatetime;
@property (nonatomic,assign) BOOL state;

@end
