//
//  MainViewController.m
//  PublishDemo
//
//  Created by liwenlong on 15/10/9.
//  Copyright (c) 2015年 vhall. All rights reserved.
//

#import "MainViewController.h"

#import "SettingViewController.h"
#import "VHallApi.h"
#import "LaunchLiveViewController.h"   //发起直播
#import "WatchLiveViewController.h"    //观看直播
#import "WatchPlayBackViewController.h"//观看回放

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@end

@implementation MainViewController

#pragma mark - Private Method

-(void)initDatas
{
   EnableVHallDebugModel(YES);
}

- (void)initViews
{
//    NSDictionary * info = [[NSBundle mainBundle] infoDictionary];
//    _versionLabel.text = [NSString stringWithFormat:@"v%@.%@",info[@"CFBundleShortVersionString"],info[@"CFBundleVersion"]];
//    _versionLabel.text = [NSString stringWithFormat:@"v%@",info[@"CFBundleShortVersionString"]];
    _versionLabel.text = [NSString stringWithFormat:@"v%@",[VHallApi sdkVersion]];
    _loginBtn.selected = [VHallApi isLoggedIn];
    _accountTextField.text  = DEMO_Setting.account;
    _passwordTextField.text = DEMO_Setting.password;
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
    if (DEMO_Setting.videoBitRate<=0 || DEMO_Setting.audioBitRate<=0) {
        [UIAlertView popupAlertByDelegate:nil title:@"码率不能为负数" message:nil];
        return;
    }
    if (DEMO_Setting.videoCaptureFPS< 1 || DEMO_Setting.videoCaptureFPS>30) {
        [UIAlertView popupAlertByDelegate:nil title:@"帧率设置错误[1-30]" message:nil];
        return;
    }
    
    LaunchLiveViewController * rtmpLivedemoVC = [[LaunchLiveViewController alloc] init];
    rtmpLivedemoVC.videoResolution = [DEMO_Setting.videoResolution intValue];
    rtmpLivedemoVC.roomId = DEMO_Setting.activityID;
    rtmpLivedemoVC.token = DEMO_Setting.liveToken;
    rtmpLivedemoVC.videoBitRate = DEMO_Setting.videoBitRate*1000;
    rtmpLivedemoVC.audioBitRate = DEMO_Setting.audioBitRate*1000;
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
    if (DEMO_Setting.videoBitRate<=0 || DEMO_Setting.audioBitRate<=0) {
        [UIAlertView popupAlertByDelegate:nil title:@"码率不能为负数" message:nil];
        return;
    }
    LaunchLiveViewController * rtmpLivedemoVC = [[LaunchLiveViewController alloc]init];
    rtmpLivedemoVC.videoResolution = [DEMO_Setting.videoResolution intValue];
    rtmpLivedemoVC.roomId = DEMO_Setting.activityID;
    rtmpLivedemoVC.token = DEMO_Setting.liveToken;
    rtmpLivedemoVC.videoBitRate = DEMO_Setting.videoBitRate*1000;
    rtmpLivedemoVC.audioBitRate = DEMO_Setting.audioBitRate*1000;
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

    WatchLiveViewController * watchVC  =[[WatchLiveViewController alloc]init];
    watchVC.roomId = DEMO_Setting.activityID;
    watchVC.kValue = DEMO_Setting.kValue;
    watchVC.bufferTimes = DEMO_Setting.bufferTimes;
    watchVC.watchVideoType = kWatchVideoRTMP;
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

- (IBAction)loginBtnClick:(id)sender
{
    [self closeKeyBtnClick:nil];

    if([DEMO_AppKey isEqualToString:@"替换成您自己的AppKey"])//此处只用于提示信息判断，只替换CONSTS.h中的AppKey即可
    {
        [self showMsg:@"请填写CONSTS.h中的AppKey" afterDelay:1.5];
        return;
    }
    
    __weak typeof(self) weekself = self;
    if([VHallApi isLoggedIn])
    {
        [VHallApi logout:^{
            weekself.loginBtn.selected = [VHallApi isLoggedIn];
            [weekself showMsg:@"已退出" afterDelay:1.5];
        } failure:^(NSError *error) {
            weekself.loginBtn.selected = [VHallApi isLoggedIn];
        }];
    }
    else
    {
        if(_accountTextField.text.length <= 0 || _passwordTextField.text.length <= 0)
        {
            VHLog(@"账号或密码为空");
            [self showMsg:@"账号或密码为空" afterDelay:1.5];
            return;
        }
        
        DEMO_Setting.account  = _accountTextField.text;
        DEMO_Setting.password = _passwordTextField.text;
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [VHallApi loginWithAccount:DEMO_Setting.account password:DEMO_Setting.password success:^{
            weekself.loginBtn.selected = [VHallApi isLoggedIn];
            [MBProgressHUD hideAllHUDsForView:weekself.view animated:YES];
            VHLog(@"Account: %@ Login:%d",[VHallApi currentAccount],[VHallApi isLoggedIn]);
            [weekself showMsg:@"登录成功" afterDelay:1.5];
        } failure:^(NSError * error) {
            weekself.loginBtn.selected = [VHallApi isLoggedIn];
            VHLog(@"登录失败%@",error);
            dispatch_async(dispatch_get_main_queue(), ^{
                 [MBProgressHUD hideAllHUDsForView:weekself.view animated:YES];
                [weekself showMsg:error.domain afterDelay:1.5];
            });
        }];
    }

}


- (IBAction)closeKeyBtnClick:(id)sender
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
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
