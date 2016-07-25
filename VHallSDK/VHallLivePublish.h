//
//  VHallLivePublish.h
//  VHLivePlay
//
//  Created by liwenlong on 16/2/3.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "CameraEngineRtmp.h"

@class GPUImageVideoCamera;
@class GPUImageRawDataOutput;

@protocol VHallLivePublishFilterDelegate <NSObject>
@optional
- (void)addGPUImageFilter:(GPUImageVideoCamera *)source Output:(GPUImageRawDataOutput *)output;
@end

@interface VHallLivePublish : CameraEngineRtmp
@property (nonatomic, assign) id<VHallLivePublishFilterDelegate> GPUFilterDelegate;
@property (nonatomic, assign) BOOL openFilter;

/*! @brief 获取当前微吼SDK的版本号
 *
 * @return 返回当前微吼SDK的版本号
 */
+(NSString *) getSDKVersion;

//采集设备初始化
- (id)initWithOrgiation:(DeviceOrgiation)orgiation;
/**
 *  初始化 CaptureVideo
 *
 *  @param captureDevicePosition AVCaptureDevicePositionBack 代表后置摄像头 AVCaptureDevicePositionFront 代表前置摄像头
 *
 *  @return 是否成功
 */
- (BOOL)initCaptureVideo:(AVCaptureDevicePosition)captureDevicePosition;

//初始化音频
- (BOOL)initAudio;

//开始视频采集
- (BOOL)startVideoCapture;

//停止视频采集
- (BOOL)stopVideoCapture;

//开启音频采集;
- (BOOL)startAudioCapture;

//暂停音频采集
- (BOOL)pauseAudioCapture;

//停止音频采集
- (BOOL)stopAudioCapture;

/**
 *  开始发起直播
 *
 *  @param param
 *  param[@"id"] = 活动Id 必传
 *  param[@"app_key"] =    必传
 *  param[@"access_token"] = 必传
 *  param[@"app_secret_key"] = 必传
 *
 */
-(void)startLive:(NSDictionary*)param;
/**
 *  切换摄像头
 *
 *  @param captureDevicePosition
 *
 *  @return 是否切换成功
 */
- (BOOL)swapCameras:(AVCaptureDevicePosition)captureDevicePosition;

//手动对焦
-(void)setFoucsFoint:(CGPoint)newPoint;
/**
 *  变焦
 *
 *  @param zoomSize 变焦的比例
 */
- (void)captureDeviceZoom:(CGFloat)zoomSize;

/**
 * 设置闪关灯的模式
 */
- (BOOL)setDeviceTorchModel:(AVCaptureTorchMode)captureTorchMode;

//断网后重连
-(BOOL)reconnect;

/**
 *  销毁初始化数据
 */
- (void)destoryObject;

/**
 *  断开推流的连接,注意app进入后台时要手动调用此方法
 */
- (void)disconnect;


@end
