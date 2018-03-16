//
//  MyNewsChatViewController.m
//  idoubs
//
//  Created by Momo on 16/6/22.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "MyNewsChatViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "BaloonChatCell.h"
#import "AppDelegate.h"

#import "BottomChatToolView.h"
#import "ContactModel.h"


//
//	History Data
//

@interface MyNewsChatViewController(Private)
-(void) scrollToBottom:(BOOL)animated;
-(void) refreshData;
-(void) reloadData;
-(void) refreshDataAndReload;
-(void) onHistoryEvent:(NSNotification*)notification;
@end

@implementation MyNewsChatViewController(Private)

-(void) refreshData{
    @synchronized(messages){
        //[messages removeAllObjects];
        
//        NSArray* events = [[[[NgnEngine sharedInstance].historyService events] allValues] sortedArrayUsingSelector:@selector(compareHistoryEventByDateDESC:)];
        
//        for (int i = 0 ; i < events.count; i ++) {
//            NgnHistoryEvent* event = events[i];
//            if (!event) {
//                continue;
//            }
//            if (!(event.mediaType & MediaType_SMS)) {
//                continue;
//            }
//            if (![event.remoteParty isEqualToString: self.remoteParty]) {
//                continue;
//            }
//            if(!event || !(event.mediaType & MediaType_SMS) || ![event.remoteParty isEqualToString: self.remoteParty]){
//                continue;
//            }
//            [messages addObject:event];
//        }
        
    }
}

-(void) scrollToBottom:(BOOL)animated{
    
    if([messages count] >0){
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:([messages count] - 1)]
                         atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

-(void) reloadData{
    [tableView reloadData];
    [self scrollToBottom:YES];
}

-(void) refreshDataAndReload{
    [self refreshData];
    [self reloadData];
}

-(void) onHistoryEvent:(NSNotification*)notification{
//    NgnHistoryEventArgs* eargs = [notification object];
//
//    switch (eargs.eventType) {
//        case HISTORY_EVENT_ITEM_ADDED:
//        {
//            if((eargs.mediaType & MediaType_SMS)){
//                NgnHistoryEvent* event = [[[NgnEngine sharedInstance].historyService events] objectForKey: [NSNumber numberWithLongLong: eargs.eventId]];
//                NSInteger eventInt = [event.remoteParty integerValue];
//                NSInteger remotInt = [self.remoteParty integerValue];
//                if (event) {
//                    if (eventInt == remotInt) {
//                        [messages addObject: event];
//                        [self reloadData];
//                    }
//                }
//            }
//            break;
//        }
//
//        case HISTORY_EVENT_ITEM_MOVED:
//        case HISTORY_EVENT_ITEM_UPDATED:
//        {
//            [self reloadData];
//            break;
//        }
//
//        case HISTORY_EVENT_ITEM_REMOVED:
//        {
//            if((eargs.mediaType & MediaType_SMS)){
//                for (NgnHistoryEvent* event in messages) {
//                    if(event.id == eargs.eventId){
//                        [messages removeObject: event];
//                        [tableView reloadData];
//                        break;
//                    }
//                }
//            }
//            break;
//        }
//
//        case HISTORY_EVENT_RESET:{
//            [[NgnEngine sharedInstance].historyService deleteEventWithId:eargs.eventId];
//        }
//        default:
//        {
//            [self refreshDataAndReload];
//            break;
//        }
//    }
}

@end

@interface MyNewsChatViewController ()
//@property(nonatomic,retain) NgnContact *contact;
@property(nonatomic,retain) NSString* remotePartyUri;


//底部工具选项
@property (nonatomic,strong) BottomChatToolView * bottomView;

@end

@implementation MyNewsChatViewController

#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        messages = [[NSMutableArray alloc] init];
        
        if (![PMTools isNullOrEmpty:params[@"myRemoteParty"]]) {
            self.remoteParty = params[@"myRemoteParty"];
//            self.contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber: self.remoteParty];
//            self.remotePartyUri = [NgnUriUtils makeValidSipUri:self.remoteParty];
            
        }
        if (![PMTools isNullOrEmpty:params[@"name"]]) {
            self.myNewsTitle = params[@"name"];
        }
        
        self.remoteParty = params[@"myRemoteParty"];
        self.myNewsTitle = params[@"name"];
        self.dictParams = params;
        
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64 - 50) style:UITableViewStylePlain];
        self.tableView.backgroundColor = BGColor;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:self.tableView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
        [self.tableView addGestureRecognizer:tap];
    }
    return self;
}

@synthesize tableView;
@synthesize textView;
@synthesize viewFooter;
@synthesize remotePartyUri;
//@synthesize contact;


