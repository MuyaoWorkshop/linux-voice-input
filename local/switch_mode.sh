#!/bin/bash
# 语音输入模式切换脚本
# 在守护进程模式（快速）和普通模式（按需加载）之间切换

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 快捷键路径
KEYBINDING_PATH="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-local/"

# 脚本路径
DAEMON_SCRIPT="$SCRIPT_DIR/local/voice_input_fast.sh"
NORMAL_SCRIPT="$SCRIPT_DIR/local/voice_input_wrapper.sh"

# 检测当前模式
check_current_mode() {
    local current_command=$(gsettings get $KEYBINDING_PATH command 2>/dev/null | tr -d "'")
    local daemon_running=$(systemctl --user is-active voice-input-daemon 2>/dev/null || echo "inactive")

    echo -e "${BLUE}=== 当前语音输入模式 ===${NC}\n"

    if [[ "$current_command" == *"voice_input_fast.sh"* ]]; then
        echo -e "快捷键模式: ${GREEN}守护进程模式 (快速)${NC}"
    else
        echo -e "快捷键模式: ${YELLOW}普通模式 (按需加载)${NC}"
    fi

    if [[ "$daemon_running" == "active" ]]; then
        echo -e "守护进程状态: ${GREEN}运行中${NC}"

        # 显示资源占用
        local pid=$(pgrep -f voice_input_daemon.py | head -1)
        if [[ -n "$pid" ]]; then
            local cpu=$(ps -p $pid -o %cpu --no-headers | xargs)
            local mem=$(ps -p $pid -o rss --no-headers | xargs)
            local mem_mb=$((mem / 1024))
            echo -e "资源占用: CPU ${cpu}%, 内存 ${mem_mb}MB"
        fi
    else
        echo -e "守护进程状态: ${YELLOW}未运行${NC}"
    fi

    echo ""
}

# 切换到守护进程模式
switch_to_daemon() {
    echo -e "${BLUE}=== 切换到守护进程模式 ===${NC}\n"

    # 1. 检查并创建 systemd service 文件
    SERVICE_FILE="$HOME/.config/systemd/user/voice-input-daemon.service"
    if [ ! -f "$SERVICE_FILE" ]; then
        echo "1. 创建 systemd service 文件..."
        mkdir -p "$HOME/.config/systemd/user"

        cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Voice Input Daemon (Whisper)
After=default.target

[Service]
Type=simple
ExecStart=$SCRIPT_DIR/venv/bin/python3 $SCRIPT_DIR/local/voice_input_daemon.py
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF
        echo -e "   ${GREEN}✓${NC} Service 文件已创建"
        systemctl --user daemon-reload
    fi

    # 2. 启动守护进程
    echo "2. 启动守护进程..."
    systemctl --user start voice-input-daemon
    systemctl --user enable voice-input-daemon
    sleep 2

    # 检查是否启动成功
    if systemctl --user is-active voice-input-daemon &>/dev/null; then
        echo -e "   ${GREEN}✓${NC} 守护进程已启动"
    else
        echo -e "   ${RED}✗${NC} 守护进程启动失败"
        echo "   请查看日志: journalctl --user -u voice-input-daemon -n 20"
        exit 1
    fi

    # 3. 更新快捷键
    echo "3. 更新快捷键配置..."
    gsettings set $KEYBINDING_PATH command "$DAEMON_SCRIPT"
    echo -e "   ${GREEN}✓${NC} 快捷键已更新为守护进程模式"

    echo ""
    echo -e "${GREEN}=== 切换完成 ===${NC}"
    echo ""
    echo "守护进程模式特点："
    echo "  ✓ 启动速度极快 (<0.5秒)"
    echo "  ✓ 实时音量条显示"
    echo "  ⚠ 常驻内存 (~900MB)"
    echo ""
    echo "现在按 Super+V 试试，应该能立即开始录音！"
}

# 切换到普通模式
switch_to_normal() {
    echo -e "${BLUE}=== 切换到普通模式 ===${NC}\n"

    # 1. 停止守护进程
    echo "1. 停止守护进程..."
    systemctl --user stop voice-input-daemon
    systemctl --user disable voice-input-daemon
    echo -e "   ${GREEN}✓${NC} 守护进程已停止"

    # 2. 更新快捷键
    echo "2. 更新快捷键配置..."
    gsettings set $KEYBINDING_PATH command "$NORMAL_SCRIPT"
    echo -e "   ${GREEN}✓${NC} 快捷键已更新为普通模式"

    echo ""
    echo -e "${GREEN}=== 切换完成 ===${NC}"
    echo ""
    echo "普通模式特点："
    echo "  ✓ 不占用常驻内存"
    echo "  ⚠ 启动速度较慢 (4-5秒)"
    echo ""
    echo "现在按 Super+V 试试，会等待几秒加载模型。"
}

# 显示帮助信息
show_help() {
    echo "语音输入模式切换工具"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  status    查看当前模式"
    echo "  daemon    切换到守护进程模式（快速，常驻内存）"
    echo "  normal    切换到普通模式（按需加载，不占内存）"
    echo "  toggle    自动切换（守护进程 ↔ 普通）"
    echo "  help      显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 status    # 查看当前使用哪种模式"
    echo "  $0 daemon    # 切换到守护进程模式"
    echo "  $0 normal    # 切换到普通模式"
    echo "  $0 toggle    # 自动切换模式"
}

# 自动切换模式
toggle_mode() {
    local current_command=$(gsettings get $KEYBINDING_PATH command 2>/dev/null | tr -d "'")

    if [[ "$current_command" == *"voice_input_fast.sh"* ]]; then
        # 当前是守护进程模式，切换到普通模式
        switch_to_normal
    else
        # 当前是普通模式，切换到守护进程模式
        switch_to_daemon
    fi
}

# 主函数
main() {
    case "${1:-}" in
        status)
            check_current_mode
            ;;
        daemon)
            switch_to_daemon
            ;;
        normal)
            switch_to_normal
            ;;
        toggle)
            toggle_mode
            ;;
        help|--help|-h)
            show_help
            ;;
        "")
            # 无参数时显示当前状态和菜单
            check_current_mode
            echo "请选择操作："
            echo "  1) 切换到守护进程模式（快速）"
            echo "  2) 切换到普通模式（按需加载）"
            echo "  3) 退出"
            echo ""
            read -p "请输入选择 [1-3]: " choice

            case $choice in
                1)
                    echo ""
                    switch_to_daemon
                    ;;
                2)
                    echo ""
                    switch_to_normal
                    ;;
                3)
                    echo "退出"
                    exit 0
                    ;;
                *)
                    echo -e "${RED}无效选择${NC}"
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo -e "${RED}错误: 未知选项 '$1'${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"
