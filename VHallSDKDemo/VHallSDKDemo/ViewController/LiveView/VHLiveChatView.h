//
//  VHLiveChatView.h
//  VhallIphone
//
//  Created by dev on 16/8/3.
//  Copyright © 2016年 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHActMsg.h"

typedef NS_ENUM(NSUInteger, ChatViewActionType) {
    ChatViewActionTypeTalkTo,
    ChatViewActionTypeCheckUser
};
@interface VHLiveChatView : UIView

- (instancetype)initWithFrame:(CGRect)frame msgTotal:(NSInteger(^)())number msgSource:(VHActMsg*(^)(NSInteger index))msg action:(void(^)(ChatViewActionType type ,NSString * userId ,NSString * nickName))action;

- (void)update;

@end
