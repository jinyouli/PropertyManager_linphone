//
//  AppDelegate.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//

#import "AppDelegate.h"

#import "Reachability.h"  //网络监听
#import "GeTuiSdk.h"
#import "iflyMSC/IFlySpeechUtility.h" //讯飞
#import "Definition.h"
#import "AppDelegate+Private.h"
#import "AppDelegate+SipCallback.h"
#import "AppDelegate+SipBackground.h"
#import "AppDelegate+Notification.h"

#import "HomeViewController.h"  //首页
#import "LoginViewController.h" //登录页
#import "SettingViewController.h" //设置页
#import "ShareMyAppViewController.h"//分享页面
#import "AboutMyAppViewController.h" //关于页面
#import "OwnerViewController.h" //业主详情页
#import "ResetPasswordViewController.h" //重设密码
#import "DNDViewController.h"   //勿扰模式
#import "NewsNoticeSettingViewController.h"//消息设置
#import "ChangePasswordViewController.h" //修改密码
#import "VesionInfoViewController.h" //版本信息
#import "ForgetPasswordViewController.h" // 忘记密码
#import "MyNewsChatViewController.h" //信息列表
#import "SearchLockViewController.h" //门禁
#import "ApplyViewController.h"//应用
#import "PlotViewController.h"//小区
#import "RepairsViewController.h" //报修投诉页
#import "A_ZTableViewController.h"//联系人列表
#import "ProOrderNewsViewController.h" //订单详情消息
#import "OrderCommandViewController.h" //点击评论
#import "AcceptOrderViewController.h"  //接受订单页面
#import "SendOrderViewController.h" //派单界面
#import "CompleteOrderViewController.h" //完成订单页面
#import "MoreHistroyCommandViewController.h" //更多历史记录
#import "PlotCellDetailViewController.h"//小区消息详情
#import "PlotWebViewController.h" //小区网页
#import "SendOrderCauseViewController.h"//转单原因
#import "GroupTableViewController.h"//分组列表
#import "PhoneHistTableViewController.h"//拨号历史记录
#import "ClauseViewController.h"//条款页面
#import "UntreatedTableViewController.h"
#import "MyProcessingTableViewController.h"
#import "ProcessingTableViewController.h"
#import "MyCompletedTableViewController.h"
#import "CompletedTableViewController.h"
#import "UMMobClick/MobClick.h"


#define USHARE_DEMO_APPKEY @"57690fd167e58eeedf00206b"

@interface AppDelegate ()<GeTuiSdkDelegate,SYLinphoneDelegate>
@property (nonatomic,assign) BOOL isCallComing; //只显示一个门口机呼过来页面
@property (nonatomic,assign) SYLinphoneCall *currentCall;   //当前呼叫的call
@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"上一次的登录==%@,%@",userLoginUsername,userPassword);
    SYLog(@"登录二级 ScoendLocalhost === %@,%@",FirstLocalhost,ScoendLocalhost);
    
    //[[NSUserDefaults standardUserDefaults] setObject:@"123" forKey:@"token"];
    // 初始化注册sip次数
    self.sipRegCount = 0;
    
    // 已经登录过 并且退到后台被挂起的时候运行一次登录 重新获取token
    if (![PMTools isNullOrEmpty:userToken] && ![PMTools isNullOrEmpty:userLoginUsername] && ![PMTools isNullOrEmpty:userPassword]) {
        NSLog(@"已经登录过 并且退到后台被挂起的时候运行一次登录 重新获取token");
        [PMTokenTools gainNewToken];
    }
    
    if ([PMTools isNullOrEmpty:clientID]) {
        //个推
        [self regiestGeTui];
    }
    
    //讯飞
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",APPID_VALUE];
    [IFlySpeechUtility createUtility:initString];

    //根控制器
    [self setmanagerRootVC];

    //检查更新
//    [PMTools updateVersion];
    
    //开启网络状况的监听
    [self MyNetReachability];

    // idoubs 注册通知
    [self registNotification];
    
    [self configLinphone];

    // idoubs 后台运行
    [self didFinishLaunchingWithOptions];
    [self setupUM];
    
   // [self getDeviceInfo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendLocalMessage:) name:@"getNewMessage" object:nil];
    
    [self createDataBase];
    //[DetailRequest loginBtnClickWithPhone:userLoginUsername password:userPassword isFirstLogin:NO];
    return YES;
}

