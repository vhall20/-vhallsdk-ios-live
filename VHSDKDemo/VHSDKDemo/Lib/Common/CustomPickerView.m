//
//  CustomPickerView.m
//  ECarWash
//
//  Created by 李文龙 on 15/5/13.
//  Copyright (c) 2015年 vjifen. All rights reserved.
//

#import "CustomPickerView.h"

#define PickerViewHeight     236

@interface CustomPickerView()<UIPickerViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSUInteger _selectedRow;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *pickerBgView;
@property (weak, nonatomic) IBOutlet UIButton *bgViewBtn;
@end

@implementation CustomPickerView

#pragma mark - Public Method
-(void)showPickerView:(UIView*)superView
{
    if (!_isShow) {
        self.pickerBgView.top = superView.height;
        [superView addSubview:self];
        [_pickerView reloadAllComponents];
        _isShow = YES;
        self.hidden = NO;
        __weak typeof(self) weakself = self;
        [UIView animateWithDuration:0.25f animations:^{
            self.pickerBgView.top -= self.pickerBgView.height;
            _bgViewBtn.alpha = 0.5f;
        }completion:^(BOOL finished) {
            weakself.pickerViewBottomConstraint.constant = 0.0f;
        }];
    }
}

-(void)hidePickerView
{
    if (_isShow) {
        __weak typeof(self) weakself = self;
        [UIView animateWithDuration:0.25f animations:^{
            self.pickerBgView.top += self.pickerBgView.height;
            _bgViewBtn.alpha = 0.0f;
        }completion:^(BOOL finished) {
            self.hidden = YES;
            [self removeFromSuperview];
             weakself.pickerViewBottomConstraint.constant = -PickerViewHeight;
        }];
        _isShow = NO;
    }
}

#pragma mark - Private Method

- (void)initDatas
{
    
}

- (void)initViews
{
    self.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    self.bgViewBtn.backgroundColor = [UIColor blackColor];
    self.bgViewBtn.alpha = 0.0f;
    // 设置选择器
    //_pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 30, self.width, 200.0f)];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.showsSelectionIndicator = YES;
    //[self.pickerBgView insertSubview:_pickerView atIndex:0];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self initDatas];
    [self initViews];
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    _titleLabel.text = title;
}

-(void)setFrame:(CGRect)frame
{
    super.frame = frame;
}

#pragma mark - UIButton Event
- (IBAction)cancelBtnclick:(id)sender {
    [self hidePickerView];
}

- (IBAction)confirmBtnClick:(id)sender
{
    [self hidePickerView];
    if ([_delegate respondsToSelector:@selector(customPickerView:didSelectRow:)]) {
        [_delegate  customPickerView:_pickerView didSelectRow:_selectedRow];
    }
}

#pragma mark - UIPickerViewDataSource
// 返回显示的列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1;
}

// 返回当前列显示的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([_dataSource respondsToSelector:@selector(numberOfRowsInPickerView)]) {
        return [_dataSource numberOfRowsInPickerView];
    }
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 44;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel * mycom = view ? (UILabel *) view : [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.width, 44.0f)];
    if ([_dataSource respondsToSelector:@selector(titleOfRowCustomPickerViewWithRow:)]) {
        mycom.text = [_dataSource titleOfRowCustomPickerViewWithRow:row];
    }
    mycom.textAlignment = NSTextAlignmentCenter;
    [mycom setFont:[UIFont systemFontOfSize:20.0f]];
    mycom.backgroundColor = [UIColor clearColor];
    return mycom;
}

#pragma mark - UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        _selectedRow = row;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
