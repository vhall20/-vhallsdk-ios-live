//
//  CONSTS.h
//  VhallRtmpDemo
//
//  Created by liwenlong on 15/10/10.
//  Copyright © 2015年 vhall. All rights reserved.
//

#ifndef CONSTS_h
#define CONSTS_h

#define Id             @""
#define AppKey         @""
#define SecretKey      @""
#define AppSecretKey   @""
#define AccessToken    @""

#if DEBUG  // 调试状态, 打开LOG功能
#define VHLog(...) NSLog(__VA_ARGS__)
#else // 发布状态, 关闭LOG功能
#define VHLog(...)
#endif

typedef NS_ENUM(int,WatchVideoType)
{
   kWatchVideoNone,
   kWatchVideoRTMP,
   kWatchVideoHLS,
   kWatchVideoPlayback
};

#define kViewFramePath  @"frame"

#pragma mark - iphone detection functions

#define APPDELEGATE [AppDelegate getAppDelegate]

#define IOSVersion  [[UIDevice currentDevice].systemVersion floatValue]

#define KIScreenHeight [[UIScreen mainScreen] bounds].size.height

#define KIScreenWidth [[UIScreen mainScreen] bounds].size.width

#endif /* CONSTS_h */
