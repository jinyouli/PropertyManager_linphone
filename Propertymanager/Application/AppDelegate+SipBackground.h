//
//  AppDelegate+SipBackground.h
//  PropertyManager
//
//  Created by Momo on 16/12/29.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (SipBackground)

-(void)registNotification;

/** didFinishLaunchingWithOptions*/
-(void)didFinishLaunchingWithOptions;

/** applicationDidReceiveMemoryWarning*/
-(void)applicationDidReceiveMemoryWarning;

/** applicationDidEnterBackground*/
-(void)applicationDidEnterBackground;

/** applicationWillEnterForeground*/
-(void)applicationWillEnterForeground;

@end
