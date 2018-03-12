//
//  MyMessageHistoryEntry.h
//  idoubs
//
//  Created by Momo on 16/7/12.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "model/NgnHistorySMSEvent.h"

@interface MyMessageHistoryEntry : NSObject
{
    long long eventId;
    NSString* remoteParty;
    NSString* content;
    NSDate* date;
    NSTimeInterval start;
}

@property(nonatomic,readonly) long long eventId;
@property(nonatomic,retain) NSString *remoteParty;
@property(nonatomic,retain) NSString *content;
@property(nonatomic,retain) NSDate *date;
@property(nonatomic,assign) NSTimeInterval start;

-(MyMessageHistoryEntry*)initWithEvent: (NgnHistorySMSEvent*)event;
@end
