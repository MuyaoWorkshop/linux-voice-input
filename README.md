# 语音输入工具

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.8+-green.svg)](https://www.python.org/)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)](https://www.linux.org/)

**一句话说明：** 在 Linux 上用说话代替打字，实现语音输入文本 🎤 → 📝

## ✨ 特点

- 🚀 **双方案支持**：离线 Whisper + 在线讯飞云，双快捷键随时切换
- ⚡ **极速启动**：守护进程模式，<0.5秒响应（可选）
- 📊 **实时反馈**：音量条、静音倒计时显示
- 📋 **自动粘贴**：识别完成自动复制到剪贴板
- 🎯 **开箱即用**：一键安装脚本，5分钟配置完成
- 🔒 **隐私保护**：支持完全离线的本地识别
- 🔄 **灵活切换**：本地方案支持守护进程/普通模式一键切换

## 🎬 使用演示

```
按 Super+V         → 🎤 本地识别（离线，隐私保护）
按 Super+Shift+V   → 🎤 讯飞云识别（在线，高精度）
                   ↓
                🔊 实时音量条显示
                   ↓
                ⏸️ 静音倒计时
                   ↓
                📋 自动复制到剪贴板
                   ↓
                Ctrl+V 粘贴使用
```

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

---

## 🚀 快速安装（5分钟）

### 一键安装

项目默认安装双方案（本地 Whisper + 讯飞云），配置双快捷键：

```bash
cd <项目目录>
./install.sh
```

**安装流程：**
1. ✓ 检查系统依赖（Python、xclip、portaudio 等）
2. ✓ 创建项目虚拟环境（venv/）
3. ✓ 安装双方案 Python 依赖包
4. ✓ 下载 Whisper 模型（如果未存在）
5. ✓ 选择本地方案模式：
   - **守护进程模式**（推荐）：启动快 <0.5秒，常驻内存 ~450MB
   - **普通模式**：启动慢 ~10秒，按需加载
6. ✓ 配置 GNOME 双快捷键：
   - `Super+V` → 本地 Whisper（离线）
   - `Super+Shift+V` → 讯飞云（在线）

### 方案特点

**本地 Whisper（离线）**
- ✅ 完全离线，隐私保护
- ✅ 无需 API 密钥
- ✅ 实时音量条和倒计时显示
- ⚠️ 识别速度较慢（3-5秒）
- ⚠️ 无自动标点

**讯飞云（在线）**
- ✅ 实时识别，速度快（<500ms）
- ✅ 准确率高（95%+）
- ✅ 自动添加标点
- ✅ 实时音量条显示
- ⚠️ 需要网络连接
- ⚠️ 需要配置 API 密钥（免费）

**使用建议** ⭐
- 日常使用讯飞云（快速准确，自动标点）
- 敏感内容用本地（隐私保护，完全离线）
- 双快捷键随时切换，灵活方便

---

## 📖 详细文档

### 快速开始指南

如果你是第一次使用，按照以下步骤：

1. **运行安装脚本**
   ```bash
   cd <项目目录>
   ./install.sh
   ```

2. **选择本地方案模式**
   - 守护进程模式（推荐）：启动快，常驻内存
   - 普通模式：按需加载，节省内存

3. **配置快捷键**
   - 选择 `y` 自动配置 GNOME 快捷键
   - `Super+V` → 本地方案
   - `Super+Shift+V` → 讯飞云方案

4. **配置讯飞云 API 密钥**（首次使用讯飞云时）
   - 运行：`cd xfyun && ./setup_xfyun.sh`
   - 访问：https://www.xfyun.cn/ 注册账号
   - 创建应用，开通"语音听写（流式版）"服务
   - 获取 APPID、APISecret、APIKey
   - 详细步骤见：[讯飞云方案文档](docs/XFYUN.md)

5. **测试使用**
   - 按 `Super+V` 测试本地方案
   - 按 `Super+Shift+V` 测试讯飞云方案
   - 对着麦克风说话
   - 结果自动复制到剪贴板

### 方案文档

#### 本地 Whisper 方案（离线）

📁 **完整指南**: [docs/LOCAL.md](docs/LOCAL.md)

**适合场景：**
- 完全离线环境
- 隐私敏感内容
- 作为云服务的备选方案

#### 讯飞云方案（在线）

📁 **完整指南**: [docs/XFYUN.md](docs/XFYUN.md)

**适合场景：**
- 日常办公、笔记输入
- 长文本连续输入
- 对准确率要求高
- 需要实时反馈

#### 其他文档

- **[常见问题 FAQ](docs/FAQ.md)** - 故障排查、使用技巧

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

**配置双快捷键（自动配置）：**
- `Super + V` → 本地 Whisper（离线）
- `Super + Shift + V` → 讯飞云（在线）

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

1. 按 `Super + Shift + V`
2. 对着麦克风连续说话（无时长限制）
3. 按 `Ctrl + C` 停止
4. 识别完成，自动复制
5. 按 `Ctrl + V` 粘贴

### 命令行

```bash
# 本地 Whisper
cd <项目目录>
source venv/bin/activate
./local/voice_input.py

# 讯飞云
./xfyun/voice_input_xfyun.py
```

---

## ⚡ 守护进程模式（性能优化）

### 什么是守护进程模式？

离线 Whisper 方案支持**两种运行模式**：

#### 1. 普通模式
- **启动速度**：~10 秒
- **内存占用**：0MB 常驻
- **适合场景**：偶尔使用（日均 1-2 次）
- **界面效果**：实时音量条、静音倒计时

#### 2. 守护进程模式（推荐）⭐
- **启动速度**：**<0.5 秒** 🚀
- **内存占用**：~450MB 常驻
- **适合场景**：频繁使用（日均 10+ 次）
- **界面效果**：实时音量条、静音倒计时

### 一键切换模式

```bash
# 查看当前模式
cd <项目目录>/local
./switch_mode.sh status

# 切换到守护进程模式（快速）
./switch_mode.sh daemon

# 切换到普通模式（节省内存）
./switch_mode.sh normal

# 自动切换
./switch_mode.sh toggle
```

详细说明见：[docs/LOCAL.md](docs/LOCAL.md)

---

## ⚠️ 常见问题

### 快速排查表

| 症状 | 可能原因 | 快速解决方案 |
|------|---------|------------|
| 🎤 录音失败 | 麦克风权限/驱动 | 运行 `arecord -l` 检查麦克风 |
| 🌐 讯飞连接失败 | API密钥错误/网络 | 检查 `xfyun/config.ini` 密钥 |
| 🐌 识别很慢 | CPU性能不足 | 换用 tiny 模型或使用讯飞云 |
| ❌ 无法粘贴 | xclip 未安装 | 运行 `sudo apt install xclip` |
| ⌨️ 快捷键不工作 | 脚本权限/路径 | 运行 `chmod +x <项目目录>/*/*.sh` |

详细故障排查请查看：
- [常见问题 FAQ](docs/FAQ.md)
- [本地方案文档](docs/LOCAL.md)
- [讯飞云方案文档](docs/XFYUN.md)

---

## 项目结构

```
voice-input/
├── README.md                    # 本文件（总览）
├── install.sh                   # 一键安装脚本 ⭐
├── uninstall.sh                 # 一键卸载脚本 ⭐
├── venv/                        # Python 虚拟环境
│
├── local/                       # 离线 Whisper 方案
│   ├── voice_input.py           # 主程序（普通模式）
│   ├── voice_input_wrapper.sh   # 普通模式快捷键脚本
│   ├── voice_input_fast.sh      # 守护进程模式快捷键脚本
│   ├── voice_input_daemon.py    # 守护进程服务
│   ├── voice_input_trigger.py   # 守护进程触发器
│   └── switch_mode.sh           # 模式切换脚本 ⭐
│
├── xfyun/                       # 讯飞云 API 方案
│   ├── voice_input_xfyun.py     # 主程序
│   ├── voice_input_wrapper_xfyun.sh  # 快捷键脚本
│   ├── setup_xfyun.sh           # API 配置脚本 ⭐
│   ├── config.json              # API 密钥配置
│   └── config.json.example      # 配置模板
│
└── docs/                        # 文档目录
    ├── LOCAL.md                 # 本地方案完整指南
    ├── XFYUN.md                 # 讯飞云方案完整指南
    └── FAQ.md                   # 常见问题
```

---

## 🗑️ 卸载方法

### 一键卸载

项目提供了完整的卸载脚本：

```bash
cd <项目目录>
./uninstall.sh
```

**卸载脚本会自动：**
1. ✓ 停止并删除守护进程
2. ✓ 删除双快捷键配置
3. ✓ 删除虚拟环境
4. ✓ 清理符号链接
5. ✓ 询问是否删除 Whisper 模型缓存（~140MB）
6. ✓ 询问是否删除讯飞云配置

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
- **系统**: Linux

---

## 贡献与支持

- **项目地址**: https://github.com/MuyaoWorkshop/linux-voice-input
- **问题反馈**: https://github.com/MuyaoWorkshop/linux-voice-input/issues
- **文档更新**: 2025-12-27

---

## 许可证

MIT License

---

## 快速上手

```bash
cd <项目目录>
./install.sh              # 安装
./local/switch_mode.sh    # 切换模式（可选）
./uninstall.sh            # 卸载（如需）
```
