//
//  PMTools.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "PMTools.h"
#define kStringEmpty	@""
#import "KeyChainStore.h"
#import "MediaContent.h"
#import "MediaSessionMgr.h"
#import "tsk_base64.h"


#import "AppDelegate.h"
// Credentials

static BOOL kEnableEarlyIMS = TRUE;

@implementation PMTools

+ (NSString*)FilteSQLStr:(NSString *)originStr{
    return [originStr stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
}

//判断当前是否可以连接到网络
+ (BOOL)connectedToNetwork{
    
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags) {
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    BOOL nonWifi = flags & kSCNetworkReachabilityFlagsTransientConnection;
    BOOL moveNet = flags & kSCNetworkReachabilityFlagsIsWWAN;
    
    return ((isReachable && !needsConnection) || nonWifi || moveNet) ? YES : NO;
}

//正则表达式判断手机号
+ (BOOL)isPhoneNumber:(NSString *)phoneNumber{
    
//    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
//    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
//    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
//    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
//    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
//    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
//    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
//    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
//    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
//    if (([regextestmobile evaluateWithObject:phoneNumber] == YES)
//        || ([regextestcm evaluateWithObject:phoneNumber] == YES)
//        || ([regextestct evaluateWithObject:phoneNumber] == YES)
//        || ([regextestcu evaluateWithObject:phoneNumber] == YES))
//    {
//        return YES;
//    }
//    else
//    {
//        return NO;
//    }

    NSString * allPhone = @"^((13[0-9])|(15[^4,\\D])|(18[0-9])|(14[0-9])|(17[0-9]))\\d{8}$";
    NSPredicate *regextestallPhone = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", allPhone];
    if ([regextestallPhone evaluateWithObject:phoneNumber] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }

}

//拨打电话
+ (void)callPhoneNumber:(NSString *)phoneNum inView:(UIView *)view{
    NSString *callingPhoneNum = [NSString stringWithFormat:@"tel:%@",phoneNum];
    UIWebView *callWebView;
    if (!callWebView) {
        callWebView = [[UIWebView alloc]init];
        [view addSubview:callWebView];
    }
    [callWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:callingPhoneNum]]];
}

/** 获取当前页*/
+ (UIViewController *)getCurrentVC{
    //获取当前的控制器
    MyRootViewController * rootVC = (MyRootViewController *)[AppDelegate sharedInstance].window.rootViewController;
    UINavigationController * nav = rootVC.midViewController;
    UIViewController * modalViewController = [nav.viewControllers lastObject];
    return modalViewController;
}

//判断token是否有效，
+(BOOL)checkVaildToken{
    
    return YES;
}

+(BOOL)isNullOrEmpty:(id)string{
    
    if ([string isKindOfClass:[NSString class]] ) {
        return string == nil || string==(id)[NSNull null] || [string isEqualToString: kStringEmpty] || [string isEqualToString: @"<null>"] || [string isEqualToString: @"(null)"];
    }
    if ([string isKindOfClass:[NSArray class]]) {
        return string == nil || string==(id)[NSNull null] || ((NSArray *)string).count == 0;
    }
    if ([string isKindOfClass:[NSNumber class]]) {
        return string == nil || string==(id)[NSNull null] ;
    }
    else
        return string == nil || string==(id)[NSNull null];
}

+(NSString *)getUUID
{
    NSString * strUUID = (NSString *)[KeyChainStore load:@"com.company.app.usernamepassword"];
    
    //首次执行该方法时，uuid为空
    if ([PMTools isNullOrEmpty:strUUID])
    {
        //生成一个uuid的方法
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        
        //将该uuid保存到keychain
        [KeyChainStore save:KEY_USERNAME_PASSWORD data:strUUID];
        
        //add start
        CFRelease(uuidRef);
        // end by zy
    }
    return strUUID;
}

+ (UIColor *)colorFromHexRGB:(NSString *)inColorString
{
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); // masks off high bits
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte/ 0xff
              blue: (float)blueByte / 0xff
              alpha:1.0];
    return result;
}

