//
//  VHallApi.h
//  VHallSDK
//
//  Created by vhall on 16/8/23.
//  Copyright © 2016年 vhall. All rights reserved.
//

#ifndef VHallApi_h
#define VHallApi_h

#import "VHallLivePublish.h"
#import "VHallMoviePlayer.h"
#import "VHallChat.h"
#import "VHallQAndA.h"
#import "VHallMsgModels.h"

@interface VHallApi : NSObject 

/*！
 * 用来获得当前sdk的版本号
 * return 返回sdk版本号
 */
+(NSString *) sdkVersion;

/*！
 *  注册app
 *  需要在 application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 中调用
 *  @param appKey       vhall后台注册生成的appkey
 *  @param secretKey    vhall后台注册生成的appsecretKey
 *
 */
+ (void)registerApp:(NSString *)appKey SecretKey:(NSString *)secretKey;

#pragma mark - 使用用户系统相关功能需登录SDK
/*!
 *  登录 (如使用聊天，问答等功能必须登录)
 *
 *  @param aAccount         账号  需服务器调用微吼注册API 注册该用户账号密码
 *  @param aPassword        密码
 *  @param aSuccessBlock    成功的回调
 *  @param aFailureBlock    失败的回调
 *
 */
+ (void)loginWithAccount:(NSString *)aAccount
                password:(NSString *)aPassword
                success:(void (^)())aSuccessBlock
                failure:(void (^)(NSError *error))aFailureBlock;

/*!
 *  退出当前账号
 *
 *  @param aSuccessBlock    成功的回调
 *  @param aFailureBlock    失败的回调
 *
 *  @result 错误信息
 */
+ (void)logout:(void (^)())aSuccessBlock
              failure:(void (^)(NSError *error))aFailureBlock;

/*!
 *  获取当前登录状态
 *
 *  @result 当前是否已登录
 */
+ (BOOL)isLoggedIn;

/*!
 *  获取当前登录用户账号
 *
 *  @result 前登录用户账号
 */
+ (NSString *)currentAccount;

/*!
 *  获取当前登录用户id
 *
 *  @result 前登录用户id
 */
+ (NSString *)currentUserID;

@end

#endif /* VHApi_h */
