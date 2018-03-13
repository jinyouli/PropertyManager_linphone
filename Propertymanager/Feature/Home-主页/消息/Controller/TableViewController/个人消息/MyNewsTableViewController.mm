//
//  MyNewsTableViewController.m
//  idoubs
//
//  Created by Momo on 16/6/21.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "MyNewsTableViewController.h"

#import "AppDelegate.h"

#import "MyMessageHistoryEntry.h"
#import "MyMessageTableViewCell.h"
@interface MyNewsTableViewController (Private)
-(void) refreshData;
-(void) refreshDataAndReload;
-(void) onHistoryEvent:(NSNotification*)notification;
@end

@implementation MyNewsTableViewController(Private)
-(void) refreshData{
//    @synchronized(self->messages){
//        NSMutableDictionary* entries = [NSMutableDictionary dictionary];
//        NSArray* events = [[[NgnEngine sharedInstance].historyService events] allValues];
//        for (NgnHistoryEvent *event in events) {
//            if(!event || !(event.mediaType & MediaType_SMS)){
//                continue;
//            }
//            
//            MyMessageHistoryEntry* entry = [entries objectForKey:event.remoteParty];
//            if(entry == nil || ((entry.start - event.start) < 0)){
//                MyMessageHistoryEntry* newEntry = [[MyMessageHistoryEntry alloc] initWithEvent:(NgnHistorySMSEvent*)event];
//                [entries setObject:newEntry forKey:newEntry.remoteParty];
//                NSLog(@"新增==%@,%ld",newEntry.remoteParty,newEntry.eventId);
//            }
//            //[[NgnEngine sharedInstance].historyService addEvent:event];
//            
////            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:event];
////            [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"chatData"];
//        }
//
//        //NSArray* sortedEntries = [[entries allValues] sortedArrayUsingSelector:@selector(compareEntryByDate:)];
//        //[self->messages removeAllObjects];
//
//        for (int i=0; i<[entries allValues].count; i++) {
//            
//            MyMessageHistoryEntry* newMessage = [[entries allValues] objectAtIndex: i];
//            for (int j=0; j<self->messages.count; j++) {
//                MyMessageHistoryEntry* oldMessage = [self->messages objectAtIndex: j];
//                if ([newMessage.remoteParty isEqualToString:oldMessage.remoteParty]) {
//                    [self->messages removeObject:oldMessage];
//                }
//            }
//        }
//        [self->messages addObjectsFromArray:[entries allValues]];
//    }
    
}

-(void) refreshDataAndReload{
    [self refreshData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self cheakDataCount:messages];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    });
}

-(void) onHistoryEvent:(NSNotification*)notification{
//    NgnHistoryEventArgs* eargs = [notification object];
//
//    switch (eargs.eventType) {
//        case HISTORY_EVENT_ITEM_ADDED:
//        {
//            if((eargs.mediaType & MediaType_SMS)){
//
//                //FIXME
//                [self refreshDataAndReload];
//
//            }
//
//            break;
//        }
//
//        case HISTORY_EVENT_ITEM_MOVED:
//        case HISTORY_EVENT_ITEM_UPDATED:
//        {
//            [self.tableView reloadData];
//            break;
//        }
//
//        case HISTORY_EVENT_ITEM_REMOVED:
//        {
//            if((eargs.mediaType & MediaType_SMS)){
//                //FIXME
//                [self refreshDataAndReload];
//
//            }
//            break;
//        }
//
//        case HISTORY_EVENT_RESET:
//             [[NgnEngine sharedInstance].historyService deleteEventWithId:eargs.eventId];
//        default:
//        {
//            [self refreshDataAndReload];
//            break;
//        }
//    }
}

//== PagerMode IM (MESSAGE) events == //
-(void) onMessagingEvent:(NSNotification*)notification {
//    NgnMessagingEventArgs* eargs = [notification object];
//
//    switch (eargs.eventType) {
//        case MESSAGING_EVENT_CONNECTING:
//        case MESSAGING_EVENT_CONNECTED:
//        case MESSAGING_EVENT_TERMINATING:
//        case MESSAGING_EVENT_TERMINATED:
//        case MESSAGING_EVENT_FAILURE:
//        case MESSAGING_EVENT_SUCCESS:
//        case MESSAGING_EVENT_OUTGOING:
//        default:
//        {
//            break;
//        }
//
//        case MESSAGING_EVENT_INCOMING:
//        {
//            if(eargs.payload){
//                // The payload is a NSData object which means that it could contain binary data
//                // here I consider that it's utf8 text message
//
//                //[self refreshDataAndReload];
//        }
//            break;
//        }
//    }
    //    labelDebugInfo.text = [NSString stringWithFormat: @"onMessagingEvent: %@", eargs.sipPhrase];
}

@end


@interface MyNewsTableViewController ()
//@property(nonatomic,retain) NgnContact *pickedContact;
//@property(nonatomic,retain) NgnPhoneNumber *pickedNumber;
@property(nonatomic,readonly) NSMutableArray *messages;
@end

@implementation MyNewsTableViewController

//@synthesize pickedContact;
//@synthesize pickedNumber;
@synthesize messages;

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self cheakDataCount:messages];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //[[NgnEngine sharedInstance].historyService load];
    
    if(!self.messages){
        self->messages = [[NSMutableArray alloc] init];
    }
    [self cheakDataCount:messages];
    self.tableView.mj_header.hidden = NO;
    self.tableView.mj_footer.hidden = YES;
    // refresh data set datasource
    [self refreshData];
    
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self selector:@selector(onHistoryEvent:) name:kNgnHistoryEventArgs_Name object:nil];
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self selector:@selector(onMessagingEvent:) name:kNgnMessagingEventArgs_Name object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(pushChatVC:) name:@"pushChatVC" object:nil];

    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 11.0) {
        self.tableView.contentInset = UIEdgeInsetsMake(45, 0, 0, 0);
    }
}

-(void)pushChatVC:(NSNotification *)noti{
    NSString * remoteParty = [noti object];
//    SYLog(@"pushChatVC === remoteParty === %@",remoteParty);
    
    ContactModel * model = [PMSipTools gainContactModelFromSipNum:remoteParty];
    NSString * name = remoteParty;
    if (model) {
        name = model.fworkername;
    }
    
    [[Routable sharedRouter] open:MYNEWSCHAT_VIEWCONTROLLER animated:YES extraParams:@{@"myRemoteParty":remoteParty,@"name":name}];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [messages count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyMessageTableViewCell *cell = [MyMessageTableViewCell cellWithTableview:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    MyMessageHistoryEntry* entry = [messages objectAtIndex: indexPath.row];
    if (entry) {
        cell.entry = [messages objectAtIndex: indexPath.row];
        ContactModel * model = [PMSipTools gainContactModelFromSipNum:entry.remoteParty];
        if (model) {
            cell.contactModel = model;
        }
        
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MyMessageTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.entry) {
        NSString * name = cell.entry.remoteParty;
        if (cell.contactModel) {
            name = cell.contactModel.fworkername;
        }
       // [[NgnEngine sharedInstance].historyService load];
        NSString * strSip = [NSString stringWithFormat:@"%@",cell.entry.remoteParty];
        [[Routable sharedRouter] open:MYNEWSCHAT_VIEWCONTROLLER animated:YES extraParams:@{@"myRemoteParty":strSip,@"name":name}];
    }

}

@end
