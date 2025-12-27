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
- 🔄 **一键切换**：双模式灵活选择，守护进程模式可选

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
- **磁盘空间**：1GB（Whisper 模型 + 依赖）
- **内存**：4GB RAM
- **麦克风**：任何 USB 或内置麦克风

### 推荐配置
- **内存**：8GB RAM
- **CPU**：4 核心以上（离线识别更快）
- **网络**：稳定网络连接（使用讯飞云方案时）

### 已测试环境
- ✅ Debian 12 + GNOME

其他 Linux 发行版（Ubuntu/Arch/Fedora 等）理论上也可用，但未经测试。

---

## 🚀 快速安装（5分钟）

### 一键安装

项目提供了统一的安装脚本，自动完成所有配置：

```bash
cd ~/bin/tools/voice_input
./install.sh
```

**安装脚本会自动完成：**
1. ✓ 检查系统依赖（Python、xclip、portaudio 等）
2. ✓ 创建项目虚拟环境（venv/）
3. ✓ 安装 Python 依赖包
4. ✓ 下载 Whisper 模型（如果未存在）
5. ✓ 可选：配置守护进程服务
6. ✓ 可选：配置 GNOME 快捷键

### 安装选项

**选项 1：仅安装本地 Whisper（离线方案）**
- ✅ 完全离线，隐私保护
- ✅ 无需 API 密钥
- ⚠️ 识别速度较慢（3-5秒）
- ⚠️ 无自动标点

**选项 2：仅安装讯飞云（在线方案）**
- ✅ 实时识别，速度快（<500ms）
- ✅ 准确率高（95%+）
- ✅ 自动添加标点
- ⚠️ 需要网络连接
- ⚠️ 需要注册讯飞账号（免费）

**选项 3：安装双方案（推荐）** ⭐
- ✅ 灵活切换，兼顾效率和隐私
- ✅ 日常使用讯飞云（快速准确）
- ✅ 敏感内容用本地（隐私保护）
- ✅ 配置双快捷键，随时切换

---

## 📖 详细文档

### 快速开始指南

如果你是第一次使用，按照以下步骤：

1. **运行安装脚本**
   ```bash
   cd ~/bin/tools/voice_input
   ./install.sh
   ```

2. **选择安装方案**
   - 推荐选择 `3) 安装双方案`
   - 如果选择讯飞云，需要准备 API 密钥

3. **获取讯飞 API 密钥**（如果选择讯飞云）
   - 访问：https://www.xfyun.cn/ 注册账号
   - 创建应用，开通"语音听写（流式版）"服务
   - 获取 APPID、APISecret、APIKey
   - 详细步骤见：[讯飞云方案文档](docs/XFYUN.md)

4. **测试使用**
   - 按 `Super + V` 测试
   - 对着麦克风说话
   - 结果自动复制到剪贴板

### 方案文档

#### 本地 Whisper 方案（离线）

📁 **完整指南**: [docs/LOCAL.md](docs/LOCAL.md)

**适合场景：**
- 完全离线环境
- 隐私敏感内容
- 作为云服务的备选方案

**主要内容：**
- 详细安装步骤
- 守护进程模式配置
- 性能优化技巧
- 故障排查

#### 讯飞云方案（在线）

📁 **完整指南**: [docs/XFYUN.md](docs/XFYUN.md)

**适合场景：**
- 日常办公、笔记输入
- 长文本连续输入
- 对准确率要求高
- 需要实时反馈

**主要内容：**
- 注册与配置步骤
- API 密钥获取
- 详细使用说明
- 费用说明

#### 其他文档

- **[常见问题 FAQ](docs/FAQ.md)** - 故障排查、使用技巧
- **[守护进程优化](docs/DAEMON_OPTIMIZATION.md)** - 技术深度解析

---

## 方案对比

### 📦 功能对比

