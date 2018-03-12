//
//  ZYTextField.m
//  ZYDoubs
//
//  Created by Momo on 17/1/12.
//  Copyright © 2017年 Momo. All rights reserved.
//

#import "ZYTextField.h"

@interface ZYTextField ()

/** tag */
@property (nonatomic,assign) NSInteger tag;

@end

@implementation ZYTextField


- (instancetype) initWithPlaceText:(NSString *)placeText font:(UIFont *)fieldFont tag:(NSInteger)tag{
    if (self = [super init]) {
        
        
        if (placeText) {
            self.placeholder = placeText;
        }
        
        self.text = @"";
        
        if (fieldFont) {
            self.font = fieldFont;
        }
        
        self.tag = 0;
        if (tag) {
            self.tag = tag;
        }
        
        
        [self addTarget:self action:@selector(textFieldValueChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

-(void)textFieldValueChange:(UITextField *)textField{
    
    if (self.block) {
        self.block(self.tag,self.text);
    }
}

@end
