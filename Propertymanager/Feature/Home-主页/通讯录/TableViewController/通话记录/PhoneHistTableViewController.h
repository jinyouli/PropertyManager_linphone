//
//  PhoneHistTableViewController.h
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "BaseContactTableViewController.h"
#import "iOSNgnStack.h"
@interface PhoneHistTableViewController : BaseContactTableViewController<UIActionSheetDelegate> {

    NgnHistoryEventMutableArray* mEvents;
    HistoryEventStatus_t mStatusFilter;
    
    NgnBaseService<INgnContactService>* mContactService;
    NgnBaseService<INgnHistoryService>* mHistoryService;
    
    MyFMDataBase * database;
    
}

@end
