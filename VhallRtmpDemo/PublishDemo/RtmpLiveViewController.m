//
//  DemoViewController.m
//  PublishDemo
//
//  Created by liwenlong on 15/10/9.
//  Copyright (c) 2015年 vhall. All rights reserved.
//

#import "RtmpLiveViewController.h"
#import "CameraEngineRtmp.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "UIAlertView+ITTAdditions.h"
#import "CONSTS.h"
#import "MBProgressHUD.h"
#import "VHallLivePublish.h"

@interface RtmpLiveViewController ()<CameraEngineRtmpDelegate,UITextFieldDelegate>
{
    BOOL  _isStart;
    BOOL  _torchType;
    BOOL  _onlyVideo;
    BOOL  _isFontVideo;
    MBProgressHUD * _hud;
}

@property (weak, nonatomic) IBOutlet UIView *perView;

@property (strong, nonatomic)VHallLivePublish *engine;

@property (weak, nonatomic) IBOutlet UIButton *startAndStopBtn;
@property (weak, nonatomic) IBOutlet UILabel *bitRateLabel;
@property (weak, nonatomic) IBOutlet UIButton *torchBtn;
@property (weak, nonatomic) IBOutlet UIView *networkStatusView;

@end

@implementation RtmpLiveViewController

#pragma mark - UIButton Event
- (IBAction)closeBtnClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    [self.navigationController popViewControllerAnimated:NO];
    [_engine destoryObject];
    self.engine = nil;
}

- (IBAction)swapBtnClick:(id)sender
{
    _isFontVideo = !_isFontVideo;
    if (_isFontVideo) {
        [_engine swapCameras:AVCaptureDevicePositionFront];
        _torchBtn.hidden = YES;
    }else{
         [_engine swapCameras:AVCaptureDevicePositionBack];
        _torchBtn.hidden = NO;
    }
}

- (IBAction)torchBtnClick:(id)sender
{
    _torchType = !_torchType;
    if (_torchType) {
        [_engine setDeviceTorchModel:AVCaptureTorchModeOn];
    }else{
        [_engine setDeviceTorchModel:AVCaptureTorchModeOff];
    }
}

- (IBAction)onlyVideoBtnClick:(id)sender
{
    _onlyVideo = !_onlyVideo;
    if (_onlyVideo)
    {
        //[_engine pauseAudioCapture];
        _engine.isMute = YES;
        [UIAlertView popupAlertByDelegate:nil title:@"开始静音" message:nil cancel:@"知道了" others:nil];
    }
    else
    {
        _engine.isMute = NO;
        //[_engine pauseAudioCapture];
        [UIAlertView popupAlertByDelegate:nil title:@"结束静音" message:nil cancel:@"知道了" others:nil];
    }
}

- (IBAction)startPlayer
{
    if (!_isStart)
    {
        [_hud show:YES];
        _engine.videoResolution = _videoResolution;
        _engine.bitRate = self.bitrate;

       NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
       param[@"id"] =  _roomId;
       param[@"app_key"] = AppKey;
       param[@"access_token"] = _token;
       param[@"app_secret_key"] = AppSecretKey;
       [_engine startLive:param];
       
    }else{
        
        _bitRateLabel.text = @"";
        [_hud hide:YES];
        [_startAndStopBtn setTitle:@"开始直播" forState:UIControlStateNormal];
        [_engine disconnect];//停止向服务器推流
        
    }
    _isStart = !_isStart;
}

#pragma mark - Private Method

-(void)initDatas
{
    _isStart = NO;
    _torchType = NO;
    _onlyVideo = NO;
    _isFontVideo = NO;
    _videoResolution = kHVideoResolution;
}

- (void)initViews
{
    //阻止iOS设备锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self registerLiveNotification];
    _hud = [[MBProgressHUD alloc]initWithView:self.view];
    _networkStatusView.layer.cornerRadius = 7;
    _networkStatusView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_hud];
}

