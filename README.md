# X 随心

X 随心（XSuixin）是面向 X/Twitter iOS 客户端的独立 Theos tweak，提供转推管理、视频与动图下载、分享图片、推荐/广告过滤，以及时间线和操作栏定制。

本仓库从 [BHTwitter](https://github.com/BandarHL/BHTwitter) 工作区提取 X 随心相关代码，并保留其独立构建所需的 JGProgressHUD、FFmpegKit 头文件和静态库。插件源码位于 [`RepostsDownloads/`](RepostsDownloads/)，详细版本记录、功能开关和测试说明见 [`RepostsDownloads/README.md`](RepostsDownloads/README.md)。

## 当前源码与头像诊断

当前源码为 2.4.3。根据真机日志，新增头像 URL 缺失时的原生图片回退：核对 `TUIAvatarImageView` 绑定的原作者账号和图片到达时序，接收稍后加载的 UIImage / 图层图片。保留身份冲突与单元格复用保护，并补充头像媒体实体读取。完整说明见 [2.4.3 发布记录](RepostsDownloads/RELEASE-2.4.3.md)。

同时提供含相同修复的 `2.4.3+diag.1` 文件诊断构建，便于真机复验；本地模拟测试不代表手机显示效果已经确认。

诊断包构建命令：`sh RepostsDownloads/build-avatar-diagnostics.sh`。GitHub Actions 的 `XSuixin-avatar-diagnostics` 产物提供诊断 DEB 与 SHA-256；日志路径和复现步骤见[头像诊断说明](RepostsDownloads/AVATAR-DIAGNOSTICS.md)。

## 已发布 Release

[下载 X 随心 2.4.0（标准 Rootless）](https://github.com/Caun1112/XSuixin/releases/tag/v2.4.0)

安装包：`XSuixin_2.4.0_rootless.deb`（iOS 15.0+、arm64、标准 rootless 越狱环境）。发布页同时提供 SHA-256 校验文件。

2.4.0 修复了 X 12.24.1 / iOS 17.1.1 图片全屏页的入口识别，增加可点击的图片工具箱，并将视频下载按钮贴近右侧安全区。

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