- (void)createDataBase
{
    NSArray *userArray = [NSArray arrayWithObjects:@"user",@"time",@"message",@"state",@"myName",@"otherName", nil];
    [[MyFMDataBase shareMyFMDataBase] createDataBaseWithDataBaseName:@"PersonCall"];
    [[MyFMDataBase shareMyFMDataBase] createTableWithTableName:@"PersonCall" tableArray:userArray];
    
    //勿扰模式列表
    [[MyFMDataBase shareMyFMDataBase] createDataBaseWithDataBaseName:DontDisturbInfo];
    [[MyFMDataBase shareMyFMDataBase] createTableWithTableName:DontDisturbInfo tableArray:DontDisturbInfoDic];
}

- (void)sendLocalMessage:(NSNotification *)notif
{
    NSLog(@"[notif userInfo] == %@",[notif userInfo]);
    if (![[PMTools getCurrentVC] isKindOfClass:[MyNewsChatViewController class]]) {
        int state = [[notif userInfo][@"state"] intValue];
        if (state == 2) {
            UILocalNotification *localNote = [[UILocalNotification alloc] init];
            localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
            localNote.alertBody = [notif userInfo][@"message"];
            localNote.soundName = UILocalNotificationDefaultSoundName;
            localNote.applicationIconBadgeNumber = 1;
            localNote.userInfo = @{@"type":@"localMessage",@"sipNumber":[notif userInfo][@"sipNumber"],@"message":[notif userInfo][@"message"]};
            [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
        }
    }
}



#pragma mark - 友盟
- (void)setupUM
{

    UMConfigInstance.appKey = USHARE_DEMO_APPKEY;
    UMConfigInstance.ePolicy = BATCH;
    [MobClick startWithConfigure:UMConfigInstance];
    
    //[MobClick profileSignInWithPUID:@"playerID"];
    //[MobClick setLogEnabled:YES];
}

#pragma mark - linphone 初始化
- (void)configLinphone{
    
    [[SYLinphoneManager instance] startSYLinphonephone];
    [SYLinphoneManager instance].nExpires = 120 * 60;
    [SYLinphoneManager instance].ipv6Enabled = NO;
    [SYLinphoneManager instance].videoEnable = YES;
    [[SYLinphoneManager instance] setDelegate:self];
}

#pragma mark - 注册个推
-(void)regiestGeTui{

    [GeTuiSdk runBackgroundEnable:YES]; // 是否允许APP后台运行
    [GeTuiSdk resetBadge];

    SYLog(@"注册个推");
    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
    [self registerRemoteNotification];
    [GeTuiSdk setPushModeForOff:NO];
}




#pragma mark - 开启网络监听
-(void)MyNetReachability{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    Reachability *hostReach =[Reachability reachabilityWithHostName:@"www.google.com"];//可以以多种形式初始化
    [hostReach startNotifier]; //开始监听,会启动一个run loop
    [self updateInterfaceWithReachability: hostReach];
}

- (void)reachabilityChanged: (NSNotification*)note
{
    Reachability*curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}


//处理连接改变后的情况
- (void)updateInterfaceWithReachability: (Reachability*)curReach
{
    //对连接改变做出响应的处理动作。
    
    NetworkStatus status=[curReach currentReachabilityStatus];
    
    if(status != NotReachable)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Reachable" object:nil];
    } else if (status== NotReachable) {

        //停止刷新等
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotReachable" object:nil];
    }
}


#pragma mark - 设置根页面
-(void)setmanagerRootVC{
    
    if ([MyUserDefaults boolForKey:@"initializeFlag"]) {
        if (!FirstLocalhost) {
            [MyUserDefaults setObject:SYFirIP forKey:@"firLocalhost"];
        }
        
        UIViewController * vc = self.window.rootViewController;
        if ([PMTools isNullOrEmpty:userToken]) {

            [PMSipTools sipUnRegister];
            [self loginVCOrRootVC:YES];
        }
        else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //个推
                [self regiestGeTui];
                //获取七牛凭证
                [DetailRequest getQiNiuToken];
            });
            [self loginVCOrRootVC:NO];
        }
        [vc removeFromParentViewController];
        vc.view = nil;
        
    } else {
        
        [self setInitializeStandardUserDefaults];
        [self loginVCOrRootVC:YES];
    }
}

