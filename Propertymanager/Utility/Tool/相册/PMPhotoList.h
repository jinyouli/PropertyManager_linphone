//
//  PMPhotoList.h
//  idoubs
//
//  Created by Momo on 16/6/27.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMPhotoList : UIView

//创建相册列表的单例
+ (PMPhotoList *)photoManager;

@property (nonatomic,strong) NSMutableArray * photoArr;

@end
