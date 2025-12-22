#!/bin/bash
# 讯飞云语音输入包装脚本 - 用于快捷键调用

# 在终端中运行，显示进度
gnome-terminal --title="语音输入 (讯飞云)" --geometry=80x20 -- bash -c "
    source ~/.virtualenvs/voice_input/bin/activate
    python3 ~/bin/tools/voice_input/xfyun/voice_input_xfyun.py
    echo ''
    read -p '按回车关闭窗口...'
"
