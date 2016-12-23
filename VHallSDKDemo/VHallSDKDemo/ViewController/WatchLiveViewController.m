//
//  WatchRTMPViewController.m
//  VHallSDKDemo
//
//  Created by developer_k on 16/4/13.
//  Copyright © 2016年 vhall. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "WatchLiveViewController.h"
#import "ALMoviePlayerController.h"
#import "ALMoviePlayerControls.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#import "WatchLiveOnlineTableViewCell.h"
#import "WatchLiveChatTableViewCell.h"
#import "WatchLiveQATableViewCell.h"
#import "WatchLiveLotteryViewController.h"

#import "VHallApi.h"

@interface WatchLiveViewController ()<VHallMoviePlayerDelegate, VHallChatDelegate, VHallQADelegate, VHallLotteryDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    VHallMoviePlayer  *_moviePlayer;//播放器
    UIView            *_showView;
    VHallChat         *_chat;       //聊天
    VHallQAndA        *_QA;         //问答
    VHallLottery      *_lottery;    //抽奖
    UIImageView       *_logView;    //当播放音频时显示的图片
    WatchLiveLotteryViewController *_lotteryVC; //抽奖VC
    BOOL _isStart;
    BOOL _isMute;
    BOOL _isAllScreen;
    BOOL _isReciveHistory;
    int  _bufferCount;
    NSMutableArray    *_chatDataArray;
    NSMutableArray    *_QADataArray;
}

@property (weak, nonatomic) IBOutlet UILabel *bufferCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *allScreenBtn;
@property (weak, nonatomic) IBOutlet UILabel *bitRateLabel;
@property (weak, nonatomic) IBOutlet UIButton *startAndStopBtn;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *textImageView;
@property (weak, nonatomic) IBOutlet UILabel *liveTypeLabel;

@property (weak, nonatomic) IBOutlet UIButton *detailBtn;
@property (weak, nonatomic) IBOutlet UIButton *docBtn;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;
@property (weak, nonatomic) IBOutlet UIButton *QABtn;
@property (weak, nonatomic) IBOutlet UITableView *chatView;
@property (weak, nonatomic) IBOutlet UITextField *chatMsgInput;
@property (weak, nonatomic) IBOutlet UIButton *chatMsgSend;

@property (nonatomic,assign) VHallMovieVideoPlayMode playModelTemp;
@property (nonatomic,strong) UILabel*textLabel;

@property (weak, nonatomic) IBOutlet UIButton *definitionBtn0;
@property (weak, nonatomic) IBOutlet UIButton *definitionBtn1;
@property (weak, nonatomic) IBOutlet UIButton *definitionBtn2;
@property (weak, nonatomic) IBOutlet UIButton *definitionBtn3;
@property (weak, nonatomic) IBOutlet UIButton *playModeBtn0;
@property (weak, nonatomic) IBOutlet UIButton *playModeBtn1;
@property (weak, nonatomic) IBOutlet UIButton *playModeBtn2;
@property (weak, nonatomic) IBOutlet UIButton *playModeBtn3;
@end

@implementation WatchLiveViewController

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
    _chatDataArray = [NSMutableArray arrayWithCapacity:0];
    _QADataArray = [NSMutableArray arrayWithCapacity:0];
}

