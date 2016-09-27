IOS SDK 2.3.0 升级到2.4.0 注意事项
需调整代码：
1、AppDelegate.m
     #import "VHallApi.h"
     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
         [VHallApi registerApp:AppKey SecretKey:AppSecretKey];
    }

2、VHallLivePublish.h
     - (void)startLive:(NSDictionary*)param;参数发生变化  去掉AppKey和AppSecretKey
     - (void)stopLive;结束直播 用于替换原来disconnect方法 与startLive成对出现，如果调用startLive，则需要调用stopLive以释放相应资源
     - (void)disconnect; 方法不再用于结束直播，只用于手动断开直播流， 断开推流的连接,注意app进入后台时要手动调用此方法、切回到前台需reconnect重新推流
     bitRate -> videoBitRate  比特率属性变为videoBitRate

3、VHallMoviePlayer.h
     -(BOOL)startPlay:(NSDictionary*)param;参数发生变化   去掉AppKey和AppSecretKey
     -(void)startPlayback:(NSDictionary*)parammoviePlayer:(MPMoviePlayerController *)moviePlayerController;参数发生变化  去掉AppKey和AppSecretKey

4、BundleID 填写认证
   http://e.vhall.com/home/vhallapi/authlist 点击编辑下一步选择IOSsdk填写您的BundleID
