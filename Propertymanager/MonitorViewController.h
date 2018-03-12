//
//  MonitorViewController.h
//  Propertymanager
//
//  Created by Li JinYou on 2018/3/9.
//  Copyright © 2018年 Li JinYou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonitorViewController : UIViewController

@property (nonatomic, assign) SYLinphoneCall *call;
@property (nonatomic, strong) SYLockListModel *model;
@property (nonatomic, assign) BOOL isInComingCall;

- (instancetype)initWithCall:(SYLinphoneCall *)call GuardInfo:(SYLockListModel *)model InComingCall:(BOOL)isInComingCall;
@end
