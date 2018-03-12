//
//  SYCommon.m
//  PropertyManager
//
//  Created by Li JinYou on 2018/1/18.
//  Copyright © 2018年 Momo. All rights reserved.
//

#import "SYCommon.h"

@implementation SYCommon

+ (void)addAlertWithTitle:(NSString*)string
{
    //[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]]
    
    if (string.length > 0) {
        iToastSettings *theSettings = [iToastSettings getSharedSettings];
        [theSettings setDuration:iToastDurationNormal];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[iToast makeText:string] show];
        });
    }
}

+ (void)showAlert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    [alert show];
}

@end
