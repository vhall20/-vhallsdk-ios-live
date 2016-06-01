//
//  WatchRTMPViewController.m
//  VHallSDKDemo
//
//  Created by developer_k on 16/4/13.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "WatchRTMPViewController.h"
#import "RtmpLiveViewController.h"
#import "ALMoviePlayerController.h"
#import "ALMoviePlayerControls.h"
#import "OpenCONSTS.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#import <AVFoundation/AVFoundation.h>
#import "VHallMoviePlayer.h"

@interface WatchRTMPViewController ()<VHallMoviePlayerDelegate>
{
    VHallMoviePlayer  *_moviePlayer;//播放器
    BOOL _isStart;
    BOOL _isMute;
    BOOL _isAllScreen;
    int  _bufferCount;
}

@property (weak, nonatomic) IBOutlet UILabel *bufferCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *allScreenBtn;
@property (weak, nonatomic) IBOutlet UILabel *bitRateLabel;
@property (weak, nonatomic) IBOutlet UIButton *startAndStopBtn;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *textImageView;
@property (weak, nonatomic) IBOutlet UILabel *liveTypeLabel;

@property (nonatomic,assign) VHallMovieVideoPlayMode playModelTemp;
@property (nonatomic,strong) UILabel*textLabel;

@end

@implementation WatchRTMPViewController

-(UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc]init];
        _textLabel.frame = CGRectMake(0, 10, self.textImageView.width, 21);
        _textLabel.text = @"无文档";
        _textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _textLabel;
}


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
    [self registerLiveNotification];
    _moviePlayer = [[VHallMoviePlayer alloc]initWithDelegate:self];
    self.view.clipsToBounds = YES;
    _moviePlayer.movieScalingMode = kRTMPMovieScalingModeAspectFit;
    _moviePlayer.bufferTime = (int)_bufferTimes;
    _moviePlayer.reConnectTimes = 2;
    [self.backView addSubview:_moviePlayer.moviePlayerView];
    [self.backView sendSubviewToBack:_moviePlayer.moviePlayerView];
}

- (void)destoryMoivePlayer
{
    [_moviePlayer destroyMoivePlayer];
}

#pragma mark - 注册通知
- (void)registerLiveNotification
{
    [self.view addObserver:self forKeyPath:kViewFramePath options:NSKeyValueObservingOptionNew context:nil];
    //已经进入活跃状态的通知
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive)name:UIApplicationDidBecomeActiveNotification object:nil];
    //监听耳机的插拔
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(outputDeviceChanged:)name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}

#pragma mark - UIButton Event
- (IBAction)stopWatchBtnClick:(id)sender
{
    if (_isStart) {
        _bufferCount = 0;
        //todo
        NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
        param[@"id"] =  _roomId;
        param[@"app_key"] = DEMO_AppKey;
        param[@"app_secret_key"] = DEMO_AppSecretKey;
        param[@"name"] = DEMO_Setting.nickName;
        param[@"email"] = DEMO_Setting.userID;
        if (_password&&_password.length>0) {
            param[@"pass"] = _password;
        }
        [_moviePlayer startPlay:param];
        if (self.playModelTemp == VHallMovieVideoPlayModeTextAndVoice ) {
            self.liveTypeLabel.text = @"语音直播中";
        }else{
            self.liveTypeLabel.text = @"";
        }
    }else{
        _bitRateLabel.text = @"";
        [_startAndStopBtn setTitle:@"开始播放" forState:UIControlStateNormal];
        [_moviePlayer stopPlay];
        if (self.playModelTemp == VHallMovieVideoPlayModeTextAndVoice ) {
            self.liveTypeLabel.text = @"已暂停语音直播";
        }
    }

    if (self.textImageView.image == nil) {
        [self.textImageView addSubview:self.textLabel];
    }else{
        [self.textLabel removeFromSuperview];
        self.textLabel = nil;
    }
    _isStart = !_isStart;
}

#pragma mark - 返回上层界面按钮
- (IBAction)closeBtnClick:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf destoryMoivePlayer];
    }];
}

#pragma mark - 静音
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