+(BOOL)isHaveIllegalChar:(NSString *)str
{
    if ([PMTools isNullOrEmpty:str]) {
        str = @"";
    }
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"[]{}（#%-*+=_）\\|~(＜＞$%^&*)_+ "];
    NSRange range = [str rangeOfCharacterFromSet:doNotWant];
    return range.location<str.length;
}

/**
 *  计算文字尺寸
 *
 *  @param text    需要计算尺寸的文字
 *  @param font    文字的字体
 *  @param maxSize 文字的最大尺寸
 */
+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize
{
    if ([PMTools isNullOrEmpty:text]) {
        return CGSizeZero;
    }
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

//json串转换为字典
+(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        SYLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+(NSString *)subStringFromString:(NSString *)str isFrom:(BOOL)isFrom{
    if ([PMTools isNullOrEmpty:str]) {
        return @"";
    }
    else{
        NSInteger length = str.length;
        if (!isFrom) {
            //To
            if (length > 2) {
                return [str substringToIndex:2];
            }
            else{
                return str;
            }
        }
        else{
            
            if (length > 2) {
                return [str substringFromIndex:length - 2];
            }
            else{
                return str;
            }
        }
        
        
    }
}

/**
 版本更新
 */
+ (void) updateVersion{
    

    //AppStore里的版本
    NSString * url = @"https://itunes.apple.com/lookup?id=1138808109";
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    NSHTTPURLResponse * urlResponse = nil;
    NSError * error = nil;
    NSData * receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers error:nil];
    NSArray * appStoreInfoArr = [dic objectForKey:@"results"];
    
    if (appStoreInfoArr.count != 0) {
        
        NSString * versionStr =[[[dic objectForKey:@"results"] objectAtIndex:0] valueForKey:@"version"];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString * localVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
        
        //以"."分隔数字然后分配到不同数组
        NSArray * serverArray = [versionStr componentsSeparatedByString:@"."];
        NSArray * localArray = [localVersion componentsSeparatedByString:@"."];
        
        for (int i = 0; i < serverArray.count; i++) {
            
            //以服务器版本为基准，判断本地版本位数小于服务器版本时，直接返回（并且判断为新版本，比如服务器1.5.1 本地为1.5）
            if(i > (localArray.count -1)){
                //有新版本，提示！
//                [self showUpdateView:versionStr withViewController:viewController];
                [WJYAlertView showTwoButtonsWithTitle:@"更新通知" Message:@"有新的版本更新，是否前往更新？" ButtonType:WJYAlertViewButtonTypeNone ButtonTitle:@"更新" Click:^{
                    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/cn/app/you-lin-bang/id1138808109?mt=8"];
                    [[UIApplication sharedApplication]openURL:url];
                } ButtonType:WJYAlertViewButtonTypeNone ButtonTitle:@"关闭" Click:^{
                    
                }];
                break;
            }
            
            //有新版本，服务器版本对应数字大于本地
            if ( [serverArray[i] intValue] > [localArray[i] intValue]) {
                //有新版本，提示！
//                [self showUpdateView:versionStr withViewController:viewController];
                [WJYAlertView showTwoButtonsWithTitle:@"更新通知" Message:@"有新的版本更新，是否前往更新？" ButtonType:WJYAlertViewButtonTypeNone ButtonTitle:@"更新" Click:^{
                    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/cn/app/you-lin-bang/id1138808109?mt=8"];
                    [[UIApplication sharedApplication]openURL:url];
                } ButtonType:WJYAlertViewButtonTypeNone ButtonTitle:@"关闭" Click:^{
                    
                }];
                break;
            }
        }

    }
    

}


+ (void) removeSelectsPhotos{
    
    [[AppDelegate sharedInstance].photosSelectedViewController.selectedPhotos removeAllObjects];
    [[AppDelegate sharedInstance].photosSelectedViewController.selectedAssets removeAllObjects];
}


@end
