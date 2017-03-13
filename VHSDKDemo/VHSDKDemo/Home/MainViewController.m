//
//  MainViewController.m
//  PublishDemo
//
//  Created by liwenlong on 15/10/9.
//  Copyright (c) 2015年 vhall. All rights reserved.
//

#import "MainViewController.h"
#import "VHHomeViewController.h"

@interface MainViewController ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@end

@implementation MainViewController

#pragma mark - Private Method

-(void)initDatas
{
   EnableVHallDebugModel(NO);
}

- (void)initViews
{
    _versionLabel.text = [NSString stringWithFormat:@"v%@",[VHallApi sdkVersion]];
    _loginBtn.selected = [VHallApi isLoggedIn];
    _accountTextField.text  = DEMO_Setting.account;
    _passwordTextField.text = DEMO_Setting.password;
}

- (IBAction)loginBtnClick:(id)sender
{
  [self closeKeyBtnClick:nil];

    if([DEMO_AppKey isEqualToString:@"替换成您自己的AppKey"])//此处只用于提示信息判断，只替换CONSTS.h中的AppKey即可
    {
        [self showMsg:@"请填写CONSTS.h中的AppKey" afterDelay:1.5];
        return;
    }
    
    __weak typeof(self) weekself = self;
    if([VHallApi isLoggedIn])
    {
        [VHallApi logout:^{
            weekself.loginBtn.selected = [VHallApi isLoggedIn];
            [weekself showMsg:@"已退出" afterDelay:1.5];
        } failure:^(NSError *error) {
            weekself.loginBtn.selected = [VHallApi isLoggedIn];
        }];
    }
    else
    {
        if(_accountTextField.text.length <= 0 || _passwordTextField.text.length <= 0)
        {
            VHLog(@"账号或密码为空");
            [self showMsg:@"账号或密码为空" afterDelay:1.5];
            return;
        }
        
        DEMO_Setting.account  = _accountTextField.text;
        DEMO_Setting.password = _passwordTextField.text;
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [VHallApi loginWithAccount:DEMO_Setting.account password:DEMO_Setting.password success:^{
            weekself.loginBtn.selected = [VHallApi isLoggedIn];
            [MBProgressHUD hideAllHUDsForView:weekself.view animated:YES];
            VHLog(@"Account: %@ Login:%d",[VHallApi currentAccount],[VHallApi isLoggedIn]);
            [weekself showMsg:@"登录成功" afterDelay:1.5];
            VHHomeViewController *homeVC=[[VHHomeViewController alloc] init];
            [self presentViewController:homeVC animated:YES completion:nil];
        } failure:^(NSError * error) {
            weekself.loginBtn.selected = [VHallApi isLoggedIn];
            VHLog(@"登录失败%@",error);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                 [MBProgressHUD hideAllHUDsForView:weekself.view animated:YES];
                [weekself showMsg:error.domain afterDelay:1.5];
            });
        }];
    }

}

- (IBAction)guestCLick:(id)sender
{
    VHHomeViewController *homeVC=[[VHHomeViewController alloc] init];
    [self presentViewController:homeVC animated:YES completion:nil];
}

- (IBAction)closeKeyBtnClick:(id)sender
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerBtnClicked:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册热线：400-682-6882" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",@"4006826882"];
        UIWebView * callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebview];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    return YES;
}

@end
