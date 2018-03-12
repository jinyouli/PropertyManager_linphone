//
//  EntranceView.h
//  PropertyManager
//
//  Created by Momo on 16/9/13.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ReturnSelectIndex)(NSInteger tag);

@interface EntranceView : UIView
{
    NSString * _domain_sn;
}
-(instancetype)initWithFrame:(CGRect)frame withDomain:(NSString *)domain_sn sipNum:(NSString *)sipNum;
@property (nonatomic,strong) NSString * domain_sn;
@property (nonatomic,strong) NSString * plotName;
@property (nonatomic,strong) NSString * sipNum;

@property (nonatomic,copy) ReturnSelectIndex block;
-(void)returnSelectIndex:(ReturnSelectIndex)block;

@end