- (void)initViews
{
    //阻止iOS设备锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self addPanGestureRecognizer];
    [self registerLiveNotification];
    // chat & QA 在播放之前初始化并设置代理
    _chat = [[VHallChat alloc] init];
    _chat.delegate = self;
    _QA = [[VHallQAndA alloc] init];
    _QA.delegate = self;
    _lottery = [[VHallLottery alloc] init];
    _lottery.delegate = self;
    _moviePlayer = [[VHallMoviePlayer alloc]initWithDelegate:self];
    self.view.clipsToBounds = YES;
    _moviePlayer.movieScalingMode = kRTMPMovieScalingModeAspectFit;
    _moviePlayer.bufferTime = (int)_bufferTimes;
    _moviePlayer.reConnectTimes = 2;
    _logView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vhallLogo.png"]];
    _logView.backgroundColor = [UIColor whiteColor];
    _logView.contentMode = UIViewContentModeCenter;
    [self.backView addSubview:_moviePlayer.moviePlayerView];
    [self.backView sendSubviewToBack:_moviePlayer.moviePlayerView];
    [_moviePlayer.moviePlayerView addSubview:_logView];    
    [self.view bringSubviewToFront:self.backView];
    _textImageView.hidden = YES;
    _logView.hidden = YES;
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
    if([DEMO_AppKey isEqualToString:@"替换成您自己的AppKey"])//此处只用于提示信息判断，只替换CONSTS.h中的AppKey即可
    {
        [self showMsg:@"请填写CONSTS.h中的AppKey" afterDelay:1.5];
        return;
    }
    
    _definitionBtn0.hidden = YES;
    _definitionBtn1.hidden = YES;
    _definitionBtn2.hidden = YES;
    _definitionBtn3.hidden = YES;
    
    _playModeBtn0.hidden = YES;
    _playModeBtn1.hidden = YES;
    _playModeBtn2.hidden = YES;
    _playModeBtn3.hidden = YES;

    if (_isStart) {
        _bufferCount = 0;
        //todo
        NSMutableDictionary * param = [[NSMutableDictionary alloc]init];
        param[@"id"] =  _roomId;
        param[@"name"] = DEMO_Setting.nickName;
        param[@"email"] = DEMO_Setting.email;
        if (_kValue&&_kValue.length>0) {
            param[@"pass"] = _kValue;
        }
        [_moviePlayer startPlay:param];
        if (self.playModelTemp == VHallMovieVideoPlayModeTextAndVoice || self.playModelTemp == VHallMovieVideoPlayModeVoice) {
            self.liveTypeLabel.text = @"语音直播中";
        }else{
            self.liveTypeLabel.text = @"";
        }
    }else{
        _bitRateLabel.text = @"";
        [_startAndStopBtn setTitle:@"开始播放" forState:UIControlStateNormal];
        [_moviePlayer stopPlay];
        if (self.playModelTemp == VHallMovieVideoPlayModeTextAndVoice || self.playModelTemp == VHallMovieVideoPlayModeVoice) {
            self.liveTypeLabel.text = @"已暂停语音直播";
        }
        
        self.chatBtn.hidden = YES;
        self.QABtn.hidden = YES;
        [self detailsButtonClick: nil];
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
- (IBAction)muteBtnClick:(UIButton *)sender
{
    _isMute = !_isMute;
    [_moviePlayer setMute:_isMute];
    if (_isMute) {
        [sender setTitle:@"取消" forState:UIControlStateNormal];
    }else{
        [sender setTitle:@"静音" forState:UIControlStateNormal];
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
            frame = self.backView.bounds;
        } else {
            //横屏
            frame = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
        }
        _moviePlayer.moviePlayerView.frame = frame;
        _logView.frame = _moviePlayer.moviePlayerView.bounds;
        _lotteryVC.view.frame = _showView.bounds;
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
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillLayoutSubviews
{
    _moviePlayer.moviePlayerView.frame = self.backView.bounds;
    _logView.frame = _moviePlayer.moviePlayerView.bounds;
    _lotteryVC.view.frame = _showView.bounds;
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
    
    if (_QA) {
        _QA = nil;
    }
    
    if (_lottery) {
        _lottery = nil;
    }
    
    if (_lotteryVC) {
        [_lotteryVC.view removeFromSuperview];
        [_lotteryVC removeFromParentViewController];
        [_lotteryVC destory];
        _lotteryVC = nil;
    }
    
    //阻止iOS设备锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self.view removeObserver:self forKeyPath:kViewFramePath];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    VHLog(@"%@ dealloc",[[self class]description]);
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
    else if (_QABtn.selected)
    {
        static NSString * qaIndetify = @"WatchLiveQACell";
        cell = [tableView dequeueReusableCellWithIdentifier:qaIndetify];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WatchLiveQATableViewCell" owner:self options:nil] objectAtIndex:0];
        }
        ((WatchLiveQATableViewCell *)cell).model = [_QADataArray objectAtIndex:indexPath.row];
    }
   else
    {
        static NSString * qaIndetify = @"identifiCell";
        cell = [tableView dequeueReusableCellWithIdentifier:qaIndetify];
        if (!cell) {
            cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:qaIndetify];
        }
    }
    cell.width = self.view.bounds.size.width;
    return cell;
}

-(NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (_chatBtn.selected) {
        return _chatDataArray.count;
    }
    
    if (_QABtn.selected) {
        return _QADataArray.count;
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
    
    if (_QABtn.selected)
    {
        height = 120;
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

#pragma mark - VHMoviePlayerDelegate
-(void)moviePlayerWillMoveFromWindow
{
}

-(void)connectSucceed:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:YES];
    [_startAndStopBtn setTitle:@"停止播放" forState:UIControlStateNormal];
    self.chatBtn.hidden = NO;
    self.QABtn.hidden = NO;
    _definitionBtn0.selected = NO;
    _definitionBtn1.selected = NO;
    _definitionBtn2.selected = NO;
    _definitionBtn3.selected = NO;
    switch (_moviePlayer.curDefinition) {
        case VHallMovieDefinitionOrigin:
            _definitionBtn0.selected = YES;
            break;
        case VHallMovieDefinitionUHD:
            _definitionBtn1.selected = YES;
            break;
        case VHallMovieDefinitionHD:
            _definitionBtn2.selected = YES;
            break;
        case VHallMovieDefinitionSD:
            _definitionBtn3.selected = YES;
            break;
        default:
            break;
    }
}

-(void)bufferStart:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    _bufferCount++;
    _bufferCountLabel.text = [NSString stringWithFormat:@"卡顿次数： %d",_bufferCount];
    [MBProgressHUD showHUDAddedTo:_moviePlayer.moviePlayerView animated:YES];
}

-(void)bufferStop:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:YES];

}

