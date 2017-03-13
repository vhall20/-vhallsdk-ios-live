//
//  VHSettingGroup.m
//  VHallSDKDemo
//
//  Created by yangyang on 2017/2/13.
//  Copyright © 2017年 vhall. All rights reserved.
//

#import "VHSettingGroup.h"

@implementation VHSettingGroup
+(instancetype)groupWithItems:(NSArray *)items
{
    VHSettingGroup *group = [[VHSettingGroup alloc] init];
    group.items = items;
    return group;
}
@end
