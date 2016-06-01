//
//  VHStystemSetting.m
//  
//
//  Created by vhall on 16/5/11.
//  Copyright (c) 2016年 www.vhall.com. All rights reserved.
//

#import "VHStystemSetting.h"

@implementation VHStystemSetting

static VHStystemSetting *pub_sharedSetting = nil;

+ (VHStystemSetting *)sharedSetting
{
    @synchronized(self)
    {
        if (pub_sharedSetting == nil)
        {
            pub_sharedSetting = [[VHStystemSetting alloc] init];
        }
    }
    
    return pub_sharedSetting;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (pub_sharedSetting == nil) {
            
            pub_sharedSetting = [super allocWithZone:zone];
            return pub_sharedSetting;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        //活动设置
        _activityID = [standardUserDefaults objectForKey:@"VHactivityID"];   //活动ID     必填
        _nickName   = [standardUserDefaults objectForKey:@"VHnickName"];     //参会昵称    为空默认随机字符串做昵称
        _userID     = [standardUserDefaults objectForKey:@"VHuserID"];       //用户唯一ID  为空默认使用设备UUID做为唯一ID
        _kValue     = [standardUserDefaults objectForKey:@"VHkValue"];       //K值        可以为空

        //直播设置
        _videoResolution= [standardUserDefaults objectForKey:@"VHvideoResolution"];//发起直播分辨率
        _liveToken      = [standardUserDefaults objectForKey:@"VHliveToken"];            //直播令牌
        _bitRate        = [standardUserDefaults integerForKey:@"VHbitRate"];              //发直播视频码率
        _videoCaptureFPS= [standardUserDefaults integerForKey:@"VHvideoCaptureFPS"];//发直播视频帧率 ［1～30］ 默认10
        
        //观看设置
        _bufferTimes    = [standardUserDefaults integerForKey:@"VHbufferTimes"];          //RTMP观看缓冲时间

        if(DEMO_ActivityId && DEMO_ActivityId.length > 0)
        {
            self.activityID = DEMO_ActivityId;
        }
        if(DEMO_AccessToken && DEMO_AccessToken.length > 0)
        {
            self.liveToken = DEMO_AccessToken;
        }
        
        if(_nickName == nil || _nickName.length == 0)
        {
            _nickName = [NSString stringWithFormat:@"SDKsuer_%d",arc4random()% 100000];
        }
        if(_userID == nil || _userID.length == 0)
        {
            self.userID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            if(_userID == nil || _userID.length == 0)
            {
                self.userID = @"unknown";
            }
        }
        if(_videoResolution == nil || _videoResolution.length == 0)
        {
            self.videoResolution = @"1";
        }

        if(_bitRate<=0)
            self.bitRate = 300;
        if(_videoCaptureFPS <1)
            self.videoCaptureFPS = 10;
        if(_videoCaptureFPS >30)
            self.videoCaptureFPS = 30;
        if(_bufferTimes <=0)
            self.bufferTimes = 2;
    }
    return self;
}

- (void)setActivityID:(NSString*)activityID
{
    _activityID = activityID;
    if(activityID == nil || activityID.length == 0)
        _activityID = DEMO_ActivityId;
    
    [[NSUserDefaults standardUserDefaults] setObject:_activityID forKey:@"VHactivityID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setNickName:(NSString*)nickName
{
    if(nickName == nil || nickName.length == 0)
        return;
    
    _nickName = nickName;
    [[NSUserDefaults standardUserDefaults] setObject:_nickName forKey:@"VHnickName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setUserID:(NSString*)userID
{
    if(userID == nil || userID.length == 0)
        return;
    
    _userID = userID;
    [[NSUserDefaults standardUserDefaults] setObject:_userID forKey:@"VHuserID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setKValue:(NSString*)kValue
{
    _kValue = kValue;
    [[NSUserDefaults standardUserDefaults] setObject:_kValue forKey:@"VHkValue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setVideoResolution:(NSString*)videoResolution
{
    if(videoResolution == nil || videoResolution.length == 0)
        return;
    if([videoResolution integerValue]<0 || [videoResolution integerValue]>3)
        return;
    
    _videoResolution = videoResolution;
    [[NSUserDefaults standardUserDefaults] setObject:_videoResolution forKey:@"VHvideoResolution"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setLiveToken:(NSString*)liveToken
{
    _liveToken = liveToken;
    [[NSUserDefaults standardUserDefaults] setObject:_liveToken forKey:@"VHliveToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setBitRate:(NSInteger)bitRate
{
    if(bitRate<=0)
        return;

    _bitRate = bitRate;
    [[NSUserDefaults standardUserDefaults] setInteger:bitRate forKey:@"VHbitRate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setVideoCaptureFPS:(NSInteger)videoCaptureFPS
{
    if(videoCaptureFPS <1)
        videoCaptureFPS = 10;
    if(videoCaptureFPS >30)
        videoCaptureFPS = 30;

    _videoCaptureFPS = videoCaptureFPS;
    [[NSUserDefaults standardUserDefaults] setInteger:videoCaptureFPS forKey:@"VHvideoCaptureFPS"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setBufferTimes:(NSInteger)bufferTimes
{
    if(bufferTimes <=0)
        bufferTimes = 2;
    
    _bufferTimes = bufferTimes;
    [[NSUserDefaults standardUserDefaults] setInteger:bufferTimes forKey:@"VHbufferTimes"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
