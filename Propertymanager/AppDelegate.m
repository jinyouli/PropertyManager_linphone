//
//  AppDelegate.m
//  Propertymanager
//
//  Created by Li JinYou on 2018/3/9.
//  Copyright © 2018年 Li JinYou. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    ViewController *firstVC = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:firstVC];
    
    [self.window setRootViewController:nav];
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - linphone 初始化
- (void)configLinphone{
    [[SYLinphoneManager instance] startSYLinphonephone];

    [SYLinphoneManager instance].ipv6Enabled = NO;
    [SYLinphoneManager instance].videoEnable = YES;
    [[SYLinphoneManager instance] setDelegate:self];
}

@end
