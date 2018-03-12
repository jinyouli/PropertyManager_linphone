//
//  ContactInfoView.h
//  idoubs
//
//  Created by Momo on 16/7/18.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactInfoView : UIView

//CGRectMake(0, contactY, ScreenWidth, 40)
//iconColor:(UIColor *)iconColor nameColor:(UIColor *)nameColor departColor:(UIColor *)departColor
-(instancetype)initWithPoint:(CGPoint)point withWorkName:(NSString *)workName department:(NSString *)department colorArr:(NSArray *)colorArr;

@end
