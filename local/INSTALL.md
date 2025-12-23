# 语音输入工具 - 完整安装指南

基于 OpenAI Whisper 的离线语音转文字工具，适用于 Linux 系统（已测试：Debian 12）。

## 目录

- [系统要求](#系统要求)
- [环境准备](#环境准备)
- [安装步骤](#安装步骤)
- [配置快捷键](#配置快捷键)
- [测试验证](#测试验证)
- [故障排查](#故障排查)

---

## 系统要求

### 硬件要求
- **CPU**: 任意 x86_64 处理器
- **内存**: 最低 4GB，推荐 8GB+
- **磁盘**: ~500MB (模型 + 依赖)
- **麦克风**: 可用的音频输入设备

### 软件要求
- **系统**: Debian 12（已测试）。其他 Linux 发行版（Ubuntu/Arch/Fedora 等）理论上可用，但未经测试
- **桌面**: GNOME (本文档基于 GNOME，其他桌面环境需调整快捷键配置)
- **Python**: 3.8+
- **Shell**: bash / zsh

### 性能说明

**本方案基于 CPU 运行**（无需 GPU），测试环境：
- **机型**: ThinkPad T14, 16GB RAM
- **模型**: Whisper base
- **首次加载**: ~3 秒
- **识别 5 秒语音**: ~3-5 秒
- **CPU 占用**: 50-70%

---

## 环境准备

### 1. Python 虚拟环境管理

本方案使用 `virtualenvwrapper + direnv` 管理 Python 虚拟环境。

#### 安装 virtualenvwrapper 和 direnv

```bash
# 安装 virtualenvwrapper
sudo apt install python3-virtualenvwrapper

# 安装 direnv
sudo apt install direnv
```

#### 配置 shell 环境

编辑 `~/.bashrc` 或 `~/.zshrc`，添加：

```bash
# virtualenvwrapper 配置
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

# direnv 配置
eval "$(direnv hook bash)"  # 如果使用 zsh，改为 $(direnv hook zsh)
```

重新加载配置：

```bash
source ~/.bashrc  # 或 source ~/.zshrc
```

#### 验证安装

```bash
# 验证 virtualenvwrapper
mkvirtualenv test
workon test
deactivate
rmvirtualenv test

# 验证 direnv
direnv version
```

**关于虚拟环境的说明**：

```
【虚拟环境目录】              【项目目录】
~/.virtualenvs/voice_input/   ~/bin/tools/voice_input/
├── bin/                      ├── voice_input.py (代码)
├── lib/                      └── .envrc (关联文件)
│   └── python3.x/
│       └── site-packages/    【.envrc 内容】
│           ├── whisper/      source ~/.virtualenvs/voice_input/bin/activate
│           ├── torch/
│           └── ... (所有包)
```

- **虚拟环境**: 集中存放在 `~/.virtualenvs/`，包含 Python 解释器和所有依赖包
- **项目目录**: 存放代码和配置文件
- **.envrc**: 关联文件，进入目录时自动激活虚拟环境

### 2. 系统依赖安装

安装必要的系统库和工具：

```bash
sudo apt update
sudo apt install -y \
    portaudio19-dev \
    python3-pyaudio \
    xdotool \
    xclip \
    pulseaudio-utils \
    ffmpeg
```

**依赖说明**：
- `portaudio19-dev`: PyAudio 编译依赖
- `python3-pyaudio`: 音频录制库
- `xdotool`: 键盘模拟工具
- `xclip`: 剪贴板操作工具
- `pulseaudio-utils`: 音频系统工具
- `ffmpeg`: Whisper 依赖的音频处理库

---

## 安装步骤

### 1. 创建项目目录

```bash
mkdir -p ~/bin/tools/voice_input
cd ~/bin/tools/voice_input
```

### 2. 创建 Python 虚拟环境

```bash
# 创建名为 voice_input 的虚拟环境
mkvirtualenv voice_input

# 虚拟环境会自动激活，提示符显示 (voice_input)
```

### 3. 安装 Python 依赖

**方法一：正确安装（推荐）**

先安装 CPU 版本的 PyTorch，避免 NVIDIA 相关错误：

```bash
# 确保在 voice_input 虚拟环境中
workon voice_input

# 安装 CPU 版本的 PyTorch
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# 安装 Whisper 和 PyAudio
pip install openai-whisper pyaudio
```

**方法二：直接安装（会有 NVIDIA 警告，但不影响使用）**

```bash
workon voice_input
pip install openai-whisper pyaudio
```

> 注意：如果看到 NVIDIA 相关的错误提示，不用担心，这是正常的。我们使用 CPU 模式，不需要 GPU 支持。

### 4. 下载代码文件

将以下三个文件放到 `~/bin/tools/voice_input/` 目录：

#### 文件 1: `voice_input.py`

主程序脚本（见本仓库 `voice_input.py`）

#### 文件 2: `voice_input_wrapper.sh`

快捷键包装脚本（见本仓库 `voice_input_wrapper.sh`）

#### 文件 3: `.envrc`

direnv 配置文件：

```bash
echo "source ~/.virtualenvs/voice_input/bin/activate" > ~/bin/tools/voice_input/.envrc
```

### 5. 设置文件权限

```bash
cd ~/bin/tools/voice_input
chmod +x voice_input.py
chmod +x voice_input_wrapper.sh
```

### 6. 授权 direnv

```bash
cd ~/bin/tools/voice_input
direnv allow
```

以后每次进入该目录，direnv 会自动激活 `voice_input` 虚拟环境。

---

## 配置快捷键

### GNOME 桌面环境

#### 方法一：命令行配置（快速）

```bash
# 添加自定义快捷键
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
"['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', \
'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', \
'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice/']"

# 配置名称
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice/ \
name "Voice Input"

# 配置命令
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice/ \
command "/home/$USER/bin/tools/voice_input/voice_input_wrapper.sh"

# 配置快捷键 (Super+V)
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice/ \
binding '<Super>v'
```

#### 方法二：图形界面配置

1. 打开 **设置** → **键盘** → **查看和自定义快捷键**
2. 滚动到底部，点击 **"+"** 添加自定义快捷键
3. 填写信息：
   - **名称**: Voice Input
   - **命令**: `/home/你的用户名/bin/tools/voice_input/voice_input_wrapper.sh`
   - **快捷键**: 按 `Super + V`（Windows键 + V）
4. 点击 **添加**

#### 验证快捷键

```bash
# 查看配置
gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice/ binding

# 应该输出: '<Super>v'
```

### 其他桌面环境

- **KDE Plasma**: 系统设置 → 快捷键 → 自定义快捷键
- **XFCE**: 设置 → 键盘 → 应用程序快捷键
- **i3wm**: 编辑 `~/.config/i3/config`，添加：
  ```
  bindsym $mod+v exec ~/bin/tools/voice_input/voice_input_wrapper.sh
  ```

---

## 测试验证

### 1. 命令行测试

```bash
cd ~/bin/tools/voice_input
./voice_input.py
```

**预期输出**：
```
正在加载 Whisper 模型...
模型加载完成: base

🎤 开始录音... (说话后停顿2秒自动结束)
...........
检测到静音，停止录音
录音结束
正在识别...
识别结果: 今天天气很好

✓ 已复制到剪贴板，可使用 Ctrl+V 粘贴
```

**首次运行**会自动下载 Whisper base 模型（~150MB），需要 1-2 分钟。

### 2. 快捷键测试

1. 打开文本编辑器（gedit、VS Code 等）
2. 按 `Super + V`
3. 弹出终端窗口，对着麦克风说话
4. 停顿 2 秒后自动结束
5. 识别完成后显示"已复制到剪贴板"
6. 回到编辑器，按 `Ctrl + V` 粘贴

### 3. 麦克风测试

如果无法录音，测试麦克风：

```bash
# 查看麦克风设备
arecord -l

# 测试录音 5 秒
arecord -d 5 test.wav

# 播放录音
aplay test.wav
```

---

## 故障排查

### 问题 1: 无法录音

**错误信息**:
```
ALSA lib pcm.c:2722:(snd_pcm_open_noupdate) Unknown PCM
```

**解决方法**:
```bash
# 检查麦克风设备
arecord -l

# 检查 PulseAudio
pulseaudio --check
pulseaudio --start
```

### 问题 2: 未找到 xclip

**错误信息**:
```
❌ 错误: 未找到 xclip 命令
```

**解决方法**:
```bash
sudo apt install xclip
```

### 问题 3: PyAudio 编译失败

**错误信息**:
```
fatal error: portaudio.h: No such file or directory
```

**解决方法**:
```bash
sudo apt install portaudio19-dev python3-pyaudio
pip install pyaudio
```

### 问题 4: 识别不准确

**可能原因和解决方法**:

1. **环境噪音太大**
   - 在安静环境使用
   - 使用质量更好的麦克风

2. **说话不清晰**
   - 说话速度适中
   - 吐字清晰

3. **模型太小**
   - 编辑 `voice_input.py`，修改：
     ```python
     WHISPER_MODEL = "small"  # 或 "medium"
     ```
   - 更大的模型更准确，但更慢

### 问题 5: 识别速度太慢

**优化方法**:

1. **使用更小的模型**
   ```python
   WHISPER_MODEL = "tiny"  # 最快，准确率 ~80%
   ```

2. **减少录音时长**
   ```python
   RECORD_SECONDS = 5  # 默认 10 秒
   ```

### 问题 6: 虚拟环境未激活

**错误信息**:
```
ModuleNotFoundError: No module named 'whisper'
```

**解决方法**:
```bash
cd ~/bin/tools/voice_input
workon voice_input
./voice_input.py
```

或确保 direnv 已授权：
```bash
cd ~/bin/tools/voice_input
direnv allow
```

### 问题 7: 快捷键不工作

**检查步骤**:

1. 验证脚本可执行
   ```bash
   ls -l ~/bin/tools/voice_input/voice_input_wrapper.sh
   # 应该有 x 权限
   ```

2. 手动运行包装脚本
   ```bash
   ~/bin/tools/voice_input/voice_input_wrapper.sh
   ```

3. 检查快捷键配置
   - 打开 **设置** → **键盘** → **查看和自定义快捷键**
   - 查找 "Voice Input"
   - 确认快捷键和命令路径正确

---

## 卸载

如果需要卸载：

```bash
# 1. 删除虚拟环境
rmvirtualenv voice_input

# 2. 删除项目文件
rm -rf ~/bin/tools/voice_input

# 3. 删除快捷键（GNOME）
# 在设置 → 键盘中手动删除 "Voice Input"

# 4. 卸载系统依赖（可选）
sudo apt remove portaudio19-dev xdotool xclip
```

---

## 附录

### 目录结构

```
~/bin/tools/voice_input/
├── voice_input.py          # 主程序
├── voice_input_wrapper.sh  # 快捷键包装脚本
├── .envrc                  # direnv 配置
├── INSTALL.md              # 本安装文档
├── README.md               # 使用说明
└── (临时音频文件)          # 自动清理

~/.virtualenvs/voice_input/
├── bin/
│   └── python              # Python 解释器
└── lib/python3.x/site-packages/
    ├── whisper/            # Whisper 库
    ├── torch/              # PyTorch
    └── ...                 # 其他依赖
```

### Whisper 模型对比

| 模型    | 大小  | 内存  | 速度 (CPU) | 准确率 | 推荐场景          |
|---------|-------|-------|------------|--------|-------------------|
| tiny    | 75MB  | ~1GB  | 快 (~2s)   | ~75%   | 快速笔记          |
| base    | 150MB | ~2GB  | 中 (~4s)   | ~85%   | 日常使用（推荐）  |
| small   | 490MB | ~3GB  | 慢 (~10s)  | ~90%   | 重要文档          |
| medium  | 1.5GB | ~5GB  | 很慢 (~30s)| ~95%   | 专业场景          |
| large   | 3GB   | ~10GB | 极慢 (~60s)| ~98%   | 不推荐（CPU 太慢）|

### 性能测试数据

测试环境：ThinkPad T14 (Intel i5, 16GB RAM)

| 语音长度 | tiny   | base   | small  |
|----------|--------|--------|--------|
| 3 秒     | 1.5s   | 2.8s   | 7.2s   |
| 5 秒     | 2.1s   | 4.3s   | 10.5s  |
| 10 秒    | 3.5s   | 7.8s   | 18.2s  |

---

## 🚀 守护进程模式（性能优化）

### 概述

离线 Whisper 方案支持两种运行模式：

| 模式 | 启动方式 | 启动速度 | 内存占用 | 适用场景 |
|------|---------|---------|---------|---------|
| **普通模式** | 按需加载模型 | 4-5 秒 | 0MB 常驻 | 偶尔使用（日均 1-2 次） |
| **守护进程模式** | 后台常驻 | <0.5 秒 🚀 | ~900MB 常驻 | 频繁使用（日均 10+ 次） |

### 守护进程模式优势

1. **极速启动**：<0.5 秒响应，比普通模式快 **87.5%**
2. **实时反馈**：
   - 🎤 实时音量条显示
   - ⏸️ 静音倒计时
   - 📊 识别进度提示
3. **开机自启**：无需手动管理
4. **低 CPU 占用**：空闲时仅 ~1.6%

### 安装守护进程模式

#### 1. 安装额外依赖

```bash
workon voice_input
pip install opencc-python-reimplemented numpy
```

**依赖说明**：
- `opencc-python-reimplemented`: 繁简转换（修复 Whisper 输出繁体的问题）
- `numpy`: 音量计算优化

#### 2. 切换到守护进程模式

```bash
cd ~/bin/tools/voice_input/local
./switch_mode.sh daemon
```

输出示例：
```
=== 切换到守护进程模式 ===

1. 启动守护进程...
   ✓ 守护进程已启动
2. 更新快捷键配置...
   ✓ 快捷键已更新为守护进程模式

=== 切换完成 ===

守护进程模式特点：
  ✓ 启动速度极快 (<0.5秒)
  ✓ 实时音量条显示
  ⚠ 常驻内存 (~900MB)

现在按 Super+V 试试，应该能立即开始录音！
```

### 使用效果对比

**普通模式**：
```
按 Super+V
  ↓ (等待 4-5秒加载模型...)
🎤 开始录音...
.....
录音结束
⏳ 正在识别...
识别结果: xxx
```

**守护进程模式**：
```
按 Super+V
  ↓ (<0.5秒立即响应)
✓ 已连接到守护进程
🎤 开始录音...
✓ 检测到声音，开始记录...
🎤 [████████████░░░░░░░░░░░░░░░░░░] 60%  ← 实时音量条
⏸️  静音检测中... 还剩 2.1 秒          ← 停顿倒计时
✓ 检测到 3.0 秒静音，停止录音
⏳ 正在识别...
📋 识别结果: xxx
✓ 完成！总耗时: 8.5秒
```

### 管理守护进程

#### 查看状态

```bash
# 方法 1：使用切换脚本
./switch_mode.sh status

# 方法 2：使用 systemctl
systemctl --user status voice-input-daemon
```

输出示例：
```
=== 当前语音输入模式 ===

快捷键模式: 守护进程模式 (快速)
守护进程状态: 运行中
资源占用: CPU 1.6%, 内存 911MB
```

#### 启动/停止/重启

```bash
# 启动
systemctl --user start voice-input-daemon

# 停止
systemctl --user stop voice-input-daemon

# 重启
systemctl --user restart voice-input-daemon

# 开机自启动（切换时自动设置）
systemctl --user enable voice-input-daemon

# 禁用开机自启动
systemctl --user disable voice-input-daemon
```

#### 查看日志

```bash
# 实时查看日志
journalctl --user -u voice-input-daemon -f

# 查看最近 50 行
journalctl --user -u voice-input-daemon -n 50

# 查看今天的日志
journalctl --user -u voice-input-daemon --since today
```

### 模式切换

#### 切换到普通模式（释放内存）

```bash
./switch_mode.sh normal
```

这会：
1. 停止守护进程
2. 禁用开机自启动
3. 更新快捷键为普通模式

#### 自动切换

```bash
./switch_mode.sh toggle
```

自动判断当前模式并切换到另一个。

### 资源占用详情

**守护进程模式资源占用（空闲状态）**：

| 资源 | 占用 | 说明 |
|------|------|------|
| **内存** | ~900MB | Whisper base 模型 + Python 运行时 |
| **CPU** | ~1.6% | 使用 select() 优化，几乎可忽略 |
| **磁盘 I/O** | 0 | 模型常驻内存，无磁盘读写 |
| **网络** | 0 | 完全本地，无网络通信 |

**工作状态资源占用**：
- CPU：录音时 ~20-30%，识别时 ~150%（多核）
- 内存：峰值 ~1GB

### 技术原理

想深入了解守护进程模式的实现原理？

👉 **[守护进程优化：从 4 秒到 0.5 秒](../docs/DAEMON_OPTIMIZATION.md)**

**技术文档内容**：
- 性能瓶颈分析（模型加载耗时 3.5 秒）
- 解决方案设计（守护进程 vs 其他方案）
- 架构设计（Unix Socket 通信）
- 实现细节（Python + systemd）
- 性能优化过程（CPU 占用 10% → 1.6%）
- 适合初学者的详细讲解

### 常见问题

**Q: 守护进程模式值得吗？**

A: 如果你：
- ✅ 每天使用 10+ 次 → 每月节省 45 分钟
- ✅ 内存充足（16GB+）→ 900MB 占用可忽略
- ✅ 追求体验 → 即按即用，思路不被打断

那么**非常值得**！用 5.6% 内存换回每年 8+ 小时生命。

**Q: 会影响其他程序性能吗？**

A: 不会。空闲时 CPU 占用仅 1.6%，对其他程序几乎无影响。

**Q: 如何确认守护进程正常工作？**

A: 按 `Super+V` 后：
1. 如果立即（<0.5秒）打开终端 → 守护进程正常
2. 如果等待 4-5 秒 → 守护进程未运行，运行 `./switch_mode.sh daemon`

**Q: 崩溃了怎么办？**

A: systemd 会自动重启。如果持续崩溃，查看日志：
```bash
journalctl --user -u voice-input-daemon -n 50
```

**Q: 如何完全卸载守护进程模式？**

A:
```bash
# 切换到普通模式
./switch_mode.sh normal

# 删除守护进程文件（可选）
rm -f ~/.config/systemd/user/voice-input-daemon.service
systemctl --user daemon-reload
```

---

## 支持

- **项目地址**: https://github.com/MuyaoWorkshop/linux-voice-input
- **问题反馈**: https://github.com/MuyaoWorkshop/linux-voice-input/issues
- **文档更新**: 2025-12-23
