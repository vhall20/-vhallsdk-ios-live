//
//  DemoViewController.m
//  PublishDemo
//
//  Created by liwenlong on 15/10/9.
//  Copyright (c) 2015年 vhall. All rights reserved.
//

#import "LaunchLiveViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIAlertView+ITTAdditions.h"
#import "CONSTS.h"
#import "MBProgressHUD.h"
#import "GPUImage.h"
#import "GPUImageBeautifyFilter.h"
#import "WatchLiveOnlineTableViewCell.h"
#import "WatchLiveChatTableViewCell.h"

#import "VHallApi.h"

@interface LaunchLiveViewController ()<CameraEngineRtmpDelegate, VHallLivePublishFilterDelegate, VHallChatDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    BOOL  _isVideoStart;
    BOOL  _isAudioStart;
    BOOL  _torchType;
    BOOL  _onlyVideo;
    BOOL  _isFontVideo;
    MBProgressHUD * _hud;
}

@property (strong, nonatomic)VHallLivePublish *engine;
@property (weak, nonatomic) IBOutlet UIView *perView;
@property (weak, nonatomic) IBOutlet UIImageView *logView;
@property (weak, nonatomic) IBOutlet UILabel *bitRateLabel;
@property (weak, nonatomic) IBOutlet UIView *networkStatusView;
@property (weak, nonatomic) IBOutlet UIView *controlsView;
@property (weak, nonatomic) IBOutlet UIButton *videoStartAndStopBtn;
@property (weak, nonatomic) IBOutlet UIButton *audioStartAndStopBtn;
@property (weak, nonatomic) IBOutlet UIButton *torchBtn;
@property (weak, nonatomic) IBOutlet UIButton *filterBtn;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;
@property (weak, nonatomic) IBOutlet UIView *chatContainerView;
@property (weak, nonatomic) IBOutlet UITableView *chatView;
@property (weak, nonatomic) IBOutlet UITextField *chatMsgInput;
@property (weak, nonatomic) IBOutlet UIButton *chatMsgSend;

@end

@implementation LaunchLiveViewController
{
    VHallChat         *_chat;       //聊天
    NSMutableArray    *_chatDataArray;
}