| 特性 | 离线 Whisper | 讯飞云 API |
|------|-------------|------------|
| **识别速度** | ⭐⭐ 延迟 3-5秒 | ⭐⭐⭐⭐⭐ 实时 <500ms |
| **启动速度** | ⭐⭐⭐⭐⭐ <0.5秒（守护进程）<br>⭐⭐ 4-5秒（普通模式） | ⭐⭐⭐⭐⭐ 实时 |
| **准确率** | ⭐⭐⭐⭐ 85% | ⭐⭐⭐⭐⭐ 95%+ |
| **时长限制** | ⭐⭐⭐ 60秒 | ⭐⭐⭐⭐⭐ 无限制 |
| **标点符号** | ❌ 无 | ✅ 自动添加 |
| **网络需求** | ✅ 完全离线 | ⚠️ 需要联网 |
| **隐私性** | ⭐⭐⭐⭐⭐ 本地处理 | ⭐⭐ 数据上传 |
| **费用** | ✅ 完全免费 | ⭐⭐⭐⭐ 基本免费 |

### 🎯 使用建议

**推荐：混合使用（双方案）**
- **日常使用** → 讯飞云（90%场景）- 快速、准确、长文本
- **隐私保护** → 离线 Whisper（10%场景）- 敏感内容、离线环境

**配置双快捷键：**
- `Super + V` → 本地 Whisper
- `Super + Shift + V` → 讯飞云（需手动配置）

---

## 使用方法

### 快捷键（推荐）

#### 本地 Whisper（离线）

1. 按 `Super + V`
2. 对着麦克风说话（60秒内）
3. 停顿 2 秒自动结束
4. 识别完成，自动复制
5. 按 `Ctrl + V` 粘贴

#### 讯飞云（在线）

1. 按 `Super + Shift + V`（如已配置双快捷键）
2. 对着麦克风连续说话（无时长限制）
3. 按 `Ctrl + C` 停止
4. 识别完成，自动复制
5. 按 `Ctrl + V` 粘贴

### 命令行

```bash
# 本地 Whisper
cd ~/bin/tools/voice_input
source venv/bin/activate
./local/voice_input.py

# 讯飞云
./xfyun/voice_input_xfyun.py
```

---

## ⚡ 守护进程模式（性能优化）

### 什么是守护进程模式？

离线 Whisper 方案支持**两种运行模式**：

#### 1. 普通模式（默认）
- **启动速度**：4-5 秒
- **内存占用**：0MB 常驻
- **适合场景**：偶尔使用（日均 1-2 次）

#### 2. 守护进程模式（推荐）⭐
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

