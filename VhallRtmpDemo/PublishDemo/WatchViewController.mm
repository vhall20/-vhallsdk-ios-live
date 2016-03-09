//
//  WatchViewController.m
//  VhallRtmpLiveDemo
//
//  Created by liwenlong on 15/10/10.
//  Copyright © 2015年 vhall. All rights reserved.
//

#import "WatchViewController.h"
#import "RtmpLiveViewController.h"
#import "ALMoviePlayerController.h"
#import "ALMoviePlayerControls.h"
#import "OpenCONSTS.h"
#import "MBProgressHUD.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#import <AVFoundation/AVFoundation.h>
#import "VHallMoviePlayer.h"

@interface WatchViewController ()<VHMoviePlayerDelegate,ALMoviePlayerControllerDelegate>
{
   
    VHallMoviePlayer  *_moviePlayer;//播放器
   
    BOOL _isStart;
    MBProgressHUD * _hud;
    BOOL _isMute;
    BOOL _isAllScreen;
    int  _bufferCount;
}

@property (weak, nonatomic) IBOutlet UILabel *bufferCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *allScreenBtn;
@property (weak, nonatomic) IBOutlet UILabel *bitRateLabel;
@property (weak, nonatomic) IBOutlet UIButton *startAndStopBtn;
@property(nonatomic,strong) MPMoviePlayerController * hlsMoviePlayer;
@end

@implementation WatchViewController

#pragma mark - Private Method

-(void)addPanGestureRecognizer
{
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    panGesture.maximumNumberOfTouches = 1;
    panGesture.minimumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panGesture];
}

-(void)initDatas
{
    _isStart = YES;
    _isMute = NO;
    _isAllScreen = NO;
}

- (void)initViews
{
    //阻止iOS设备锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self addPanGestureRecognizer];
    _hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view insertSubview:_hud atIndex:0];
    [self registerLiveNotification];
    _moviePlayer = [[VHallMoviePlayer alloc]initWithDelegate:self];
    if (_watchVideoType == kWatchVideoRTMP)
    {
        self.view.clipsToBounds = YES;
        _moviePlayer.movieScalingMode = kRTMPMovieScalingModeAspectFit;
        _moviePlayer.bufferTime = (int)_bufferTimes;
        _moviePlayer.reConnectTimes = 2;
        [self.view insertSubview:_moviePlayer.moviePlayerView atIndex:0];
        
    }else if(_watchVideoType == kWatchVideoHLS||_watchVideoType == kWatchVideoPlayback)
    {
        _allScreenBtn.hidden = YES;
        _muteBtn.hidden = YES;
        self.hlsMoviePlayer =[[MPMoviePlayerController alloc] init];
        self.hlsMoviePlayer.controlStyle=MPMovieControlStyleDefault;
        [self.hlsMoviePlayer prepareToPlay];
        [self.hlsMoviePlayer.view setFrame:self.view.bounds];  // player的尺寸
        self.hlsMoviePlayer.shouldAutoplay=YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.hlsMoviePlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:self.hlsMoviePlayer];
        //    self.hlsMoviePlayer  = [[ALMoviePlayerController alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        //    self.hlsMoviePlayer.delegate = self; //IMPORTANT!
        //    _rtmpMoviePlayer.moviePlayerController = self.hlsMoviePlayer;
        //    // create the controls
        //    ALMoviePlayerControls * movieControls = [[ALMoviePlayerControls alloc] initWithMoviePlayer:self.hlsMoviePlayer style:ALMoviePlayerControlsStyleDefault];
        //    self.hlsMoviePlayer.shouldAutoplay=YES;
        //    // optionally customize the controls here...
        //    [movieControls setBarColor:[[UIColor blackColor]colorWithAlphaComponent:0.5]];
        //    [movieControls setTimeRemainingDecrements:YES];
        //    [movieControls setFadeDelay:2.0];
        //    [movieControls setBarHeight:30.f];
        //    [movieControls setSeekRate:2.f];
        //
        //    // assign the controls to the movie player
        //    [self.hlsMoviePlayer setControls:movieControls];
        // add movie player to your view
    }
}

