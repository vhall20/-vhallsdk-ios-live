//
//  VHallMoviePlayer.h
//  VHLivePlay
//
//  Created by liwenlong on 16/2/16.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "VHMoviePlayer.h"

@interface VHallMoviePlayer : VHMoviePlayer
/**
 *  初始化VHMoviePlayer对象
 *
 *  @param delegate
 *
 *  @return   返回VHMoviePlayer的一个实例
 */
- (instancetype)initWithDelegate:(id <VHMoviePlayerDelegate>)delegate;

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
