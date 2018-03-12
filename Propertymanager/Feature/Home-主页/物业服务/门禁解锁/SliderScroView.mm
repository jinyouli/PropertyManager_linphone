//
//  SliderScroView.m
//  PropertyManager
//
//  Created by Momo on 16/9/26.
//  Copyright © 2016年 Doubango Telecom. All rights reserved.
//

#import "SliderScroView.h"
@interface SliderScroView ()<UIScrollViewDelegate>
@property (nonatomic,strong) UIImageView * bgImgView1;
@property (nonatomic,strong) UIImageView * bgImgView2;
@property (nonatomic,strong) UILabel * textLab;
@property (nonatomic,strong) UIImageView * choiceImgView;

@property (nonatomic,strong) NSTimer * timer;
@end

@implementation SliderScroView

-(instancetype)initWithFrame:(CGRect)frame withSn_Domain:(NSString *)sn_Domain type:(NSString *)type sipNum:(NSString *)sipnum{
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bounces = NO;
        self.pagingEnabled = YES;
        self.layer.cornerRadius = 5.0;
        self.backgroundColor = [UIColor blueColor];
        self.delegate = self;
        
        self.domain_sn = sn_Domain;
        self.type = type;
        self.sip_number = sipnum;
        
        self.bgImgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width , self.frame.size.height)];
        self.bgImgView1.backgroundColor = [PMTools colorFromHexRGB:@"00b4c7"];
        [self addSubview:self.bgImgView1];
        
        self.bgImgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        self.bgImgView2.backgroundColor = MYColor(195, 195, 195);
        [self addSubview:self.bgImgView2];
        
        
        self.textLab = [[UILabel alloc] init];
        self.textLab.frame = CGRectMake(60, 0, self.frame.size.width - 60, self.frame.size.height);
//        self.textLab.text = [NSString stringWithFormat:@"右滑打开门锁(%ld)",self.leftTime];
        self.textLab.text = @"右滑打开门锁";
        self.textLab.textAlignment = NSTextAlignmentCenter;
        self.textLab.font = MiddleFont;
        self.textLab.textColor = [UIColor whiteColor];
        [self.bgImgView2 addSubview:self.textLab];
        
        self.choiceImgView = [[UIImageView alloc] init];
        self.choiceImgView.frame = CGRectMake(0, 0, 60, self.frame.size.height);
        self.choiceImgView.layer.cornerRadius = 5.0;
        self.choiceImgView.image = [UIImage imageNamed:@"滑块"];
        [self.bgImgView2 addSubview:self.choiceImgView];
        
        self.leftTime = 0;
   
        
        self.contentSize = CGSizeMake(2 * self.frame.size.width, self.frame.size.height);
        self.contentOffset = CGPointMake(self.frame.size.width, 0);
        
        self.timer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(leftTimeSub) userInfo:nil repeats:YES];
        [self.timer setFireDate:[NSDate distantPast]];
    }
    return self;
}

-(void)leftTimeSub{
    
    [self.timer setFireDate:[NSDate distantFuture]];
    self.textLab.text = @"右滑打开门锁";
    self.userInteractionEnabled = YES;
    
    /*
    self.leftTime --;
    if (self.leftTime > 0) {
        self.textLab.text = [NSString stringWithFormat:@"右滑打开门锁(%zds)",self.leftTime];
        self.userInteractionEnabled = NO;
    }
    else{
        //关闭定时器
        [self.timer setFireDate:[NSDate distantFuture]];
        self.textLab.text = @"右滑打开门锁";
        self.userInteractionEnabled = YES;
    }
     */
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (!self.isDecelerating) {
        if(self.contentOffset.x <= 10)
        {
            [self sendOpenLock];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollVie
{
    
    if(self.contentOffset.x <= 62)
    {
        [self sendOpenLock];
    }
}

-(void)sendOpenLock
{
    SYLog(@"解锁操作");
    SystemAudio *audio = [[SystemAudio alloc] initSystemShake];      //震动
    [audio play];
    
    UserManager * user = [UserManagerTool userManager];
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
    long long dTime = [[NSNumber numberWithDouble:time] longLongValue]; // 将double转为long long型
    NSString *curTime = [NSString stringWithFormat:@"%llu",dTime]; // 输出long long型
    
    //网络开锁请求
    NSDictionary * paraDic = @{@"username":user.username,
                               @"domain_sn":self.domain_sn,
                               @"time":curTime,
                               @"type":self.type};
    
    
    [DetailRequest SYRemote_unlockWithParms:paraDic];
    
    self.leftTime = 7;
    //开启定时器
    [self.timer setFireDate:[NSDate distantPast]];
    [self.myDelegate RequestFinish];
    
    
    
    NSDictionary * params = @{@"username":user.username,
                              @"domain_sn":self.domain_sn,
                              @"type":self.type,
                              @"time":curTime,
                              @"sip_number":self.sip_number};
    [SYSipSendMessage sipSendMessageUnlockDoorMonitorWithParams:params];
}


-(void)dealloc{
    
    [self.timer invalidate];
    self.timer = nil;
}


@end
