#!/bin/bash
# 离线 Whisper 语音输入包装脚本 - 用于快捷键调用

# 获取项目根目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 在终端中运行，显示进度
gnome-terminal --title="语音输入 (离线)" --geometry=80x20 -- bash -c "
    source '$PROJECT_DIR/venv/bin/activate'
    python3 '$PROJECT_DIR/local/voice_input.py'
    echo ''
    read -p '按回车关闭窗口...'
"
