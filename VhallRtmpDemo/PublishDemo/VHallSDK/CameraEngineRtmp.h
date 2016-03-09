//
//  CameraEngine.h
//  Encoder Demo
//
//  Created by Geraint Davies on 19/02/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "OpenCONSTS.h"

@interface CameraEngineRtmp : NSObject
{
    
}
/**
 *  推流连接的超时时间，单位为毫秒 默认2000
 */
@property (nonatomic,assign)int publishConnectTimeout;
/**
 *  推流断开重连的次数 默认为 1
 */
@property (nonatomic,assign)int publishConnectTimes;
/**
 *  用来显示摄像头拍摄内容的View
 */
@property(nonatomic,strong,readonly)UIView * displayView;
/**
 *  代理
 */
@property(nonatomic,assign)id <CameraEngineRtmpDelegate> delegate;
/**
 *  视频分辨率 默认值是kGeneralViodeResolution 960*540
 */
@property(nonatomic,assign)VideoResolution videoResolution;
/**
 *  码率设置
 */
@property(nonatomic,assign)NSInteger bitRate;
/**
 *  设置静音
 */
@property(assign,nonatomic)BOOL isMute;
/**
 *  判断用户使用是前置还是后置摄像头
 */
@property(nonatomic,assign,readonly)AVCaptureDevicePosition captureDevicePosition;

@end
