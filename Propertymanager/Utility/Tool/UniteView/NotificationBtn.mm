//
//  NotificationBtn.m
//  PropertyManager
//
//  Created by Momo on 16/8/9.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "NotificationBtn.h"
#import "ProOrderNewsViewController.h"

static const CGFloat CSToastFadeDuration        = 0.2;

@interface NotificationBtn ()

@property (nonatomic,strong) NSString * repair_id;
@property (nonatomic,strong) UILabel * btnTitleLabel;

@end

@implementation NotificationBtn

+(NotificationBtn *)notificationBtn{
    static NotificationBtn * _btn;
    if (_btn == nil) {
        _btn = [[NotificationBtn alloc]init];
        _btn.backgroundColor = [UIColor blackColor];
        
        UIImageView * iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12, 40, 40)];
        iconImageView.image = [UIImage imageNamed:@"logo80"];
        [_btn addSubview:iconImageView];
        
        CGFloat btnX = CGRectGetMaxX(iconImageView.frame) + 10;
        _btn.btnTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(btnX, 20, ScreenWidth - btnX - 10, 40)];
        _btn.btnTitleLabel.font = LargeFont;
        _btn.btnTitleLabel.numberOfLines = 0;
        _btn.btnTitleLabel.textColor = [UIColor whiteColor];
        [_btn addSubview:_btn.btnTitleLabel];
        
        [_btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _btn;
}

+ (void)toast:(NSString*)msg withRepair:(NSString *)repair_id{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    NotificationBtn *toastBtn = [NotificationBtn notificationBtn];
    toastBtn.frame = CGRectMake(0, -64, ScreenWidth, 64);
    toastBtn.btnTitleLabel.text = msg;
    toastBtn.repair_id = repair_id;
    [window addSubview:toastBtn];
    
    [UIView animateWithDuration:CSToastFadeDuration animations:^{
        toastBtn.frame = CGRectMake(0, 0, ScreenWidth, 64);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NotificationBtn *toastBtn = [NotificationBtn notificationBtn];
        [UIView animateWithDuration:CSToastFadeDuration animations:^{
            toastBtn.frame = CGRectMake(0, -64, ScreenWidth, 64);
        } completion:nil];
    });


}

+(void)btnClick{
    
    NotificationBtn *toastBtn = [NotificationBtn notificationBtn];
    [UIView animateWithDuration:CSToastFadeDuration animations:^{
        toastBtn.frame = CGRectMake(0, -64, ScreenWidth, 64);
    } completion:nil];
    
    [[Routable sharedRouter] open:PROORDERNEWS_VIEWCONTROLLER animated:YES extraParams:@{@"frepairs_id":toastBtn.repair_id}];
}

@end
