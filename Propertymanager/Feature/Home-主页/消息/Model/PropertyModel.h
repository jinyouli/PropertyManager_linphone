//
//  PropertyModel.h
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PropertyModel : NSObject

@property (nonatomic,strong) NSString * fname;
@property (nonatomic,strong) NSString * fcreatetime;
@property (nonatomic,strong) NSString * frepairs_id;
@property (nonatomic,strong) NSString * fpush_type;
@property (nonatomic,strong) NSString * fcontent;
@property (nonatomic,assign) BOOL state;

@end
