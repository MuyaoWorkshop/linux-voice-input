#!/bin/bash
# 讯飞云语音输入包装脚本 - 用于快捷键调用

# 获取项目根目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 在终端中运行，显示进度
gnome-terminal --title="语音输入 (讯飞云)" --geometry=80x20 -- bash -c "
    source '$PROJECT_DIR/venv/bin/activate'
    python3 '$PROJECT_DIR/xfyun/voice_input_xfyun.py'
    echo ''
    read -p '按回车关闭窗口...'
"
