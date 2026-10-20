# X 随心 2.5.0

X 随心（XSuixin）是面向 X/Twitter iOS 客户端的独立 Theos tweak，提供转推管理、视频与动图下载、分享图片、推荐/广告过滤，以及时间线和操作栏定制。

**正式源码仓库：[Caun1112/XSuixin](https://github.com/Caun1112/XSuixin)，开发主分支：`main`。** 插件源码与安装包元数据位于 [`RepostsDownloads/`](RepostsDownloads/)。功能版本为 **2.5.0**，完整 Debian 构建号为 **2.5.0-1**；设置、运行状态和导出日志同时显示源码仓库及提交。

## 下载与升级

[下载 2.5.0-1 rootless DEB 与 SHA-256](https://github.com/Caun1112/XSuixin/releases/tag/v2.5.0-1)

安装包为 `XSuixin_2.5.0-1_rootless.deb`，支持 iOS 15.0+、arm64、标准 `/var/jb` rootless 越狱环境，保留已有设置。覆盖安装后彻底退出并重开 X。仅提供一个默认内置诊断日志的包；未在真实设备验证的项目继续标注待验，不把编译或菜单出现当作真机通过。

## 本版变化

- 补齐此前仅推送到 BHTwitter 工作仓库的 2.4.7-7、2.4.7-8 修复：本地 JSON 日志隔离、验收页刷新、首页添加入口、推文操作栏下载按钮与右侧悬浮下载共存。
- 图片和链接复制核对实际剪贴板变化；图片检查类型及本次写入的数据，失败明确提示。当前图复制仍不联网。
- 普通 `marker=false` 广告观察保留首条，其余按计数与字节数汇总。真实丢弃、写入失败和主动聚合分开显示。
- 性能采样不足时明确显示待验证，避免短暂采样或上轮残留数据被描述为足够样本。
- 保留当前视频身份和来源限制，补齐有界视频诊断；脱敏导出保留资源拒绝类别，移除原始地址。

详细说明见 [2.5.0-1 发布记录](RepostsDownloads/RELEASE-2.5.0-1.md) 和 [真机验收清单](RepostsDownloads/DEVICE-ACCEPTANCE.md)。

## 为什么此前在这里找不到 2.4.7-8

2026-10-20 核对时，本仓库 `main` 仍为 `7919d0c` / 2.4.7-6；此前同步目标是另一个仓库 `Caun1112/BHTwitter`。2.4.7-8 的标签指向 `f02b0cd`，安装包发布在 [BHTwitter 的历史 Release](https://github.com/Caun1112/BHTwitter/releases/tag/v2.4.7-8)。之后 BHTwitter 的 `feature/block-retweet` 到达 `5248612`，但没有自动同步本仓库。

本次保留本仓库历史并同步产品源码，不移动或冒充旧标签。以后请以本仓库 `main`、完整版本标签及对应 Release 为准。GitHub Actions 从标签的干净提交构建；每次不同源码使用新修订，见 [构建政策](RepostsDownloads/BUILD-POLICY.md)。

## 构建与验证

需要 Theos、iOS 16.5 SDK、GNU Make、ldid、dpkg 和 FFmpeg。项目内保留独立构建需要的 JGProgressHUD、FFmpegKit 头文件和静态库。

```sh
sh RepostsDownloads/tests/run_all.sh
THEOS="$HOME/theos" sh RepostsDownloads/build.sh
python3 RepostsDownloads/scripts/verify_deb.py PACKAGE.deb --version 2.5.0-1 --commit FULL_40_CHARACTER_COMMIT --repository Caun1112/XSuixin
```

普通分支/PR 执行完整回归；版本标签或手动构建才生成 rootless 安装包。标签构建验证元数据、源码身份、rootless 路径及代码签名后自动发布包和 SHA-256。详细日志临时开启 10 分钟，不自动上传；见 [诊断日志](RepostsDownloads/AVATAR-DIAGNOSTICS.md)。

## 归属

X 随心的部分实现源自 BHTwitter（Bandar Alruwaili），下载按钮包含 actuallyaridan 的修改；分享图片主题配色参考 fluxdo。源文件中的第三方版权声明保持不变。请在分发或修改时同时遵守对应上游项目及 FFmpeg/FFmpegKit、JGProgressHUD 的许可条款。
