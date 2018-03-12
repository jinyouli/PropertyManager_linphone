//
//  KeyChainStore.h
//  idoubs
//
//  Created by 乔香彬 on 16/3/10.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyChainStore : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteKeyData:(NSString *)service;

@end
