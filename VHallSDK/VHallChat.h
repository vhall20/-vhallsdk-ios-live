//
//  VHallChat.h
//  VHallSDK
//
//  Created by Ming on 16/8/23.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VHallChatDelegate <NSObject>
@optional

- (void)reciveOnlineMsg:(NSArray *)msgs;
- (void)reciveChatMsg:(NSArray *)msgs;

@end

@interface VHallChat : NSObject

@property (nonatomic, assign) id <VHallChatDelegate> delegate;

/**
 *  发送聊天内容
 *  成功回调成功Block
 *  失败回调失败Block
 *  		失败Block中的字典结构如下：
 * 		key:code 表示错误码
 *		value:content 表示错误信息
 */
- (void)sendMsg:(NSString *)msg success:(void(^)())success failed:(void (^)(NSDictionary* failedData))reslutFailedCallback;

@end
