# 语音输入工具

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.8+-green.svg)](https://www.python.org/)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)](https://www.linux.org/)
[![Version](https://img.shields.io/badge/version-v3.0.0-brightgreen.svg)](https://github.com/MuyaoWorkshop/linux-voice-input)

**一句话说明：** 在 Linux 上用说话代替打字，实现语音输入文本 🎤 → 📝

> **v3.0 极简版**：专注 Whisper 离线识别，3 个核心文件，<0.1秒启动

## ✨ 特点

- 🚀 **完全离线**：基于 Whisper 本地识别，无需联网
- ⚡ **快速启动**：守护进程模式，<0.1秒响应
- 📊 **实时反馈**：音量条、静音倒计时、图形界面
- 📋 **快速复制**：识别完成自动复制到剪贴板，Ctrl+V 粘贴
- 🎯 **开箱即用**：一键安装脚本，5分钟配置完成
- 🔒 **隐私保护**：完全本地识别，数据不上传

## 🎬 使用演示

```
按 Super+V → 🎤 说话 → ⏱️ 实时识别 → 📋 自动复制 → Ctrl+V 粘贴
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

### 已测试环境
- ✅ Debian 12 + GNOME

其他 Linux 发行版（Ubuntu/Arch/Fedora 等）理论上也可用，但未经测试。

---

## 🚀 快速开始

### 一键安装（推荐）⭐

```bash
# 1. 克隆或下载项目到任意目录
cd ~/Downloads
git clone <项目仓库地址>
cd voice_input

# 2. 运行安装脚本（自动安装所有依赖）
./setup.sh install

# 3. 按提示配置（GNOME 会自动配置快捷键）
# 完成！
```

安装脚本会自动：
- ✅ 检测系统环境并安装依赖
- ✅ 在项目目录创建 Python 虚拟环境
- ✅ 下载 Whisper 模型
- ✅ 配置守护进程服务（可选）
- ✅ GNOME 桌面自动配置快捷键

安装完成后：
- 项目目录可以放在任意位置
- 按 `Super+V` 即可使用
- 不需要添加到 PATH 或安装到系统目录

---

## 📖 详细安装

### 1. 系统依赖

```bash
# Debian/Ubuntu
sudo apt update
sudo apt install -y portaudio19-dev python3-pyaudio xclip ffmpeg python3-tk

# Arch Linux
sudo pacman -S portaudio python-pyaudio xclip ffmpeg tk

# Fedora
sudo dnf install -y portaudio-devel python3-pyaudio xclip ffmpeg python3-tkinter
```

**依赖说明**：
- `portaudio19-dev` - 音频录制库
- `python3-pyaudio` - Python 音频接口
- `xclip` - 剪贴板工具
- `ffmpeg` - 音频处理
- `python3-tk` - 图形界面（可选，不安装会使用终端模式）

### 2. 运行安装脚本

```bash
cd /path/to/voice_input
./setup.sh install
```

安装脚本会：
1. 检测系统环境和依赖
2. 在项目目录创建 `venv/` 虚拟环境
3. 安装 Python 依赖包
4. 下载 Whisper 模型（~150MB）
5. 创建 systemd 服务（守护进程模式，可选）
6. GNOME 桌面自动配置 `Super+V` 快捷键

### 3. 快捷键配置

**GNOME（自动配置）**：
安装脚本会自动配置 `Super+V` 快捷键。

**KDE/XFCE/其他桌面（手动配置）**：

1. 打开系统设置 → 键盘 → 快捷键 → 自定义快捷键
2. 添加新快捷键：
   - **名称**: 语音输入
   - **命令**: `/path/to/voice_input/trigger.py`（守护进程模式）或 `/path/to/voice_input/voice_input.py`（普通模式）
   - **快捷键**: `Super+V`

**i3/sway**：
```bash
# 编辑 ~/.config/i3/config 或 ~/.config/sway/config
# 守护进程模式（推荐）
bindsym $mod+v exec /path/to/voice_input/trigger.py
# 或普通模式
bindsym $mod+v exec /path/to/voice_input/voice_input.py
```

**注意**：`trigger.py` 只在启用守护进程模式后才会生成

---

## 🎯 使用方法

### 快捷键（推荐）

1. 按 `Super + V`
2. 对着麦克风说话
3. 停顿 2 秒自动结束
4. 自动复制到剪贴板
5. 按 `Ctrl + V` 粘贴

### 命令行

```bash
# 进入项目目录
cd /path/to/voice_input

# 普通模式（4-5秒启动）
./voice_input.py

# 守护进程模式（推荐）
# 1. 启动守护进程服务（后台常驻）
systemctl --user start voice-input-daemon

# 2. 触发识别（<0.1秒启动）
./trigger.py
```

**注意**：首次使用守护进程需要运行 `./setup.sh install` 并选择启用守护进程

---

## ⚡ 守护进程模式（性能优化）

### 什么是守护进程模式？

离线 Whisper 方案支持**两种运行模式**：

#### 1. 普通模式
- **启动方式**：按快捷键时加载模型
- **启动速度**：4-5 秒
- **内存占用**：不占用常驻内存
- **适合场景**：偶尔使用（日均 1-2 次）

#### 2. 守护进程模式（推荐）⭐
- **启动方式**：后台常驻，预加载模型
- **启动速度**：**<0.1 秒** 🚀
- **内存占用**：~900MB 常驻
- **适合场景**：频繁使用（日均 10+ 次）
- **额外功能**：轻量级触发器（trigger.py）、实时音量条、静音倒计时

### 守护进程管理

使用 systemd 服务管理守护进程：

```bash
# 启动守护进程
systemctl --user start voice-input-daemon

# 停止守护进程
systemctl --user stop voice-input-daemon

# 查看状态和资源占用
systemctl --user status voice-input-daemon

# 查看实时日志
journalctl --user -u voice-input-daemon -f

# 开机自启动
systemctl --user enable voice-input-daemon

# 禁用自启动
systemctl --user disable voice-input-daemon
```

### 性能原理

**为什么快？**

普通模式每次启动都要：
1. 加载 Python 解释器（0.3秒）
2. 导入库（0.8秒）
3. **加载 Whisper 模型（3.5秒）** ← 瓶颈
4. 初始化音频设备（0.4秒）

守护进程模式：
- 启动时一次性加载模型到内存
- 后续使用直接复用已加载的模型
- 通过 Unix Socket 通信，几乎无延迟
- **动态生成轻量级触发器**：`trigger.py` 仅导入轻量库（socket、json、tkinter），避免加载重型库（whisper、numpy、pyaudio）

**资源占用优化：**
- 触发器启动时间：<0.1 秒（仅导入轻量库）
- 守护进程使用 `select()` 等待连接，空闲时 CPU <2%
- 内存占用稳定在 ~900MB
- 无任务时不消耗 CPU 资源

---

## 配置和优化

### Whisper 模型选择

编辑 `voice_input.py` 第 100 行：

```python
WHISPER_MODEL = "base"  # 修改这里
```

**模型对比**：

| 模型 | 内存占用 | 识别速度 | 准确率 | 说明 |
|------|---------|---------|--------|------|
| tiny | ~390MB | ⭐⭐⭐⭐⭐ 很快 | ⭐⭐⭐ 80% | 低配机器 |
| base | ~580MB | ⭐⭐⭐⭐ 快 | ⭐⭐⭐⭐ 85% | 推荐日常使用 |
| small | ~1.2GB | ⭐⭐⭐ 中等 | ⭐⭐⭐⭐ 90% | 高准确率 |
| medium | ~3.1GB | ⭐⭐ 较慢 | ⭐⭐⭐⭐⭐ 95% | 专业使用 |

**推荐**：
- 日常使用：`base` 模型
- 低配机器：`tiny` 模型
- 高准确率：`small` 模型

### 静音检测时间

编辑 `voice_input.py` 第 108 行：

```python
SILENCE_DURATION = 2.0  # 修改停顿时长（秒）
```

- 设置过短（1.0秒）：说话时容易被中断
- 设置过长（3.0秒）：等待时间变长

### UI 模式切换

```bash
# 强制使用图形界面
export VOICE_INPUT_UI_MODE=gui
./voice_input.py

# 强制使用终端模式
export VOICE_INPUT_UI_MODE=terminal
./voice_input.py
```

---

## ⚠️ 常见问题

### 1. 麦克风无法录音

**检查麦克风设备**：
```bash
arecord -l  # 列出所有音频设备
arecord -d 5 test.wav  # 录音测试 5 秒
aplay test.wav  # 播放测试
```

**解决方案**：
- 确认麦克风已连接并被系统识别
- 检查音量设置：`alsamixer`
- 添加用户到 audio 组：`sudo usermod -aG audio $USER`（需重新登录）

### 2. 识别速度慢

**方案 1：使用守护进程模式**（推荐）
```bash
systemctl --user start voice-input-daemon
# 按 Super+V 启动速度 <0.1秒
```

**方案 2：降级模型**
编辑 `voice_input.py`，将 `WHISPER_MODEL = "base"` 改为 `"tiny"`

**方案 3：减少静音检测时间**
编辑 `voice_input.py`，将 `SILENCE_DURATION = 2.0` 改为 `1.5`

### 3. 剪贴板无法粘贴

**症状**：识别完成但无法粘贴

**解决方案**：
```bash
# 安装 xclip
sudo apt install xclip

# 测试剪贴板
echo "test" | xclip -selection clipboard
xclip -selection clipboard -o  # 应输出 test
```

### 4. 守护进程无法启动

**查看日志**：
```bash
journalctl --user -u voice-input-daemon -n 50
```

**检查 socket 文件**：
```bash
ls -l /tmp/voice_input_daemon.sock
```

**手动启动测试**：
```bash
# 通过 systemd 启动
systemctl --user restart voice-input-daemon

# 查看是否生成了 trigger.py
ls -l /path/to/voice_input/trigger.py
```

### 5. Tkinter 图形界面不可用

**症状**：提示 "Tkinter 不可用，降级为终端模式"

**解决方案**：
```bash
# Debian/Ubuntu
sudo apt install python3-tk

# Arch Linux
sudo pacman -S tk

# Fedora
sudo dnf install python3-tkinter
```

### 6. 识别结果没有标点符号

**原因**：Whisper 本地识别模型默认不支持自动添加标点符号

**解决方案**：
- 识别后手动添加标点
- 或使用在线 API（如讯飞云，需额外配置）

### 7. 快捷键不生效

**检查快捷键是否已设置**：
```bash
# GNOME 查看快捷键配置
gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings
```

**重新配置快捷键**：
```bash
./setup.sh install  # 重新运行安装脚本
```

---

## 📂 项目结构（简化后）

```
voice_input/
├── voice_input.py      # 主程序（包含所有功能）
├── README.md           # 本文档（包含所有说明）
├── setup.sh            # 安装/卸载脚本
├── LICENSE             # MIT 许可证
├── venv/               # Python 虚拟环境（安装后自动创建）
└── trigger.py          # 轻量级触发器（启用守护进程时动态生成）
```

**极简设计理念**：
- ✅ 只有 3 个核心文件（voice_input.py、README.md、setup.sh）
- ✅ 无需安装到系统目录
- ✅ 项目可放在任意位置
- ✅ 易于管理和备份
- ✅ trigger.py 仅在启用守护进程时自动生成，保持项目简洁

---

## 🗑️ 卸载

```bash
# 运行卸载脚本
./setup.sh uninstall

# 或手动删除
cd /path/to/voice_input
systemctl --user stop voice-input-daemon
systemctl --user disable voice-input-daemon
rm ~/.config/systemd/user/voice-input-daemon.service
rm -rf venv/
rm -rf ~/.cache/whisper/  # 删除模型缓存（可选）
```

**GNOME 删除快捷键**：
```bash
gsettings reset org.gnome.settings-daemon.plugins.media-keys custom-keybindings
```

---

## 技术栈

### 核心技术
- **语音识别**: [OpenAI Whisper](https://github.com/openai/whisper)
- **深度学习**: PyTorch (CPU mode)
- **音频录制**: PyAudio
- **UI 框架**: Tkinter
- **系统集成**: xclip, systemd

### 架构特点
- **守护进程**: Unix Socket + systemd 服务
- **UI 设计**: 支持 GUI/终端双模式
- **性能优化**: 模型预加载 + select() 空闲优化

---

## 常见使用场景

### 场景 1：写工作日报

**传统方式：** 键盘打字 5 分钟，写 200 字
**使用语音输入：** 说话 1 分钟 ⚡

```
操作步骤：
1. 打开文本编辑器
2. 按 Super+V 启动语音输入
3. 说话：「今天完成了用户登录模块的开发...」
4. 停顿 2 秒自动结束
5. 按 Ctrl+V 粘贴到编辑器
6. ✅ 完成！
```

### 场景 2：回复长邮件

**传统方式：** 打字 10 分钟
**使用语音输入：** 说话 3 分钟 ⚡

特别适合：
- 需要详细解释的技术邮件
- 项目进度汇报
- 客户需求沟通

### 场景 3：聊天输入长文本

**微信/QQ/Telegram 等聊天工具都能用**

```
1. 在聊天窗口点击输入框
2. 按 Super+V
3. 说出你想发送的内容
4. 停顿 2 秒，Ctrl+V 粘贴
5. 发送
```

### 场景 4：写技术文档

**边想边说，思路更流畅**

```
传统：想 → 组织语言 → 打字（思维中断）
语音：想 → 直接说出来 → 粘贴（思维连贯）

特别适合：
- API 文档说明
- 操作步骤记录
- 设计思路整理
```

---

## 总结

基于 **Whisper 完全离线识别**：

- ✅ **隐私保护** - 完全本地，数据不上传
- ✅ **快速启动** - <0.1秒启动（守护进程）
- ✅ **实时反馈** - 音量条、倒计时、图形界面
- ✅ **开箱即用** - 一键安装，5分钟配置
- ✅ **极简设计** - 只需 3 个文件

**开始使用**：
```bash
./setup.sh install              # 一键安装
# 按 Super+V 开始使用
```

---

## 📌 版本说明

**当前版本：v3.0.0** （2025-12-26）

### v3.0.0 主要变化
相比 v1.1 版本，v3.0 进行了**极简化重构**：

**精简内容**：
- ❌ 移除讯飞云在线识别方案（保留离线方案）
- ❌ 删除 bin/、docs/、config/ 等多层目录结构
- ❌ 合并 18+ 个文件为 3 个核心文件
- ✅ 项目文件减少 64%，更易维护

**保留功能**：
- ✅ Whisper 离线识别（完全本地，隐私保护）
- ✅ 守护进程模式（<0.1秒快速启动）
- ✅ 图形界面（音量条、实时反馈）
- ✅ 一键安装脚本

**新增优化**：
- 🚀 动态生成轻量级触发器（trigger.py）
- 🚀 自动依赖检查和虚拟环境切换
- 🚀 优化 UI 布局和用户体验
- 📦 单文件设计，所有功能集成到 voice_input.py

**设计理念**：
- 专注离线方案，做到极致
- 简化项目结构，降低维护成本
- 后续计划在新分支重新开发双方案版本

---

## 支持与反馈

- **项目地址**: https://github.com/MuyaoWorkshop/linux-voice-input
- **问题反馈**: https://github.com/MuyaoWorkshop/linux-voice-input/issues
- **文档更新**: 2025-12-26

---

## License

MIT License - 详见 [LICENSE](LICENSE) 文件