-(void)downloadSpeed:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info
{
    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:YES];

    NSString * content = info[@"content"];
    _bitRateLabel.text = [NSString stringWithFormat:@"%@ kb/s",content];
    VHLog(@"downloadSpeed:%@",[info description]);
}

- (void)recStreamtype:(VHMoviePlayer*)moviePlayer info:(NSDictionary*)info
{
    VHallStreamType streamType = (VHallStreamType)[info[@"content"] intValue];
    if (streamType == kVHallStreamTypeVideoAndAudio) {
        _logView.hidden = YES;
    } else if(streamType == kVHallStreamTypeOnlyAudio){
        _logView.hidden = NO;
    }
}

- (void)playError:(LivePlayErrorType)livePlayErrorType info:(NSDictionary *)info;
{
    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:YES];
    void (^resetStartPlay)(NSString * msg) = ^(NSString * msg){
        _isStart = YES;
        _bitRateLabel.text = @"";
        [_startAndStopBtn setTitle:@"开始播放" forState:UIControlStateNormal];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self detailsButtonClick: nil];
            self.chatBtn.hidden = YES;
            self.QABtn.hidden = YES;
            if (APPDELEGATE.isNetworkReachable) {
                [UIAlertView popupAlertByDelegate:nil title:msg message:nil];
            }else{
                [UIAlertView popupAlertByDelegate:nil title:@"没有可以使用的网络" message:nil];
            }
        });
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
            [self detailsButtonClick: nil];
            self.chatBtn.hidden = YES;
            self.QABtn.hidden = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBHUDHelper showWarningWithText:info[@"content"]];
            });
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
        case VHallMovieVideoPlayModeVoice:
        {
            self.liveTypeLabel.text = @"语音直播中";
        }
            break;
        default:
            break;
    }

    [self alertWithMessage:playMode];
}

