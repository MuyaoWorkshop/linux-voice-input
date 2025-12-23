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

## 支持

- **项目地址**: https://github.com/MuyaoWorkshop/linux-voice-input
- **问题反馈**: https://github.com/MuyaoWorkshop/linux-voice-input/issues
- **文档更新**: 2025-12-22
