//
//  WatchLiveOnlineTableViewCell.m
//  VHallSDKDemo
//
//  Created by Ming on 16/8/25.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "WatchLiveOnlineTableViewCell.h"

@implementation WatchLiveOnlineTableViewCell
{
    __weak IBOutlet UILabel *lblShow;
    __weak IBOutlet UILabel *lblState;
    
    NSString* userName;
    NSString* room;
    NSString* event;
    NSString* time;
    NSString* role;
    NSString* concurrent_user;
    NSString* attend_count;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    userName        = @"";
    room            = @"";
    event           = @"";
    time            = @"";
    role            = @"";
    concurrent_user = @"";
    attend_count    = @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    userName = _model.user_name;
    room = _model.room;
    time = _model.time;
    concurrent_user = _model.concurrent_user;
    attend_count = _model.attend_count;
    
    if([_model.event isEqualToString:@"online"]) {
        event = @"上线";
    }else if([_model.event isEqualToString:@"offline"]){
        event = @"下线";
    }
    
    if([_model.role isEqualToString:@"host"]) {
        role = @"主持人";
    }else if([_model.role isEqualToString:@"guest"]) {
        role = @"嘉宾";
    }else if([_model.role isEqualToString:@"assistant"]) {
        role = @"助手";
    }else if([_model.role isEqualToString:@"user"]) {
        role = @"观众";
    }

    if ([_model.event isEqualToString:@"online"]) {
        lblShow.text = [NSString stringWithFormat:@"欢迎%@%@加入房间:%@(%@)", role, userName, room, event];
        lblState.text = [NSString stringWithFormat:@"加入时间:%@ 当前用户数:%@ 参会人数:%@", time, concurrent_user, attend_count];
    }else if ([_model.event isEqualToString:@"offline"])
    {
        lblShow.text = [NSString stringWithFormat:@"%@%@退出房间:%@(%@)", role, userName, room, event];
        lblState.text = [NSString stringWithFormat:@"退出时间:%@ 当前用户数:%@ 参会人数:%@", time, concurrent_user, attend_count];
    }
    
}

@end