# 自动切换
./switch_mode.sh toggle
```

详细说明见：[docs/LOCAL.md](docs/LOCAL.md) 或 [守护进程技术文档](docs/DAEMON_OPTIMIZATION.md)

---

## 📖 实际使用示例

### 场景1：写工作日报

**传统方式：** 键盘打字 5 分钟，写 200 字
**使用语音输入：** 说话 1 分钟 ⚡

```
操作步骤：
1. 打开文本编辑器
2. 按 Super+V 启动语音输入
3. 说话："今天完成了用户登录模块的开发，修复了三个bug..."
4. 停顿2秒或按Ctrl+C停止
5. 按 Ctrl+V 粘贴到编辑器
6. ✅ 完成！
```

### 场景2：回复长邮件

**传统方式：** 打字 10 分钟
**使用语音输入：** 说话 3 分钟 ⚡

### 场景3：聊天输入长文本

**微信/QQ/Telegram 等聊天工具都能用**

```
1. 在聊天窗口点击输入框
2. 按 Super+V
3. 说出你想发送的内容
4. 停止后自动复制
5. Ctrl+V 粘贴并发送
```

---

## ⚠️ 常见问题

### 快速排查表

| 症状 | 可能原因 | 快速解决方案 |
|------|---------|------------|
| 🎤 录音失败 | 麦克风权限/驱动 | 运行 `arecord -l` 检查麦克风 |
| 🌐 讯飞连接失败 | API密钥错误/网络 | 检查 `xfyun/config.ini` 密钥 |
| 🐌 识别很慢 | CPU性能不足 | 换用 tiny 模型或使用讯飞云 |
| ❌ 无法粘贴 | xclip 未安装 | 运行 `sudo apt install xclip` |
| ⌨️ 快捷键不工作 | 脚本权限/路径 | 运行 `chmod +x ~/bin/tools/voice_input/*/*.sh` |

详细故障排查请查看：
- [常见问题 FAQ](docs/FAQ.md)
- [本地方案文档](docs/LOCAL.md)
- [讯飞云方案文档](docs/XFYUN.md)

---

## 项目结构

```
~/bin/tools/voice_input/
├── README.md                    # 本文件（总览）
├── install.sh                   # 统一安装脚本 ⭐
├── venv/                        # Python 虚拟环境
│
├── local/                       # 离线 Whisper 方案
│   ├── voice_input.py           # 主程序
│   ├── voice_input_wrapper.sh   # 快捷键脚本
│   ├── voice_input_fast.sh      # 守护进程快捷键
│   ├── voice_input_daemon.py    # 守护进程服务
│   ├── voice_input_trigger.py   # 守护进程触发器
│   └── switch_mode.sh           # 模式切换脚本
│
├── xfyun/                       # 讯飞云 API 方案
│   ├── voice_input_xfyun.py     # 主程序
│   ├── voice_input_wrapper_xfyun.sh  # 快捷键脚本
│   ├── setup_xfyun.sh           # 配置脚本
│   ├── config.ini               # API 密钥配置
│   └── config.ini.example       # 配置模板
│
└── docs/                        # 文档目录
    ├── LOCAL.md                 # 本地方案完整指南
    ├── XFYUN.md                 # 讯飞云方案完整指南
    ├── FAQ.md                   # 常见问题
    └── DAEMON_OPTIMIZATION.md   # 守护进程技术文档
```

---

## 🗑️ 卸载方法

### 完全卸载

```bash
# 1. 停止守护进程（如果启用）
systemctl --user stop voice-input-daemon
systemctl --user disable voice-input-daemon

# 2. 删除项目文件
rm -rf ~/bin/tools/voice_input

# 3. 删除快捷键
# 设置 → 键盘 → 查看和自定义快捷键 → 删除"语音输入"相关项

# 4. （可选）卸载系统依赖
sudo apt remove xclip portaudio19-dev
```

### 只卸载某个方案

```bash
cd ~/bin/tools/voice_input

# 只删除讯飞云方案
rm -rf xfyun/

# 只删除离线方案
rm -rf local/
systemctl --user stop voice-input-daemon
systemctl --user disable voice-input-daemon
```

---

## 技术栈

### 离线方案
- **语音识别**: [OpenAI Whisper](https://github.com/openai/whisper)
- **深度学习**: PyTorch (CPU mode)
- **音频录制**: PyAudio
- **系统集成**: xclip, gnome-terminal

### 讯飞云方案
- **语音识别**: [讯飞开放平台](https://www.xfyun.cn/)
- **通信协议**: WebSocket
- **音频录制**: PyAudio
- **系统集成**: xclip, gnome-terminal

### 共同依赖
- **Python 环境**: venv (项目虚拟环境)
- **桌面环境**: GNOME (其他桌面需调整快捷键配置)
- **系统**: Linux (Debian 12 已测试)

---

## 贡献与支持

- **项目地址**: https://github.com/MuyaoWorkshop/linux-voice-input
- **问题反馈**: https://github.com/MuyaoWorkshop/linux-voice-input/issues
- **文档更新**: 2025-12-27

---

## 许可证

MIT License

---

## 总结

这个项目提供了**灵活的混合方案**：

1. **离线 Whisper** - 隐私保护，完全本地
2. **讯飞云 API** - 实时准确，体验最佳

**推荐配置：**
- 使用 `./install.sh` 安装双方案
- 配置双快捷键，根据场景灵活切换
- 日常使用讯飞云（快速准确）
- 敏感内容用本地（隐私保护）

**立即开始：**
```bash
cd ~/bin/tools/voice_input
./install.sh
```
