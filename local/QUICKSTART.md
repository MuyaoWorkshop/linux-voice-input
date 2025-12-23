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

## 支持与反馈

- **项目地址**: https://github.com/MuyaoWorkshop/linux-voice-input
- **问题反馈**: https://github.com/MuyaoWorkshop/linux-voice-input/issues