#pragma mark - UIButton Event
- (IBAction)closeBtnClick:(id)sender
{
    [_engine stopLive];//停止活动
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    [self.navigationController popViewControllerAnimated:NO];
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

- (IBAction)filterBtnClick:(id)sender
{
    _engine.openFilter = !_engine.openFilter;
    [_filterBtn setTitle:_engine.openFilter?@"关闭美颜":@"开启美颜" forState:UIControlStateNormal];
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

- (IBAction)chatBtnClick:(id)sender
{
    CGRect frame = _controlsView.frame;
    frame.origin.x = self.view.frame.size.width;
    _chatContainerView.frame = frame;
    _chatContainerView.hidden = NO;
    _controlsView.hidden = YES;
    
    [UIView animateWithDuration:0.3f animations:^{
        
        CGRect frame = _controlsView.frame;
        frame.origin.x = -self.view.frame.size.width;
        _controlsView.frame = frame;
        frame = _chatContainerView.frame;
        frame.origin.x = 0;
        _chatContainerView.frame = frame;
        
    } completion:^(BOOL finished) {
        
        if (finished) {
            _chatBtn.selected = YES;
            [_chatView reloadData];
        }
    }];
}

- (IBAction)startVideoPlayer
{
    if([DEMO_AppKey isEqualToString:@"替换成您自己的AppKey"])
    {
        [self showMsg:@"请填写CONSTS.h中的AppKey" afterDelay:1.5];
        return;
    }
    
    if (!_isVideoStart)
    {
//        _isAudioStart = YES;
//        [self startAudioPlayer];
        
        _filterBtn.hidden = YES;
        _chatBtn.hidden = NO;
        [_hud show:YES];
        _engine.openFilter = NO;
        _engine.videoResolution = _videoResolution;
        _engine.videoBitRate = _videoBitRate;
       NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
       param[@"id"] =  _roomId;
       param[@"access_token"] = _token;
       param[@"is_single_audio"] = @"0";    // 0 ：视频， 1：音频
       [_engine startLive:param];
    }else{
        
        _bitRateLabel.text = @"";
        _filterBtn.hidden = YES;
        _chatBtn.hidden = YES;
        _engine.openFilter = NO;
        [_hud hide:YES];
        [_videoStartAndStopBtn setTitle:@"开始直播" forState:UIControlStateNormal];
        [_engine stopLive];//停止活动
    }
    _logView.hidden = YES;
    _isVideoStart = !_isVideoStart;
    [_filterBtn setTitle:_engine.openFilter?@"关闭美颜":@"开启美颜" forState:UIControlStateNormal];
}

- (IBAction)startAudioPlayer
{
    // TODO:暂时不支持此功能，但保留。
//    if (!_isAudioStart)
//    {
//        _isVideoStart = YES;
//        [self startVideoPlayer];
//        
//        _logView.hidden = NO;
//        _chatBtn.hidden = NO;
//        [_hud show:YES];
//        _engine.audioBitRate = _audioBitRate;
//        NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
//        param[@"id"] =  _roomId;
//        param[@"access_token"] = _token;
//        param[@"is_single_audio"] = @"1";   // 0 ：视频， 1：音频
//        [_engine startLive:param];
//    }else{
//        _logView.hidden = YES;
//        _bitRateLabel.text = @"";
//        _chatBtn.hidden = YES;
//        [_hud hide:YES];
//        [_audioStartAndStopBtn setTitle:@"音频直播" forState:UIControlStateNormal];
//        [_engine disconnect];//停止向服务器推流
//    }
//    _isAudioStart = !_isAudioStart;
}

- (IBAction)changeView:(UISwipeGestureRecognizer *)sender
{
    if (!_isVideoStart) {
        return;
    }
    
    if (_chatBtn.selected)
    {
        if (UISwipeGestureRecognizerDirectionLeft == sender.direction) {
            return;
        }
        
        if (UISwipeGestureRecognizerDirectionRight == sender.direction) {
        
            [UIView animateWithDuration:0.3f animations:^{
                
                CGRect frame = _chatContainerView.frame;
                frame.origin.x = self.view.frame.size.width;
                _chatContainerView.frame = frame;
                frame = _controlsView.frame;
                frame.origin.x = 0;
                _controlsView.frame = frame;
                
            } completion:^(BOOL finished) {
                
                if (finished) {
                    _chatBtn.selected = NO;
                    _chatContainerView.hidden = YES;
                    _controlsView.hidden = NO;
                }
            }];
        }
    }
    else
    {
        if (UISwipeGestureRecognizerDirectionLeft == sender.direction) {
            [self chatBtnClick:_chatBtn];
        }
        
        if (UISwipeGestureRecognizerDirectionRight == sender.direction) {
            return;
        }
    }
}

#pragma mark - 发送
- (IBAction)sendMsgButtonClick:(UIButton *)sender {
    
    if (_chatBtn.selected == YES) {
        
        [_chat sendMsg:_chatMsgInput.text success:^{
            
            _chatMsgInput.text = @"";
            
        } failed:^(NSDictionary *failedData) {
            
            NSString* code = [NSString stringWithFormat:@"%@", failedData[@"code"]];
            [UIAlertView popupAlertByDelegate:nil title:failedData[@"content"] message:code];
            
        }];
        
        return;
    }
}

#pragma mark - Private Method

-(void)initDatas
{
    _isVideoStart = NO;
    _isAudioStart = NO;
    _torchType = NO;
    _onlyVideo = NO;
    _isFontVideo = NO;
    _videoResolution = kHVideoResolution;
    _chatDataArray = [NSMutableArray arrayWithCapacity:0];
}

- (void)initViews
{
    //阻止iOS设备锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self registerLiveNotification];
    _hud = [[MBProgressHUD alloc]initWithView:self.view];
    _networkStatusView.layer.cornerRadius = 7;
    _networkStatusView.backgroundColor = [UIColor greenColor];
    _filterBtn.hidden = YES;
    _chatBtn.hidden = YES;
    // chat在播放之前初始化并设置代理
    _chat = [[VHallChat alloc] init];
    _chat.delegate = self;
    [self.view addSubview:_hud];
    [_hud hide:YES];
    _controlsView.frame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    // TODO:暂时不支持此功能，但保留。
    _audioStartAndStopBtn.hidden = YES;
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
    self.engine.videoCaptureFPS = (int)_videoCaptureFPS;
    self.engine.delegate = self;
    self.engine.GPUFilterDelegate = self;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LaunchLiveWillResignActive)name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LaunchLiveDidBecomeActive)name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - CameraEngineDelegate

-(void)firstCaptureImage:(UIImage *)image
{
    VHLog(@"第一张图片");
}

-(void)publishStatus:(LiveStatus)liveStatus withInfo:(NSDictionary *)info
{
    void (^resetStartPlay)(NSString * msg) = ^(NSString * msg){
        _isVideoStart = NO;
        _bitRateLabel.text = @"";
        [_videoStartAndStopBtn setTitle:@"开始直播" forState:UIControlStateNormal];
        _chatBtn.hidden = YES;
        _filterBtn.hidden = YES;
        _engine.openFilter = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (APPDELEGATE.isNetworkReachable) {
                [UIAlertView popupAlertByDelegate:nil title:msg message:nil];
            }else{
                [UIAlertView popupAlertByDelegate:nil title:@"没有可以使用的网络" message:nil];
            }
        });
    };

    _chatBtn.hidden = NO;
    _filterBtn.hidden = YES;
    _engine.openFilter = NO;
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
            
            if (_isVideoStart) {
                [_videoStartAndStopBtn setTitle:@"停止直播" forState:UIControlStateNormal];
            }
            
            if (_isAudioStart) {
                [_audioStartAndStopBtn setTitle:@"停止直播" forState:UIControlStateNormal];
            }
        }
            break;
        case kLiveStatusSendError:
        {
            [_hud hide:YES];
            resetStartPlay(@"网断啦！不能再带你直播带你飞了");
            _chatBtn.hidden = YES;
            _filterBtn.hidden = YES;
            _engine.openFilter = NO;
        }
            break;
        case kLiveStatusPushConnectError:
        {
            [_hud hide:YES];
            resetStartPlay(@"服务器任性...连接失败");
            _chatBtn.hidden = YES;
            _filterBtn.hidden = YES;
            _engine.openFilter = NO;
        }
            break;
        case kLiveStatusParamError:
        {
            [_hud hide:YES];
            resetStartPlay(@"参数错误");
            _chatBtn.hidden = YES;
            _filterBtn.hidden = YES;
            _engine.openFilter = NO;
        }
            break;
        case kLiveStatusGetUrlError:
        {
            [_hud hide:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBHUDHelper showWarningWithText:content];
            });
            _chatBtn.hidden = YES;
            _filterBtn.hidden = YES;
            _engine.openFilter = NO;
        }
            break;
        case kLiveStatusUploadNetworkOK:
        {
            _networkStatusView.backgroundColor = [UIColor greenColor];
            VHLog(@"kLiveStatusNetworkStatus:%@",content);
        }
            break;
        case kLiveStatusUploadNetworkException:
        {
            _networkStatusView.backgroundColor = [UIColor redColor];
            VHLog(@"kLiveStatusNetworkStatus:%@",content);
            _chatBtn.hidden = YES;
            _filterBtn.hidden = YES;
            _engine.openFilter = NO;
        }
            break;
        case kLiveStatusRecvStreamType:
        {
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = nil;
    
    if (_chatBtn.selected)
    {
        id model = [_chatDataArray objectAtIndex:indexPath.row];
        if ([model isKindOfClass:[VHallOnlineStateModel class]])
        {
            static NSString * indetify = @"WatchLiveOnlineCell";
            cell = [tableView dequeueReusableCellWithIdentifier:indetify];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"WatchLiveOnlineTableViewCell" owner:nil options:nil] objectAtIndex:0];
            }
            ((WatchLiveOnlineTableViewCell *)cell).model = model;
        }
        else
        {
            static NSString * indetify = @"WatchLiveChatCell";
            cell = [tableView dequeueReusableCellWithIdentifier:indetify];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"WatchLiveChatTableViewCell" owner:self options:nil] objectAtIndex:0];
            }
            ((WatchLiveChatTableViewCell *)cell).model = model;
        }
    }
    
    cell.width = self.view.bounds.size.width;
    cell.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f];
    return cell;
}

