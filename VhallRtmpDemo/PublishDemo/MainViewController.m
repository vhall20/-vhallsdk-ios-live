//
//  MainViewController.m
//  PublishDemo
//
//  Created by liwenlong on 15/10/9.
//  Copyright (c) 2015年 vhall. All rights reserved.
//

#import "MainViewController.h"
#import "RtmpLiveViewController.h"
#import "WatchViewController.h"
#import "CustomPickerView.h"
#import "OpenCONSTS.h"

@interface MainViewController ()<CustomPickerViewDataSource,CustomPickerViewDelegate,UITextFieldDelegate>
{
   NSArray * _selectArray;
   CustomPickerView * _pickerView;     //选择框控件
   VideoResolution _videoResolution;
}

@property (weak, nonatomic) IBOutlet UILabel *streamNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *swapResolutionBtn;
@property (weak, nonatomic) IBOutlet UITextField *roomIdText;
@property (weak, nonatomic) IBOutlet UITextField *tokenText;
@property (weak, nonatomic) IBOutlet UITextField *bitRateText;
@property (weak, nonatomic) IBOutlet UITextField *bufferTimesTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;

@end

@implementation MainViewController

#pragma mark - Private Method

-(void)initDatas
{
   _selectArray = @[@"352X288",@"640X480",@"960X540",@"1280X720"];
   _videoResolution = kGeneralVideoResolution;
}

- (void)initViews
{
   NSDictionary *attributeDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [UIFont systemFontOfSize:14.0],NSFontAttributeName,
                                  [UIColor blackColor],NSForegroundColorAttributeName,nil];
   NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:@"请输入roomId" attributes:attributeDict];
   _roomIdText.attributedPlaceholder = attributedStr;
   _roomIdText.delegate = self;
   _tokenText.delegate = self;
   
   _streamNameLabel.text = @"id";
   _roomIdText.text = Id;
   _tokenText.text = AccessToken;
   _passwordTextField.delegate = self;
   _passwordTextField.text = nil;
   
   _bitRateText.delegate = self;
   _bitRateText.text = @"300";
   _bufferTimesTextField.delegate = self;
   _bufferTimesTextField.text = @"2";
   
   _pickerView = [CustomPickerView loadFromXib];
   _pickerView.delegate = self;
   _pickerView.dataSource = self;
   [_pickerView setTitle:@"请选择分辨率"];
   _swapResolutionBtn.layer.borderColor = [UIColor blackColor].CGColor;
   _swapResolutionBtn.layer.borderWidth = 1.0;
}

#pragma mark - UIButton Event
- (IBAction)protraitStartBtnClick:(id)sender
{
   BOOL isAnimated = NO;
   if (sender) {
      isAnimated = YES;
   }
   if (_roomIdText.text == nil||_roomIdText.text.length<=0) {
      [UIAlertView popupAlertByDelegate:nil title:@"请输入roomId" message:nil];
      return;
   }
   if (_tokenText.text == nil||_roomIdText.text.length<=0) {
      [UIAlertView popupAlertByDelegate:nil title:@"请输入token" message:nil];
      return;
   }
   if (_bitRateText.text==nil||_bitRateText.text.length<=0||[_bitRateText.text integerValue]<=0) {
      [UIAlertView popupAlertByDelegate:nil title:@"码率不能为负数" message:nil];
      return;
   }
   RtmpLiveViewController * rtmpLivedemoVC = [[RtmpLiveViewController alloc]init];
   rtmpLivedemoVC.videoResolution = _videoResolution;
   rtmpLivedemoVC.roomId = _roomIdText.text;
   rtmpLivedemoVC.token = _tokenText.text;
   rtmpLivedemoVC.bitrate = [_bitRateText.text integerValue]*1000;
   [self presentViewController:rtmpLivedemoVC animated:isAnimated completion:^{
      
   }];
}

