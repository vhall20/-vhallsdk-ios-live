//
//  WatchRTMPViewController.h
//  VHallSDKDemo
//
//  Created by developer_k on 16/4/13.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "BaseViewController.h"

@interface WatchRTMPViewController : BaseViewController
@property(nonatomic,copy)NSString * roomId;
@property(nonatomic,copy)NSString * password;
@property(nonatomic,assign)WatchVideoType  watchVideoType;
@property(nonatomic,assign)NSInteger bufferTimes;
@end
