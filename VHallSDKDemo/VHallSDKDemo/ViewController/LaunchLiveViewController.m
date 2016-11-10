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
#import "WatchLiveOnlineTableViewCell.h"
#import "WatchLiveChatTableViewCell.h"
#import "VHallApi.h"

@interface LaunchLiveViewController ()<CameraEngineRtmpDelegate, VHallChatDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    BOOL  _isVideoStart;
    BOOL  _isAudioStart;
    BOOL  _torchType;
    BOOL  _onlyVideo;
    BOOL  _isFontVideo;
    BOOL  _isReciveHistory;
    MBProgressHUD * _hud;
    UIButton * _lastFilterSelectBtn;
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
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;
@property (weak, nonatomic) IBOutlet UIView *chatContainerView;
@property (weak, nonatomic) IBOutlet UITableView *chatView;
@property (weak, nonatomic) IBOutlet UITextField *chatMsgInput;
@property (weak, nonatomic) IBOutlet UIButton *chatMsgSend;
@property (weak, nonatomic) IBOutlet UIButton *filterBtn;
@property (weak, nonatomic) IBOutlet UIView *filterView;
@property (weak, nonatomic) IBOutlet UIButton *filterViewCloseBtn;
@property (weak, nonatomic) IBOutlet UIButton *defaultFilterSelectBtn;
@end

@implementation LaunchLiveViewController
{
    VHallChat         *_chat;       //聊天
    NSMutableArray    *_chatDataArray;
}

#pragma mark -
#pragma mark - Lifecycle

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

-(void)LaunchLiveWillResignActive
{
    [_engine disconnect];
}

-(void)LaunchLiveDidBecomeActive
{
    [_engine reconnect];
}

- (IBAction)closeBtnClick:(id)sender
{
    [_engine stopLive];//停止活动
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - Lifecycle(Private)

- (void)registerLiveNotification
{
    [self.view addObserver:self forKeyPath:kViewFramePath options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LaunchLiveWillResignActive)name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LaunchLiveDidBecomeActive)name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)initDatas
{
    _isVideoStart = NO;
    _isAudioStart = NO;
    _torchType = NO;
    _onlyVideo = NO;
    _isFontVideo = NO;
    _videoResolution = kHVideoResolution;
    _chat = [[VHallChat alloc] init];
    _chatDataArray = [NSMutableArray arrayWithCapacity:0];
}

- (void)initViews
{
    //阻止iOS设备锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self registerLiveNotification];
    _hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:_hud];
    [_hud hide:YES];
    _networkStatusView.layer.cornerRadius = 7;
    _networkStatusView.backgroundColor = [UIColor greenColor];
    // chat在播放之前初始化并设置代理
    _chatBtn.hidden = YES;
    _chat.delegate = self;
    [self filterSettingBtnClick:_defaultFilterSelectBtn];
    // TODO:暂时不支持此功能，但保留。
    _audioStartAndStopBtn.hidden = YES;
    _filterBtn.hidden=YES;
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
    BOOL ret = [_engine initCaptureVideo:AVCaptureDevicePositionBack];
    if (!ret) {
        VHLog(@"initCaptureVideo 调用失败！");
    }
    //音频初始化
    [_engine initAudio];
    
    self.engine.displayView.frame = _perView.bounds;
    self.engine.publishConnectTimes = 2;
    self.engine.videoCaptureFPS = (int)_videoCaptureFPS;
    self.engine.delegate = self;
    [self.perView insertSubview:_engine.displayView atIndex:0];
    
    //开始视频采集
    [_engine startVideoCapture];

}

#pragma mark - Lifecycle(ObserveValueForKeyPath)
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:kViewFramePath])
    {
        CGRect frame = [[change objectForKey:NSKeyValueChangeNewKey]CGRectValue];
        self.engine.displayView.frame = frame;
    }
}

#pragma mark -
#pragma mark - Camera

- (IBAction)swapBtnClick:(id)sender
{
    UIButton *btn=(UIButton*)sender;
    btn.enabled=NO;
    _isFontVideo = !_isFontVideo;
    
    if (_isFontVideo)
    {
      BOOL success=  [_engine swapCameras:AVCaptureDevicePositionFront];
        if(success)
        {
             _torchBtn.hidden = YES;
            //禁止快速切换摄像头
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                btn.enabled=YES;
               
            });
            
          
        }
        
    }else{
       BOOL success=  [_engine swapCameras:AVCaptureDevicePositionBack];
        if (success)
        {
            _torchBtn.hidden = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                btn.enabled=YES;
                
            });
        }
        
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