- (void)destoryMoivePlayer
{
    [_moviePlayer destroyMoivePlayer];
}

//注册通知
- (void)registerLiveNotification
{
    [self.view addObserver:self forKeyPath:kViewFramePath options:NSKeyValueObservingOptionNew context:nil];
    //已经进入活跃状态的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive)name:UIApplicationDidBecomeActiveNotification object:nil];
    //监听耳机的插拔
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(outputDeviceChanged:)name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}

#pragma mark - UIButton Event
- (IBAction)stopWatchBtnClick:(id)sender
{
    if (_isStart) {
        [_hud show:YES];
        if (_watchVideoType == kWatchVideoRTMP)
        {
           _bufferCount = 0;
           NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
           param[@"id"] =  _roomId;
           param[@"app_key"] = AppKey;
           param[@"app_secret_key"] = AppSecretKey;
           param[@"name"] = @"xxxxxxx";
           param[@"email"] = @"xxxxxxx@163.com";
           if (_password&&_password.length>0) {
              param[@"pass"] = _password;
           }
           [_moviePlayer startPlay:param];

        }else if(_watchVideoType == kWatchVideoHLS)
        {
           //观看直播
           NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
           param[@"id"] =  _roomId;
           param[@"app_key"] = AppKey;
           param[@"app_secret_key"] = AppSecretKey;
           param[@"name"] = @"xxxxxxx";
           param[@"email"] = @"xxxxxxx@163.com";
           if (_password&&_password.length) {
              param[@"pass"] = _password;
           }
           [_moviePlayer startPlay:param moviePlayer:self.hlsMoviePlayer];

        }else if(_watchVideoType == kWatchVideoPlayback){
           
           //观看回放地址
           NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
           param[@"id"] =  _roomId;
           param[@"app_key"] = AppKey;
           param[@"app_secret_key"] = AppSecretKey;
           param[@"name"] = @"xxxxxxx";
           param[@"email"] = @"xxxxxxx@163.com";
           if (_password&&_password.length) {
              param[@"pass"] = _password;
           }
           [_moviePlayer startPlayback:param moviePlayer:self.hlsMoviePlayer];
        }
        
    }else{
        _bitRateLabel.text = @"";
        [_startAndStopBtn setTitle:@"开始播放" forState:UIControlStateNormal];
        [_moviePlayer stopPlay];
        [_hud hide:YES];
    }
    _isStart = !_isStart;
}

- (IBAction)closeBtnClick:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.watchVideoType == kWatchVideoRTMP)
        {
            [weakSelf destoryMoivePlayer];
            
        }else if(weakSelf.watchVideoType == kWatchVideoHLS||weakSelf.watchVideoType == kWatchVideoPlayback)
        {
            [weakSelf.hlsMoviePlayer stop];
             weakSelf.hlsMoviePlayer = nil;
        }
    }];
}

- (IBAction)muteBtnClick:(id)sender
{
    _isMute = !_isMute;
    [_moviePlayer setMute:_isMute];
    if (_isMute) {
        [UIAlertView popupAlertByDelegate:nil title:@"开始静音" message:nil];
    }else{
        [UIAlertView popupAlertByDelegate:nil title:@"静音结束" message:nil];
    }
}

