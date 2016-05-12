//
//  MainViewController.m
//  PublishDemo
//
//  Created by liwenlong on 15/10/9.
//  Copyright (c) 2015年 vhall. All rights reserved.
//

#import "MainViewController.h"

#import "SettingViewController.h"

#import "RtmpLiveViewController.h"//发起直播
#import "WatchRTMPViewController.h"//rtmp观看直播
#import "WatchHLSViewController.h"//hls观看直播
#import "WatchPlayBackViewController.h"//观看回放

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@end

@implementation MainViewController

#pragma mark - Private Method

-(void)initDatas
{
   EnableVHallDebugModel(YES);
}

- (void)initViews
{
    NSDictionary * info = [[NSBundle mainBundle] infoDictionary];
//    _versionLabel.text = [NSString stringWithFormat:@"v%@.%@",info[@"CFBundleShortVersionString"],info[@"CFBundleVersion"]];
    _versionLabel.text = [NSString stringWithFormat:@"v%@",info[@"CFBundleShortVersionString"]];
}

#pragma mark - UIButton Event
- (IBAction)settingBtnClicked:(id)sender {
    SettingViewController * settingVC = [[SettingViewController alloc]init];
    [self presentViewController:settingVC animated:YES completion:^{
        
    }];
}
- (IBAction)protraitStartBtnClick:(id)sender
{
    BOOL isAnimated = NO;
    if (sender) {
        isAnimated = YES;
    }
    if (DEMO_Setting.activityID == nil||DEMO_Setting.activityID.length<=0) {
        [UIAlertView popupAlertByDelegate:nil title:@"请输入roomId" message:nil];
        return;
    }
    if (DEMO_Setting.liveToken == nil||DEMO_Setting.liveToken<=0) {
        [UIAlertView popupAlertByDelegate:nil title:@"请输入token" message:nil];
        return;
    }
    if (DEMO_Setting.bitRate<=0) {
        [UIAlertView popupAlertByDelegate:nil title:@"码率不能为负数" message:nil];
        return;
    }
    if (DEMO_Setting.videoCaptureFPS< 1 || DEMO_Setting.videoCaptureFPS>30) {
        [UIAlertView popupAlertByDelegate:nil title:@"帧率设置错误[1-30]" message:nil];
        return;
    }
    
    RtmpLiveViewController * rtmpLivedemoVC = [[RtmpLiveViewController alloc]init];
    rtmpLivedemoVC.videoResolution = [DEMO_Setting.videoResolution intValue];
    rtmpLivedemoVC.roomId = DEMO_Setting.activityID;
    rtmpLivedemoVC.token = DEMO_Setting.liveToken;
    rtmpLivedemoVC.bitrate = DEMO_Setting.bitRate*1000;
    rtmpLivedemoVC.videoCaptureFPS = DEMO_Setting.videoCaptureFPS;
    [self presentViewController:rtmpLivedemoVC animated:isAnimated completion:^{

    }];
}

- (IBAction)landscapeStartBtnClick:(id)sender
{
    BOOL isAnimated = NO;
    if (sender) {
        isAnimated = YES;
    }
    if (DEMO_Setting.activityID == nil||DEMO_Setting.activityID.length<=0) {
        [UIAlertView popupAlertByDelegate:nil title:@"请输入roomId" message:nil];
        return;
    }
    if (DEMO_Setting.liveToken == nil||DEMO_Setting.liveToken<=0) {
        [UIAlertView popupAlertByDelegate:nil title:@"请输入token" message:nil];
        return;
    }
    if (DEMO_Setting.bitRate<=0) {
        [UIAlertView popupAlertByDelegate:nil title:@"码率不能为负数" message:nil];
        return;
    }
    RtmpLiveViewController * rtmpLivedemoVC = [[RtmpLiveViewController alloc]init];
    rtmpLivedemoVC.videoResolution = [DEMO_Setting.videoResolution intValue];
    rtmpLivedemoVC.roomId = DEMO_Setting.activityID;
    rtmpLivedemoVC.token = DEMO_Setting.liveToken;
    rtmpLivedemoVC.bitrate = DEMO_Setting.bitRate*1000;
    rtmpLivedemoVC.videoCaptureFPS = DEMO_Setting.videoCaptureFPS;
    rtmpLivedemoVC.interfaceOrientation = UIInterfaceOrientationLandscapeRight;
    [self presentViewController:rtmpLivedemoVC animated:isAnimated completion:^{

    }];
}

- (IBAction)rtmpWatchBtnClick:(id)sender
{
    if (DEMO_Setting.activityID == nil||DEMO_Setting.activityID<=0) {
        [UIAlertView popupAlertByDelegate:nil title:@"请输入roomId" message:nil];
        return;
    }
    if (DEMO_Setting.bufferTimes<0) {
        [UIAlertView popupAlertByDelegate:nil title:@"请输入bufferTimes,切值>=0" message:nil];
        return;
    }

    WatchRTMPViewController * watchVC  =[[WatchRTMPViewController alloc]init];
    watchVC.roomId = DEMO_Setting.activityID;
    watchVC.password = DEMO_Setting.kValue;
    watchVC.bufferTimes = DEMO_Setting.bufferTimes;
    watchVC.watchVideoType = kWatchVideoRTMP;
    [self presentViewController:watchVC animated:YES completion:nil];
}

- (IBAction)hlsWatchBtnClick:(id)sender
{
    if (DEMO_Setting.activityID == nil||DEMO_Setting.activityID<=0) {
        [UIAlertView popupAlertByDelegate:nil title:@"请输入roomId" message:nil];
        return;
    }

    WatchHLSViewController * watchVC  =[[WatchHLSViewController alloc]init];
    watchVC.roomId = DEMO_Setting.activityID;
    watchVC.password = DEMO_Setting.kValue;
    watchVC.watchVideoType = kWatchVideoHLS;
    [self presentViewController:watchVC animated:YES completion:nil];
}

- (IBAction)watchPlaybackBtnClick:(id)sender
{
    if (DEMO_Setting.activityID == nil||DEMO_Setting.activityID<=0) {
        [UIAlertView popupAlertByDelegate:nil title:@"请输入roomId" message:nil];
        return;
    }
    
    WatchPlayBackViewController * watchVC  =[[WatchPlayBackViewController alloc]init];
    watchVC.roomId = DEMO_Setting.activityID;
    watchVC.password = DEMO_Setting.kValue;
    watchVC.watchVideoType = kWatchVideoPlayback;
    [self presentViewController:watchVC animated:YES completion:nil];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