#pragma mark - 选择根视图
- (void) loginVCOrRootVC:(BOOL)ret{
    
    if (ret) {
        // 登录页面
        LoginViewController * loginVC = [[LoginViewController alloc]init];
        [self setupRouter];
        
        UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:loginVC];
        nav.navigationBar.backgroundColor = mainColor;
        nav.navigationBar.translucent = NO;
        nav.navigationBar.barTintColor = mainColor;
        [nav.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [nav.navigationBar setShadowImage:[UIImage new]];
        
        [[Routable sharedRouter] setNavigationController:nav];
        
        self.window.rootViewController = nav;
        self.window.backgroundColor = MYColor(220, 220, 220);
        [self.window makeKeyAndVisible];
    }
    else{
        [self setupRouter];
        MyRootViewController * rootVC = [[MyRootViewController alloc]init];
        [[Routable sharedRouter] setNavigationController:rootVC.midViewController];
        self.window.rootViewController = rootVC;
        [self.window makeKeyAndVisible];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideHub" object:nil];
    }
}

#pragma mark - 初始化偏好设置
-(void)setInitializeStandardUserDefaults{
    
    // 初始化
    [MyUserDefaults setBool:YES forKey:@"initializeFlag"];
    //一级平台
//    [MyUserDefaults setObject:SYFirIP forKey:@"firLocalhost"];
//    // 二级平台
//    [MyUserDefaults setObject:KMyScoendLocalhost forKey:@"scoendLocalhost"];
    
    // 声音
    [MyUserDefaults setBool:YES forKey:AllSoundOpen];
    [MyUserDefaults setBool:YES forKey:NewsSoundOpen];
    [MyUserDefaults setBool:YES forKey:OrdersSoundOpen];
    
    [MyUserDefaults setBool:YES forKey:AllShakeOpen];
    [MyUserDefaults setBool:YES forKey:NewsShakeOpen];
    [MyUserDefaults setBool:YES forKey:OrdersShakeOpen];
}



//有来电
- (void)onIncomingCall:(SYLinphoneCall *)call withState:(SYLinphoneCallState)state withMessage:(NSDictionary *)message withIsVideo:(BOOL)isVideo{
    
    UserManager * user = [UserManagerTool userManager];
    NSString *sipNumber = [[SYLinphoneManager instance] getSipNumber:call];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:user.username forKey:@"fusername"];
    [dict setObject:@"" forKey:@"first_py"];
    [dict setObject:@"" forKey:@"fdepartmentname"];
    [dict setObject:@"" forKey:@"fworkername"];
    [dict setObject:@"" forKey:@"worker_id"];
    [dict setObject:sipNumber forKey:@"user_sip"];
    [dict setObject:@"" forKey:@"fgroup_name"];
    NSDictionary *insertDict = [[NSDictionary alloc] initWithDictionary:dict];
    [[MyFMDataBase shareMyFMDataBase] insertDataWithTableName:@"PeopleCalled" insertDictionary:insertDict];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"alreadyCalled" object:nil];
    
    NSArray *arrayA_ZInfo = [[MyFMDataBase shareMyFMDataBase] selectDataWithTableName:A_ZInfo withDic:nil];
    
    BOOL hasUserdata = NO;
    ContactModel *selectModel = [[ContactModel alloc] init];
    for (ContactModel *model in arrayA_ZInfo) {
        if ([model.user_sip isEqualToString:sipNumber]) {
            selectModel = model;
            hasUserdata = YES;
        }
    }
    
    //如果已经有来电呼叫，则把后面呼进来的都拒掉
    if (self.isCallComing) {
        [[SYLinphoneManager instance] hangUpCall:call];
        return;
    }
    //[[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_DissMissGuardView object:nil];
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        
        UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        VideoCallViewController *vc = [[VideoCallViewController alloc] initWithCall:call GuardInfo:nil InComingCall:YES isLanguage:isVideo otherName:selectModel.fworkername];
        //vc.sipNumber = [[SYLinphoneManager instance] getSipNumber:call];
        [viewController presentViewController:vc animated:YES completion:^{
            
        }];
    }else{
        //保存当前call
        self.currentCall = call;
    }
