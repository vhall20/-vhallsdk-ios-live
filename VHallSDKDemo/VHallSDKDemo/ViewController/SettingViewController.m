//
//  SettingViewController.m
//  VHallSDKDemo
//
//  Created by vhall on 16/5/11.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "SettingViewController.h"
#import "CustomPickerView.h"
#import "OpenCONSTS.h"

@interface SettingViewController ()<CustomPickerViewDataSource,CustomPickerViewDelegate,UITextFieldDelegate>

{
    NSArray * _selectArray;
    CustomPickerView * _pickerView;     //选择框控件
}
@property (weak, nonatomic) IBOutlet UIView *view0;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;

@property (weak, nonatomic) IBOutlet UITextField *activityIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *recordIDTextField;

@property (weak, nonatomic) IBOutlet UIButton    *videoResolutionButton;
@property (weak, nonatomic) IBOutlet UITextField *liveTokenTextField;
@property (weak, nonatomic) IBOutlet UITextField *audiobitRateTextField;
@property (weak, nonatomic) IBOutlet UITextField *bitRateTextField;
@property (weak, nonatomic) IBOutlet UITextField *FPSTextField;

@property (weak, nonatomic) IBOutlet UITextField *bufferTimesTextField;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *kValueTextField;

@end

@implementation SettingViewController
#pragma mark - Private Method

-(void)initDatas
{
    _selectArray = @[@"352X288",@"640X480",@"960X540",@"1280X720"];
    EnableVHallDebugModel(YES);
}

- (void)initViews
{
    [_videoResolutionButton setTitle:_selectArray[[DEMO_Setting.videoResolution intValue]] forState:0];
    
    _activityIDTextField.text = DEMO_Setting.activityID;
    _recordIDTextField.text = DEMO_Setting.recordID;
    _liveTokenTextField.text = DEMO_Setting.liveToken;
    _bitRateTextField.text = [NSString stringWithFormat:@"%ld",(long)DEMO_Setting.videoBitRate];
    _audiobitRateTextField.text = [NSString stringWithFormat:@"%ld",(long)DEMO_Setting.audioBitRate];
    _FPSTextField.text = [NSString stringWithFormat:@"%ld",(long)DEMO_Setting.videoCaptureFPS];
    _bufferTimesTextField.text = [NSString stringWithFormat:@"%ld",(long)DEMO_Setting.bufferTimes];
    _nickNameTextField.text = DEMO_Setting.nickName;
    _userIDTextField.text = DEMO_Setting.email;
    _kValueTextField.text = DEMO_Setting.kValue;
    _activityIDTextField.delegate = self;
    _recordIDTextField.delegate = self;
    _liveTokenTextField.delegate = self;
    _bitRateTextField.delegate = self;
    _audiobitRateTextField.delegate = self;
    _FPSTextField.delegate = self;
    _bufferTimesTextField.delegate = self;
    _nickNameTextField.delegate = self;
    _userIDTextField.delegate = self;
    _kValueTextField.delegate = self;
    
    _pickerView = [CustomPickerView loadFromXib];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    [_pickerView setTitle:@"请选择分辨率"];
//    NSDictionary *attributeDict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   [UIFont systemFontOfSize:14.0],NSFontAttributeName,
//                                   [UIColor blackColor],NSForegroundColorAttributeName,nil];
//    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:@"请输入roomId" attributes:attributeDict];
//    _roomIdText.attributedPlaceholder = attributedStr;
//    _roomIdText.delegate = self;
//    _tokenText.delegate = self;
//    _streamNameLabel.text = @"活动id";
//    _roomIdText.text = DEMO_ActivityId;
//    _recordIDTextField.text = DEMO_Setting.recordID;
//    _tokenText.text = DEMO_AccessToken;
//    _passwordTextField.delegate = self;
//    _passwordTextField.text = nil;
//    _bitRateText.delegate = self;
//    _bitRateText.text = @"300";
//    _bufferTimesTextField.delegate = self;
//    _bufferTimesTextField.text = @"2";
//    
//    _pickerView = [CustomPickerView loadFromXib];
//    _pickerView.delegate = self;
//    _pickerView.dataSource = self;
//    [_pickerView setTitle:@"请选择分辨率"];
//    _swapResolutionBtn.layer.borderColor = [UIColor blackColor].CGColor;
//    _swapResolutionBtn.layer.borderWidth = 1.0;
}


#pragma mark - Lifecycle Method
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initDatas];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _pickerView.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)didClicksegmentedControlAction:(UISegmentedControl *)sender {
    [self hideKey];
    NSInteger Index = sender.selectedSegmentIndex;
    NSLog(@"Index %li", (long)Index);
    switch (Index) {
        case 0:
        {
            _view0.hidden = NO;
            _view1.hidden = YES;
            _view2.hidden = YES;
        }
            break;
        case 1:
        {
            _view1.hidden = NO;
            _view0.hidden = YES;
            _view2.hidden = YES;
        }
            break;
        case 2:
        {
            _view2.hidden = NO;
            _view1.hidden = YES;
            _view0.hidden = YES;
        }
            break;
        default:
            break;
    }
}
- (IBAction)videoResolutionBtnCliked:(id)sender {
    [self hideKey];
    
    [_pickerView showPickerView:self.view];
}
- (IBAction)closeBtnClicked:(id)sender {
    [self hideKey];
    
    DEMO_Setting.activityID = _activityIDTextField.text;
    DEMO_Setting.recordID = _recordIDTextField.text;
    DEMO_Setting.liveToken  = _liveTokenTextField.text;
    DEMO_Setting.videoBitRate = [_bitRateTextField.text integerValue];
    DEMO_Setting.audioBitRate = [_audiobitRateTextField.text integerValue];
    DEMO_Setting.videoCaptureFPS = [_FPSTextField.text integerValue];
    DEMO_Setting.bufferTimes = [_bufferTimesTextField.text integerValue];
    DEMO_Setting.nickName = _nickNameTextField.text;
    DEMO_Setting.email = _userIDTextField.text;
    DEMO_Setting.kValue = _kValueTextField.text;
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - CustomPickerViewDataSource
- (NSString*)titleOfRowCustomPickerViewWithRow:(NSInteger)row
{
    NSString * title =_selectArray[row];
    return title;
}

- (NSInteger)numberOfRowsInPickerView
{
    return _selectArray.count;
}

#pragma mark - CustomPickerViewDelegate
- (void)customPickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
{
    NSString * title =_selectArray[row];
    [_videoResolutionButton setTitle:title forState:UIControlStateNormal];
    DEMO_Setting.videoResolution =  [NSString stringWithFormat:@"%ld",(long)row];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)hideKey
{
    [_activityIDTextField resignFirstResponder];
    [_recordIDTextField resignFirstResponder];
    [_liveTokenTextField resignFirstResponder];
    [_bitRateTextField resignFirstResponder];
    [_FPSTextField resignFirstResponder];
    [_bufferTimesTextField resignFirstResponder];
    [_nickNameTextField resignFirstResponder];
    [_userIDTextField resignFirstResponder];
    [_kValueTextField resignFirstResponder];
}

@end
