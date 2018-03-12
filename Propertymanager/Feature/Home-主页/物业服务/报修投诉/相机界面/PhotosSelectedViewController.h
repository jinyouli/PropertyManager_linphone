//
//  PhotosSelectedViewController.h
//  PropertyManager
//
//  Created by Momo on 16/8/19.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "BaseViewController.h"

@interface PhotosSelectedViewController : BaseViewController
{
    NSMutableArray *_selectedAssets;
}
@property (nonatomic,strong) NSMutableArray *selectedPhotos;
@property (nonatomic,strong) NSMutableArray *selectedAssets;

-(void)pushImagePickerController;

@end