-(void)VideoPlayModeList:(NSArray*)playModeList
{
    _playModeBtn0.hidden = YES;
    _playModeBtn1.hidden = YES;
    _playModeBtn2.hidden = YES;
    _playModeBtn3.hidden = YES;
    
    for (NSNumber *playMode in playModeList) {
        switch ([playMode intValue]) {
            case VHallMovieVideoPlayModeMedia:
                _playModeBtn1.hidden = NO;
                break;
            case VHallMovieVideoPlayModeTextAndVoice:
                _playModeBtn3.hidden = NO;
                break;
            case VHallMovieVideoPlayModeTextAndMedia:
                _playModeBtn2.hidden = NO;
                break;
            case VHallMovieVideoPlayModeVoice:
                _playModeBtn0.hidden = NO;
                break;
            default:
                _playModeBtn0.hidden = YES;
                _playModeBtn1.hidden = YES;
                _playModeBtn2.hidden = YES;
                _playModeBtn3.hidden = YES;
                break;
        }
    }
}

-(void)ActiveState:(VHallMovieActiveState)activeState
{
    VHLog(@"activeState-%ld",(long)activeState);
}

- (void)VideoDefinitionList: (NSArray*)definitionList
{
    NSLog(@"可用分辨率%@ 当前分辨率：%ld",definitionList,(long)_moviePlayer.curDefinition);
    _definitionBtn0.hidden = YES;
    _definitionBtn1.hidden = YES;
    _definitionBtn2.hidden = YES;
    _definitionBtn3.hidden = YES;
    
    for (NSNumber *num in definitionList) {
        switch ([num intValue]) {
            case VHallMovieDefinitionOrigin:
                _definitionBtn0.hidden = NO;
                break;
            case VHallMovieDefinitionUHD:
                _definitionBtn1.hidden = NO;
                break;
            case VHallMovieDefinitionHD:
                _definitionBtn2.hidden = NO;
                break;
            case VHallMovieDefinitionSD:
                _definitionBtn3.hidden = NO;
                break;
            default:
                break;
        }
    }
}

- (void)LiveStoped
{
    NSLog(@"直播已结束");
    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:YES];
    _isStart = NO;
    [self stopWatchBtnClick:nil];
    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"直播已结束" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
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

#pragma mark - VHallQAndADelegate
- (void)reciveQAMsg:(NSArray *)msgs
{
    if (msgs.count > 0)
    {
        VHallQAModel * qaModel = [msgs lastObject];
        if (qaModel.questionModel) {
            [_QADataArray addObject:qaModel.questionModel];
        }
        
        if (qaModel.answerModels && qaModel.answerModels.count > 0) {
            [_QADataArray addObjectsFromArray:qaModel.answerModels];
        }
        
        if (_QABtn.selected) {
            [_chatView reloadData];
        }
    }
}

#pragma mark - VHallLotteryDelegate
- (void)startLottery:(VHallStartLotteryModel *)msg
{
    if (_lotteryVC) {
        [_lotteryVC.view removeFromSuperview];
        [_lotteryVC removeFromParentViewController];
        _lotteryVC = nil;
    }
    
    _lotteryVC = [[WatchLiveLotteryViewController alloc] initWithNibName:@"WatchLiveLotteryViewController" bundle:nil];
    _lotteryVC.lottery = _lottery;
    _lotteryVC.view.frame = _showView.bounds;
    [_showView addSubview:_lotteryVC.view];
}

- (void)endLottery:(VHallEndLotteryModel *)msg
{
    if (!_lotteryVC) {
        _lotteryVC = [[WatchLiveLotteryViewController alloc] initWithNibName:@"WatchLiveLotteryViewController" bundle:nil];
        _lotteryVC.lottery = _lottery;
        _lotteryVC.view.frame = _showView.bounds;
        [_showView addSubview:_lotteryVC.view];
    }
    _lotteryVC.lotteryOver = YES;
    _lotteryVC.endLotteryModel = msg;
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
        _moviePlayer.moviePlayerView.frame = self.backView.bounds;
        _logView.frame = _moviePlayer.moviePlayerView.bounds;
        _lotteryVC.view.frame = _showView.bounds;
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
    self.chatView.hidden = YES;
    self.chatMsgInput.hidden = YES;
    self.chatMsgSend.hidden = YES;
    self.detailBtn.selected = YES;
    self.docBtn.selected = NO;
    self.chatBtn.selected = NO;
    self.QABtn.selected = NO;
    self.chatMsgInput.text = @"";
}

