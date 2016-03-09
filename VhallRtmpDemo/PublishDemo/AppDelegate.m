//
//  AppDelegate.m
//  PublishDemo
//
//  Created by liwenlong on 15/10/9.
//  Copyright (c) 2015年 vhall. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "Reachability.h"

static AppDelegate *_appDelegate = nil;

@interface AppDelegate ()
{
    
}
@property (strong, nonatomic) Reachability* reachability;
@end

@implementation AppDelegate

/**
 *  方法功能：获取AppDelegate的实例
 */
+ (AppDelegate*)getAppDelegate
{
    return _appDelegate;
}

#pragma mark - Lifecycle Method
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    _appDelegate = self;
    //横屏显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    CGRect bounds = [[UIScreen mainScreen]bounds];
    self.window = [[UIWindow alloc]initWithFrame:bounds];
    
    MainViewController * mainVC = [[MainViewController alloc]init];
    self.window.rootViewController = mainVC;
    [self checkReachability];//添加对网络的监听
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Reachability Methods
- (void)checkReachability
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    [self updateInterfaceWithReachability:self.reachability];
}

/*!
 * Called by Reachability whenever status changes.
 */
- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    NetworkStatus status = [reachability currentReachabilityStatus];
    if(status == NotReachable)
    {
        //No internet
        VHLog(@"No Internet");
        self.isNetworkReachable = NO;
        
    }
    else if (status == ReachableViaWiFi)
    {
        //WiFi
        VHLog(@"Reachable WIFI");
        self.isNetworkReachable = YES;
    }
    else if (status == ReachableViaWWAN)
    {
        //3G
        VHLog(@"Reachable 3G");
        self.isNetworkReachable = YES;
    }
}

@end
