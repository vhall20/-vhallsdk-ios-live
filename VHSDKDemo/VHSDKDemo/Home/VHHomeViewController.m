//
//  HomeViewController.m
//  VHallSDKDemo
//
//  Created by yangyang on 2017/2/13.
//  Copyright © 2017年 vhall. All rights reserved.
//

#import "VHHomeViewController.h"
#import "VHStystemSetting.h"
#import "UIImageView+WebCache.h"
#import "VHallApi.h"
#import "LaunchLiveViewController.h"
#import "VHSettingViewController.h"
#import "WatchLiveViewController.h"
#import "WatchPlayBackViewController.h"
#import "MainViewController.h"


@interface VHHomeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *videoBitRate;//视频码率
@property (weak, nonatomic) IBOutlet UILabel *videoResolution;//视频分辨率
@property (weak, nonatomic) IBOutlet UILabel *videoCaptureFPS;//视频帧率
@property (weak, nonatomic) IBOutlet UIImageView *headImage;//头像
@property (weak, nonatomic) IBOutlet UILabel *nickName;//昵称
@property(nonatomic,strong) NSArray *videoResolutionArray;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIView *cornerOne;
@property (weak, nonatomic) IBOutlet UIView *cornerTow;

@property (weak, nonatomic) IBOutlet UILabel *deviceCategory;

@property (weak, nonatomic) IBOutlet UIImageView *landCreateImageView;

@property (weak, nonatomic) IBOutlet UIImageView *proCreateImageView;
@property (weak, nonatomic) IBOutlet UIImageView *watchLiving;

@property (weak, nonatomic) IBOutlet UIImageView *watchPlayBack;

@end

@implementation VHHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setVideoData];
    [self  setUserData];
    if ([VHallApi isLoggedIn])
    {
        [_loginBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    }else
    {
        [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    }
    
    [self.deviceCategory setText:[UIDevice currentDevice].name];
    self.cornerOne.layer.borderColor=[UIColor whiteColor].CGColor;
    self.cornerTow.layer.borderColor=[UIColor whiteColor].CGColor;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//音视频参数设置
-(void)setVideoData
{
    
    _videoBitRate.text=[NSString stringWithFormat:@"%ld",(long)[VHStystemSetting sharedSetting].videoBitRate];
    
    int arrayIndex=[[VHStystemSetting sharedSetting].videoResolution intValue];
   _videoResolution.text=[NSString stringWithFormat:@"%@",[self.videoResolutionArray objectAtIndex:arrayIndex]];
    _videoCaptureFPS.text =[NSString stringWithFormat:@"%ld",(long)[VHStystemSetting sharedSetting].videoCaptureFPS];

}

//用户参数

-(void)setUserData
{
    [_headImage sd_setImageWithURL:[NSURL URLWithString:[VHallApi currentUserHeadUrl]] placeholderImage:[UIImage imageNamed:@"defaultHead"]];
    NSString *temName=[VHallApi currentUserNickName] ;
    if (temName)
    {
        _nickName.text =temName;
    }else
    {
        if ([VHallApi isLoggedIn]) {
            _nickName.text = @"";
        }else
        {
             _nickName.text = @"游客";
        }
        
    }
    
}

-(NSArray *)videoResolutionArray
{
    if (!_videoResolutionArray)
    {
        _videoResolutionArray = @[@"352X288",@"640X480",@"960X540",@"1280X720"];
    }
    return _videoResolutionArray;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//竖屏发直播
- (IBAction)protraitStartBtnClick:(id)sender
{
    
  
    self.proCreateImageView.image = [UIImage imageNamed:@"porLivingSelec"];
    self.landCreateImageView.image=[UIImage imageNamed:@"LandLiving"];
    self.watchLiving.image = [UIImage imageNamed:@"watchLiving"];
    self.watchPlayBack.image = [UIImage imageNamed:@"playBack"];
    
    
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
    rtmpLivedemoVC.interfaceOrientation = UIInterfaceOrientationPortrait;
    [self presentViewController:rtmpLivedemoVC animated:isAnimated completion:^{
        
    }];

}

//横屏发直播
- (IBAction)landscapeStartBtnClick:(id)sender
{
    self.proCreateImageView.image = [UIImage imageNamed:@"porLiving"];
    self.landCreateImageView.image=[UIImage imageNamed:@"LandLivingSelected"];
    self.watchLiving.image = [UIImage imageNamed:@"watchLiving"];
    self.watchPlayBack.image = [UIImage imageNamed:@"playBack"];

    
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

- (IBAction)watchLivingClick:(id)sender
{
    self.proCreateImageView.image = [UIImage imageNamed:@"porLiving"];
    self.landCreateImageView.image=[UIImage imageNamed:@"LandLiving"];
    self.watchLiving.image = [UIImage imageNamed:@"watchLivingSelected"];
    self.watchPlayBack.image = [UIImage imageNamed:@"playBack"];
    
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
- (IBAction)watchPlayBackClick:(id)sender
{
    self.proCreateImageView.image = [UIImage imageNamed:@"porLiving"];
    self.landCreateImageView.image=[UIImage imageNamed:@"LandLiving"];
    self.watchLiving.image = [UIImage imageNamed:@"watchLiving"];
    self.watchPlayBack.image = [UIImage imageNamed:@"playBackSelect"];
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

- (IBAction)systemSettingClick:(id)sender
{
    VHSettingViewController *settingVc=[[VHSettingViewController alloc] init];
    [self presentViewController:settingVc animated:YES completion:nil];
}
- (IBAction)loginOrloginOutClick:(id)sender
{
    if ([DEMO_AppKey isEqualToString:@"替换成您自己的AppKey"])
    {
        [self showMsg:@"请填写CONSTS.h中的AppKey" afterDelay:1.5];
        return;
    }
    
    __weak typeof(self) weekself= self;
    if ([VHallApi isLoggedIn])
    {
        [VHallApi logout:^{
            weekself.loginBtn.selected = [VHallApi isLoggedIn];
            [weekself showMsg:@"已退出" afterDelay:1.5];
            [weekself setUserData];
            [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        } failure:^(NSError *error) {
            weekself.loginBtn.selected = [VHallApi isLoggedIn];
        }];
    }else
    {
        MainViewController *main = [[MainViewController alloc] init];
        [self presentViewController:main animated:YES completion:nil];
    }
}

- (void)showMsg:(NSString*)msg afterDelay:(NSTimeInterval)delay
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.margin = 10.f;
    //            hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:delay];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
