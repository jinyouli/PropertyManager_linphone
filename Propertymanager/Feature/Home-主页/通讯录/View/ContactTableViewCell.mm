//
//  ContactTableViewCell.m
//  WeChatContacts-demo
//
//  Created by shen_gh on 16/3/12.
//  Copyright © 2016年 com.joinup(Beijing). All rights reserved.
//

#import "ContactTableViewCell.h"
#import "ContactInfoView.h"
@interface ContactTableViewCell()

@property (nonatomic,strong) ContactInfoView * contactView;

@end


@implementation ContactTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //布局View
        [self setUpView];
    }
    return self;
}

//-(void)contactName:(NSString *)name department:(NSString *)department letter:(NSString *)letter{
//    
//    [self.contactView removeFromSuperview];
//    self.contactView = [[ContactInfoView alloc]initWithPoint:CGPointMake(40, 10) withWorkName:name department:department colorArr:@[mainColor,mainTextColor,lineColor]];
//    [self.contentView addSubview:self.contactView];
//    
//    if (![PMTools isNullOrEmpty:letter]) {
//        self.letterLabel.text = letter;
//    }
//}

#pragma mark - setUpView
- (void)setUpView{
    //字母
    [self.contentView addSubview:self.letterLabel];
    //头像
    [self.contentView addSubview:self.headImageView];
    [self.headImageView addSubview:self.nameL];
    //姓名
    [self.contentView addSubview:self.nameLabel];
    //部门
    [self.contentView addSubview:self.departmentLabel];
}
- (UIImageView *)headImageView{
    if (!_headImageView) {
        _headImageView=[[UIImageView alloc]initWithFrame:CGRectMake(40, 10.0, 40.0, 40.0)];
        _headImageView.layer.cornerRadius = 20;
        _headImageView.clipsToBounds = YES;
        [_headImageView setContentMode:UIViewContentModeScaleAspectFill];
    }
    return _headImageView;
}

-(UILabel *)nameL{
    if (!_nameL) {
        _nameL = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 40, 20)];
        _nameL.font = MiddleFont;
        _nameL.textAlignment = NSTextAlignmentCenter;
        _nameL.textColor = [UIColor whiteColor];
    }
    return _nameL;
}
- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(90.0, 10.0, ScreenWidth-60.0, 25.0)];
        _nameLabel.font = LargeFont;
        _nameLabel.textColor = mainTextColor;
    }
    return _nameLabel;
}
-(UILabel *)departmentLabel{
    if (!_departmentLabel) {
        _departmentLabel=[[UILabel alloc]initWithFrame:CGRectMake(90.0, 35, ScreenWidth-60.0, 15.0)];
        _departmentLabel.font = SmallFont;
        _departmentLabel.textColor = lineColor;
    }
    return _departmentLabel;
}
-(UILabel *)letterLabel{
    if (!_letterLabel) {
        _letterLabel=[[UILabel alloc]initWithFrame:CGRectMake(10.0, 20.0, 20.0, 20.0)];
        _letterLabel.textColor = mainTextColor;
        [_letterLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    }
    return _letterLabel;
}

@end
