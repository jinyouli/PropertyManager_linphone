//
//  SliderScroView.h
//  PropertyManager
//
//  Created by Momo on 16/9/26.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SliderScroViewDelegate <NSObject>

-(void)RequestFinish;

@end

@interface SliderScroView : UIScrollView
-(instancetype)initWithFrame:(CGRect)frame withSn_Domain:(NSString *)sn_Domain type:(NSString *)type sipNum:(NSString *)sipnum;
@property (nonatomic,strong) NSString * type;
@property (nonatomic,strong) NSString * domain_sn;
@property (nonatomic,strong) NSString * sip_number;
@property (nonatomic,weak) id<SliderScroViewDelegate> myDelegate;
@property (nonatomic,assign) NSInteger leftTime;
@end
