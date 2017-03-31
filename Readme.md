# vhallsdk-live-ios
自助式网络直播SDK

注：SDK地址已迁移，请往新地址下载  https://github.com/vhall/vhallsdk_live_ios

### APP工程集成SDK基本设置
1、工程中任意 *.m 文件修改为 *.mm<br>
2、关闭bitcode 设置<br>
3、plist 中 App Transport Security Settings -> Allow Arbitrary Loads 设置为YES<br>
4、注册`AppKey`  [VHallApi registerApp:`AppKey` SecretKey:`AppSecretKey`]; <br>
5、检查工程 `Bundle ID` 是否与`AppKey`对应 <br>

### 使用CocoaPods 引入SDK
pod 'VHallSDK_Live' , :git => 'https://github.com/vhall20/vhallsdk_live_ios.git'<br>
使用美颜功能SDK<br>
pod 'VHallSDK_LiveFilter' , :git => 'https://github.com/vhall20/vhallsdk_live_ios.git'<br>


### 版本更新信息
#### 版本 v2.7.0 更新时间：2017.03.13
更新内容：<br>

1：新增问卷功能<br>
2：Demo UI层拆分<br>


### 版本更新信息
#### 版本 v2.6.0 更新时间：2017.03.03
更新内容：<br>

1：新增公告功能<br>
2：新增签到功能<br>
3：DEMO弹幕显示<br>
4：DEMO聊天表情显示<br>

#### 版本 v2.5.4 更新时间：2016.12.30

更新内容：<br>

1：bug修复<br>

#### 版本 v2.5.3 更新时间：2016.12.23

更新内容：<br>

1：新增美颜功能<br>
2：评论相关功能 <br>
3：支持 MP4格式回放 <br>
4：支持 Https 协议<br>

#### 版本 v2.5.0 更新时间：2016.11.10

更新内容：<br>

1：新增抽奖功能<br>
2：新增获取20条最近聊天记录功能<br>

#### 版本 v2.4.0    更新时间：2016.09.26

更新内容：<br>

1、新增登录<br>
2、新增聊天<br>
3、新增问答<br>
4、集成应用签名机制<br>
5、观看直播支持音视频切换<br>
6、优化发直播调用方式<br>


#### 版本：v2.3.0  更新时间：2016.07.25

更新内容：<br>

1、加入美颜滤镜；<br>
2、加入清晰度切换；<br>
3、多线路智能切换；<br>
4、修复iOS返回第一帧图片时的内容泄露；<br>
	 
#### 版本：v2.2.2  更新时间：2016.06.01

更新内容：<br>

1、支持ipv6；<br>
2、修复bug；<br>

#### 版本：v2.2.1  更新时间：2016.05.12

更新内容：<br>

1、新增帧率配置；<br>
   
   
#### 版本：v2.2.0  更新时间：2016.05.06

更新内容：<br>

1、新增文档演示；<br>
2、优化观看体验；<br>


#### 版本：v2.1.2  更新时间：2016.04.14

更新内容：<br>

1、优化重名问题；<br>


#### 版本：v2.1.1  更新时间：2016.03.24

更新内容：<br>

1、pc端rtmp发起直播，sdk观看视频扭曲；<br>
2、sdk关闭播放会有卡顿问题；<br>
3、sdk观看rtmp直播，切换发起端设置，观看端卡顿问题；<br>
