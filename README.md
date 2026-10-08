# X 随心

X 随心（XSuixin）是面向 X/Twitter iOS 客户端的独立 Theos tweak，提供转推管理、视频与动图下载、分享图片、推荐/广告过滤，以及时间线和操作栏定制。

本仓库从 [BHTwitter](https://github.com/BandarHL/BHTwitter) 工作区提取 X 随心相关代码，并保留其独立构建所需的 JGProgressHUD、FFmpegKit 头文件和静态库。插件源码位于 [`RepostsDownloads/`](RepostsDownloads/)，详细版本记录、功能开关和测试说明见 [`RepostsDownloads/README.md`](RepostsDownloads/README.md)。

## 当前版本与诊断日志

当前完整构建为 2.4.7-6。连续 Swift 竖屏卡片通过当前 `status` 读取原生 MP4 清晰度，避免后续视频只剩 HLS。HLS 后备探测增加网络读超时、最长等待、会话/耗时/错误类别日志与验收阶段。右侧独立图标、TAV 兼容、性能观察及默认日志保留。说明见 [2.4.7-6 发布记录](RepostsDownloads/RELEASE-2.4.7-6.md)，操作与反馈流程见 [设备验收](RepostsDownloads/DEVICE-ACCEPTANCE.md)。

安装后进入“X 随心 → 运行状态与恢复 → 实际运行验收”，开始一轮，再回到 X 操作并查看结果。性能观察需主动开始；有采样不等于性能通过，视频菜单呈现不等于传输完成。异常时导出附件和复现步骤，下一构建修订递增为 2.4.7-7 再复验。

以后只提供一个 rootless DEB，默认内置本机日志。“X 随心 → 文件与诊断 → 诊断日志”支持查看、刷新和导出，无需另装诊断版。不会自动上传日志。本地模拟测试不代表已完成真机广告验收。

GitHub Actions 只输出 `XSuixin-rootless` 一份产物。构建命令为 `sh RepostsDownloads/build.sh`，日志说明见[诊断日志](RepostsDownloads/AVATAR-DIAGNOSTICS.md)。

## 已发布 Release

[下载 X 随心 2.4.7-6（Rootless，内置验收与日志）](https://github.com/Caun1112/XSuixin/releases/tag/v2.4.7-6)

安装包：`XSuixin_2.4.7-6_rootless.deb`（iOS 15.0+、arm64、标准 rootless 越狱环境）。只提供一个默认带日志的包和 SHA-256 校验文件，可从 2.4.7-5 或更早版本升级。每次不同源码递增 Debian 修订，设置与日志显示准确提交，正式包从干净提交生成，见 [构建政策](RepostsDownloads/BUILD-POLICY.md)。

安装后彻底退出并重开 X，保持“启用视频与动图下载”和“全屏右侧独立下载按钮”开启。直接进入全屏视频点击右侧图标，不先点评论，再滑到其他视频验证内容对应；异常时从实际运行验收页导出。

## 构建

需要 Theos、iOS 16.5 SDK、GNU Make、ldid 和 dpkg：

```sh
THEOS="$HOME/theos" ./RepostsDownloads/build.sh
```

构建产物会写入 `RepostsDownloads/packages/`。逻辑回归测试：

```sh
./RepostsDownloads/tests/run.sh
sh ./RepostsDownloads/tests/run_downloads.sh
sh ./RepostsDownloads/tests/run_quality_ads.sh
sh ./RepostsDownloads/tests/run_recommendations.sh
sh ./RepostsDownloads/tests/run_share.sh
sh ./RepostsDownloads/tests/run_all.sh
```

## 归属

X 随心的部分实现源自 BHTwitter（Bandar Alruwaili），下载按钮包含 actuallyaridan 的修改；分享图片主题配色参考 fluxdo。源文件中的第三方版权声明保持不变。请在分发或修改时同时遵守对应上游项目及 FFmpeg/FFmpegKit、JGProgressHUD 的许可条款。