- (IBAction)landscapeStartBtnClick:(id)sender
{
   BOOL isAnimated = NO;
   if (sender) {
      isAnimated = YES;
   }
   if (_roomIdText.text == nil||_roomIdText.text.length<=0) {
      [UIAlertView popupAlertByDelegate:nil title:@"请输入roomId" message:nil];
      return;
   }
   if (_tokenText.text == nil||_roomIdText.text.length<=0) {
      [UIAlertView popupAlertByDelegate:nil title:@"请输入token" message:nil];
      return;
   }
   if (_bitRateText.text==nil||_bitRateText.text.length<=0||[_bitRateText.text integerValue]<=0) {
      [UIAlertView popupAlertByDelegate:nil title:@"码率不能为负数" message:nil];
      return;
   }
   RtmpLiveViewController * rtmpLivedemoVC = [[RtmpLiveViewController alloc]init];
   rtmpLivedemoVC.videoResolution = _videoResolution;
   rtmpLivedemoVC.roomId = _roomIdText.text;
   rtmpLivedemoVC.token = _tokenText.text;
   rtmpLivedemoVC.bitrate = [_bitRateText.text integerValue]*1000;
   rtmpLivedemoVC.interfaceOrientation = UIInterfaceOrientationLandscapeRight;
   [self presentViewController:rtmpLivedemoVC animated:isAnimated completion:^{
      
   }];
}

- (IBAction)rtmpWatchBtnClick:(id)sender
{
   if (_roomIdText.text == nil||_roomIdText.text.length<=0) {
      [UIAlertView popupAlertByDelegate:nil title:@"请输入roomId" message:nil];
      return;
   }
   if (_tokenText.text == nil||_roomIdText.text.length<=0) {
      [UIAlertView popupAlertByDelegate:nil title:@"请输入token" message:nil];
      return;
   }
   if (_bufferTimesTextField.text == nil||_bufferTimesTextField.text.length<=0||[_bufferTimesTextField.text integerValue]<0) {
      [UIAlertView popupAlertByDelegate:nil title:@"请输入bufferTimes,切值>=0" message:nil];
      return;
   }
   
   WatchViewController * watchVC  =[[WatchViewController alloc]init];
   watchVC.roomId = _roomIdText.text;
   watchVC.token = _tokenText.text;
   watchVC.password = _passwordTextField.text;
   watchVC.bufferTimes = [_bufferTimesTextField.text integerValue];
   watchVC.watchVideoType = kWatchVideoRTMP;
   [self presentViewController:watchVC animated:YES completion:nil];
}

- (IBAction)hlsWatchBtnClick:(id)sender
{
   if (_roomIdText.text == nil||_roomIdText.text.length<=0) {
      [UIAlertView popupAlertByDelegate:nil title:@"请输入roomId" message:nil];
      return;
   }
   if (_tokenText.text == nil||_roomIdText.text.length<=0) {
      [UIAlertView popupAlertByDelegate:nil title:@"请输入token" message:nil];
      return;
   }
   WatchViewController * watchVC  =[[WatchViewController alloc]init];
   watchVC.roomId = _roomIdText.text;
   watchVC.token = _tokenText.text;
   watchVC.password = _passwordTextField.text;
   watchVC.watchVideoType = kWatchVideoHLS;
   [self presentViewController:watchVC animated:YES completion:nil];
}

- (IBAction)watchPlaybackBtnClick:(id)sender
{
   if (_roomIdText.text == nil||_roomIdText.text.length<=0) {
      [UIAlertView popupAlertByDelegate:nil title:@"请输入roomId" message:nil];
      return;
   }
   if (_tokenText.text == nil||_roomIdText.text.length<=0) {
      [UIAlertView popupAlertByDelegate:nil title:@"请输入token" message:nil];
      return;
   }
   WatchViewController * watchVC  =[[WatchViewController alloc]init];
   watchVC.roomId = _roomIdText.text;
   watchVC.token = _tokenText.text;
   watchVC.password = _passwordTextField.text;
   watchVC.watchVideoType = kWatchVideoPlayback;
   [self presentViewController:watchVC animated:YES completion:nil];
}

- (IBAction)swapResolutionBtnClick:(id)sender
{
   [_pickerView showPickerView:self.view];
}

- (IBAction)bgClick:(id)sender
{
   [_roomIdText resignFirstResponder];
   [_bitRateText resignFirstResponder];
   [_bufferTimesTextField resignFirstResponder];
   [_tokenText resignFirstResponder];
   [_passwordTextField resignFirstResponder];
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

-(void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
   _pickerView.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
   
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
   [_swapResolutionBtn setTitle:title forState:UIControlStateNormal];
   _videoResolution = (VideoResolution)row;
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
   [textField resignFirstResponder];
   return YES;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
