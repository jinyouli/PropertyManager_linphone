//
//  MyNewsChatViewController.h
//  idoubs
//
//  Created by Momo on 16/6/22.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "BaseViewController.h"
#import "iOSNgnStack.h"
@interface MyNewsChatViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource, UITextViewDelegate>
{
    UITableView *tableView;
    UITextView *textView;
    UIView *viewFooter;
    
    NSMutableArray* messages;
    NgnContact* contact;
    NSString* remoteParty;
    NSString* remotePartyUri;
}

/** 导航栏标题*/
@property (nonatomic,strong) NSString * myNewsTitle;
/** 聊天tableview*/
@property(nonatomic,strong) UITableView *tableView;
/** 聊天输入文本框*/
@property(nonatomic,retain) UITextView *textView;
/** 底部view*/
@property(nonatomic,retain) UIView *viewFooter;
/** 对方impi*/
@property(nonatomic,retain) NSString *remoteParty;

-(void)setRemoteParty:(NSString *)remoteParty andContact:(NgnContact*)contact;

@end
