# 换机恢复与软件清单

盘点日期：2026-10-10。目标：同架构 x86_64 的 Arch/CachyOS，保留 KDE，额外恢复 Hyprland Vendetta。
这是配置和安装流程，不是磁盘镜像；账户、软件许可证、云端登录、密钥需要自行恢复。

## 1. 工作区

| 编号 | 名称 | 主要用途 |
|---|---|---|
| 1 | Development | VS Code、JetBrains、Neovide、Monado 模拟器 |
| 2 | Browser | Edge、Firefox |
| 3 | AI | ChatGPT / Codex、Claude |
| 4 | Entertainment | Steam、Spotify、Cider、YesPlayMusic、视频播放器 |
| 5 | Communication | QQ、微信、Discord、飞书、Telegram |
| 6 | System | 系统设置、系统监视器、RustDesk |
| 7 | Research | Zotero、Jupyter、PDF / 文献工具 |
| 8 | Graphics | Godot、Blender、RenderDoc、Nsight |
| 9 | Office | Office、会议、WinBoat；已知游戏例外到 4 |
| 10 | Temporary | 临时窗口 |

普通新主窗口静默归类；终端、Dolphin 保持当前工作区。Neovide 打开项目会主动跳到开发区。
现有窗口不会因加载规则自动搬家。浏览器中的 AI/Jupyter 页面仍属于浏览器。

## 2. 离开旧电脑前

- 提交 dotfiles，单独保存私有项目（食练、Daily English 等）；不要推送聊天记录、日记、浏览器配置、密钥或 API token。
- `packages/explicit-native.txt`：当前仓库来源的显式安装包；`explicit-foreign.txt`：外部包，**不等于全部都是 AUR**。
- `packages/installed-versions.txt`：完整包版本快照，仅用于排查/比较，不是锁定版本的安装指令。
- **不要整批重放快照**：其中包含本机内核、NVIDIA 驱动、引导器、CachyOS/KDE 预装包。
- 将以下私有备份保存到自己的外置盘（可能含登录信息，宜加密），不加入 Git：

```bash
# 从家目录归档，避免备份旧用户名绝对路径；目的盘路径请自行替换。
cd "$HOME"
tar -czf /path/to/private-backup/vendetta-runtime.tar.gz .local/share/end4-vendetta/runtime
# 用户安装程序按存在情况选择备份：
# .local/opt/  .local/share/yesplaymusic/  .local/bin/  .local/share/applications/
# .config/nvim/  .config/fcitx5/  .config/omnilyrics/  .local/share/fcitx5/
# .config/hypr/end4-session/illogical-impulse/config.json
# .local/state/end4-vendetta/quickshell/user/todo.json
```

WinBoat 需单独备份 Windows 虚拟磁盘和 compose 配置；先正常关闭 Windows，再做一致性备份。
compose 可能含凭据，不放 Git。只复制 EXE 启动器不能恢复 Windows 和应用。

## 3. 新系统与包安装

先完成新电脑的 CachyOS/Arch、KDE、显卡驱动与网络安装，确认 KDE 正常。
根据新 GPU/内核选择驱动，**不要复制旧机的 NVIDIA 模块或引导配置**。

```bash
sudo pacman -Syu
sudo pacman -S --needed git python
mkdir -p ~/.local/share/end4-vendetta
git clone --branch vendetta https://github.com/zzxzzk115/dots-hyprland.git ~/.local/share/end4-vendetta/repo
cd ~/.local/share/end4-vendetta/repo
bash vendetta/tools/install-packages.sh desktop development input apps
# 查看计划后执行：
bash vendetta/tools/install-packages.sh --apply desktop development input apps
# 按需：
bash vendetta/tools/install-packages.sh --apply research-graphics virtualization
# 仅 NVIDIA CUDA 开发机器：
bash vendetta/tools/install-packages.sh --apply nvidia-development
```

脚本检查包是否存在于新机配置的仓库；若有缺失，停止并列出名称，查明当前包名/来源后再安装。
不会自动启用 Docker、修改用户组、驱动或登录管理器。需要 WinBoat 时按其要求启用 Docker/KVM，验证 `/dev/kvm` 权限；加入 docker 组具有高权限含义，按需操作。

## 4. 常用软件安装来源