#pragma mark - 文档
- (IBAction)textButtonClick:(UIButton *)sender {
    self.textImageView.hidden = NO;
    self.chatView.hidden = YES;
    self.chatMsgInput.hidden = YES;
    self.chatMsgSend.hidden = YES;
    self.detailBtn.selected = NO;
    self.docBtn.selected = YES;
    self.chatBtn.selected = NO;
    self.QABtn.selected = NO;
    self.chatMsgInput.text = @"";
}

#pragma mark - 聊天
- (IBAction)chatButtonClick:(UIButton *)sender {
    self.textImageView.hidden = YES;
    self.chatView.hidden = NO;
    self.chatMsgInput.hidden = NO;
    self.chatMsgSend.hidden = NO;
    self.detailBtn.selected = NO;
    self.docBtn.selected = NO;
    self.chatBtn.selected = YES;
    self.QABtn.selected = NO;
    self.chatMsgInput.text = @"";
    [_chatView reloadData];
    
    if (!_isReciveHistory)
    {
        [_chat getHistoryWithType:YES success:^(NSArray * msgs) {
            
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
}

#pragma mark - 问答
- (IBAction)QAButtonClick:(UIButton *)sender {
    self.textImageView.hidden = YES;
    self.chatView.hidden = NO;
    self.chatMsgInput.hidden = NO;
    self.chatMsgSend.hidden = NO;
    self.detailBtn.selected = NO;
    self.docBtn.selected = NO;
    self.chatBtn.selected = NO;
    self.QABtn.selected = YES;
    self.chatMsgInput.text = @"";
    [_chatView reloadData];
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
    
    if (_QABtn.selected == YES) {
        
        [_QA sendMsg:_chatMsgInput.text success:^{
            
            _chatMsgInput.text = @"";
            
        } failed:^(NSDictionary *failedData) {
            
            NSString* code = [NSString stringWithFormat:@"%@", failedData[@"code"]];
            [UIAlertView popupAlertByDelegate:nil title:failedData[@"content"] message:code];
            
        }];
        
        return;
    }
}

#pragma mark -
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


- (IBAction)definitionBtnCLicked:(UIButton *)sender {
    if(sender.isSelected)return;
    
    [MBProgressHUD showHUDAddedTo:_moviePlayer.moviePlayerView animated:YES];
    [_moviePlayer setDefinition:sender.tag];
    _definitionBtn0.selected = NO;
    _definitionBtn1.selected = NO;
    _definitionBtn2.selected = NO;
    _definitionBtn3.selected = NO;
    _playModeBtn0.selected = NO;
    _playModeBtn1.selected = NO;
    _playModeBtn2.selected = NO;
    _playModeBtn3.selected = NO;
    switch (_moviePlayer.curDefinition) {
        case VHallMovieDefinitionOrigin:
            _definitionBtn0.selected = YES;
            break;
        case VHallMovieDefinitionUHD:
            _definitionBtn1.selected = YES;
            break;
        case VHallMovieDefinitionHD:
            _definitionBtn2.selected = YES;
            break;
        case VHallMovieDefinitionSD:
            _definitionBtn3.selected = YES;
            break;
        default:
            break;
    }
}

- (IBAction)playModeBtnCLicked:(UIButton *)sender {
     if(sender.isSelected)return;
    
    [MBProgressHUD showHUDAddedTo:_moviePlayer.moviePlayerView animated:YES];
    
    _moviePlayer.playMode = sender.tag;
    if (sender.tag == VHallMovieVideoPlayModeVoice || sender.tag == VHallMovieVideoPlayModeTextAndVoice) {
        [_moviePlayer setDefinition:VHallMovieDefinitionAudio];
        _definitionBtn0.selected = NO;
        _definitionBtn1.selected = NO;
        _definitionBtn2.selected = NO;
        _definitionBtn3.selected = NO;
    }
    else {
        [_moviePlayer setDefinition:VHallMovieDefinitionOrigin];
    }
    
    _playModeBtn0.selected = NO;
    _playModeBtn1.selected = NO;
    _playModeBtn2.selected = NO;
    _playModeBtn3.selected = NO;
    
    sender.selected = YES;
}

@end
