#!/bin/bash
# 离线 Whisper 语音输入包装脚本 - 用于快捷键调用

# 在终端中运行，显示进度
gnome-terminal --title="语音输入 (离线)" --geometry=80x20 -- bash -c "
    source ~/.virtualenvs/voice_input/bin/activate
    python3 ~/bin/tools/voice_input/local/voice_input.py
    echo ''
    read -p '按回车关闭窗口...'
"