-(void)dealloc{
    SYLog(@"MyNewsChatViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}


-(void)tapClick{
    [self.bottomView.voiceTextView resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createLeftBarButtonItemWithTitle:self.myNewsTitle];
    [self createRightBarButtonItemWithImage:nil WithTitle:@"发送" withMethod:@selector(sendMessageBtnClick)];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    //[self refreshDataAndReload];

    
//    [[NSNotificationCenter defaultCenter]    addObserver:self
//                                             selector:@selector(onHistoryEvent:)
//                                                 name:kNgnHistoryEventArgs_Name
//                                               object:nil];
    
    //注册键盘监听事件
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardUP:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDown:) name:UIKeyboardWillHideNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(textReceivedEvent:)
                                               name:kLinphoneMessageReceived
                                             object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDataFromDataBase) name:@"getChatMessage" object:nil];
    
    
    self.bottomView = [[BottomChatToolView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 64 - 50, ScreenWidth, 50)];
    self.bottomView.voiceBtn.selected = NO;
    self.bottomView.talkBtn.hidden = YES;
    self.bottomView.voiceTextView.hidden = NO;
    self.bottomView.addImageRightBtn.enabled = NO;
    [self.bottomView myBtnClickBlock:^(NSInteger index, BOOL isUp, NSInteger volume, NSString *myVoiceStr) {
        [self bottomBtnClickWithIndex:index isUp:isUp withVolume:volume withMyVoiceStr:myVoiceStr];
    }];

    [self.view addSubview:self.bottomView];
    
    [self getDataFromDataBase];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    [self.tableView addGestureRecognizer:longGesture];
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)longGesture
{
    if (longGesture.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [longGesture locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        
        [WJYAlertView showTwoButtonsWithTitle:@"提示" Message:@"确定删除该聊天记录吗？" ButtonType:WJYAlertViewButtonTypeNone ButtonTitle:@"确定" Click:^{
            
            NSDictionary *dict = [messages objectAtIndex:indexPath.section];
            NSDictionary *deleteDic = [[NSDictionary alloc] initWithObjectsAndKeys:[dict objectForKey:@"id"],@"id", nil];
            [[MyFMDataBase shareMyFMDataBase] deleteDataWithTableName:@"PersonCall" delegeteDic:deleteDic];
            [self getDataFromDataBase];
            
        } ButtonType:WJYAlertViewButtonTypeNone ButtonTitle:@"取消" Click:^{
            
        }];
    }
}

- (void)getDataFromDataBase
{
    UserManager * user = [UserManagerTool userManager];
    NSDictionary *selectDic = [[NSDictionary alloc] initWithObjectsAndKeys:user.username,@"myName",self.myNewsTitle,@"otherName", nil];
    NSArray *result = [[MyFMDataBase shareMyFMDataBase] selectDataWithTableName:@"PersonCall" withDic:selectDic];
    
    messages = [[NSMutableArray alloc] initWithArray:result];
    [tableView reloadData];
}

#pragma mark - Event Functions

- (void)textReceivedEvent:(NSNotification *)notif {
    
    [messages addObject:[notif userInfo]];
    [self refreshDataAndReload];
    
    UserManager * user = [UserManagerTool userManager];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[notif userInfo]];
    [dict setObject:user.username forKey:@"myName"];
    [dict setObject:self.myNewsTitle forKey:@"otherName"];
    
    [[MyFMDataBase shareMyFMDataBase] insertDataWithTableName:@"PersonCall" insertDictionary:[NSDictionary dictionaryWithDictionary:dict]];
    [self getDataFromDataBase];
}

