#!/bin/bash
# 快速语音输入触发脚本 - 调用守护进程（无需等待模型加载）
# 使用守护进程模式，启动速度 < 0.5秒

# 获取项目根目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 在终端中运行触发器
gnome-terminal --title="语音输入 (快速)" --geometry=80x20 -- bash -c "
    source '$PROJECT_DIR/venv/bin/activate'
    python3 '$PROJECT_DIR/local/voice_input_trigger.py'
    echo ''
    read -p '按回车关闭窗口...'
"
