//
//  SignView.h
//  VHallSDKDemo
//
//  Created by vhall on 17/2/14.
//  Copyright © 2017年 vhall. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface SignView : UIView
+ (void)showSignBtnClickedBlock:(BOOL(^)())block;
+ (void)close;
+ (void)remainingTime:(NSTimeInterval)remainingTime;
+ (void)layoutView:(CGRect)frame;
@end
