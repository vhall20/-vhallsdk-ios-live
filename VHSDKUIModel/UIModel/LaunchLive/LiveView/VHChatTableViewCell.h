//
//  VHChatTableViewCell.h
//  VhallIphone
//
//  Created by vhall on 15/11/27.
//  Copyright © 2015年 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHActMsg.h"

extern NSString * const VHChatMsgIdentifier;
extern NSString * const VHChatOnlineIdentifier;
extern NSString * const VHChatPayIdentifier;
extern NSString * const VHChatQuestionIdentifier;

@interface VHChatTableViewCell : UITableViewCell
+ (CGFloat)getCellHeight:(VHActMsg *)msg;
+ (CGSize)calStrSize:(NSString*)str width:(CGFloat)width font:(UIFont*)font;
+ (CGSize)calStrSize:(NSString*)str font:(UIFont*)font;

@property(nonatomic,strong) VHActMsg *msg;
@property (nonatomic,copy)void(^headerViewAction)(NSString * userId);
@property (nonatomic,copy)void(^bgViewAction)(NSString * userId,NSString * userName);
@end

@interface VHChatDoubleSideTableViewCell : VHChatTableViewCell

@end

@interface VHChatSingleSideTableViewCell : VHChatTableViewCell

@end
