//
//  WatchHLSViewController.m
//  VHallSDKDemo
//
//  Created by developer_k on 16/4/12.
//  Copyright © 2016年 vhall. All rights reserved.
//


#import "RtmpLiveViewController.h"
#import "ALMoviePlayerController.h"
#import "ALMoviePlayerControls.h"
#import "OpenCONSTS.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#import <AVFoundation/AVFoundation.h>
#import "VHallMoviePlayer.h"
#import "WatchHLSViewController.h"

@interface WatchHLSViewController ()<ALMoviePlayerControllerDelegate,VHallMoviePlayerDelegate>
{
    VHallMoviePlayer  *_moviePlayer;//播放器
    int  _bufferCount;
}

@property (weak, nonatomic) IBOutlet UILabel *bufferCountLabel;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property(nonatomic,strong) MPMoviePlayerController * hlsMoviePlayer;
@property (weak, nonatomic) IBOutlet UIImageView *textImageView;
@property (weak, nonatomic) IBOutlet UILabel *liveTypeLabel;

@property (nonatomic,assign) VHallMovieVideoPlayMode playModelTemp;

@property (nonatomic,strong) UILabel*textLabel;

@end

@implementation WatchHLSViewController

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

- (void)initViews
{
    //阻止iOS设备锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self addPanGestureRecognizer];
    [self registerLiveNotification];
    _moviePlayer = [[VHallMoviePlayer alloc]initWithDelegate:self];
        self.hlsMoviePlayer =[[MPMoviePlayerController alloc] init];
        self.hlsMoviePlayer.controlStyle=MPMovieControlStyleDefault;
        [self.hlsMoviePlayer prepareToPlay];
        [self.hlsMoviePlayer.view setFrame:self.view.bounds];  // player的尺寸
        self.hlsMoviePlayer.shouldAutoplay=YES;
        self.hlsMoviePlayer.view.backgroundColor = [UIColor whiteColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.hlsMoviePlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:self.hlsMoviePlayer];

        //ALMoviePlayerController  使用
        /*
         self.hlsMoviePlayer  = [[ALMoviePlayerController alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
         self.hlsMoviePlayer.delegate = self; //IMPORTANT!
         _rtmpMoviePlayer.moviePlayerController = self.hlsMoviePlayer;
         // create the controls
         ALMoviePlayerControls * movieControls = [[ALMoviePlayerControls alloc] initWithMoviePlayer:self.hlsMoviePlayer style:ALMoviePlayerControlsStyleDefault];
         self.hlsMoviePlayer.shouldAutoplay=YES;
         // optionally customize the controls here...
         [movieControls setBarColor:[[UIColor blackColor]colorWithAlphaComponent:0.5]];
         [movieControls setTimeRemainingDecrements:YES];
         [movieControls setFadeDelay:2.0];
         [movieControls setBarHeight:30.f];
         [movieControls setSeekRate:2.f];

         // assign the controls to the movie player
         [self.hlsMoviePlayer setControls:movieControls];
         add movie player to your view

         */
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

#pragma mark - 返回上层界面
- (IBAction)closeBtnClick:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf destoryMoivePlayer];
            [weakSelf.hlsMoviePlayer stop];
            weakSelf.hlsMoviePlayer = nil;
    }];
}

#pragma mark - 屏幕自适应
- (IBAction)allScreenBtnClick:(UIButton*)sender
{
    if (sender.selected) {
        [self.hlsMoviePlayer setScalingMode: MPMovieScalingModeAspectFill];
    }else{
        [self.hlsMoviePlayer setScalingMode:MPMovieScalingModeNone];
    }
    sender.selected = !sender.selected;

}

