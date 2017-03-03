//
//  WatchLiveChatTableViewCell.m
//  VHallSDKDemo
//
//  Created by Ming on 16/8/25.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "WatchLiveChatTableViewCell.h"
#import "MLEmojiLabel+atColor.h"

@implementation WatchLiveChatTableViewCell
{
    __weak IBOutlet UIImageView *pic;
    __weak IBOutlet UILabel *lblNickName;
    __weak IBOutlet UILabel *lblTime;
    __weak IBOutlet UILabel *lblContext;
    MLEmojiLabel *_textLabel;
    UIImage *image;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    image = nil;
      [self layoutIfNeeded];
    if(!_textLabel)
    {
        _textLabel = [MLEmojiLabel new];
        _textLabel.numberOfLines = 1;
        
//        _textLabel.font = lblContext.font;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _textLabel.isNeedAtAndPoundSign = YES;
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        _textLabel.customEmojiPlistName = @"faceExpression.plist";
        _textLabel.userInteractionEnabled=NO;
        _textLabel.disableThreeCommon = YES;
        _textLabel.frame = lblContext.frame;
        [self.contentView addSubview:_textLabel];
        lblContext.hidden = YES;
    }
//    _textLabel.text = @"[惊讶]";
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
    //内容
    [_textLabel setText:_model.text];
   
    [_textLabel sizeToFit];
    
  
    
}

@end
