//
//  YLB.h
//  YLB_LINPHONE_SDK
//
//  Created by sayee on 17/4/26.
//  Copyright © 2017年 sayee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class BCLockListModel;
@class ScannedPeripheralModel;
@interface YLB : NSObject

@property (nonatomic, retain) NSMutableArray *allGuardsMArr;
@property (nonatomic, assign) BOOL isPlayingSipVideo; //是否视频监控中
@property (nonatomic, assign) BOOL isPlayingVideoAndOtherImComing;
@property (nonatomic, retain) NSNumber *fpsNumber;
@property (nonatomic, strong) NSTimer *fpsTimer;
@property (nonatomic, assign) BOOL isstar;


+ (YLB *)shareInstance;

/**
 *  登录YLBSDK    默认会初始化YLBSDK
 *  @param username     账号
 *  @param key   密钥
 *  @param appID   appID
 *  @param token     凭证 (可选)
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 */
+ (void)loginYLBWithUsename:(NSString *)username WithKey:(NSString *)key WithAppID:(NSString *)appID WithToken:(NSString *)token WithNeiborFlag:(NSString *)neiborFlag Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock;

/**
 *  退出登录（注销YLBSDK视频监控）
 */
+ (void)loginOutYLB;

//更新Token
+ (void)updateNewToken;

/**
 *  初始化YLBSDK   启动app时，在didFinishLaunchingWithOptions调用； 可以不调用，不过要在didFinishLaunchingWithOptions登录YLBSDK，不然就不能监听到视频来电
 *  @param ipv6Enabled    IPV6支持  默认传NO
 *  @param nExpires   Expires 默认传0
 *  @param videoEnable   是否允许显示视频监控 默认传YES
 */
- (void)initYLBSDKWithIPV6Enabled:(BOOL)ipv6Enabled WithExpires:(int)nExpires videoEnable:(BOOL)videoEnable;

/**
 *  YLBSDK URL
 */
+ (void)setHostURL:(NSString *)url;

/**
 *  蓝牙密钥
 */
+ (NSString *)getBluetoothEncodeKey;

/**
 *  拿最新接口蓝牙密钥   基本上用上面那个getBluetoothEncodeKey就可以  只是防止后台平台接口数据改动
 */
+ (void)getBluetoothEncodeKeyReflash:(NSString *)neiborFlag WithUsername:(NSString *)username Succeed:(void(^)(NSString *bluetoothEncodeKey))successBlock fail:(void(^)(NSError *error))errorBlock;

#pragma mark 获取门禁列表
+ (NSMutableArray*)fetchCommunityData;

+ (NSString*)getCommunityNameFromModel:(NSString*)peripheralNumber community:(NSMutableArray*)community;

#pragma mark -- 蓝牙开门部分
/** 获取蓝牙秘钥*/
+(void)requestBlueToothcode_keyWithNeibor_flag:(NSString *)neibor_flag username:(NSString *)username complete:(void(^)(NSString * key))complete;

/** 搜索到蓝牙设备的回调 filter: 是否过滤 */
+ (void) searchAllPeripheralsComplete:(void(^)(NSArray * Peripherals)) peripheralsBlock;

/** 蓝牙发送开锁指令
 username: 用户名
 doorname: 门口机名称
 key:蓝牙秘钥
 shake：是否由摇一摇进入 摇一摇按照信号最强开门 不是则由点击开门
 */
//+ (void) blueToothOpenDoorWithUsername:(NSString *)username doorName:(NSString *)doorname codeKey:(NSString *)key andIsShake:(BOOL)shake timeInterval:(NSTimeInterval)time;

+ (void) blueToothOpenDoorWithUsername:(NSString *)username doorName:(NSString *)doorname codeKey:(NSString *)key andIsShake:(BOOL)shake timeInterval:(NSTimeInterval)time Block:(void(^)())block;

#pragma mark - ViewController
/** 进入锁列表*/
+ (void)gotoLockListViewController;

