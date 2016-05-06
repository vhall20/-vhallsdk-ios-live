//
//  WatchHLSViewController.h
//  VHallSDKDemo
//
//  Created by developer_k on 16/4/12.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WatchHLSViewController : BaseViewController

@property(nonatomic,copy)NSString * roomId;
@property(nonatomic,copy)NSString * token;
@property(nonatomic,copy)NSString * password;
@property(nonatomic,assign)WatchVideoType  watchVideoType;
@property(nonatomic,assign)NSInteger bufferTimes;

@end