//    if ([SYAppConfig isPlayingSipVideo]) {
//        self.isDismissInComingCallVC = YES;
//        [SYAppConfig shareInstance].isPlayingVideoAndOtherImComing = YES;
//        [[SYLinphoneManager instance] hangUpCall];
//    }
    self.isCallComing = YES;
}

//=呼叫失败
- (void)onDialFailed:(SYLinphoneCallState)state withMessage:(NSDictionary *)message{
    
    self.currentCall = nil;
    self.isCallComing = NO;
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        
    }
}

//挂机
- (void)onHangUp:(SYLinphoneCall *)call withState:(SYLinphoneCallState)state withMessage:(NSDictionary *)message{
    self.isCallComing = NO;
}

//通话连接成功
-(void)onAnswer:(SYLinphoneCall *)call withState:(SYLinphoneCallState)state withMessage:(NSDictionary *)message{
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        
    }
    self.currentCall = nil;
}

- (void)onPaused:(SYLinphoneCall *)call withState:(SYLinphoneCallState)state withMessage:(NSDictionary *)message{
    
}



#pragma mark - 懒加载
+(AppDelegate*) sharedInstance{
    return ((AppDelegate*) [[UIApplication sharedApplication] delegate]);
}

-(UIWindow *)window{
    if (_window == nil) {
        //窗体
        CGRect frame = [[UIScreen mainScreen]bounds];
        _window= [[UIWindow alloc]initWithFrame:frame];
    }
    return _window;
}

-(LookEntranceVedioViewController *)lookEntranceViewController{
    if (!_lookEntranceViewController) {
        _lookEntranceViewController = [[LookEntranceVedioViewController alloc]init];
    }
    return _lookEntranceViewController;
}
-(PhotosSelectedViewController *)photosSelectedViewController{
    if (!_photosSelectedViewController) {
        _photosSelectedViewController = [[PhotosSelectedViewController alloc]init];
        
    }
    return _photosSelectedViewController;
}


