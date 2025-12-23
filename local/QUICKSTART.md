# 快速开始指南

5 分钟快速部署语音输入工具。

## 前提条件

- Linux 系统（已测试：Debian 12）
- 已安装 virtualenvwrapper 和 direnv
- 有可用的麦克风

## 快速安装

### 1. 安装系统依赖（1 分钟）

```bash
sudo apt update
sudo apt install -y portaudio19-dev python3-pyaudio xdotool xclip pulseaudio-utils ffmpeg
```

### 2. 创建虚拟环境（1 分钟）

```bash
# 创建虚拟环境
mkvirtualenv voice_input

# 安装 Python 包（首次会下载模型，需要 2-3 分钟）
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
pip install openai-whisper pyaudio
```

### 3. 配置项目（1 分钟）

```bash
# 进入项目目录
cd ~/bin/tools/voice_input

# 设置权限
chmod +x voice_input.py voice_input_wrapper.sh

# 配置 direnv
echo "source ~/.virtualenvs/voice_input/bin/activate" > .envrc
direnv allow
```

### 4. 配置快捷键（1 分钟）

```bash
# 使用命令行快速配置 Super+V
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
"['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice/']"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice/ \
name "Voice Input"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice/ \
command "/home/$USER/bin/tools/voice_input/voice_input_wrapper.sh"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice/ \
binding '<Super>v'
```

### 5. 测试（1 分钟）

```bash
# 命令行测试
cd ~/bin/tools/voice_input
./voice_input.py

# 说几句话，停顿 2 秒，应该显示识别结果并复制到剪贴板
```

## 使用

1. 打开任意文本编辑器
2. 按 `Super + V`
3. 对着麦克风说话
4. 停顿 2 秒自动结束
5. 按 `Ctrl + V` 粘贴

## 问题？

查看 [INSTALL.md](./INSTALL.md) 获取详细文档。

## 常用命令

```bash
# 进入项目目录（自动激活虚拟环境）
cd ~/bin/tools/voice_input

# 手动激活虚拟环境
workon voice_input

# 测试麦克风
arecord -d 5 test.wav && aplay test.wav

# 查看已安装的包
pip list | grep -E "(whisper|torch|pyaudio)"
```

---

完成！现在你可以随时使用 `Super + V` 进行语音输入了。

## 🚀 可选：启用守护进程模式（极速启动）

如果你希望启动速度从 4-5 秒提升到 <0.5 秒，可以启用守护进程模式：

### 什么是守护进程模式？

- **普通模式**（当前）：按快捷键时加载模型（4-5秒）
- **守护进程模式**：后台常驻，预加载模型（<0.5秒）✨

### 启用守护进程模式

```bash
# 1. 安装额外依赖（繁简转换）
workon voice_input
pip install opencc-python-reimplemented

# 2. 切换到守护进程模式
cd ~/bin/tools/voice_input/local
./switch_mode.sh daemon
```

### 效果对比

**普通模式**：
```
按 Super+V → 等待 4-5秒 → 开始录音
```

**守护进程模式**：
```
按 Super+V → 立即开始录音 (<0.5秒) 🚀
             + 实时音量条显示
             + 静音倒计时
```

### 资源占用

- **内存**: ~900MB 常驻
- **CPU**: ~1.6%（空闲时）
- **适合**: 频繁使用（日均 10+ 次）

### 模式切换

```bash
# 查看当前模式
./switch_mode.sh status

# 切换到守护进程模式（快速）
./switch_mode.sh daemon

# 切换到普通模式（节省内存）
./switch_mode.sh normal

# 自动切换
./switch_mode.sh toggle
```

### 了解更多

详细技术文档：[守护进程优化：从 4 秒到 0.5 秒](../docs/DAEMON_OPTIMIZATION.md)

---

## 支持与反馈

- **项目地址**: https://github.com/MuyaoWorkshop/linux-voice-input
- **问题反馈**: https://github.com/MuyaoWorkshop/linux-voice-input/issues
