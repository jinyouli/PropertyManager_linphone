//
//  PMTokenTools.h
//  PropertyManager
//
//  Created by Momo on 17/1/15.
//  Copyright © 2017年 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMTokenTools : NSObject


/**
    重新获取token
 */
+(void)getTokenByOldToken;

+(void)gainNewToken;

@end
