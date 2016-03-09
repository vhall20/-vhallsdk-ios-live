//
//  WatchViewController.h
//  VhallRtmpLiveDemo
//
//  Created by liwenlong on 15/10/10.
//  Copyright © 2015年 vhall. All rights reserved.
//

#import "BaseViewController.h"

@interface WatchViewController : BaseViewController
{
    
}
@property(nonatomic,copy)NSString * roomId;
@property(nonatomic,copy)NSString * token;
@property(nonatomic,copy)NSString * password;
@property(nonatomic,assign)WatchVideoType  watchVideoType;
@property(nonatomic,assign)NSInteger bufferTimes;
@end
