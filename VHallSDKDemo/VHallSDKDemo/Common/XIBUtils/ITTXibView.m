//
//  ITTXibView.m
//  iTotemFrame
//
//  Created by jack 廉洁 on 3/9/12.
//  Copyright (c) 2012 iTotemStudio. All rights reserved.
//

#import "ITTXibView.h"
#import "ITTXibViewUtils.h"


@implementation ITTXibView

- (void)dealloc
{
    VHLog(@"%@ is dealloced!", [self class]);
}

+ (id)loadFromXib
{
    return [ITTXibViewUtils loadViewFromXibNamed:NSStringFromClass([self class])];
}
@end
