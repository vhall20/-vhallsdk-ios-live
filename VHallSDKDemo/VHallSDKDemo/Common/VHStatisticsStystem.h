//
//  VHStatisticsStystem.h
//  vhallIphone
//
//  Created by vhallrd01 on 14-8-5.
//  Copyright (c) 2014年 zhangxingming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VHStatisticsStystem : NSObject

@property (nonatomic,strong)NSString *iphoneIp;

+ (VHStatisticsStystem *)sharedManager;
#ifdef DEBUG
- (NSArray *)getDataCounters;
- (float) cpu_usage;
- (double)availableMemory;
- (double)usedMemory;
#endif
@end
