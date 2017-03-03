//
//  VHSettingItem.m
//  VHallSDKDemo
//
//  Created by yangyang on 2017/2/13.
//  Copyright © 2017年 vhall. All rights reserved.
//

#import "VHSettingItem.h"

@implementation VHSettingItem
+(instancetype)itemWithTitle:(NSString *)title
{
    VHSettingItem *item = [[self alloc] init];
    item.title = title;
    return item;
}
@end
