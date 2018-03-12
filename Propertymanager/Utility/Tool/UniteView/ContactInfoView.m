//
//  ContactInfoView.m
//  idoubs
//
//  Created by Momo on 16/7/18.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "ContactInfoView.h"

@interface ContactInfoView()

@property (nonatomic,strong) UILabel * iconName;
@property (nonatomic,strong) UILabel * nameLabel;
@property (nonatomic,strong) UILabel * departmentLabel;

@end

@implementation ContactInfoView
//iconColor:(UIColor *)iconColor nameColor:(UIColor *)nameColor departColor:(UIColor *)departColor
-(instancetype)initWithPoint:(CGPoint)point withWorkName:(NSString *)workName department:(NSString *)department colorArr:(NSArray *)colorArr{
    if (self = [super init]) {
        self.frame = CGRectMake(point.x, point.y, ScreenWidth - point.x, 40);
        [self createSubviewsWithWorkName:workName department:department colorArr:colorArr];
    }
    return self;
}
-(void)createSubviewsWithWorkName:(NSString *)workName department:(NSString *)department colorArr:(NSArray *)colorArr{

    UIImageView * icon = [[UIImageView alloc]init];
    icon.frame = CGRectMake(20, 0, 40, 40);
    icon.backgroundColor = colorArr[0];
    icon.layer.cornerRadius = 20;
    icon.clipsToBounds = YES;
    [self addSubview:icon];
    
    self.iconName = [[UILabel alloc]init];
    self.iconName.font = LargeFont;
    self.iconName.textAlignment = NSTextAlignmentCenter;
    self.iconName.frame = CGRectMake(0, 7.5, 40, 25);
    self.iconName.textColor = [UIColor whiteColor];
    self.iconName.text = [PMTools subStringFromString:workName isFrom:YES];
    [icon addSubview:self.iconName];
    
    self.nameLabel = [[UILabel alloc]init];
    self.nameLabel.frame = CGRectMake(70, icon.frame.origin.y, ScreenWidth - 90, 25);
    self.nameLabel.font = LargeFont;
    self.nameLabel.textColor = colorArr[1];
    self.nameLabel.text = workName;
    [self addSubview:self.nameLabel];
    
    self.departmentLabel = [[UILabel alloc]init];
    self.departmentLabel.frame = CGRectMake(70, CGRectGetMaxY(self.nameLabel.frame), ScreenWidth - 90, 20);
    self.departmentLabel.font = SmallFont;
    self.departmentLabel.textColor = colorArr[2];
    self.departmentLabel.text = department;
    [self addSubview:self.departmentLabel];

}

@end