#pragma mark - Lifecycle Method
- (instancetype)init
{
    self = [super init];
    if (self) {

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
    //如果是iosVersion  8.0之前，UI出现问题请在此调整
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
        if (self.watchVideoType == kWatchVideoRTMP)
        {
            _moviePlayer.moviePlayerView.frame = frame;

        }else if(self.watchVideoType == kWatchVideoHLS||self.watchVideoType == kWatchVideoPlayback)
        {
            _hlsMoviePlayer.view.frame = frame;
            [self.backView addSubview:self.hlsMoviePlayer.view];
            [self.backView sendSubviewToBack:_hlsMoviePlayer.view];
        }
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
    if (self.hlsMoviePlayer.view) {
        [MBProgressHUD showHUDAddedTo:self.hlsMoviePlayer.view animated:YES];
    }
    //todo
    NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
    param[@"id"] =  _roomId;
    param[@"app_key"] = DEMO_AppKey;
    param[@"app_secret_key"] = DEMO_AppSecretKey;
    param[@"name"] = DEMO_Setting.nickName;
    param[@"email"] = DEMO_Setting.userID;
    if (_password&&_password.length) {
        param[@"pass"] = _password;
    }
    [_moviePlayer startPlay:param moviePlayer:self.hlsMoviePlayer];

    //播放器
    _hlsMoviePlayer.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.backView.height);//self.view.bounds;
    [self.backView addSubview:self.hlsMoviePlayer.view];
    [self.backView sendSubviewToBack:self.hlsMoviePlayer.view];

    if (self.playModelTemp == VHallMovieVideoPlayModeTextAndVoice ) {
        self.liveTypeLabel.text = @"语音直播中";
    }else{
        self.liveTypeLabel.text = @"";
    }
    
    if (self.textImageView.image == nil) {
        [self.textImageView addSubview:self.textLabel];
    }else{
        [self.textLabel removeFromSuperview];
        self.textLabel = nil;
    }
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

-(void)connectSucceed:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info
{

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
    //NSString * content = info[@"content"];
    VHLog(@"downloadSpeed:%@",[info description]);
}

- (void)playError:(LivePlayErrorType)livePlayErrorType info:(NSDictionary *)info;
{
    if (self.hlsMoviePlayer.view) {
        [MBProgressHUD hideAllHUDsForView:self.hlsMoviePlayer.view animated:YES];
    }
    void (^resetStartPlay)(NSString * msg) = ^(NSString * msg){
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
    self.liveTypeLabel.text = nil;
    _playModelTemp = playMode;
    _hlsMoviePlayer.controlStyle = MPMovieControlStyleNone;
    switch (playMode) {
        case VHallMovieVideoPlayModeNone:
        case VHallMovieVideoPlayModeMedia:

            break;
        case VHallMovieVideoPlayModeTextAndVoice:
            self.liveTypeLabel.text = @"语音直播中";
            break;
        case VHallMovieVideoPlayModeTextAndMedia:
            
        default:
            break;
    }

    [self alertWithMessage:playMode];


}

-(void)ActiveState:(VHallMovieActiveState)activeState
{
    VHLog(@"activeState - %ld",(long)activeState);
}

#pragma mark - ALMoviePlayerControllerDelegate
- (void)movieTimedOut
{

}

- (void)moviePlayerWillMoveFromWindow
{
    if (![self.backView.subviews containsObject:self.hlsMoviePlayer.view])
        [self.backView sendSubviewToBack:self.hlsMoviePlayer.view];
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
        //CGRect frame = [[change objectForKey:NSKeyValueChangeNewKey]CGRectValue];
        _hlsMoviePlayer.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.backView.height);
        //[self.backView addSubview:self.hlsMoviePlayer.view];
        [self.backView sendSubviewToBack:self.hlsMoviePlayer.view];

    }
}

- (void)moviePlaybackStateDidChange:(NSNotification *)note
{
    switch (self.hlsMoviePlayer.playbackState)
    {
        case MPMoviePlaybackStatePlaying:
        {
            VHLog(@"播放");
            if (self.playModelTemp == VHallMovieVideoPlayModeTextAndVoice )
            self.liveTypeLabel.text = @"语音直播中";
        }
            break;
        case MPMoviePlaybackStateSeekingBackward:
        case MPMoviePlaybackStateSeekingForward:
        {
            VHLog(@"快进－－快退");
        }
            break;
        case MPMoviePlaybackStateInterrupted:
        {
            VHLog(@"中断了");
        }
            break;
        case MPMoviePlaybackStatePaused:
        {
            VHLog(@"暂停");
            if (self.playModelTemp == VHallMovieVideoPlayModeTextAndVoice )
            self.liveTypeLabel.text = @"已暂停语音直播";
        }
            break;
        case MPMoviePlaybackStateStopped:
        {
            VHLog(@"停止播放");
            if (self.hlsMoviePlayer.view) {
                [MBProgressHUD hideAllHUDsForView:self.hlsMoviePlayer.view animated:YES];
            }
            if (self.playModelTemp == VHallMovieVideoPlayModeTextAndVoice )
            self.liveTypeLabel.text = @"已暂停语音直播";
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
        if (self.hlsMoviePlayer.view) {
            [MBProgressHUD showHUDAddedTo:self.hlsMoviePlayer.view animated:YES];
        }

        VHLog(@"开始加载加载");
    }else if(self.hlsMoviePlayer.loadState == (MPMovieLoadStatePlaythroughOK|MPMovieLoadStatePlayable))
    {
        if (self.hlsMoviePlayer.view) {
            [MBProgressHUD hideAllHUDsForView:self.hlsMoviePlayer.view animated:YES];
        }
        VHLog(@"加载完成");
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

#pragma mark - 详情
- (IBAction)detailsButtonClick:(UIButton *)sender {
    self.textImageView.hidden = YES;
}

#pragma mark - 文档
- (IBAction)textButtonClick:(UIButton *)sender {
    self.textImageView.hidden = NO;
}


#pragma mark - alertView
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

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

