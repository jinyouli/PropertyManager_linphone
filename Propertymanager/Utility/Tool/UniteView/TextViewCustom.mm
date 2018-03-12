//
//  TextViewCustom.m
//  idoubs
//
//  Created by Momo on 16/6/22.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "TextViewCustom.h"

#define INT_LONG_BASE(x) ((long)x)
#define INT_ULONG_BASE(x) ((unsigned long)x)

@implementation TextViewCustom

@synthesize promptLab,placehLab;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 20)];
        self.textView.delegate = self;
        self.textView.font = LargeFont;
        self.textView.textColor = mainTextColor;
        self.textView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.textView];
        
        placehLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,frame.size.width-10, 20)];
        placehLab.textColor	= lineColor;
        placehLab.font = MiddleFont;
        placehLab.text = @"点击这里输入内容";
        [self.textView addSubview:placehLab];
        
        promptLab = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 20, frame.size.width, 20)];
        promptLab.textAlignment = NSTextAlignmentRight;
        promptLab.backgroundColor = [UIColor clearColor];
        promptLab.font = MiddleFont;
        promptLab.textColor	= lineColor;
        promptLab.text = @"0/100";
        [self addSubview:promptLab];
        
        [self viewdidload];
    }
    return self;
}



- (void)viewdidload{

    _textLength = 100;
    _interception = NO;
    
    _placehTextColor = lineColor;
    _placehFont = LargeFont;
    _placehText = @"";
    
    _promptLabHiden = NO;
    _promptFrameMaxX = 10.0;
    _promptFrameMaxY = 0.0;
    _promptTextColor = lineColor;
    _promptFont = MiddleFont;
    _promptBackground = self.backgroundColor;
    
    

    
}

#pragma mark - 设置文本长度
- (void)setTextLength:(NSInteger)textLength{
    _textLength = textLength;
    
    promptLab.text = [NSString stringWithFormat:@"0/%ld",(long)_textLength];
    
    self.textView.scrollEnabled = YES;
    self.textView.contentInset = UIEdgeInsetsMake(self.textView.contentInset.top, self.textView.contentInset.left, CGRectGetHeight(promptLab.frame)+_promptFrameMaxY, self.textView.contentInset.right);
}

#pragma mark - 设置默认提示
- (void)setPlacehTextColor:(UIColor *)placehTextColor{
    _placehTextColor = placehTextColor;
    placehLab.textColor = _placehTextColor;
}
- (void)setPlacehFont:(UIFont *)placehFont{
    _placehFont = placehFont;
    placehLab.font = _placehFont;
}
- (void)setPlacehText:(NSString *)placehText{
    _placehText = placehText;
    placehLab.text = _placehText;
//    [placehLab sizeToFit];
}

#pragma mark - 设置文字计数
- (void)setPromptFrameMaxX:(CGFloat)promptFrameMaxX{
    _promptFrameMaxX = promptFrameMaxX;
}
- (void)setPromptFrameMaxY:(CGFloat)promptFrameMaxY{
    _promptFrameMaxY = promptFrameMaxY;

}
- (void)setPromptTextColor:(UIColor *)promptTextColor{
    _promptTextColor = promptTextColor;
    promptLab.textColor = _promptTextColor;
}
- (void)setPromptFont:(UIFont *)promptFont{
    _promptFont = promptFont;
    promptLab.font = _promptFont;
    
    

}
- (void)setPromptBackground:(UIColor *)promptBackground{
    _promptBackground = promptBackground;
    promptLab.backgroundColor = _promptBackground;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    placehLab.hidden = YES;
//    if (self.textView.text.length == 0) {
//        placehLab.hidden = NO;
//    }else{
//        placehLab.hidden = YES;
//    }

    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView{//编辑结束
    
}

-(void)textViewDidChange:(UITextView *)textView{//编辑中
    if (self.textView.text.length == 0) {
        placehLab.hidden = NO;
        
    }else{
        placehLab.hidden = YES;
    }
    
    NSString *toBeString = self.textView.text;
    NSString *primaryLanguageStr = self.textInputMode.primaryLanguage; // 键盘输入模式
    if ([primaryLanguageStr isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [self.textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [self.textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > _textLength) {
                self.textView.text = [toBeString substringToIndex:_textLength];
                [self changePromptLab];
            }else{
                [self changePromptLab];
            }
        }else{
            // 有高亮选择的字符串，则暂不对文字进行统计和限制
        }
    }else{
        // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > _textLength) {

            self.textView.text = [toBeString substringToIndex:_textLength];
            [self changePromptLab];
        }else{
            [self changePromptLab];
        }
    }
    
    if (self.EditChangedBlock) {//一个词语输出监听
        self.EditChangedBlock();
    }
}
- (void)changePromptLab{
    
    CGSize maxSize = [PMTools sizeWithText:self.textView.text font:self.textView.font maxSize:CGSizeMake(self.frame.size.width, 500)];
    
    NSString *changeStr = [NSString stringWithFormat:@"%ld/%ld",(unsigned long)self.textView.text.length,(long)_textLength];
    promptLab.text = changeStr;
    

}

-(void)dealloc{
    
    if (self.EditChangedBlock) {
        self.EditChangedBlock = nil;
    }
}

@end
