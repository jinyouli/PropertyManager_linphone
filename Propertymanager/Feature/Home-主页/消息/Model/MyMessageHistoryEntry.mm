//
//  MyMessageHistoryEntry.m
//  idoubs
//
//  Created by Momo on 16/7/12.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "MyMessageHistoryEntry.h"


@interface MyMessageHistoryEntry(Private)
-(NSComparisonResult)compareEntryByDate:(MyMessageHistoryEntry *)otherEntry;
@end

@implementation MyMessageHistoryEntry(Private)

-(NSComparisonResult)compareEntryByDate:(MyMessageHistoryEntry *)otherEntry{
    NSTimeInterval diff = self->start - otherEntry->start;
    return diff==0 ? NSOrderedSame : (diff > 0 ?  NSOrderedAscending : NSOrderedDescending);
}

@end

// private properties
@interface MyMessageHistoryEntry()
@end


// default implementation
@implementation MyMessageHistoryEntry

@synthesize eventId;
@synthesize remoteParty;
@synthesize content;
@synthesize date;
@synthesize start;

-(MyMessageHistoryEntry*)initWithEvent: (NgnHistorySMSEvent*)event{
    if((self = [super init])){
        self->eventId = event.id;
        self.remoteParty = event.remoteParty;
        self->start = event.start;
        self.date = [NSDate dateWithTimeIntervalSince1970: self.start];
        self.content = event.contentAsString;
    }
    return self;
}

@end

