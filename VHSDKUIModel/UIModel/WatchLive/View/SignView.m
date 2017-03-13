//
//  SignView.m
//  VHallSDKDemo
//
//  Created by vhall on 17/2/14.
//  Copyright © 2017年 vhall. All rights reserved.
//

#import "SignView.h"
static SignView *g_signView = nil;

typedef BOOL(^BtnClickedBlock)();


@interface SignView()
{
    UILabel *_tiemlabel;
    UIButton *tempBtn;
}
@property (nonatomic,strong)BtnClickedBlock btnClickedblock;
@end

@implementation SignView


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (void)showSignBtnClickedBlock:(BOOL(^)())block
{
    if(!g_signView)
    {
        g_signView = [[SignView alloc]initWithFrame:CGRectMake(0, 0, VHScreenWidth, VHScreenHeight)];
        g_signView.btnClickedblock = block;
    }
    UIWindow *win=[UIApplication sharedApplication].windows[0];
    [win addSubview:g_signView];
}

+ (void)close
{
    [g_signView removeFromSuperview];
    g_signView = nil;
}

+ (void)remainingTime:(NSTimeInterval)remainingTime
{
    [g_signView remainingTime:(int)remainingTime];
}

+ (void)layoutView:(CGRect)frame
{
    g_signView.frame = CGRectMake(0, 0, VHScreenWidth, VHScreenHeight);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = MakeColor(0, 0, 0, 0.3);
        UIView * v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 270, 165)];
        v.tag = 10000;
        v.centerX = self.width/2;
        v.centerY = self.height/2;
        v.backgroundColor = MakeColor(255, 255, 255, 1);
        v.layer.cornerRadius = 5;
        v.layer.masksToBounds= YES;
        [self addSubview:v];
        
        UIView * v1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, v.width, 50)];
        v1.backgroundColor = MakeColor(255, 255, 255, 1);
        [v addSubview:v1];
        
        UIView *line =[[UIView alloc] initWithFrame:CGRectMake(10, 49, v1.width-20, 1)];
        line.backgroundColor=MakeColorRGB(0xcdcdce);
        [v1 addSubview:line];
//        UILabel *l = [[UILabel alloc]initWithFrame:v1.bounds];
//        l.text = @"签到";
//        l.textColor = [UIColor blackColor];
//        l.font = [UIFont systemFontOfSize:18];
//        l.textAlignment = NSTextAlignmentCenter;
       // [v1 addSubview:l];
        
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(v1.width-10-14, 10, 14, 14)];
       // [btn setTitle:@"X" forState:0];
        [btn setBackgroundImage:[UIImage imageNamed:@"UIModel.bundle/关闭.tiff"] forState:UIControlStateNormal];
//        btn.backgroundColor = [UIColor blueColor];
        [btn setTitleColor:[UIColor blackColor] forState:0];
        [btn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        [v1 addSubview:btn];
        
        UILabel *info = [[UILabel alloc]initWithFrame:CGRectMake(0,20, v1.width, 15)];
        info.text = @"主持人发起了签到";
        info.textColor = MakeColorRGB(0x2a2c31);
        info.font = [UIFont systemFontOfSize:21];
        info.textAlignment = NSTextAlignmentCenter;
        [v1 addSubview:info];
        
        _tiemlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, v1.bottom+30, v.width, 30)];
        _tiemlabel.textColor = MakeColorRGB(0x2c2b31);
        _tiemlabel.textAlignment = NSTextAlignmentCenter;
        [v addSubview:_tiemlabel];
        
        
        UIButton *signbtn = [[UIButton alloc]initWithFrame:CGRectMake(0, v.height - 40, v.width, 40)];
        signbtn.tag =1011;
        [signbtn setTitle:@"签 到" forState:0];
        signbtn.backgroundColor = MakeColorRGB(0xff3433);
        signbtn.layer.cornerRadius = 5;
        signbtn.layer.masksToBounds= YES;
        tempBtn=signbtn;
        [signbtn addTarget:self action:@selector(signbtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [v addSubview:signbtn];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    UIView * v = [self viewWithTag:10000];
    v.centerX = self.width/2;
    v.centerY  = self.height/2;
}

- (void)remainingTime:(int)remainingTime
{
    _tiemlabel.text = [NSString stringWithFormat:@"您有 %d 秒的时间进行签到",(int)remainingTime];
    NSRange r = [_tiemlabel.text rangeOfString:@"秒"];
    NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] initWithString:_tiemlabel.text];
    [richText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(2, r.location-2)];//设置字体颜色
    _tiemlabel.attributedText = richText;
}

- (void)closeView
{
    [SignView close];
}

- (void)signbtnClicked
{
    if(_btnClickedblock)
    {
        if(_btnClickedblock())
        {
            [self closeView];
        }
    }
}



@end
