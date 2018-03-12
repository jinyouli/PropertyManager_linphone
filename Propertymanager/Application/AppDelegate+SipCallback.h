//
//  AppDelegate+SipCallback.h
//  PropertyManager
//
//  Created by Momo on 16/12/29.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (SipCallback)


-(void) onNetworkEvent:(NSNotification*)notification;
-(void) onNativeContactEvent:(NSNotification*)notification;
-(void) onStackEvent:(NSNotification*)notification;
-(void) onRegistrationEvent:(NSNotification*)notification;
-(void) onMessagingEvent:(NSNotification*)notification;
-(void) onInviteEvent:(NSNotification*)notification;

@end
