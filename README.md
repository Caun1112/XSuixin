# X 随心

X 随心（XSuixin）是面向 X/Twitter iOS 客户端的独立 Theos tweak，提供转推管理、视频与动图下载、分享图片、推荐/广告过滤，以及时间线和操作栏定制。

本仓库从 [BHTwitter](https://github.com/BandarHL/BHTwitter) 工作区提取 X 随心相关代码，并保留其独立构建所需的 JGProgressHUD、FFmpegKit 头文件和静态库。插件源码位于 [`RepostsDownloads/`](RepostsDownloads/)，详细版本记录、功能开关和测试说明见 [`RepostsDownloads/README.md`](RepostsDownloads/README.md)。

## 当前源码与头像诊断

当前源码为 2.4.4。全屏图片复制改为纯图标按钮，补齐视频列表进入分页器前的推广条目过滤，保留原作者头像修复。实现依据、网上参考方案及验证边界见 [2.4.4 发布记录](RepostsDownloads/RELEASE-2.4.4.md)。

同时提供含相同修复的 `2.4.4+diag.1` 文件诊断构建，便于真机复验；本地模拟测试不代表所有视频广告均已屏蔽。

诊断包构建命令：`sh RepostsDownloads/build-avatar-diagnostics.sh`。GitHub Actions 的 `XSuixin-avatar-diagnostics` 产物提供诊断 DEB 与 SHA-256；日志路径和复现步骤见[头像诊断说明](RepostsDownloads/AVATAR-DIAGNOSTICS.md)。

## 已发布 Release

[下载 X 随心 2.4.4（标准 Rootless）](https://github.com/Caun1112/XSuixin/releases/tag/v2.4.4)

安装包：`XSuixin_2.4.4_rootless.deb`（iOS 15.0+、arm64、标准 rootless 越狱环境）。发布页同时提供诊断包及 SHA-256 校验文件。

安装后彻底退出并重开 X，再进入全屏图片和上下滑动的视频流验证。

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
