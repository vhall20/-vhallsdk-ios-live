//
//  WatchLiveLotteryViewController.h
//  VHallSDKDemo
//
//  Created by Ming on 16/10/14.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHallLottery.h"
#import "VHallMsgModels.h"

@interface WatchLiveLotteryViewController : UIViewController

@property (nonatomic, strong) VHallLottery * lottery;
@property (nonatomic, assign) BOOL lotteryOver;
@property (nonatomic, strong) VHallEndLotteryModel * endLotteryModel;

- (void)destory;

@end
