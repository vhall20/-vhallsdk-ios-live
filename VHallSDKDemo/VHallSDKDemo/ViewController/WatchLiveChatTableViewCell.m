//
//  WatchLiveChatTableViewCell.m
//  VHallSDKDemo
//
//  Created by Ming on 16/8/25.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "WatchLiveChatTableViewCell.h"

@implementation WatchLiveChatTableViewCell
{
    __weak IBOutlet UIImageView *pic;
    __weak IBOutlet UILabel *lblNickName;
    __weak IBOutlet UILabel *lblTime;
    __weak IBOutlet UILabel *lblContext;
    
    UIImage *image;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    image = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    if ([_model.avatar isEqualToString:@"(null)"] || [_model.avatar isEqualToString:@""])
    {
        image = [UIImage imageNamed:@"head50.png"];
    }
    else
    {
        NSURL *url = [NSURL URLWithString:_model.avatar];
        NSData *data = [NSData dataWithContentsOfURL:url];
        image = [[UIImage alloc] initWithData:data];
    }
    [pic setImage:image];
    lblNickName.text = _model.user_name;
    lblTime.text = _model.time;
    lblContext.text = [NSString stringWithFormat:@"%@\n\n", _model.text];
}

@end