#pragma mark - Router注册
- (void)setupRouter {
    // 登录页面 LoginViewController
    [[Routable sharedRouter] map:LOGIN_VIEWCONTROLLER toController:[LoginViewController class]];
    
    // 主页根 MyRootViewController
    [[Routable sharedRouter] map:MYROOT_VIEWCONTROLLER toController:[MyRootViewController class]];
    
    // 设置页面 SettingViewController
    [[Routable sharedRouter] map:SETTING_VIEWCONTROLLER toController:[SettingViewController class]];
    
    // 分享页面 ShareMyAppViewController
    [[Routable sharedRouter] map:SHARE_VIEWCONTROLLER toController:[ShareMyAppViewController class]];
    
    // 关于页面 AboutMyAppViewController
    [[Routable sharedRouter] map:ABOUT_VIEWCONTROLLER toController:[AboutMyAppViewController class]];
    
    // 业主详情页 OwnerViewController
    [[Routable sharedRouter] map:OWNER_VIEWCONTROLLER toController:[OwnerViewController class]];
    
    // 重设密码 ResetPasswordViewController
    [[Routable sharedRouter] map:RESETPASSWORD_VIEWCONTROLLER toController:[ResetPasswordViewController class]];
    
    // 勿扰模式 DNDViewController
    [[Routable sharedRouter] map:DONDISTRUB_VIEWCONTROLLER toController:[DNDViewController class]];
    
    // 消息设置 NewsNoticeSettingViewController
    [[Routable sharedRouter] map:NEWSNOTICE_VIEWCONTROLLER toController:[NewsNoticeSettingViewController class]];

    // 修密码 ChangePasswordViewController
    [[Routable sharedRouter] map:CHANGEPASSWORD_VIEWCONTROLLER toController:[ChangePasswordViewController class]];
    
    // 版本信息 VesionInfoViewController
    [[Routable sharedRouter] map:VESIONINFO_VIEWCONTROLLER toController:[VesionInfoViewController class]];
    
    // 忘记密码 ForgetPasswordViewController
    [[Routable sharedRouter] map:FORGETPASSWORD_VIEWCONTROLLER toController:[ForgetPasswordViewController class]];
    
    // 信息列表 MyNewsChatViewController
    [[Routable sharedRouter] map:MYNEWSCHAT_VIEWCONTROLLER toController:[MyNewsChatViewController class]];
    
    // 门禁 SearchLockViewController
    [[Routable sharedRouter] map:SEARCHLOCK_VIEWCONTROLLER toController:[SearchLockViewController class]];
    
    // 应用 ApplyViewController
    [[Routable sharedRouter] map:APPLY_VIEWCONTROLLER toController:[ApplyViewController class]];
    
    // 小区 PlotViewController
    [[Routable sharedRouter] map:PLOT_VIEWCONTROLLER toController:[PlotViewController class]];
    
    //报修投诉页 RepairsViewController
    [[Routable sharedRouter] map:REPAIRS_VIEWCONTROLLER toController:[RepairsViewController class]];
    
    //联系人列表 A_ZTableViewController
    [[Routable sharedRouter] map:A_ZTABLE_VIEWCONTROLLER toController:[A_ZTableViewController class]];
    
    //订单详情消息 ProOrderNewsViewController
    [[Routable sharedRouter] map:PROORDERNEWS_VIEWCONTROLLER toController:[ProOrderNewsViewController class]];
    
    //点击评论 OrderCommandViewController
    [[Routable sharedRouter] map:ORDERCOMMAND_VIEWCONTROLLER toController:[OrderCommandViewController class]];
    
    //接受订单页面 AcceptOrderViewController
    [[Routable sharedRouter] map:ACCEPTORDER_VIEWCONTROLLER toController:[AcceptOrderViewController class]];
    
    //派单界面 SendOrderViewController
    [[Routable sharedRouter] map:SENDORDER_VIEWCONTROLLER toController:[SendOrderViewController class]];
    
    //完成订单页面 CompleteOrderViewController
    [[Routable sharedRouter] map:COMPLETEORDER_VIEWCONTROLLER toController:[CompleteOrderViewController class]];
    
    //更多历史记录 MoreHistroyCommandViewController
    [[Routable sharedRouter] map:MOREHISTORY_VIEWCONTROLLER toController:[MoreHistroyCommandViewController class]];
    
    //未完成 UntreatedTableViewController
    [[Routable sharedRouter] map:UNTREATEDTABLE_VIEWCONTROLLER toController:[UntreatedTableViewController class]];
    
    //我-正在处理 MyProcessingTableViewController
    [[Routable sharedRouter] map:MYPROCESSINGTABLE_VIEWCONTROLLER toController:[MyProcessingTableViewController class]];
    
    //全部-正在处理 ProcessingTableViewController
    [[Routable sharedRouter] map:PROCESSINGTABLE_VIEWCONTROLLER toController:[ProcessingTableViewController class]];
    
    //我-已完成 MyCompletedTableViewController
    [[Routable sharedRouter] map:MYCOMPLETETABLE_VIEWCONTROLLER toController:[MyCompletedTableViewController class]];
    
    //全部-已完成 CompletedTableViewController
    [[Routable sharedRouter] map:COMPLETETABLE_VIEWCONTROLLER toController:[MoreHistroyCommandViewController class]];
    
    //小区消息详情 PlotCellDetailViewController
    [[Routable sharedRouter] map:PLOTCELLDETAIL_VIEWCONTROLLER toController:[PlotCellDetailViewController class]];
    
    //小区网页 PlotWebViewController
    [[Routable sharedRouter] map:PLOTWEB_VIEWCONTROLLER toController:[PlotWebViewController class]];
    
    //转单原因 SendOrderCauseViewController
    [[Routable sharedRouter] map:SENDORDERCAUSE_VIEWCONTROLLER toController:[SendOrderCauseViewController class]];
    
    //分组列表 GroupTableViewController
    [[Routable sharedRouter] map:GROUPTABLE_VIEWCONTROLLER toController:[GroupTableViewController class]];
    
    //拨号聊天记录 PhoneHistTableViewController
    [[Routable sharedRouter] map:PHONEHISTORYLIST_VIEWCONTROLLER toController:[PhoneHistTableViewController class]];
    
    //条款页面 ClauseViewController
    [[Routable sharedRouter] map:CLAUSE_VIEWCONTROLLER toController:[ClauseViewController class]];
}


@end




