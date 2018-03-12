//
//  Common.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/6/27.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "Common.h"
#import "MBProgressHUD.h"
#import "iToast.h"

@interface Common ()
@end

@implementation Common

+ (BOOL)isLandScap
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    return bounds.size.width > bounds.size.height;
}

+ (void)addAlertWithTitle:(NSString*)string
{
    //[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]]
    
    if (string.length > 0) {
        iToastSettings *theSettings = [iToastSettings getSharedSettings];
        [theSettings setDuration:iToastDurationNormal];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[iToast makeText:string] show];
        });
    }
}

+ (void)showMessageWithContent:(NSString *)msg duration:(NSTimeInterval)duration view:(UIView*)addView{
    
    for (UIView *subview in addView.subviews) {
        if ([subview isKindOfClass:[MBProgressHUD class]]) {
            [subview removeFromSuperview];
        }
    }
    
    MBProgressHUD *progressHud = [[MBProgressHUD alloc] initWithView:addView];
    [addView addSubview:progressHud];
    progressHud.label.text = msg;
    
    [progressHud showAnimated:YES];
}

+ (void)showAlert:(UIView*)hubview alertText:(NSString*)text afterDelay:(NSTimeInterval)delay
{
    MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:hubview animated:YES];
    hub.mode = MBProgressHUDModeText;
    hub.label.text = text;
    [hub hideAnimated:YES afterDelay:delay];
}

+ (BOOL)isIncludeSpecialCharact: (NSString *)str {
    
    NSCharacterSet *nameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"@／：；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+"];
    
    NSRange userNameRange = [str rangeOfCharacterFromSet:nameCharacters];
    
    if (userNameRange.location != NSNotFound) {
        return YES;
    }
    return NO;
}

+ (NSString *) parseByteArray2HexString:(Byte[]) bytes length:(NSUInteger)length
{
    NSMutableString *hexStr = [[NSMutableString alloc]init];
    
    int i = 0;
    if(bytes)
    {
        while (i<length)
        {
            NSString *hexByte = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];///16进制数
            
            if([hexByte length]==1)
                [hexStr appendFormat:@"0%@", hexByte];
            else
                [hexStr appendFormat:@"%@", hexByte];
            i++;
        }
    }
    
    return hexStr;
}

//将16进制的字符串转换成NSData
+ (NSMutableData *)convertHexStrToData:(NSString *)str {
    
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    
    if ([str length] %2 == 0) {
        range = NSMakeRange(0,2);
        
    } else {
        range = NSMakeRange(0,1);
    }
    
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

+ (NSInteger)getNowTimestamp{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间
    NSInteger timeSp = [[NSNumber numberWithDouble:[datenow timeIntervalSince1970]] integerValue];
    return timeSp;
}

//生成二维码
+ (UIImage *)encodeQRImageWithContent:(NSString *)content size:(CGSize)size {
    UIImage *codeImage = nil;
    
        NSData *stringData = [content dataUsingEncoding: NSUTF8StringEncoding];
        
        //生成
        CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [qrFilter setValue:stringData forKey:@"inputMessage"];
        [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
        
        UIColor *onColor = [UIColor blackColor];
        UIColor *offColor = [UIColor whiteColor];
        
        //上色
        CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                           keysAndValues:
                                 @"inputImage",qrFilter.outputImage,
                                 @"inputColor0",[CIColor colorWithCGColor:onColor.CGColor],
                                 @"inputColor1",[CIColor colorWithCGColor:offColor.CGColor],
                                 nil];
        
        CIImage *qrImage = colorFilter.outputImage;
        CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
        UIGraphicsBeginImageContext(size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
        codeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGImageRelease(cgImage);
    
    return codeImage;
}

+ (void)showAlert:(NSString*)msg
{
    if (msg.length > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

+ (UIViewController*)topViewController
{
    return[self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController

{
    if([rootViewController isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController*tabBarController = (UITabBarController*)rootViewController;
        
        return[self topViewControllerWithRootViewController:tabBarController.selectedViewController];
        
    }else if([rootViewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        
        return[self topViewControllerWithRootViewController:navigationController.visibleViewController];
        
    }else if(rootViewController.presentedViewController) {
        
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        
        return[self topViewControllerWithRootViewController:presentedViewController];
        
    }else{
        
        return rootViewController;
        
    }
}

@end
