//
//  AppDelegate.h
//  VHallSDKDemo
//
//  Created by liwenlong on 16/3/15.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL isNetworkReachable;
/**
 * 方法功能：获取AppDelegate的实例
 */
+(AppDelegate*)getAppDelegate;

@end

