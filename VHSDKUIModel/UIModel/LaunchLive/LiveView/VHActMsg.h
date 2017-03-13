//
//  VHActMsg.h
//  VhallIphone
//
//  Created by dev on 16/4/21.
//  Copyright © 2016年 www.vhall.com. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, ActMsgType) {
    ActMsgTypeMsg  = 1,         //文本消息
    ActMsgTypeOnline,       //上线消息
    ActMsgTypePay ,          //支付消息
    ActMsgTypeQuestion,       //提问消息
    ActMsgTypeGift           //礼物
};

typedef NS_ENUM(NSInteger, PayType) {//打赏来源
    PayFromPC,//PC端打赏
    PayFromApp //App端礼物打赏
    
};



@interface VHActMsg : NSObject
/*!
    消息类型
 */
@property (nonatomic,assign,readonly)ActMsgType type;

/*!
 打赏来源
 */
@property(nonatomic,assign) PayType  payFromType;


/*!
    活动ID
 */
@property (nonatomic,strong)NSString *  actId;
/*!
    消息ID
 */
@property (nonatomic,strong)NSString *  msgId;
/*!
    发消息用户参会ID
 */
@property (nonatomic,strong)NSString *  joinId;
/*!
    发消息用户头像
 */
@property (nonatomic,retain)NSString * formUserIcon;
/*!
    发消息用户昵称
 */
@property (nonatomic,retain)NSString * formUserName;
/*!
    发消息用户id
 */
@property (nonatomic,retain)NSString * formUserId;
/*!
    被@用户id
 */
//@property (nonatomic,retain)NSString * toUserId;
/*!
    消息文本
 */
@property (nonatomic,retain)NSString * text;
/*!
    发消息时间
 */
@property (nonatomic,retain)NSString * time;
/*!
    被赞数
 */
@property (nonatomic,assign)int admireNo;
/*!
    我是否赞过
 */
@property (nonatomic,assign)BOOL isAdmire;
/*!
 我是否赞过
 */
@property (nonatomic,assign,readonly)UIColor * textColor;


/*!
 道具名称
 */
@property (nonatomic,retain)NSString  *giftName;

/*!
 道具图片
 */
@property (nonatomic,retain)NSString  *giftUrl;



- (instancetype)initWithMsgType:(ActMsgType)type;

@end