| 类别 | 软件 | 当前安装形式 / 恢复方式 |
|---|---|---|
| 开发 | Neovim、Neovide、Git、CMake、Rust、Node、JDK | development 包组；另恢复个人 nvim 配置，插件依赖由配置自身安装 |
| 开发 | VS Code | 官方 Linux x64 压缩包，当前 `~/.local/opt/vscode-1.139.1/VSCode-linux-x64`；下载并校验后安装到用户目录，修改 `optional/bin/code` 的版本路径，恢复 desktop 入口 |
| 开发 | JetBrains Toolbox、CLion | 官方 Linux 包到 `~/.local/opt/jetbrains/`；可先装 Toolbox 再管理 CLion；学生账号自行验证。当前 Toolbox 3.8.1、CLion 2026.2.2 |
| 图形 | Blender、RenderDoc、Vulkan 开发工具 | research-graphics 包组 |
| 图形 | Godot | 官方 Linux x86_64 包，当前 4.7.2，`~/.local/opt/godot-4.7.2`；恢复启动器和图标 |
| XR | Monado | 当前 `monado-simulated` 自定义包与 `~/.local/opt/monado-25.1.0`；必须从该项目构建流程恢复，不假定公共仓库有此包 |
| NVIDIA | CUDA、Nsight Compute、Nsight Systems | nvidia-development 包组；新驱动与 CUDA 支持矩阵需匹配 |
| NVIDIA | Nsight Graphics | NVIDIA 官方 Linux 安装包到 `~/.local/opt/nvidia/`；恢复 `nsight-graphics`/capture/replay 启动器，更新版本路径；不要带入全局私有 Qt 路径 |
| 科研 | Jupyter、SciPy、Pandas、Matplotlib、Zotero、perf、Valgrind、heaptrack | research-graphics 包组；项目 Python 依赖用 uv/venv，不复制旧 venv |
| 浏览器 | Firefox | apps 包组 |
| 浏览器 | Microsoft Edge | 当前包 `microsoft-edge-stable`，先查询本机仓库；外部包按可信 PKGBUILD/官方发行渠道安装，再恢复 browser.sh 和可选 microsoft-edge 包装器 |
| AI | ChatGPT/Codex 桌面 | 当前包 `chatgpt-desktop-bin`；根据当前发行来源安装，重新登录；包装器可能依赖 `/usr/bin/chatgpt`，安装后核实 |
| 通信 | Discord | apps 包组 |
| 通信 | 微信 | 当前包 `wechat-bin`，仓库或审查后的外部包 |
| 通信 | QQ、飞书、腾讯会议 | 用户目录安装：linuxqq 3.2.33-52892（自身可能已升级）、feishu 7.72.23、meeting 3.26.10.401；取官方 Linux 包，解包到 `.local/opt`，恢复 linuxqq/feishu/wemeet 包装器及 desktop 图标 |
| 音乐 | Spotify、Cider | 当前包 `spotify`、`cider`；按仓库可用性安装，重新登录 |
| 音乐 | YesPlayMusic | 当前 `~/.local/share/yesplaymusic/0.4.10`，从项目发行包恢复，更新启动器路径 |
| 游戏/视频 | Steam、Haruna、mpv | apps 包组；Steam 游戏库和兼容层单独恢复 |
| 远程 | RustDesk | apps 包组；连接凭据单独恢复 |
| 办公 | LibreOffice | apps 包组 |
| Windows | WinBoat、Kindle/其他 RemoteApp | 当前 `winboat` 包 + virtualization 包组；先恢复 Windows 容器，再部署 winboat-open。不要未安装 Windows 就设置 EXE 默认关联 |
| 其他 | 百度网盘、欧路听力、Etcher、Crow Translate | 快照分别为 baidunetdisk-bin、eudic-ting-en-bin、etcher-bin、crow-translate；按需从可信来源安装，不强制安装 |
| 独立项目 | OmniLyrics、Mchose 工具 | 从各项目仓库/发行页恢复；OmniLyrics 的 token 保持本地，dotfiles 只集成其 API |
| 私有项目 | 食练、Daily English 等 | 从相应私有仓库恢复；不在本公开 fork 中发布源码/日记 |

外部包示例流程：`pacman -Si 包名` 查仓库；没有则确认上游来源，审查 PKGBUILD 后通过 yay/makepkg 安装。不要把全部 foreign 包交给 AUR helper 自动处理。应用版本是盘点记录，不承诺旧版本下载长期有效。
安装后检查 `.desktop` 的 Exec/Icon、脚本中旧用户名和固定版本路径；`~/.local/bin` 必须在 PATH 中。

## 5. Quickshell 私有运行时与配置部署

