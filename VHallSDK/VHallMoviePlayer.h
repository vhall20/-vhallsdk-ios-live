//
//  VHallMoviePlayer.h
//  VHLivePlay
//
//  Created by liwenlong on 16/2/16.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "VHMoviePlayer.h"
/**
 *  视频播放模式
 */
typedef NS_ENUM(NSInteger,VHallMovieVideoPlayMode) {
    VHallMovieVideoPlayModeNone = 0,         //不存在
    VHallMovieVideoPlayModeMedia = 1,        //单视频
    VHallMovieVideoPlayModeTextAndVoice = 2, //文档＋声音
    VHallMovieVideoPlayModeTextAndMedia = 3, //文档＋视频
};

/**
 *  活动状态
 */
typedef NS_ENUM(NSInteger,VHallMovieActiveState) {
    VHallMovieActiveStateNone = 0 ,
    VHallMovieActiveStateLive = 1,           //直播
    VHallMovieActiveStateReservation = 2,    //预约
    VHallMovieActiveStateEnd = 3,            //结束
    VHallMovieActiveStateReplay = 4,         //回放
};



@class VHallMoviePlayer ;
@protocol VHallMoviePlayerDelegate <NSObject, VHMoviePlayerDelegate>
/**
 *  包含文档 获取翻页图片路径
 *
 *  @param changeImage  图片更新
 */
- (void)PPTScrollNextPagechangeImagePath:(NSString*)changeImagePath;
/**
 *  获取视频播放模式
 *
 *  @param playMode  视频播放模式
 */
- (void)VideoPlayMode:(VHallMovieVideoPlayMode)playMode;
/**
 *  获取视频活动状态
 *
 *  @param playMode  视频活动状态
 */
- (void)ActiveState : (VHallMovieActiveState)activeState;

@end
@interface VHallMoviePlayer : VHMoviePlayer

/**
 *  初始化VHMoviePlayer对象
 *
 *  @param delegate
 *
 *  @return   返回VHMoviePlayer的一个实例
 */
- (instancetype)initWithDelegate:(id <VHallMoviePlayerDelegate>)delegate;

/**
 *  观看直播视频
 *
 *  @param param
 *  param[@"id"] = 活动Id 必传
 *  param[@"app_key"] =   必传
 *  param[@"name"] =      必传
 *  param[@"email"] =     必传
 *  param[@"pass"] =    （活动如果有K值或密码需要传）
 *  param[@"app_secret_key"] =  必传
 *
 */
-(BOOL)startPlay:(NSDictionary*)param;

/**
 *  观看直播视频   (仅HLS可用)
 *
 *  @param param
 *  param[@"id"] = 活动Id 必传
 *  param[@"app_key"] =   必传
 *  param[@"name"] =      必传
 *  param[@"email"] =     必传
 *  param[@"pass"] =    （活动如果有K值或密码需要传）
 *  param[@"app_secret_key"] =  必传
 *
 *  @param moviePlayerController MPMoviePlayerController 对象
 */
-(void)startPlay:(NSDictionary*)param moviePlayer:(MPMoviePlayerController *)moviePlayerController;

/**
 *  观看回放视频   (仅HLS可用)
 *
 *  @param param
 *  param[@"id"] = 活动Id 必传
 *  param[@"app_key"] =   必传
 *  param[@"name"] =      必传
 *  param[@"email"] =     必传
 *  param[@"pass"] =    （活动如果有K值或密码需要传）
 *  param[@"app_secret_key"] =  必传
 *
 *  @param moviePlayerController MPMoviePlayerController 对象
 */
-(void)startPlayback:(NSDictionary*)param moviePlayer:(MPMoviePlayerController *)moviePlayerController;

/**
 *  设置静音
 *
 *  @param mute 是否静音
 */
- (void)setMute:(BOOL)mute;

/**
 *  设置系统声音大小
 *
 *  @param size float  [0.0~1.0]
 */
+ (void)setSysVolumeSize:(float)size;

/**
 *  获取系统声音大小
 */
+ (float)getSysVolumeSize;

/**
 *  停止播放
 */
-(void)stopPlay;

/**
 *  销毁播放器
 */
- (void)destroyMoivePlayer;

@end
