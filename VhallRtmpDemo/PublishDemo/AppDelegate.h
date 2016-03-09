//
//  AppDelegate.h
//  PublishDemo
//
//  Created by liwenlong on 15/10/9.
//  Copyright (c) 2015年 vhall. All rights reserved.
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

