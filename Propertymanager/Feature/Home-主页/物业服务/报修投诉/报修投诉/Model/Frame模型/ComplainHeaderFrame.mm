//
//  ComplainHeaderFrame.m
//  idoubs
//
//  Created by Momo on 16/6/30.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "ComplainHeaderFrame.h"

@implementation ComplainHeaderFrame

-(instancetype)init{
    if (self = [super init]) {
    }
    return self;
}

-(void)setHeaderDataModel:(ComplainHeaderDataModel *)headerDataModel{
    _headerDataModel = headerDataModel;
    
    // 子控件之间的间距
    CGFloat padding = 10;
    
    // 1.头像
    CGFloat iconX = padding;
    CGFloat iconY = padding;
    CGFloat iconW = 35;
    CGFloat iconH = 35;
    _iconF = CGRectMake(iconX, iconY, iconW, iconH);
    
    // 2.业主名字
    NSString * frealnameStr = @"";
    if ([PMTools isNullOrEmpty:self.headerDataModel.frealname]) {
        if ([PMTools isNullOrEmpty:self.headerDataModel.flinkman]) {
            
            frealnameStr = @"业主";
        }
        else{
            frealnameStr = self.headerDataModel.flinkman;
        }
    }
    else{
        frealnameStr = self.headerDataModel.frealname;
    }
    CGSize nameSize = [PMTools sizeWithText:frealnameStr font:LargeFont maxSize:CGSizeMake(100, MAXFLOAT)];
    CGFloat nameX = CGRectGetMaxX(_iconF) + 5;
    CGFloat nameY = iconY;
    _nameF = CGRectMake(nameX, nameY, nameSize.width, nameSize.height);
    
    
    // 3.日期
    CGSize timeSize = [PMTools sizeWithText:self.headerDataModel.fcreatetime font:SmallFont maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    CGFloat timeX = nameX;
    CGFloat timeY = nameY + nameSize.height;
    _timeF = CGRectMake(timeX, timeY, timeSize.width, timeSize.height);
    
    
    // 4.地址
    CGSize addSize = [PMTools sizeWithText:self.headerDataModel.faddress font:LargeFont maxSize:CGSizeMake(160, MAXFLOAT)];
    CGFloat addX = ScreenWidth - addSize.width - padding;
    CGFloat addY = nameY;
    _addF = CGRectMake(addX, addY, addSize.width, nameSize.height);
    
    // 5.单号
    CGSize orderNumSize = [PMTools sizeWithText:[NSString stringWithFormat:@"单号:%@",self.headerDataModel.fordernum] font:SmallFont maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    CGFloat orderNumX = ScreenWidth - orderNumSize.width - padding;
    CGFloat orderNumY = timeY;
    _orderNumF = CGRectMake(orderNumX, orderNumY, orderNumSize.width, orderNumSize.height);
    
    // 6.加急
    CGSize urgentSize;
    CGFloat urgentY = timeY + timeSize.height +  padding;
    if ([PMTools isNullOrEmpty:self.headerDataModel.fremindercount]) {
        self.headerDataModel.fremindercount = @"";
    }
    if ([self.headerDataModel.fremindercount integerValue] != 0) {
        urgentSize = [PMTools sizeWithText:@"加急" font:MiddleFont maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    }
    else{
        urgentSize = CGSizeMake(0, 0);
    }
    _urgentF = CGRectMake(nameX, urgentY + 1, urgentSize.width, urgentSize.height - 2);
    
    // 7.服务内容
    CGSize desSize = [PMTools sizeWithText:self.headerDataModel.fservicecontent font:MiddleFont maxSize:CGSizeMake(ScreenWidth - nameX - urgentSize.width, MAXFLOAT)];
    CGFloat desX = nameX + urgentSize.width;
    if (urgentSize.width != 0) {
        desX += 2;
    }
    CGFloat desY = timeY + timeSize.height +  padding;
    _desF = CGRectMake(desX, desY, desSize.width, desSize.height);
    
    
    NSString * linkStr = [NSString stringWithFormat:@"%@:%@",self.headerDataModel.flinkman,self.headerDataModel.flinkman_phone];
    CGSize linkSize = [PMTools sizeWithText:linkStr font:MiddleFont maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    CGFloat linkX = nameX;
    CGFloat linkY = desY + desSize.height + 2;
    _linkPhoneBtnF = CGRectMake(linkX, linkY, linkSize.width, linkSize.height);
    
    
    // 8.图片列表 （最多三张）
    if (self.headerDataModel.repairs_imag_list.count != 0) {// 有配图
        CGFloat width = 70;
        switch (self.headerDataModel.repairs_imag_list.count) {
                
            case 7:
            case 6:
            case 5:
            case 4:
            case 3:
            {
                CGFloat pictureX = nameX + 2 * padding + 2 * width ;
                CGFloat pictureY = CGRectGetMaxY(_linkPhoneBtnF) +  padding;
                _image3ListF = CGRectMake(pictureX, pictureY, width, width);
            }
                
            case 2:
            {
                CGFloat pictureX = nameX + padding + width;
                CGFloat pictureY = CGRectGetMaxY(_linkPhoneBtnF) +  padding;
                _image2ListF = CGRectMake(pictureX, pictureY, width, width);
            }
                
            case 1:
            {
                CGFloat pictureX = nameX;
                CGFloat pictureY = CGRectGetMaxY(_linkPhoneBtnF) +  padding;
                _image1ListF = CGRectMake(pictureX, pictureY, width, width);
            }
                break;
        }
        
        
    }
    else{
        _image1ListF = CGRectMake(0, CGRectGetMaxY(_linkPhoneBtnF) +  padding , 0, 0);
        _image2ListF = CGRectMake(0, CGRectGetMaxY(_linkPhoneBtnF) +  padding , 0, 0);
        _image3ListF = CGRectMake(0, CGRectGetMaxY(_linkPhoneBtnF) +  padding , 0, 0);
    }
    
    // 9.派单button
    CGFloat sendOrderX = 1.5 * padding;
    CGFloat sendOrderY = CGRectGetMaxY(_image1ListF) + 1.5 * padding;
    CGFloat sendOrderW = 25;
    CGFloat sendOrderH = 25;
    _sendOrdersBtnF = CGRectMake(sendOrderX, sendOrderY, sendOrderW, sendOrderH);
    
    
    // 10.派单状态
    NSString * status = @"";
    NSInteger fstatus = [self.headerDataModel.fstatus integerValue];
//    NSInteger power_type = [[UserManagerTool userManager].power_type integerValue];
    NSInteger power_do = [self.headerDataModel.power_do integerValue];
    NSInteger normal_do = [self.headerDataModel.normal_do integerValue];
    if ([PMTools isNullOrEmpty:self.headerDataModel.deal_worker_id]) {
        self.headerDataModel.deal_worker_id = @"";
    }
    BOOL isMine = [self.headerDataModel.deal_worker_id isEqualToString:[UserManagerTool userManager].worker_id]?YES:NO;
    
    //工单状态 1未处理 2待接单 3正在处理 4处理完成（维修人员） 5结束
    switch (fstatus) {
        case 1:
            
//            break;
            
        case 2:
            if (power_do != 0) {
                status = power_do == 1?@"派单":@"已派";
            }
            break;
            
        case 3:
//            status = isMine ? @"我正在处理":[NSString stringWithFormat:@"%@正在处理",self.headerDataModel.fworkername];
            status = isMine ? @"我正在处理":@"正在处理";
            break;
            
        case 4:
//            status = isMine ? @"我等待评价":[NSString stringWithFormat:@"%@等待评价",self.headerDataModel.fworkername];
            status = isMine ? @"我等待评价":@"等待评价";
            break;
        case 5:
//            status = isMine ? @"我已完成":[NSString stringWithFormat:@"%@已完成",self.headerDataModel.fworkername];
            status = isMine ? @"我已完成":@"已完成";
            break;
            
        case 6:
           
        default:
            break;
    }

    if ([PMTools isNullOrEmpty:status]) {
        status = @"";
    }
    
    CGSize sendStateSize = [PMTools sizeWithText:status font:MiddleFont maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    CGFloat sendStateX = CGRectGetMaxX(_sendOrdersBtnF) + padding;
    CGFloat sendStateY = sendOrderY + 5;
    _sendStateF = CGRectMake(sendStateX, sendStateY, sendStateSize.width, sendStateSize.height);
    
    
    // 11.接受button
    NSString * acceptBtnTitle = @"";
    CGFloat acceptX = 0.0f;
    CGFloat acceptY = sendStateY;
    CGFloat acceptW = 0.0f;
    CGFloat acceptH = 0.0f;
    if ((fstatus == 1 || fstatus == 2) && normal_do == 1) {
        acceptBtnTitle = @"接受";
        acceptX = CGRectGetMaxX(_sendStateF) +padding;
    }
    if ((fstatus == 1 || fstatus == 2)&& normal_do == 0) {
        acceptBtnTitle = @"";
        acceptX = CGRectGetMaxX(_sendStateF) +padding;
    }
    
    if (fstatus == 3 && isMine == YES && normal_do == 2) {
        acceptBtnTitle = @"完成";
        acceptX = CGRectGetMaxX(_sendStateF) +padding;
        
    }
    
    if (fstatus == 4) {
        acceptBtnTitle = @"业主确认中";
        acceptX = ScreenWidth/2 - 50;
    }
    
    if (fstatus == 6) {
        acceptBtnTitle = @"业主已取消";
        acceptX = ScreenWidth/2 - 50;
    }
    
    
    CGSize accesBtnSize = [PMTools sizeWithText:acceptBtnTitle font:SmallFont maxSize:CGSizeMake(200, MAXFLOAT)];
    acceptW = accesBtnSize.width + 10;
    acceptH = accesBtnSize.height + 5;
    
    if (fstatus == 4 || fstatus == 6) {
        acceptX = ScreenWidth/2 - acceptW/2;
    }
    
    if ((fstatus == 1 || fstatus == 2)&& normal_do == 0) {
        acceptW = 0.0f;
        acceptH = 0.0f;
    }
    if (fstatus == 5) {
        acceptW = 20 * 5;
        acceptH = 20;
        acceptX = ScreenWidth/2 - 20 * 2.5 - 15;
    }
    
    _acceptBtnF = CGRectMake(acceptX, acceptY, acceptW, acceptH);
    
    // 12.评论button
    CGFloat commandX = ScreenWidth - padding - 95;
    CGFloat commandY = sendOrderY;
    CGFloat commandW = 25;
    CGFloat commandH = 25;
    _commandBtnF = CGRectMake(commandX, commandY, commandW, commandH);
    
    // 13.评论数量
    CGFloat countH = 12;
    CGFloat countX = commandX + commandW + 2;
    CGFloat countY = commandY + commandH - countH;
    CGFloat countW = 20;
    _countLabelF = CGRectMake(countX, countY, countW, countH);
    
    // 14.详情button
    CGFloat detailBtnX = ScreenWidth - padding -  50;
    CGFloat detailBtnY = commandY;
    CGFloat detailBtnW = 50;
    CGFloat detailBtnH = 25;
    _detailBtnF = CGRectMake(detailBtnX, detailBtnY, detailBtnW, detailBtnH);
    
    

    _cellHeight = CGRectGetMaxY(_detailBtnF) + 2 * padding;

}

@end