-(void)bottomBtnClickWithIndex:(NSInteger)index isUp:(BOOL)isUp withVolume:(NSInteger)volume withMyVoiceStr:(NSString *)str{
    switch (index) {
        case 1:
        {
            [SVProgressHUD showErrorWithStatus:@"该功能暂时未开放，敬请期待"];
        }
            break;
            
        case 2:
        {
            [SVProgressHUD showErrorWithStatus:@"该功能暂时未开放，敬请期待"];
        }
            break;
            
        case 3:
        {
            [SVProgressHUD showErrorWithStatus:@"该功能暂时未开放，敬请期待"];
        }
            break;
            
        case 4:
        {
            [SVProgressHUD showErrorWithStatus:@"该功能暂时未开放，敬请期待"];
        }
            break;
            
        case 5:
        {
            [SVProgressHUD showErrorWithStatus:@"该功能暂时未开放，敬请期待"];
        }
            break;
            
        case 6:
        {
            SYLog(@"文本获得第一响应 NO键盘弹出  YES键盘收回");
            if (!isUp) {
                self.bottomView.talkBtn.hidden = YES;
                self.bottomView.voiceTextView.hidden = NO;
            }
            else{
                self.bottomView.talkBtn.hidden = NO;
                self.bottomView.voiceTextView.hidden = YES;
            }

            
        }
            break;
            
        case 7:
        {
            // 收回键盘
            [self.view endEditing:YES];
            SYLog(@"收回键盘");
        }
            break;
            
        case 8:
        {
            SYLog(@"点击图片");
            [self createSVProgressMessage:@"暂时没有发送图片的功能" withMethod:nil];
        }
            break;
            
        case 9:
        {
            //声音检测
            [SVProgressHUD showErrorWithStatus:@"该功能暂时未开放，敬请期待"];
            
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 键盘上升
-(void)keyboardUP:(NSNotification *)noti{
    
    //获取键盘的高度
    NSDictionary *userInfo = [noti userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    // textView 上升
    CGRect newframe = self.bottomView.frame;
    newframe.origin.y = ScreenHeight - height - newframe.size.height - 64;
    float time = [[noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:time animations:^{
        self.bottomView.frame = newframe;
    }];
    self.bottomView.voiceBtn.selected = NO;
    self.bottomView.talkBtn.enabled = NO;
    self.bottomView.talkBtn.layer.borderColor = lineColor.CGColor;
    [self.bottomView.talkBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.view bringSubviewToFront:self.bottomView];
}
#pragma mark - 键盘下降
-(void)keyboardDown:(NSNotification *)noti{
    // textView 下降
    CGRect newframe = self.bottomView.frame;
    newframe.origin.y = ScreenHeight - newframe.size.height - 64;
    float time = [[noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:time animations:^{
        self.bottomView.frame = newframe;
    }];
}



- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[messages removeAllObjects];
}

- (void)sendMessageBtnClick{
    
    if ([self checkNetWork]) {
        NSString* text = self.bottomView.voiceTextView.text;
        [self.bottomView.voiceTextView resignFirstResponder];
        self.bottomView.voiceTextView.text = @"";
        
        if(![PMTools isNullOrEmpty:text]){
            
            [[LinphoneManager instance] sendMessage:text withExterlBodyUrl:nil withInternalURL:nil Address:self.dictParams[@"myRemoteParty"]];
            
//            NgnHistorySMSEvent* event = [NgnHistoryEvent createSMSEventWithStatus:HistoryEventStatus_Outgoing
//                                                                   andRemoteParty: self.remoteParty
//                                                                       andContent:[text dataUsingEncoding:NSUTF8StringEncoding]];
//            NgnMessagingSession* session = [NgnMessagingSession createOutgoingSessionWithStack:[[NgnEngine sharedInstance].sipService getSipStack] andToUri: self.remotePartyUri];
//            event.status = [session sendTextMessage:text contentType: kContentTypePlainText] ? HistoryEventStatus_Outgoing : HistoryEventStatus_Failed;
//            [[NgnEngine sharedInstance].historyService addEvent: event];

        }

    }
}

//-(void)setRemoteParty:(NSString *) myRemoteParty{
//
//    remoteParty = myRemoteParty;
//    self.contact = [[NgnEngine sharedInstance].contactService getContactByPhoneNumber: remoteParty];
//    self.remotePartyUri = [NgnUriUtils makeValidSipUri:self.remoteParty];
//}
//
//-(void)setRemoteParty:(NSString *)remoteParty_ andContact:(NgnContact*)contact_{
//
//    self->remoteParty = remoteParty_ ;
//    self.contact = contact_;
//    self.remotePartyUri = [NgnUriUtils makeValidSipUri:self.remoteParty];
//}

-(NSString*)remoteParty{
    return self->remoteParty;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    BaloonChatCell *cell = [BaloonChatCell cellWithTableview:tableView];
    [cell setEvent:[messages objectAtIndex:indexPath.section] forTableView:_tableView withOtherName:self.myNewsTitle];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;{
//    @synchronized(messages){
////        NgnHistorySMSEvent * event = [messages objectAtIndex: indexPath.row];
////        if(event){
////            NSString* content = event.contentAsString ? event.contentAsString : @"";
////            CGSize constraintSize = [PMTools sizeWithText:content font:MiddleFont maxSize:CGSizeMake(ScreenWidth - 120, 2500)];
////            if (constraintSize.height < 30) {
////                return 60;
////            }
////            else{
////                return 40 + constraintSize.height;
////            }
////        }
//        return 0.0;
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
//        NgnHistoryEvent* event = [messages objectAtIndex: indexPath.row];
//        if (event) {
//            [[NgnEngine sharedInstance].historyService deleteEvent: event];
//        }
    }
}


-(BOOL)cheakSip{
    
//    if ([[NgnEngine sharedInstance].sipService isRegistered]){
//
//        return YES;
//    }
//    else{
//        [self.view endEditing:YES];
//        [WJYAlertView showTwoButtonsWithTitle:@"提示" Message:@"网络不好，请稍后尝试！" ButtonType:WJYAlertViewButtonTypeNone ButtonTitle:@"确定" Click:^{
//
//            [PMSipTools sipRegister];
//
//        } ButtonType:WJYAlertViewButtonTypeNone ButtonTitle:@"取消" Click:^{
//
//        }];
//
//
//
//        return NO;
//    }
    
    return NO;
}


@end
