//
//  PlotWebViewController.m
//  idoubs
//
//  Created by Momo on 16/7/18.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "PlotWebViewController.h"

@interface PlotWebViewController ()

@property (strong, nonatomic) UITextView *textView;

@end

@implementation PlotWebViewController

#pragma mark - 使用Routable必须实现该方法
- (id)initWithRouterParams:(NSDictionary *)params {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        
        if (![PMTools isNullOrEmpty:params[@"myTitle"]]) {
            self.myTitle = params[@"myTitle"];
        }
        
        if (![PMTools isNullOrEmpty:params[@"myURLStr"]]) {
            self.myURLStr = params[@"myURLStr"];
        }
    }
    return self;
}

-(void)dealloc{
    SYLog(@" PlotWebViewController  dealloc");
    self.view = nil;
    self.textView = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createLeftBarButtonItemWithTitle:self.myTitle];
    
    self.textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64)];
    self.textView.editable = NO;
    [self.view addSubview:self.textView];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self request];
    });
    
}

-(void)request{

    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:self.myURLStr]];
        [request setHTTPMethod:@"GET"];
        NSHTTPURLResponse * urlResponse = nil;
        NSError * error = nil;
        NSData * receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        
        NSString * results = [[NSString alloc]initWithBytes:[receivedData bytes] length:[receivedData length] encoding:NSUTF8StringEncoding];
        
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:receivedData options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        if ( attrStr == nil) {
            NSScanner * scanner = [NSScanner scannerWithString:results];
            NSString * text = nil;
            while([scanner isAtEnd]==NO)
            {
                //找到标签的起始位置
                [scanner scanUpToString:@"<" intoString:nil];
                //找到标签的结束位置
                [scanner scanUpToString:@">" intoString:&text];
                //替换字符
                results = [results stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
            }
            attrStr = [[NSAttributedString alloc] initWithData:[results dataUsingEncoding:NSUTF8StringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        }
        [attrStr enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attrStr.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value) {
                NSTextAttachment *ment = value;
                CGRect rect = ment.bounds;
                CGFloat bili = 0;
                if (rect.size.width > [UIScreen mainScreen].bounds.size.width) {
                    bili = ([UIScreen mainScreen].bounds.size.width - 10) / rect.size.width;
                }else {
                    bili = rect.size.width / ([UIScreen mainScreen].bounds.size.width - 10);
                }
                
                rect.size = CGSizeMake([UIScreen mainScreen].bounds.size.width - 10, rect.size.height * bili);
                ment.bounds = rect;
            }
            
        }];
        
        
        
        _textView.attributedText = attrStr;
        _textView.contentOffset = CGPointMake(0, -5);
    });

    
    

}



@end
