//
//  VHallMsgModels.h
//  VHallSDK
//
//  Created by Ming on 16/8/25.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VHallMsgModels : NSObject
@property (nonatomic, copy) NSString * join_id;         //参会id
@property (nonatomic, copy) NSString * account_id;      //注册用户id，如果未登陆则为0
@property (nonatomic, copy) NSString * user_name;       //参会时的昵称
@property (nonatomic, copy) NSString * avatar;          //头像url，如果没有则为空字符串
@property (nonatomic, copy) NSString * room;            //房间号，即活动id
@property (nonatomic, copy) NSString * time;            //发送时间，根据服务器时间确定
@end

/**
 *  上下线消息
 */
@interface VHallOnlineStateModel : VHallMsgModels
@property (nonatomic, copy) NSString * event;          //online/offline:上下线消息
@property (nonatomic, copy) NSString * role;          //用户类型 host:主持人 guest：嘉宾 assistant：助手 user：观众
@property (nonatomic, copy) NSString * concurrent_user;//房间内当前用户数
@property (nonatomic, copy) NSString * attend_count;  //参会人数
@end

/**
 *  聊天消息
 */
@interface VHallChatModel : VHallMsgModels
@property (nonatomic, copy) NSString * text;            //聊天消息
@end


/**
 *  历史评论
 */

@interface VHCommentModel : VHallMsgModels
@property (nonatomic, copy) NSString * text;            //评论内容
@property(nonatomic,copy)   NSString *commentId;        //评论ID
@end

/**
 *  提问消息
 */
@interface VHallQuestionModel : NSObject
@property (nonatomic, copy) NSString * type;            //类型
@property (nonatomic, copy) NSString * question_id;     //问题ID
@property (nonatomic, copy) NSString * nick_name;       //昵称
@property (nonatomic, copy) NSString * content;         //提问内容
@property (nonatomic, copy) NSString * join_id;         //参会id
@property (nonatomic, copy) NSString * created_at;      //提问时间
@end

/**
 *  回答消息
 */
@interface VHallAnswerModel : VHallQuestionModel
@property (nonatomic, copy) NSString * answer_id;       //回答ID
@property (nonatomic, copy) NSString * role_name;       //角色
@property (nonatomic, assign)BOOL      is_open;         //是否公开回答
@property (nonatomic, copy) NSString * avatar;
@end

/**
 *  问答消息
 */
@interface VHallQAModel : VHallMsgModels
@property (nonatomic, strong) VHallQuestionModel * questionModel;                   //提问消息
@property (nonatomic, strong) NSMutableArray<VHallAnswerModel *> * answerModels;    //回答消息数组
@end

/**
 *  抽奖消息
 */
@interface VHallLotteryModel : NSObject
@property (nonatomic, copy) NSString * lottery_id;      //抽奖ID
@property (nonatomic, copy) NSString * survey_id;       //活动ID
@end

/**
 *  开始抽奖消息
 */
@interface VHallStartLotteryModel : VHallLotteryModel
@property (nonatomic, copy) NSString * num;             //抽奖人数
@end

/**
 *  抽奖结果
 */
@interface VHallLotteryResultModel : NSObject
@property (nonatomic, copy) NSString * nick_name;       //中奖人昵称
@end

/**
 *  结束抽奖消息
 */
@interface VHallEndLotteryModel : VHallLotteryModel
@property (nonatomic, assign) BOOL isWin;               //是否中奖
@property (nonatomic, copy) NSString * account;         //登录账号
@property (nonatomic, copy) NSMutableArray<VHallLotteryResultModel *> * resultModels; //中奖结果
@end

/**
 *  调查问卷消息
 */
@interface VHallSurveyModel : NSObject
@property(nonatomic,copy) NSString * releaseTime;//发起时间
@property(nonatomic,copy) NSString * surveyId;//问卷ID
@property(nonatomic,copy) NSString * joinId;
@end

