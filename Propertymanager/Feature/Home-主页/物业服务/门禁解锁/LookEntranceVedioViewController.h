//
//  LookEntranceVedioViewController.h
//  PropertyManager
//
//  Created by Momo on 16/9/13.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSNgnStack.h"


#import "CallViewController.h"

@interface LookEntranceVedioViewController : CallViewController

@property (nullable,strong) NSString * domain_sn;
@property (nonatomic,strong) NSString * sipnum;


@end
