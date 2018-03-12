//
//  AppDelegate.h
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioCallViewController.h"
#import "VideoCallViewController.h"


#import "MyRootViewController.h"
#import "MyNewsChatViewController.h"
#import "LookEntranceVedioViewController.h"
#import "iOSNgnStack.h"
#import "PhotosSelectedViewController.h"

#import "MediaContent.h"
#import "MediaSessionMgr.h"
#import "tsk_base64.h"


// 个推
#define kGtAppId           @"srxsXD9uIs7JTnnFIZZxk7"
#define kGtAppKey          @"J1mn6kGdLU7U086Ihlu0d8"
#define kGtAppSecret       @"G6Nk5pT6uIAhfq3JYXuJS6"


@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    LookEntranceVedioViewController * _lookEntranceViewController;
    PhotosSelectedViewController * _photosSelectedViewController;
    
    BOOL scheduleRegistration;
    BOOL nativeABChangedWhileInBackground;
    
    BOOL multitaskingSupported;
}



@property (nonatomic, retain) UIWindow *window;

/** 门口通话视频*/
@property (nonatomic, readonly) LookEntranceVedioViewController *lookEntranceViewController;

/** 相册*/
@property (nonatomic, strong) PhotosSelectedViewController * photosSelectedViewController;

/** 重复注册次数*/
@property (nonatomic,assign) NSInteger sipRegCount;

+(AppDelegate*) sharedInstance;
-(void)setmanagerRootVC;
-(void)regiestGeTui;
@end