#pragma mark -- sip开门部分
/**
 *  滑动解锁向门口机发送一条sip短信
 */
- (BOOL)sendMessage:(NSString *)message Address:(NSString *)sipNumber;

//+ (void) sipOpenDoor;


/** 进入蓝牙门禁列表*/
+(void)gotoBlueLockTableViewController:(NSMutableArray*)array;

+(BOOL)isNullOrEmpty:(id)string;

//opendoor
+ (void)sendLockBlueDoor:(NSString*)peripheralNumber community:(NSMutableArray*)community timeInterval:(NSTimeInterval)time Block:(void(^)())block;
//获取随机开锁密码
+ (void)GetPassWord:(NSString *)sipnumber Withusername:(NSString *)username Block:(void(^)())block;
//滑动开锁方法
+ (void)sliderOpenDoorWithSipnumber:(NSString *)sipnumber WithUsername:(NSString *)username Withdomain:(NSString *)domain WithType:(NSString *)type NSTimeInterval:(NSTimeInterval)time Block:(void(^)())block;
//房屋免打扰设置
+ (void)setDisturingWithHouseid:(NSString *)houseid Withnum:(NSNumber *)num Block:(void(^)())block Block:(void(^)())blockse;
//友领帮房屋免打扰设置
+ (void)setYLBDisturingWithHouseid:(NSString *)house_id WithDisturing:(BOOL)disturing Block:(void(^)())block Block:(void(^)())blockfail;
//获取子账号列表
+ (void)getChildAccountWithHouseID:(NSString *)houseid WithUsername:(NSString *)username Block:(void(^)(NSArray *arrModel))block;
//添加子账号
+ (void)setChildAccountWithCalledNumber:(NSString *)phoneNumber WithUsername:(NSString *)username WithHouseID:(NSString *)houseid WithAlias:(NSString *)nickname WithIsAdd:(BOOL)yesno WithIsCalledNumber:(BOOL)noyes WithDwellertype:(NSString *)dwellertype Block:(void(^)())block;
//设置紧急被叫
+ (void)setCalledNumberWithCalledNumber:(NSString *)callednumber WithUsername:(NSString *)username WithHouseID:(NSString *)houseid Block:(void(^)())block;
//修改子账号
+ (void)setHouseSubAccountWithCalledNumber:(NSString *)mobilePhone WithUsername:(NSString *)username  WithHouseID:(NSString *)houseid WithAlias:(NSString *)textfiled WithIsAdd:(BOOL)yesno WithIsCalledNumber:(BOOL)noyes WithDwellertype:(NSString *)dwellertype Block:(void(^)())block;
//删除子账号
+ (void)deletHouseSubAccountWithCalledNumber:(NSString *)mobilePhone WithUsername:(NSString *)username  WithHouseID:(NSString *)houseid WithAlias:(NSString *)textfiled WithIsAdd:(BOOL)noys WithIsCalledNumber:(BOOL)noyes WithDwellertype:(NSString *)dwellertype Block:(void(^)())block;
//切换视频清晰度
+ (void)changeVideoClearWithVideoSize:(int)videoSize;

//获取displayname
+ (NSString *)guardDisplayName;
//离线密码
+ (NSString *)getRandomKeyWithsip:(long)sipNumber With:(long)time;

- (BOOL)getisSipLogined;
#pragma mark -- 三通道开门
+(void)sipOpenBlueLock;

//门口机是否在线
+ (void)checkSipisOnlineWithSiplistjsonstr:(NSString *)sipList Succeed:(void(^)(NSArray *sipListmodel))successBlock fail:(void(^)(NSError *error))errorBlock;

/**SYNOTICE_ResponseIdentifyAuthenticationErrorCode TOKEN过期通知，收到通知必须重新传值
 * 初始化（调用loginYLBWithUsename）后，要设置定时器，1个小时55分钟更新一次token
 */
+ (void)updateToken:(NSString *)token;
+ (NSString *)getRegisterState;

@end