-(NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (_chatBtn.selected) {
        return _chatDataArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if (_chatBtn.selected)
    {
        id mode = [_chatDataArray objectAtIndex:indexPath.row];
        if ([mode isKindOfClass:[VHallOnlineStateModel class]])
        {
            height = 60;
        }
        else
        {
            height = 120;
        }
    }
    return height;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_chatMsgInput resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_chatMsgInput resignFirstResponder];
}

#pragma mark - LivePublishFilterDelegate
- (void)addGPUImageFilter:(GPUImageVideoCamera *)source Output:(GPUImageRawDataOutput *)output
{
    GPUImageBeautifyFilter *filter = [[GPUImageBeautifyFilter alloc] init];
    [source addTarget:filter];
    [filter addTarget:output];
}

#pragma mark - VHallChatDelegate
- (void)reciveOnlineMsg:(NSArray *)msgs
{
    if (msgs.count > 0) {
        [_chatDataArray addObjectsFromArray:msgs];
        if (_chatBtn.selected) {
            [_chatView reloadData];
            [_chatView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_chatDataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

- (void)reciveChatMsg:(NSArray *)msgs
{
    if (msgs.count > 0) {
        [_chatDataArray addObjectsFromArray:msgs];
        if (_chatBtn.selected) {
            [_chatView reloadData];
            [_chatView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_chatDataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
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
    if (_chat) {
        _chat = nil;
    }
    
    if (_engine) {
        _engine = nil;
    }
    
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

-(void)LaunchLiveWillResignActive
{
    [_engine disconnect];
}

-(void)LaunchLiveDidBecomeActive
{
    [_engine reconnect];
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
