//
//  CustomPickerView.h
//  ECarWash
//
//  Created by 李文龙 on 15/5/13.
//  Copyright (c) 2015年 vjifen. All rights reserved.
//

#import "ITTXibView.h"

@protocol CustomPickerViewDelegate <NSObject>

- (void)customPickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row;

@end

@protocol CustomPickerViewDataSource <NSObject>

- (NSString*)titleOfRowCustomPickerViewWithRow:(NSInteger)row;
- (NSInteger)numberOfRowsInPickerView;

@end

@interface CustomPickerView : ITTXibView
{
    
}

@property(assign,nonatomic)id <CustomPickerViewDelegate>delegate;
@property(assign,nonatomic)id <CustomPickerViewDataSource> dataSource;
@property(nonatomic,strong)NSString * title;
@property(nonatomic,assign,readonly)BOOL isShow;

-(void)showPickerView:(UIView*)superView;
-(void)hidePickerView;

@end