当前 `vendetta/qs` 和 `vendetta/kitty` **依赖仓库旁的 runtime/**，只装系统 Quickshell 不足以满足这两个包装器。
该目录不在 Git 内，包含 Quickshell/Kitty、Qt 库、截图工具和字体。因此 fork 单独克隆不能完整恢复桌面。

可靠的同架构迁移路径：从自己的运行时备份恢复到原相对位置：

```bash
tar -xzf /path/to/private-backup/vendetta-runtime.tar.gz -C "$HOME"
~/.local/share/end4-vendetta/repo/vendetta/qs --version
~/.local/share/end4-vendetta/repo/vendetta/kitty --version
cd ~/.local/share/end4-vendetta/repo
python3 vendetta/tools/deploy-profile.py
python3 vendetta/tools/deploy-profile.py --apply
```

新系统库不兼容时，不要把旧 Qt 库复制到 `/usr/lib`。需按新机仓库重新组装运行时，或明确改用系统 Quickshell/Kitty 后验证；目前仓库**没有完整运行时自动重建器**。Material Symbols 字体也要恢复。
部署脚本备份现有 Hyprland 配置，创建 shell 符号链接并渲染模板；已有 shell config.json 保留，不覆盖私人设置。不会注销、重启或改动 KDE。
`monitors.py` 中 Philips/HDMI-A-1 的 4K/120Hz/166.7% 是旧机特例，新机先检查接口和缩放。

## 6. 输入法（当前采用 Fcitx 5）

当前 profile 选择 Rime（不是早期 Pinyin），input 包组包含 fcitx5-rime。恢复 `optional/rime/default.custom.yaml` 到 `~/.local/share/fcitx5/rime/`，安装提供 luna_pinyin 方案的 `rime-luna-pinyin` 包并在 Fcitx 内重新部署 Rime；用户词库仅从私有备份恢复。

安装 input 包组后，选择性恢复以下配置；不要同时启动 IBus 和 Fcitx。

```bash
cd ~/.local/share/end4-vendetta/repo
mkdir -p ~/.local/bin ~/.config/fcitx5 ~/.config/systemd/user
# 已有输入法配置请先备份再复制。
cp vendetta/optional/fcitx5/{config,profile} ~/.config/fcitx5/
install -m755 vendetta/optional/bin/fcitx5-{english,recover,healthcheck} ~/.local/bin/
cp vendetta/systemd/user/fcitx5.service vendetta/systemd/user/fcitx5-healthcheck.service vendetta/systemd/user/fcitx5-healthcheck.timer ~/.config/systemd/user/
# 实际存在的单元为 fcitx5.service、fcitx5-healthcheck.service、fcitx5-healthcheck.timer。
systemctl --user daemon-reload
systemctl --user enable --now fcitx5-healthcheck.timer
# Hyprland session-start.sh 会启动 fcitx5.service。
```

不要在 KDE 内盲目 `enable --now fcitx5.service`，避免与 Plasma 虚拟键盘启动方式重复。
Ctrl+Space 由 Fcitx 根据文本上下文处理，不绑定全局 Hyprland；顶栏按钮左键英文、右键恢复输入法。
自动恢复脚本两次探测失败后重启服务。当前服务禁用了 cloudpinyin/clipboard 等插件，换机时可自行审查。

## 7. 可选集成与验证

- 按需复制 `optional/bin`，每个包装器先确认其指向的程序已安装；不要整目录覆盖个人脚本。
- 额度服务：复制 codex-usage 与对应 user service/timer，登录应用后启用 timer。不要复制认证 token 到仓库。
- NVIDIA 性能计数器授权需要重新按新机驱动/用户配置；不要全局放开性能计数器，也不要照抄旧机用户 ACL。
- WinBoat 的 EXE MIME、KDE 额度小部件是共享/额外集成，按 README 单独选择安装。
- 登录 Hyprland 后检查：`hyprctl configerrors`、`hyprctl monitors`；Super+D、截图、声音、剪贴板、输入中文、锁屏和重新登录。
- 新开 IDE/浏览器应分别进 1/2；音乐/Steam 进 4；Quickshell 资源监控和网速正常。
- 再登录 KDE，确认显示器、通知、输入法均正常。恢复失败时在 KDE 中使用部署脚本输出的备份目录；不要复制旧系统整个 `/etc`。

本次验证范围：本机包清单导出、Python/Shell/Lua 语法、安装/部署 dry-run、Hyprland 规则重载。没有在全新系统上完整安装验证。
