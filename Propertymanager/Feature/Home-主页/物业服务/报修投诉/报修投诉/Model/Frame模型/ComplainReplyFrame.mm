//
//  ComplainReplyFrame.m
//  idoubs
//
//  Created by Momo on 16/6/30.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "ComplainReplyFrame.h"

@implementation ComplainReplyFrame

-(void)setReplyDataModel:(ComplainReplyDataModel *)replyDataModel{
    
    _replyDataModel = replyDataModel;
    
    // 子控件之间的间距
    CGFloat padding = 10;
    
    // 1.头像
    CGFloat iconX = padding * 1.5;
    CGFloat iconY = padding;
    CGFloat iconW = 25;
    CGFloat iconH = 25;
    _iconF = CGRectMake(iconX, iconY, iconW, iconH);
    
    
    // 2.日期
    CGSize timeSize = [PMTools sizeWithText:_replyDataModel.fcreatetime font:SmallFont maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    CGFloat timeX = CGRectGetMaxX(_iconF) + 0.5*padding;
    CGFloat timeY = iconY + padding - 5;
    _timeF = CGRectMake(timeX, timeY, timeSize.width, timeSize.height);
    
    // 3.回复名字
    NSInteger type = [self.replyDataModel.ftype integerValue];
    NSString * name = @"";
    CGSize nameSize;
    
        if (type == 4 || type == 5 || type == 6 || type == 7) {
            name = @"工单动态";
            nameSize = [PMTools sizeWithText:[NSString stringWithFormat:@"%@:",name] font:MiddleFont maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
//            nameSize = CGSizeMake(80, 20);
        }
        else{
            
            if (![PMTools isNullOrEmpty:_replyDataModel.name]) {
                name = _replyDataModel.name;
                nameSize = [PMTools sizeWithText:[NSString stringWithFormat:@"%@:",name] font:MiddleFont maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
            }
            else{
                nameSize = CGSizeZero;
            }
        }

    
    CGFloat nameX = timeX;
    CGFloat nameY = timeY + timeSize.height + 2;
    _nameF = CGRectMake(nameX, nameY, nameSize.width, nameSize.height);
    
    // 4.服务内容
    //类型 1表示工单回复，2表示工单评论，3表示处理人提醒转单记录，4表示派单人转单记录 5表示完成订单信息记录，6表示用户返单
    //@property (nonatomic,strong) NSString * ftype;
    
    
    
    
    NSString * content = @"";
    NSString * replyDataModelName = @"";
    if (![PMTools isNullOrEmpty:_replyDataModel.name]) {
        replyDataModelName = _replyDataModel.name;
    }
    
    if (type == 1 || type == 2) {
        content = _replyDataModel.fcontent;
    }
    else if (type == 3){
        if ([PMTools isNullOrEmpty:self.replyDataModel.fcontent]) {
            
            content = @"提醒转派工单申请。";
        }
        else{
            content = [NSString stringWithFormat:@"提醒转派工单申请,原因%@。",_replyDataModel.fcontent];
        }
        
    }
    else if (type == 4){
        if ([PMTools isNullOrEmpty:self.replyDataModel.fcontent]) {
            content = [NSString stringWithFormat:@"该工单(%@号)处理人已有[%@]变更为[%@]",_replyDataModel.ID,_replyDataModel.old_name,_replyDataModel.nMyName1];
        }
        else{
            NSLog(@"原先==%@,%@",_replyDataModel.nMyName1,self.replyDataModel.fcontent);
            content = [NSString stringWithFormat:@"该工单(%@号)处理人已有[%@]变更为[%@],原因%@",_replyDataModel.ID,_replyDataModel.old_name,_replyDataModel.nMyName1,self.replyDataModel.fcontent];
        }
        
    }
    else if (type == 5){
        
        if ([PMTools isNullOrEmpty:self.replyDataModel.fcontent]) {
            content = [NSString stringWithFormat:@"工单已由[%@]完成。",replyDataModelName];
        }
        else{
            content = [NSString stringWithFormat:@"工单已由[%@]完成，完成原因%@",replyDataModelName,_replyDataModel.fcontent];
        }
//        _nameF = CGRectMake(nameX, nameY, 0, 0);
    }
    else if (type == 6){
        
        if ([PMTools isNullOrEmpty:self.replyDataModel.fcontent]) {
            content = [NSString stringWithFormat:@"工单(%@号)已由[%@]返回。",_replyDataModel.ID,replyDataModelName];
        }
        else{
            content = [NSString stringWithFormat:@"工单(%@号)已由[%@]返回，返回原因%@",_replyDataModel.ID,replyDataModelName,_replyDataModel.fcontent];
        }
        
    }
    else if (type == 7){

        if ([PMTools isNullOrEmpty:self.replyDataModel.fcontent]) {
            content = [NSString stringWithFormat:@"工单(%@号)已由业主%@取消。",_replyDataModel.ID,replyDataModelName];
        }
        else{
            content = [NSString stringWithFormat:@"工单(%@号)已由业主%@取消，取消原因%@",_replyDataModel.ID,replyDataModelName,_replyDataModel.fcontent];
        }
        
    }
    CGSize desSize;
    CGFloat desX = nameX + _nameF.size.width + 2;
    CGFloat desY = nameY;
    desSize = [PMTools sizeWithText:content font:MiddleFont maxSize:CGSizeMake(ScreenWidth - desX - 10, MAXFLOAT)];
    
    _desF = CGRectMake(desX, desY, desSize.width, desSize.height < nameSize.height ? nameSize.height : desSize.height);
    
    
    
    
    
    // 5.图片列表 （最多三张）
    NSArray * imgArr = _replyDataModel.reply_imag_list;
//    NSLog(@"imgArr ==== %@",imgArr);
    CGFloat pictureY = CGRectGetMaxY(_desF) + padding;
    _image1ListF = CGRectMake(0, pictureY , 0, 0);
    _image2ListF = CGRectMake(0, pictureY , 0, 0);
    _image3ListF = CGRectMake(0, pictureY , 0, 0);
    
    if (imgArr.count != 0) {// 有配图
        CGFloat width = 70;
        switch (imgArr.count) {
            case 11:
            case 10:
            case 9:
            case 8:
            case 7:
            case 6:
            case 5:
            case 4:
            case 3:
            {
                CGFloat pictureX = nameX + 2 * padding + 2 * width ;
                _image3ListF = CGRectMake(pictureX, pictureY, width, width);
            }
                
            case 2:
            {
                CGFloat pictureX = nameX + padding + width;
                _image2ListF = CGRectMake(pictureX, pictureY, width, width);
            }
                
            case 1:
            {
                CGFloat pictureX = nameX;
                _image1ListF = CGRectMake(pictureX, pictureY, width, width);
            }
                break;
        }
        
        
    }

    
    
    _replyCellHeight = CGRectGetMaxY(_image1ListF) + padding;
}


@end
