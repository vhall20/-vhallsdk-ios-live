IOS SDK 2.3.0 升级到2.4.0 注意事项
1) 绑定应用签名信息
使用 SDK 前集成前,务必先配置好此签名信息,否则使用时会出现“身份验证失败” 提示信息。
    进入 http://e.vhall.com/home/vhallapi/authlist ,API/SDK 使用权限信息页面。
    选择已开通的应用进行编辑操作。
    点下一步进入应用绑定页面。
    选择 IOS-SDK 切页后输入安全码 BundleID 项。(Bundle Identifier 在项目 Targets的 General 中找到)

2) AppDelegate.m
#import "VHallApi.h"
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   [VHallApi registerApp:AppKey SecretKey:AppSecretKey];//新增 
}
3) VHallLivePublish.h
- (void)startLive:(NSDictionary*)param;// 参 数 发 生 变 化 , 去 掉AppKey 和 AppSecretKey
- (void)stopLive;//结束直播 用于替换原来disconnect方法 与startLive成对出现,如果调用 startLive,则需要调用 stopLive 以释放相应资源
- (void)disconnect; //方法不再用于结束直播,只用于手动断开直播流, 断开推流的连接,注意 app 进入后台时要手动调用此方法、切回到前台需 reconnect 重新推流。 (注:特别需要使用 disconnect 的地方都改成 stopLive)
bitRate -> videoBitRate //比特率属性变为 videoBitRate
4) VHallMoviePlayer.h
- (BOOL)startPlay:(NSDictionary*)param;// 参 数 发 生 变 化 , 去 掉 AppKey 和AppSecretKey
- (void)startPlayback:(NSDictionary*)param moviePlayer:(MPMoviePlayerController*)moviePlayerController; //参数发生变化,去掉 AppKey 和 AppSecretKey
