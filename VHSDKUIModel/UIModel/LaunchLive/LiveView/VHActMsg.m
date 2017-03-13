//
//  VHActMsg.m
//  VhallIphone
//
//  Created by dev on 16/4/21.
//  Copyright © 2016年 www.vhall.com. All rights reserved.
//

#import "VHActMsg.h"

static int msgIndex = 0;
static NSArray * colorArr;
@interface VHActMsg()
{
    int _index;
}
@end
@implementation VHActMsg
+ (void)initialize
{
    if (self == [VHActMsg class]) {
        colorArr = @[MakeColorRGB(0x75b694),MakeColorRGB(0x6faff7),MakeColorRGB(0xc1a738)];
    }
}
- (instancetype)initWithMsgType:(ActMsgType)type
{
    self = [super init];
    if (self) {
        if (msgIndex>=3) {
            msgIndex = 0;
        }
        _type = type;
        if (type == ActMsgTypeMsg) {
            _index = msgIndex;
            msgIndex++;
        }
    }
    return self;
}
-(void)setFormUserId:(NSString *)formUserId
{
    if (formUserId == nil) {
        return;
    }
    _formUserId = [NSString stringWithFormat:@"%@",formUserId];
}
-(UIColor *) textColor
{
    if (_type == ActMsgTypeMsg) {
        return colorArr[_index];
    }
    return nil;
}
@end