- (IBAction)allScreenBtnClick:(id)sender
{
    _isAllScreen = !_isAllScreen;
    if (_isAllScreen) {
        [_allScreenBtn setTitle:@"自适应" forState:UIControlStateNormal];
        _moviePlayer.movieScalingMode = kRTMPMovieScalingModeAspectFill;
    }else{
        [_allScreenBtn setTitle:@"全屏" forState:UIControlStateNormal];
        _moviePlayer.movieScalingMode = kRTMPMovieScalingModeAspectFit;
    }
}
#pragma mark - Lifecycle Method

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initDatas];
    }
    return self;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (IOSVersion<8.0)
    {
        CGRect frame = self.view.frame;
        CGRect bounds = [[UIScreen mainScreen]bounds];
        if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait
            || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown) {
            //竖屏
            frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
        } else {
            //横屏
            frame = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
        }
        if (self.watchVideoType == kWatchVideoRTMP)
        {
            _moviePlayer.moviePlayerView.frame = frame;
            
        }else if(self.watchVideoType == kWatchVideoHLS||self.watchVideoType == kWatchVideoPlayback)
        {
            _hlsMoviePlayer.view.frame = frame;
            [self.view insertSubview:self.hlsMoviePlayer.view atIndex:0];
        }
    }
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initViews];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.watchVideoType == kWatchVideoRTMP)
    {
        _moviePlayer.moviePlayerView.frame = self.view.frame;
        
    }else if(self.watchVideoType == kWatchVideoHLS||self.watchVideoType == kWatchVideoPlayback)
    {
        _hlsMoviePlayer.view.frame = self.view.bounds;
        [self.view insertSubview:self.hlsMoviePlayer.view atIndex:0];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    //阻止iOS设备锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self.view removeObserver:self forKeyPath:kViewFramePath];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    VHLog(@"%@ dealloc",[[self class]description]);
}

#pragma mark - VHMoviePlayerDelegate

-(void)connectSucceed:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    [_startAndStopBtn setTitle:@"停止播放" forState:UIControlStateNormal];
}

-(void)bufferStart:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    [_hud show:YES];
   _bufferCount++;
   _bufferCountLabel.text = [NSString stringWithFormat:@"卡顿次数： %d",_bufferCount];
}

-(void)bufferStop:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    [_hud hide:YES];
}

-(void)downloadSpeed:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    NSString * content = info[@"content"];
    _bitRateLabel.text = [NSString stringWithFormat:@"%@ kb/s",content];
    //VHLog(@"downloadSpeed:%@",[info description]);
}

- (void)playError:(LivePlayErrorType)livePlayErrorType info:(NSDictionary *)info;
{
    [_hud hide:YES];
    void (^resetStartPaly)(NSString * msg) = ^(NSString * msg){
        _isStart = YES;
        _bitRateLabel.text = @"";
        [_startAndStopBtn setTitle:@"开始播放" forState:UIControlStateNormal];
        if (APPDELEGATE.isNetworkReachable) {
            [UIAlertView popupAlertByDelegate:nil title:msg message:nil];
        }else{
            [UIAlertView popupAlertByDelegate:nil title:@"没有可以使用的网络" message:nil];
        }
    };
    
    NSString * msg = @"";
    switch (livePlayErrorType) {
        case kLivePlayParamError:
        {
            msg = @"参数错误";
            resetStartPaly(msg);
        }
        break;
        case kLivePlayRecvError:
        {
            msg = @"对方已经停止直播";
            resetStartPaly(msg);
        }
            break;
        case kLivePlayCDNConnectError:
        {
            msg = @"服务器任性...连接失败";
            resetStartPaly(msg);
        }
            break;
        case kLivePlayGetUrlError:
        {
            msg = @"获取服务器地址报错";
            [MBHUDHelper showWarningWithText:info[@"content"]];
        }
            break;
        default:
            break;
    }
}

- (void)netWorkStatus:(VHMoviePlayer*)moviePlayer info:(NSDictionary*)info
{
    VHLog(@"netWorkStatus:%f",[info[@"content"]floatValue]);
}

#pragma mark - ALMoviePlayerControllerDelegate
- (void)movieTimedOut
{
    
}

- (void)moviePlayerWillMoveFromWindow
{
    if (![self.view.subviews containsObject:self.hlsMoviePlayer.view])
        [self.view insertSubview:self.hlsMoviePlayer.view atIndex:0];
    //you MUST use [ALMoviePlayerController setFrame:] to adjust frame, NOT [ALMoviePlayerController.view setFrame:]
    //[self.hlsMoviePlayer setFrame:self.view.frame];
}

