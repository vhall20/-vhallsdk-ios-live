//
//  DemoViewController.h
//  PublishDemo
//
//  Created by liwenlong on 15/10/9.
//  Copyright (c) 2015年 vhall. All rights reserved.
//

#import "BaseViewController.h"
#import "OpenCONSTS.h"

@interface RtmpLiveViewController : BaseViewController
{
    
}
@property(nonatomic,assign)VideoResolution videoResolution;
@property(nonatomic,copy)NSString * roomId;
@property(nonatomic,copy)NSString * token;
@property(nonatomic,assign)NSInteger bitrate;
@end