- (void)initCameraEngine
{
    DeviceOrgiation deviceOrgiation;
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait)
    {
        deviceOrgiation = kDevicePortrait;
    }else{
        deviceOrgiation = kDeviceLandSpaceRight;
    }

    self.engine = [[VHallLivePublish alloc] initWithOrgiation:deviceOrgiation];

    self.engine.videoResolution = _videoResolution;
    self.engine.displayView.frame = _perView.bounds;
    self.engine.publishConnectTimes = 2;
    self.engine.delegate = self;
    [self.perView insertSubview:_engine.displayView atIndex:0];
    
    //视频初始化
    BOOL ret = [_engine initCaptureVideo:AVCaptureDevicePositionBack];
    if (!ret) {
        VHLog(@"initCaptureVideo 调用失败！");
    }
    //音频初始化
    [_engine initAudio];
    //开始视频采集
    [_engine startVideoCapture];
}

//注册通知
- (void)registerLiveNotification
{
    [self.view addObserver:self forKeyPath:kViewFramePath options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive)name:UIApplicationWillResignActiveNotification object:nil];
}


#pragma mark - CameraEngineDelegate

-(void)firstCaptureImage:(UIImage *)image
{
    VHLog(@"第一张图片");
}

-(void)publishStatus:(LiveStatus)liveStatus withInfo:(NSDictionary *)info
{
    void (^resetStartPaly)(NSString * msg) = ^(NSString * msg){
        _isStart = NO;
        _bitRateLabel.text = @"";
        [_startAndStopBtn setTitle:@"开始直播" forState:UIControlStateNormal];
        if (APPDELEGATE.isNetworkReachable) {
            [UIAlertView popupAlertByDelegate:nil title:msg message:nil];
        }else{
            [UIAlertView popupAlertByDelegate:nil title:@"没有可以使用的网络" message:nil];
        }
    };

    NSString * content = info[@"content"];
    switch (liveStatus)
    {
        case kLiveStatusUploadSpeed:
        {
            _bitRateLabel.text = [NSString stringWithFormat:@"%@ kb/s",content];
        }
            break;
        case kLiveStatusPushConnectSucceed:
        {
            [_hud hide:YES];
            [_startAndStopBtn setTitle:@"停止直播" forState:UIControlStateNormal];
        }
            break;
        case kLiveStatusSendError:
        {
            [_hud hide:YES];
            resetStartPaly(@"网断啦！不能再带你直播带你飞了");
        }
            break;
        case kLiveStatusPushConnectError:
        {
            [_hud hide:YES];
            resetStartPaly(@"服务器任性...连接失败");
        }
            break;
        case kLiveStatusParamError:
        {
            [_hud hide:YES];
            resetStartPaly(@"参数错误");
        }
            break;
        case kLiveStatusGetUrlError:
        {
            [_hud hide:YES];
            [MBHUDHelper showWarningWithText:content];
        }
            break;
        case kLiveStatusNetworkStatus:
        {
            float networkStatus = [content floatValue];
            if (networkStatus>=0) {
                _networkStatusView.backgroundColor = [UIColor greenColor];
            }else{
                _networkStatusView.backgroundColor = [UIColor redColor];
            }
            VHLog(@"kLiveStatusNetworkStatus:%@",content);
        }
            break;
        default:
            break;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //初始化CameraEngine
    [self initCameraEngine];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    //允许iOS设备锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self.view removeObserver:self forKeyPath:kViewFramePath];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
     VHLog(@"%@ dealloc",[[self class]description]);
}

#pragma mark - ObserveValueForKeyPath
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:kViewFramePath])
    {
        CGRect frame = [[change objectForKey:NSKeyValueChangeNewKey]CGRectValue]; 
        self.engine.displayView.frame = frame;
    }
}

-(void)willResignActive
{
   _isStart = YES;
   [self startPlayer];
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
