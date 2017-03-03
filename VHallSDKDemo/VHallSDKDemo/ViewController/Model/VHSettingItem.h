//
//  VHSettingItem.h
//  VHallSDKDemo
//
//  Created by yangyang on 2017/2/13.
//  Copyright © 2017年 vhall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VHSettingItem : NSObject
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong)  void(^operation)(NSIndexPath *indexPath);
+(instancetype)itemWithTitle:(NSString*)title;
@property(nonatomic,strong) NSIndexPath   *indexPath;
@end