#pragma mark - RTMP屏幕自适应
- (IBAction)allScreenBtnClick:(id)sender
{
    _isAllScreen = !_isAllScreen;
    if (_isAllScreen) {
        [_allScreenBtn setTitle:@"自适应" forState:UIControlStateNormal];
        _moviePlayer.movieScalingMode = kRTMPMovieScalingModeAspectFill;

    }else{
        //[_allScreenBtn setTitle:@"全屏" forState:UIControlStateNormal];
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
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait// UIInterfaceOrientationPortrait
            || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) { //UIInterfaceOrientationPortraitUpsideDown
            //竖屏
            frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
        } else {
            //横屏
            frame = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
        }
        _moviePlayer.moviePlayerView.frame = frame;

    }
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initViews];
    _moviePlayer.moviePlayerView.frame = CGRectMake(0, 10, self.view.frame.size.width, self.backView.height-20);
    [self.view bringSubviewToFront:self.backView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
-(void)moviePlayerWillMoveFromWindow
{
}

-(void)connectSucceed:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    [_startAndStopBtn setTitle:@"停止播放" forState:UIControlStateNormal];
}

-(void)bufferStart:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    _bufferCount++;
    _bufferCountLabel.text = [NSString stringWithFormat:@"卡顿次数： %d",_bufferCount];
}

-(void)bufferStop:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
}

-(void)downloadSpeed:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    NSString * content = info[@"content"];
    _bitRateLabel.text = [NSString stringWithFormat:@"%@ kb/s",content];
    VHLog(@"downloadSpeed:%@",[info description]);
}

- (void)playError:(LivePlayErrorType)livePlayErrorType info:(NSDictionary *)info;
{
    void (^resetStartPlay)(NSString * msg) = ^(NSString * msg){
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
            resetStartPlay(msg);
        }
            break;
        case kLivePlayRecvError:
        {
            msg = @"对方已经停止直播";
            resetStartPlay(msg);
        }
            break;
        case kLivePlayCDNConnectError:
        {
            msg = @"服务器任性...连接失败";
            resetStartPlay(msg);
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

#pragma mark - vhallMoviePlayerDelegate
-(void)PPTScrollNextPagechangeImagePath:(NSString *)changeImagePath
{
    self.textImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:changeImagePath]]];
    if (self.textImageView.image == nil) {
        [self.textImageView addSubview:self.textLabel];
    }else{
        [self.textLabel removeFromSuperview];
        self.textLabel = nil;

    }

}

-(void)VideoPlayMode:(VHallMovieVideoPlayMode)playMode
{
    VHLog(@"---%ld",(long)playMode);

    self.liveTypeLabel.text = @"";
    _playModelTemp = playMode;
    switch (playMode) {
        case VHallMovieVideoPlayModeNone:
        case VHallMovieVideoPlayModeMedia:
        case VHallMovieVideoPlayModeTextAndMedia:
            break;
        case VHallMovieVideoPlayModeTextAndVoice:
        {

            self.liveTypeLabel.text = @"语音直播中";
        }

            break;

        default:
            break;
    }

    [self alertWithMessage:playMode];
}
-(void)ActiveState:(VHallMovieActiveState)activeState
{
    VHLog(@"activeState-%ld",(long)activeState);
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
        //CGRect frame = [[change objectForKey:NSKeyValueChangeNewKey]CGRectValue];
        _moviePlayer.moviePlayerView.frame = CGRectMake(0, 10, self.view.frame.size.width, self.backView.height-20);
    }
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


#pragma mark - 详情
- (IBAction)detailsButtonClick:(UIButton *)sender {
    self.textImageView.hidden = YES;
}

#pragma mark - 文档
- (IBAction)textButtonClick:(UIButton *)sender {
    self.textImageView.hidden = NO;
}

-(void)alertWithMessage : (VHallMovieVideoPlayMode)state
{
    NSString*message = nil;
    switch (state) {
        case 0:
            message = @"无内容";
            break;
        case 1:
            message = @"纯视频";
            break;
        case 2:
            message = @"文档＋声音";
            break;
        case 3:
            message = @"文档＋视频";
            break;

        default:
            break;
    }

    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

@end