#pragma mark - UIPanGestureRecognizer
-(void)handlePan:(UIPanGestureRecognizer*)pan
{
    float baseY = 200.0f;
    CGPoint translation = CGPointZero;
    static float volumeSize = 0.0f;
    CGPoint currentLocation = [pan translationInView:self.view];
    if (pan.state == UIGestureRecognizerStateBegan)
    {
        translation = [pan translationInView:self.view];
        volumeSize = [VHMoviePlayer getSysVolumeSize];
    }else if(pan.state == UIGestureRecognizerStateChanged)
    {
        float y = currentLocation.y-translation.y;
        float changeSize = ABS(y)/baseY;
        if (y>0){
            [VHMoviePlayer setSysVolumeSize:volumeSize-changeSize];
        }else{
            [VHMoviePlayer setSysVolumeSize:volumeSize+changeSize];
        }
    }
}

#pragma mark - ObserveValueForKeyPath

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:kViewFramePath])
    {
        CGRect frame = [[change objectForKey:NSKeyValueChangeNewKey]CGRectValue];
        if (self.watchVideoType == kWatchVideoRTMP)
        {
            _moviePlayer.moviePlayerView.frame = frame;
            
        }else if(self.watchVideoType == kWatchVideoHLS||self.watchVideoType == kWatchVideoPlayback)
        {
            _hlsMoviePlayer.view.frame = frame;
            [self.view insertSubview:self.hlsMoviePlayer.view atIndex:0];
        }
    }
}

- (void)moviePlaybackStateDidChange:(NSNotification *)note
{
    switch (self.hlsMoviePlayer.playbackState)
    {
        case MPMoviePlaybackStatePlaying:
        {
            [MBHUDHelper showWarningWithText:@"播放"];
            [_hud hide:YES];
            [_startAndStopBtn setTitle:@"停止播放" forState:UIControlStateNormal];
        }
            break;
        case MPMoviePlaybackStateSeekingBackward:
        case MPMoviePlaybackStateSeekingForward:
        {
            
        }
            break;
        case MPMoviePlaybackStateInterrupted:
        {
            //NSLog(@"中断了");
            [MBHUDHelper showWarningWithText:@"中断了"];
        }
            break;
        case MPMoviePlaybackStatePaused:
        {
            //NSLog(@"暂停");
            [MBHUDHelper showWarningWithText:@"暂停"];
        }
            break;
        case MPMoviePlaybackStateStopped:
        {
            //NSLog(@"停止播放");
            [MBHUDHelper showWarningWithText:@"停止播放"];
        }
            break;
        default:
            break;
    }
}

- (void)movieLoadStateDidChange:(NSNotification *)note
{
    if (self.hlsMoviePlayer.loadState == MPMovieLoadStatePlayable)
    {
        [_hud show:YES];
        //NSLog(@"开始加载加载");
    }else if(self.hlsMoviePlayer.loadState == (MPMovieLoadStatePlaythroughOK|MPMovieLoadStatePlayable))
    {
        //NSLog(@"加载完成");
        [_hud hide:YES];
    }
}

- (void)didBecomeActive
{
    //观看直播
    [self.hlsMoviePlayer play];
}
- (void)outputDeviceChanged:(NSNotification*)notification
{
    NSInteger routeChangeReason = [[[notification userInfo]objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason)
    {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        {
            VHLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            VHLog(@"Headphone/Line plugged in");
        }
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            VHLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            VHLog(@"Headphone/Line was pulled. Stopping player....");
            dispatch_async(dispatch_get_main_queue(), ^{
                 [self.hlsMoviePlayer play];
            });
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
        {
            // called at start - also when other audio wants to play
            VHLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
        }
            break;
        default:
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