- (IBAction)startVideoPlayer
{
#if (TARGET_IPHONE_SIMULATOR)
    [self showMsg:@"无法在模拟器上发起直播！" afterDelay:1.5];
    return;
#endif
    
    if([DEMO_AppKey isEqualToString:@"替换成您自己的AppKey"])
    {
        [self showMsg:@"请填写CONSTS.h中的AppKey" afterDelay:1.5];
        return;
    }
    
    if (!_isVideoStart)
    {
        //        _isAudioStart = YES;
        //        [self startAudioPlayer];
        //    self.engine.audioBitRate = _audioBitRate;
        
        _engine.videoResolution = _videoResolution;
        _engine.videoBitRate = _videoBitRate;
        _engine.audioBitRate = _audioBitRate;
        _chatBtn.hidden = NO;
        [_hud show:YES];
        NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
        param[@"id"] =  _roomId;
        param[@"access_token"] = _token;
        param[@"is_single_audio"] = @"0";    // 0 ：视频， 1：音频
        [_engine startLive:param];
    }else{
        
        _bitRateLabel.text = @"";
        _chatBtn.hidden = YES;
        [_hud hide:YES];
        [_videoStartAndStopBtn setTitle:@"开始直播" forState:UIControlStateNormal];
        [_engine stopLive];//停止活动
    }
    _logView.hidden = YES;
    _isVideoStart = !_isVideoStart;
}

- (IBAction)startAudioPlayer
{
    //    TODO:暂时不支持此功能，但保留。
    //    if (!_isAudioStart)
    //    {
    //        _isVideoStart = YES;
    //        [self startVideoPlayer];
    //
    //        _logView.hidden = NO;
    //        _chatBtn.hidden = NO;
    //        [_hud show:YES];

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

#pragma mark - Camera(CameraEngineDelegate)

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
        dispatch_async(dispatch_get_main_queue(), ^{
            if (APPDELEGATE.isNetworkReachable) {
                [UIAlertView popupAlertByDelegate:nil title:msg message:nil];
            }else{
                [UIAlertView popupAlertByDelegate:nil title:@"没有可以使用的网络" message:nil];
            }
        });
    };

    [_hud hide:YES];
    
    BOOL errorLiveStatus = NO;
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
            resetStartPlay(@"网断啦！不能再带你直播带你飞了");
            errorLiveStatus = YES;
        }
            break;
        case kLiveStatusPushConnectError:
        {
            resetStartPlay(@"服务器任性...连接失败");
            errorLiveStatus = YES;
        }
            break;
        case kLiveStatusParamError:
        {
            resetStartPlay(@"参数错误");
            errorLiveStatus = YES;
        }
            break;
        case kLiveStatusGetUrlError:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBHUDHelper showWarningWithText:content];
            });
            errorLiveStatus = YES;
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
            errorLiveStatus = YES;
        }
            break;
        case kLiveStatusRecvStreamType:
        {
            
        }
            break;
        default:
            break;
    }
    
    if (errorLiveStatus)
    {
        _chatBtn.hidden = YES;
    }
    else
    {
        _chatBtn.hidden = NO;
    }
}

#pragma mark -
#pragma mark - Filter

- (IBAction)filterBtnClick:(UIButton *)sender
{
    _filterBtn.selected = YES;
    [UIView animateWithDuration:0.3f animations:^{
        
        _controlsView.alpha = 0.0f;
        _filterView.alpha = 1.0f;
        
    }];
}

- (IBAction)filterViewCloseBtnClick:(UIButton *)sender
{
    _filterBtn.selected = NO;
    [UIView animateWithDuration:0.3f animations:^{
        
        _controlsView.alpha = 1.0f;
        _filterView.alpha = 0.0f;
        
    }];
}

- (IBAction)filterSettingBtnClick:(UIButton *)sender
{
    if (sender.selected) {
        return;
    }
    
    if (_lastFilterSelectBtn) {
        [_lastFilterSelectBtn setBackgroundColor:[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:0.5f]];
        _lastFilterSelectBtn.selected = NO;
    }
    
    sender.selected = YES;
    [sender setBackgroundColor:[UIColor colorWithRed:0.3f green:0.6f blue:0.6f alpha:1.0f]];
    _lastFilterSelectBtn = sender;
}
#pragma mark -
#pragma mark - Chat && QA

- (IBAction)chatBtnClick:(id)sender
{
    if (!_isReciveHistory)
    {
        [_chat getHistoryWithType:NO success:^(NSArray * msgs) {
            
            if (msgs.count > 0) {
                [_chatDataArray addObjectsFromArray:msgs];
                if (_chatBtn.selected) {
                    [_chatView reloadData];
                    [_chatView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_chatDataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
            }
            
        } failed:^(NSDictionary *failedData) {
            
            NSString* code = [NSString stringWithFormat:@"%@", failedData[@"code"]];
            [UIAlertView popupAlertByDelegate:nil title:failedData[@"content"] message:code];
            
        }];
        _isReciveHistory = YES;
    }
    
    [self swipeView];
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
            [self swipeView];
        }
        
        if (UISwipeGestureRecognizerDirectionRight == sender.direction) {
            return;
        }
    }
}

- (void)swipeView
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

#pragma mark - Chat && QA(Delegate)
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

#pragma mark - Chat && QA(VHallChatDelegate)
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





@end
