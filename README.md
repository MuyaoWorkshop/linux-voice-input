# 语音输入工具

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.8+-green.svg)](https://www.python.org/)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)](https://www.linux.org/)

**一句话说明：** 在 Linux 上用说话代替打字，实现语音输入文本 🎤 → 📝

## ✨ 特点

- 🚀 **双方案可选**：离线 Whisper + 在线讯飞云，按需切换
- ⚡ **极速启动**：守护进程模式，<0.5秒响应（可选）
- 📊 **实时反馈**：音量条、静音倒计时，录音状态一目了然
- 📋 **自动粘贴**：识别完成自动复制到剪贴板
- 🎯 **开箱即用**：提供完整安装脚本，5分钟配置完成
- 🔒 **隐私保护**：支持完全离线的本地识别
- 🔄 **一键切换**：守护进程模式 ↔ 普通模式，按需选择

## 🎬 使用演示

```
按 Super+Shift+V → 🎤 说话 → ⏱️ 实时识别 → 📋 自动复制 → Ctrl+V 粘贴
```

**典型场景：**
- ✍️ 写文档、记笔记时懒得打字
- 💬 聊天时快速输入长段文字
- 📧 写邮件时边想边说
- 🖥️ 任何需要文字输入的地方

**效果对比：**
- 传统打字 200 字：约 3-5 分钟
- 语音输入 200 字：约 1 分钟 ⚡

## 📋 系统要求

### 最低配置
- **操作系统**：Linux（Debian/Ubuntu/Arch/Fedora 等桌面发行版）
- **桌面环境**：GNOME（推荐）、KDE、XFCE 等
- **Python 版本**：3.8 或更高
- **磁盘空间**：2GB（Whisper 模型）
- **内存**：4GB RAM
- **麦克风**：任何 USB 或内置麦克风

### 推荐配置
- **内存**：8GB RAM
- **CPU**：4 核心以上（离线识别更快）
- **网络**：稳定网络连接（使用讯飞云方案时）

### 已测试环境
- ✅ Debian 12

其他 Linux 发行版（Ubuntu/Arch/Fedora 等）理论上也可用，但未经测试。

## 🚀 5分钟快速开始

### 我该选择哪个方案？

**回答3个问题快速决策：**

1. **你有稳定的网络吗？**
   - ✅ 有 → 推荐讯飞云（准确率 95%+、速度快）
   - ❌ 没有 → 选择离线 Whisper

2. **你在意隐私吗？**
   - ✅ 非常在意 → 离线 Whisper（完全本地）
   - ⚪ 一般 → 讯飞云（体验更好）

3. **你需要长文本输入吗？**
   - ✅ 需要（>10秒） → 讯飞云（无时长限制）
   - ❌ 不需要 → 离线 Whisper 足够

### 开始安装（3选1）

**方案 A：只装讯飞云（推荐新手）** ⭐
```bash
cd ~/bin/tools/voice_input/xfyun
./setup_xfyun.sh
# 跟随提示注册账号、获取密钥、配置
```
👉 [详细步骤](./xfyun/XFYUN_QUICKSTART.md)

**方案 B：只装离线 Whisper**
```bash
# 查看完整安装指南
cat ~/bin/tools/voice_input/local/INSTALL.md
```
👉 [详细步骤](./local/QUICKSTART.md)

**方案 C：都装（最灵活）**
先安装离线方案（基础环境），再添加讯飞云增强。

---

## ⚡ 守护进程模式（性能优化）

### 什么是守护进程模式？

离线 Whisper 方案支持**两种运行模式**：

#### 1. 普通模式（默认）
- **启动方式**：按快捷键时加载模型
- **启动速度**：4-5 秒
- **内存占用**：不占用常驻内存
- **适合场景**：偶尔使用（日均 1-2 次）

#### 2. 守护进程模式（推荐）⭐
- **启动方式**：后台常驻，预加载模型
- **启动速度**：**<0.5 秒** 🚀
- **内存占用**：~900MB 常驻
- **适合场景**：频繁使用（日均 10+ 次）
- **额外功能**：实时音量条、静音倒计时

### 一键切换模式

```bash
# 查看当前模式
cd ~/bin/tools/voice_input/local
./switch_mode.sh status

# 切换到守护进程模式（快速）
./switch_mode.sh daemon

# 切换到普通模式（节省内存）
./switch_mode.sh normal

# 自动切换（守护进程 ↔ 普通）
./switch_mode.sh toggle
```

### 守护进程管理命令

```bash
# 启动守护进程
systemctl --user start voice-input-daemon

# 停止守护进程
systemctl --user stop voice-input-daemon

# 开机自启动
systemctl --user enable voice-input-daemon

# 查看状态和资源占用
systemctl --user status voice-input-daemon

# 查看实时日志
journalctl --user -u voice-input-daemon -f
```

### 技术文档

想深入了解守护进程模式的实现原理？查看详细技术文档：

👉 **[守护进程优化：从 4 秒到 0.5 秒](./docs/DAEMON_OPTIMIZATION.md)**

**文档内容**：
- 性能瓶颈分析
- 解决方案设计与架构
- Unix Socket 通信实现
- systemd 服务配置
- CPU 优化过程（10% → 1.6%）
- 适合初学者的详细讲解

---

## 方案选择

### 📦 方案对比

| 特性 | 离线 Whisper | 讯飞云 API |
|------|-------------|------------|
| **启动速度** | ⭐⭐⭐⭐⭐ <0.5秒（守护进程）<br>⭐⭐ 4-5秒（普通模式） | ⭐⭐⭐⭐⭐ 实时 <500ms |
| **识别速度** | ⭐⭐⭐ 延迟 2-3秒 | ⭐⭐⭐⭐⭐ 实时 <500ms |
| **准确率** | ⭐⭐⭐⭐ 85% | ⭐⭐⭐⭐⭐ 95%+ |
| **时长限制** | ⭐⭐⭐ 60秒 | ⭐⭐⭐⭐⭐ 无限制 |
| **实时反馈** | ✅ 音量条+倒计时（守护进程）<br>⚠️ 简单提示（普通模式） | ✅ 实时文字流 |
| **标点符号** | ❌ 无 | ✅ 自动添加 |
| **网络需求** | ✅ 完全离线 | ⚠️ 需要联网 |
| **隐私性** | ⭐⭐⭐⭐⭐ 本地处理 | ⭐⭐ 数据上传 |
| **内存占用** | ⭐⭐⭐ ~900MB（守护进程）<br>⭐⭐⭐⭐⭐ 0MB（普通模式） | ⭐⭐⭐⭐⭐ 极低 |
| **费用** | ✅ 完全免费 | ⭐⭐⭐⭐ 基本免费 |

### 🎯 使用建议

**推荐：混合使用**
- **日常使用** → 讯飞云（90%场景）- 快速、准确、长文本
- **隐私保护** → 离线 Whisper（10%场景）- 敏感内容、离线环境

**配置双快捷键：**
- `Super + Shift + V` → 讯飞云
- `Super + V` → 离线 Whisper

## 📂 方案文档

### 方案一：离线 Whisper（基础方案）

📁 目录：`local/`

- **[完整安装指南](./local/INSTALL.md)** - 详细安装步骤和故障排查
- **[快速开始](./local/QUICKSTART.md)** - 5分钟快速部署

**适合场景：**
- 完全离线环境
- 隐私敏感内容
- 作为云服务的备选方案

### 方案二：讯飞云 API（推荐方案）

📁 目录：`xfyun/`

- **[完整配置指南](./xfyun/XFYUN_GUIDE.md)** - API注册、密钥获取、详细配置
- **[快速开始](./xfyun/XFYUN_QUICKSTART.md)** - 3分钟快速配置

**适合场景：**
- 日常办公、笔记输入
- 长文本连续输入
- 对准确率要求高
- 需要实时反馈

---

## 快速开始

### 新用户（推荐流程）

1. **先安装离线方案**（基础环境）
   ```bash
   # 查看详细步骤
   cat ~/bin/tools/voice_input/local/INSTALL.md
   ```

2. **再配置讯飞云**（日常主力）
   ```bash
   cd ~/bin/tools/voice_input/xfyun
   ./setup_xfyun.sh
   ```

3. **配置双快捷键**
   - Super+V → 离线
   - Super+Shift+V → 讯飞云

### 已有离线方案用户

直接添加讯飞云方案：
```bash
cd ~/bin/tools/voice_input/xfyun
./setup_xfyun.sh
```

---

## 使用方法

### 快捷键（推荐）

**讯飞云（日常使用）：**
1. 按 `Super + Shift + V`
2. 对着麦克风连续说话（可以很长）
3. 按 `Ctrl + C` 停止
4. 自动复制到剪贴板
5. 按 `Ctrl + V` 粘贴

**离线 Whisper（隐私保护）：**
1. 按 `Super + V`
2. 对着麦克风说话（10秒内）
3. 停顿 2 秒自动结束
4. 自动复制到剪贴板
5. 按 `Ctrl + V` 粘贴

### 命令行

```bash
# 讯飞云
cd ~/bin/tools/voice_input/xfyun
./voice_input_xfyun.py

# 离线 Whisper
cd ~/bin/tools/voice_input/local
./voice_input.py
```

---

## 工作流程对比

### 讯飞云（实时流式）
```
Super+Shift+V → 弹出终端 → 🎤开始录音 → 持续说话 → 实时显示结果 → Ctrl+C停止 → ✓复制 → Ctrl+V粘贴
```

### 离线 Whisper（批量识别）
```
Super+V → 弹出终端 → 🎤录音 → 说话 → 停顿2秒 → 识别中... → ✓复制 → Ctrl+V粘贴
```

---

## 📖 实际使用示例

### 场景1：写工作日报

**传统方式：** 键盘打字 5 分钟，写 200 字
**使用语音输入：** 说话 1 分钟 ⚡

```
操作步骤：
1. 打开文本编辑器
2. 按 Super+Shift+V 启动语音输入
3. 说话："今天完成了用户登录模块的开发，修复了三个bug，
   包括密码验证逻辑错误、session超时处理和前端表单校验问题。
   明天计划开始用户权限管理模块的设计。"
4. 按 Ctrl+C 停止录音
5. 按 Ctrl+V 粘贴到编辑器
6. ✅ 完成！自动带标点符号
```

### 场景2：回复长邮件

**传统方式：** 打字 10 分钟
**使用语音输入：** 说话 3 分钟 ⚡

```
特别适合：
- 需要详细解释的技术邮件
- 项目进度汇报
- 客户需求沟通
```

### 场景3：聊天输入长文本

**微信/QQ/Telegram 等聊天工具都能用**

```
1. 在聊天窗口点击输入框
2. 按 Super+Shift+V
3. 说出你想发送的内容
4. Ctrl+C 停止，Ctrl+V 粘贴
5. 发送
```

### 场景4：写技术文档

**边想边说，思路更流畅**

```
传统：想 → 组织语言 → 打字（思维中断）
语音：想 → 直接说出来 → 粘贴（思维连贯）

特别适合：
- API 文档说明
- 操作步骤记录
- 设计思路整理
```

### 场景5：会议记录

**实时记录会议要点**

```
会议中：
- 按 Super+Shift+V
- 听到重要内容时复述一遍
- Ctrl+C 停止
- Ctrl+V 粘贴到文档
- 继续听会议

比纯手打快 3-5 倍！
```

---

## 配置和优化

详细的配置调整和使用技巧请查看各方案文档：

### 离线 Whisper 配置
- **模型选择** - tiny/base/small/medium
- **语言设置** - 中文/英文/自动检测
- **录音参数** - 时长、静音检测阈值
- **性能优化** - CPU占用、内存管理

📖 详见：[local/INSTALL.md](./local/INSTALL.md)

### 讯飞云配置
- **API 密钥管理** - 安全存储、权限设置
- **网络优化** - 连接超时、重试策略
- **识别参数** - 方言、领域定制
- **费用管理** - 额度监控、成本优化

📖 详见：[xfyun/XFYUN_GUIDE.md](./xfyun/XFYUN_GUIDE.md)

---

## ⚠️ 常见问题与故障排查

### 快速排查表

| 症状 | 可能原因 | 快速解决方案 | 详细文档 |
|------|---------|------------|----------|
| 🎤 录音失败/"无法打开麦克风" | 麦克风权限/驱动 | 运行 `arecord -l` 检查麦克风 | [麦克风问题](#麦克风问题) |
| 🌐 讯飞连接失败 | API密钥错误/网络 | 检查 `xfyun/config.ini` 密钥 | [xfyun/XFYUN_GUIDE.md#Q1](./xfyun/XFYUN_GUIDE.md#常见问题) |
| 🐌 离线识别很慢（>10秒） | CPU性能不足/模型太大 | 换用 tiny 模型：编辑脚本 `model="tiny"` | [local/INSTALL.md#性能优化](./local/INSTALL.md) |
| ❌ 无法粘贴/剪贴板为空 | xclip 未安装 | 运行 `sudo apt install xclip` | [系统依赖](#系统依赖) |
| ⌨️ 快捷键不工作 | 脚本权限/路径错误 | 运行 `chmod +x ~/bin/tools/voice_input/*/*.sh` | [local/INSTALL.md#配置快捷键](./local/INSTALL.md) |
| 📝 识别结果无标点 | 使用了离线方案/讯飞服务未开通 | 切换到讯飞云方案 | [方案对比](#方案选择) |
| 🔄 识别结果重复/乱码 | 网络问题/WebSocket异常 | 重启终端，重新运行脚本 | [xfyun/XFYUN_GUIDE.md](./xfyun/XFYUN_GUIDE.md) |
| 💾 离线模型下载失败 | 网络问题/磁盘空间不足 | 检查磁盘空间 `df -h`，清理空间后重试 | [local/INSTALL.md](./local/INSTALL.md) |
| 🚫 "ModuleNotFoundError" | Python包未安装/虚拟环境未激活 | 运行 `workon voice_input` 激活环境 | [环境配置](#环境配置) |
| 🎯 识别准确率低 | 环境嘈杂/口音问题/模型不适合 | 在安静环境使用，或切换方案 | [提高准确率](#提高准确率) |

### 详细故障排查

#### 麦克风问题

**检查麦克风是否被识别：**
```bash
# 列出所有音频设备
arecord -l

# 测试录音（录5秒）
arecord -d 5 test.wav

# 播放测试
aplay test.wav
```

**常见解决方案：**
- Ubuntu/Debian: `sudo apt install alsa-utils pulseaudio`
- 权限问题: `sudo usermod -aG audio $USER`（需要重新登录）

#### 环境配置

**检查虚拟环境：**
```bash
# 查看是否在虚拟环境中
which python
# 应显示：/home/用户名/.virtualenvs/voice_input/bin/python

# 激活虚拟环境
workon voice_input

# 检查已安装的包
pip list | grep -E "(whisper|torch|pyaudio|websocket)"
```

#### 系统依赖

**安装缺失的依赖：**
```bash
# Debian/Ubuntu
sudo apt update
sudo apt install xclip portaudio19-dev python3-dev

# Arch Linux
sudo pacman -S xclip portaudio python
```

#### 提高准确率

**离线方案：**
- 升级模型：tiny → base → small → medium
- 在安静环境使用
- 说话清晰，速度适中

**讯飞云方案：**
- 检查网络连接稳定性
- 在安静环境使用
- 说话清晰，避免方言

### 获取帮助

如果以上方法都无法解决问题：

1. 📖 查看详细文档：
   - [离线方案完整指南](./local/INSTALL.md)
   - [讯飞云完整指南](./xfyun/XFYUN_GUIDE.md)

2. 🐛 提交问题：
   - [GitHub Issues](https://github.com/MuyaoWorkshop/linux-voice-input/issues)
   - [Gitee Issues](https://gitee.com/muyaoworkshop/linux-voice-input/issues)

3. 📋 提交时请包含：
   - 操作系统版本：`cat /etc/os-release`
   - Python版本：`python3 --version`
   - 错误信息截图或日志
   - 复现步骤

### 方案选择建议

**何时用讯飞云？**
- ✅ 日常办公、笔记
- ✅ 长文本输入
- ✅ 需要标点符号
- ✅ 要求高准确率

**何时用离线 Whisper？**
- ✅ 隐私敏感内容
- ✅ 离线环境
- ✅ 短句输入
- ✅ 不想依赖网络

详细问题排查请查看各方案的文档。

---

## 项目结构

```
~/bin/tools/voice_input/
├── README.md                    # 本文件（总览）
├── .envrc                       # direnv 配置
│
├── local/                       # 离线 Whisper 方案
│   ├── voice_input.py           # 主程序
│   ├── voice_input_wrapper.sh   # 快捷键脚本
│   ├── INSTALL.md               # 完整安装指南
│   └── QUICKSTART.md            # 快速开始
│
└── xfyun/                       # 讯飞云 API 方案
    ├── voice_input_xfyun.py     # 主程序
    ├── voice_input_wrapper_xfyun.sh  # 快捷键脚本
    ├── setup_xfyun.sh           # 自动配置脚本
    ├── config.ini.example       # 配置文件模板
    ├── XFYUN_GUIDE.md           # 完整配置指南
    └── XFYUN_QUICKSTART.md      # 快速开始

~/.virtualenvs/voice_input/      # Python 虚拟环境（共享）
├── bin/python
└── lib/python3.x/site-packages/
    ├── whisper/                 # Whisper 离线模型
    ├── torch/                   # PyTorch
    ├── pyaudio/                 # 音频录制
    └── websocket/               # WebSocket 客户端
```

## 技术栈

### 离线方案
- **语音识别**: [OpenAI Whisper](https://github.com/openai/whisper)
- **深度学习**: PyTorch (CPU mode)
- **音频录制**: PyAudio
- **系统集成**: xclip

### 讯飞云方案
- **语音识别**: [讯飞开放平台](https://www.xfyun.cn/)
- **通信协议**: WebSocket
- **音频录制**: PyAudio
- **系统集成**: xclip

### 共同依赖
- **环境管理**: virtualenvwrapper + direnv
- **桌面环境**: GNOME (其他桌面需调整快捷键配置)
- **系统**: Linux (Debian/Ubuntu)

---

## 📚 术语解释（新手可选阅读）

如果你是Linux新手，可能对一些技术术语不熟悉。这里做简单解释：

| 术语 | 解释 | 你需要知道的 |
|------|------|------------|
| **Whisper** | OpenAI 开发的离线语音识别AI模型 | 就像手机上的语音助手，但完全在你电脑上运行 |
| **讯飞云** | 科大讯飞提供的在线语音识别服务 | 类似百度、搜狗的语音输入，需要联网 |
| **virtualenv** | Python虚拟环境，隔离项目依赖 | 避免不同Python项目之间冲突，不用管细节 |
| **xclip** | Linux剪贴板工具 | 让程序能把文字复制到剪贴板 |
| **PyAudio** | Python录音库 | 让Python程序能录音 |
| **WebSocket** | 实时双向通信协议 | 让你的电脑和讯飞服务器实时传输语音 |
| **API密钥** | 访问讯飞服务的"钥匙" | 免费申请，证明你有权使用讯飞服务 |
| **Super键** | Windows键 | 键盘上带Windows图标的键 |

**总之：** 新手不需要深入理解这些，跟着安装步骤操作即可。

---

## 🗑️ 卸载方法

### 完全卸载

如果你决定不再使用这个工具，可以完全删除：

```bash
# 1. 删除项目文件
rm -rf ~/bin/tools/voice_input

# 2. 删除 Python 虚拟环境
rmvirtualenv voice_input

# 3. 删除快捷键
# 方法A：通过GNOME设置（推荐）
# 设置 → 键盘 → 查看和自定义快捷键 → 删除"语音输入"相关项

# 方法B：命令行删除
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[]"

# 4. （可选）卸载系统依赖
# 注意：这些工具可能被其他程序使用，请谨慎删除
sudo apt remove xclip portaudio19-dev
# 或 Arch: sudo pacman -R xclip portaudio
```

### 只卸载某个方案

```bash
# 只删除讯飞云方案
rm -rf ~/bin/tools/voice_input/xfyun

# 只删除离线方案（保留讯飞云）
rm -rf ~/bin/tools/voice_input/local
```

### 卸载后

- ✅ 不会影响系统其他功能
- ✅ Python虚拟环境被删除，不占用磁盘
- ✅ 快捷键失效
- ✅ 如果想恢复，重新安装即可

---

## 总结

这个项目提供了**灵活的混合方案**：

1. **离线 Whisper** - 隐私保护，完全本地
2. **讯飞云 API** - 实时准确，体验最佳

推荐配置双快捷键，根据场景灵活切换，兼顾效率和隐私。

**快速开始：**
```bash
# 1. 安装离线方案（基础）
cat ~/bin/tools/voice_input/local/QUICKSTART.md

# 2. 配置讯飞云（增强）
cd ~/bin/tools/voice_input/xfyun
./setup_xfyun.sh
```

---

## 支持与反馈

- **项目地址**: https://github.com/MuyaoWorkshop/linux-voice-input
- **问题反馈**: https://github.com/MuyaoWorkshop/linux-voice-input/issues
- **文档更新**: 2025-12-22
