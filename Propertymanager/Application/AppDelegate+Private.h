//
//  AppDelegate+Private.h
//  PropertyManager
//
//  Created by Momo on 16/12/29.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (Private)
-(void) networkAlert:(NSString*)message;
-(void) newMessageAlert:(NSString*)message;
-(BOOL) queryConfigurationAndRegister;
-(void) setAudioInterrupt: (BOOL)interrupt;

@end
