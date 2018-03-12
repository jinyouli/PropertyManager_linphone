//
//  MyRootViewController.h
//  PropertyManage
//
//  Created by Momo on 16/6/16.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LeftViewController.h"


@interface MyRootViewController : UIViewController

@property (nonatomic,strong) LeftViewController * leftViewController;
@property (nonatomic,strong) UINavigationController * midViewController;

@end