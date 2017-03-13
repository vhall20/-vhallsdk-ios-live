//
//  VHSettingGroup.h
//  VHallSDKDemo
//
//  Created by yangyang on 2017/2/13.
//  Copyright © 2017年 vhall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VHSettingGroup : NSObject
@property(nonatomic,strong) NSArray *items;
@property(nonatomic,copy)   NSString *headerTitle;
@property(nonatomic,copy)   NSString *footTitle;
+(instancetype)groupWithItems:(NSArray*)items;
@end
