#!/bin/bash
# Voice Input 安装/卸载脚本
# 极简版 - 所有东西都在项目目录里，不需要安装到系统目录

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目目录（脚本所在目录）
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 打印带颜色的消息
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ========== 检测桌面环境 ==========
detect_desktop() {
    if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ] || [ "$DESKTOP_SESSION" = "gnome" ]; then
        echo "gnome"
    elif [ "$XDG_CURRENT_DESKTOP" = "KDE" ] || [ "$DESKTOP_SESSION" = "kde-plasma" ]; then
        echo "kde"
    elif [ "$XDG_CURRENT_DESKTOP" = "XFCE" ] || [ "$DESKTOP_SESSION" = "xfce" ]; then
        echo "xfce"
    else
        echo "other"
    fi
}

# ========== 检测发行版 ==========
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# ========== 安装功能 ==========
do_install() {
    print_header "Voice Input 安装程序"
    echo ""
    echo "项目目录: $PROJECT_DIR"
    echo "安装方式: 本地安装（所有文件都在项目目录）"
    echo ""

    # 确认继续
    read -p "继续安装? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "安装已取消"
        exit 0
    fi

    # 1. 检测系统环境
    print_header "检测系统环境"
    DISTRO=$(detect_distro)
    DESKTOP=$(detect_desktop)
    print_success "发行版: $DISTRO"
    print_success "桌面环境: $DESKTOP"

    # 2. 检查系统依赖
    print_header "检查系统依赖"

    missing_deps=()
    command -v python3 &> /dev/null || missing_deps+=("python3")
    command -v pip3 &> /dev/null || missing_deps+=("python3-pip")
    command -v xclip &> /dev/null || missing_deps+=("xclip")
    command -v ffmpeg &> /dev/null || missing_deps+=("ffmpeg")

    # 检查 Python venv 模块
    if ! python3 -m venv --help &> /dev/null; then
        missing_deps+=("python3-venv")
    fi

    # 检查 portaudio 开发库
    if [ ! -f /usr/include/portaudio.h ] && [ ! -f /usr/local/include/portaudio.h ]; then
        case $DISTRO in
            debian|ubuntu|linuxmint)
                missing_deps+=("portaudio19-dev" "python3-pyaudio")
                ;;
            arch|manjaro)
                missing_deps+=("portaudio" "python-pyaudio")
                ;;
            fedora)
                missing_deps+=("portaudio-devel" "python3-pyaudio")
                ;;
        esac
    fi

    # 可选依赖：python3-tk
    TK_AVAILABLE=false
    if python3 -c "import tkinter" 2>/dev/null; then
        TK_AVAILABLE=true
        print_success "Tkinter 可用 - 将使用图形界面"
    else
        print_warning "Tkinter 不可用 - 将使用终端模式"
        echo "         提示: 安装 python3-tk 可获得图形界面"
    fi

    if [ ${#missing_deps[@]} -eq 0 ]; then
        print_success "所有系统依赖已安装"
    else
        print_warning "缺少以下系统依赖: ${missing_deps[*]}"
        echo ""
        echo "请根据你的发行版运行以下命令："
        echo ""

        case $DISTRO in
            debian|ubuntu|linuxmint)
                echo "  sudo apt update"
                echo "  sudo apt install -y ${missing_deps[*]} python3-tk"
                ;;
            arch|manjaro)
                echo "  sudo pacman -Syu --noconfirm ${missing_deps[*]} tk"
                ;;
            fedora)
                echo "  sudo dnf install -y ${missing_deps[*]} python3-tkinter"
                ;;
            *)
                echo "  请手动安装: ${missing_deps[*]}"
                ;;
        esac

        echo ""
        read -p "是否现在安装? [y/N] " -n 1 -r
        echo

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "请先安装系统依赖后再运行此脚本"
            exit 1
        fi

        # 安装系统依赖
        case $DISTRO in
            debian|ubuntu|linuxmint)
                sudo apt update && sudo apt install -y "${missing_deps[@]}" python3-tk
                ;;
            arch|manjaro)
                sudo pacman -Syu --noconfirm "${missing_deps[@]}" tk
                ;;
            fedora)
                sudo dnf install -y "${missing_deps[@]}" python3-tkinter
                ;;
            *)
                print_error "不支持自动安装，请手动安装依赖"
                exit 1
                ;;
        esac

        print_success "系统依赖安装完成"
    fi

    # 3. 创建虚拟环境
    print_header "创建 Python 虚拟环境"

    if [ -d "$PROJECT_DIR/venv" ] && [ -f "$PROJECT_DIR/venv/bin/python3" ]; then
        print_warning "虚拟环境已存在"
        read -p "是否重新创建？(会删除旧环境) [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$PROJECT_DIR/venv"
            python3 -m venv "$PROJECT_DIR/venv"
            print_success "虚拟环境已重新创建"
        else
            print_info "保留现有虚拟环境"
        fi
    else
        python3 -m venv "$PROJECT_DIR/venv"
        print_success "虚拟环境创建完成"
    fi

    # 4. 安装 Python 依赖
    print_header "安装 Python 依赖包"
    print_info "这可能需要几分钟时间..."
    echo ""

    source "$PROJECT_DIR/venv/bin/activate"

    print_info "正在升级 pip..."
    pip install --upgrade pip --quiet
    echo ""

    if [ -f "$PROJECT_DIR/requirements.txt" ]; then
        print_info "正在安装依赖包（从 requirements.txt）..."
        pip install -r "$PROJECT_DIR/requirements.txt"
    else
        # 直接安装必需的包，显示每个包的安装进度
        echo "正在安装以下依赖包："
        echo "  1/4 openai-whisper (语音识别模型，约 140MB)"
        echo "  2/4 pyaudio (音频录制库)"
        echo "  3/4 numpy (数值计算库)"
        echo "  4/4 opencc-python-reimplemented (繁简转换)"
        echo ""

        print_info "[1/4] 正在安装 openai-whisper..."
        pip install openai-whisper

        print_info "[2/4] 正在安装 pyaudio..."
        pip install pyaudio

        print_info "[3/4] 正在安装 numpy..."
        pip install numpy

        print_info "[4/4] 正在安装 opencc-python-reimplemented..."
        pip install opencc-python-reimplemented
    fi
    echo ""

    print_success "Python 依赖安装完成"

    # 5. 配置守护进程服务（可选）
    print_header "配置守护进程模式（可选）"
    echo "守护进程模式可以实现 <0.5秒 快速启动"
    echo "内存占用: ~900MB 常驻"
    echo ""
    read -p "是否启用守护进程模式？ [y/N] " -n 1 -r
    echo

    DAEMON_ENABLED=false
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p "$HOME/.config/systemd/user"
        cat > "$HOME/.config/systemd/user/voice-input-daemon.service" << EOF
[Unit]
Description=Voice Input Daemon - Whisper 语音输入守护进程
After=default.target

[Service]
Type=simple
ExecStart=$PROJECT_DIR/venv/bin/python3 $PROJECT_DIR/voice_input.py --daemon
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

        # 重新加载 systemd
        systemctl --user daemon-reload

        # 启用并启动服务
        systemctl --user enable voice-input-daemon
        systemctl --user start voice-input-daemon

        # 检查状态
        sleep 1
        if systemctl --user is-active voice-input-daemon &> /dev/null; then
            print_success "守护进程已启动"
            DAEMON_ENABLED=true
        else
            print_error "守护进程启动失败"
            print_info "查看日志: journalctl --user -u voice-input-daemon -f"
        fi
    else
        print_info "已跳过守护进程配置（可以稍后手动配置）"
    fi

    # 6. 下载 Whisper 模型（可选）
    print_header "下载 Whisper 模型（可选）"
    echo "Whisper base 模型大小约 139MB"
    echo ""
    read -p "是否立即下载模型？ [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "正在下载 Whisper base 模型..."
        "$PROJECT_DIR/venv/bin/python3" -c "import whisper; whisper.load_model('base')"
        print_success "模型下载完成"
    else
        print_info "已跳过模型下载（首次使用时会自动下载）"
    fi

    # 7. 配置快捷键
    print_header "配置快捷键"

    # 确定要使用的命令
    if [ "$DAEMON_ENABLED" = true ]; then
        SHORTCUT_CMD="$PROJECT_DIR/voice_input.py --trigger"
        SHORTCUT_DESC="语音输入 (快速模式)"
    else
        SHORTCUT_CMD="$PROJECT_DIR/voice_input.py"
        SHORTCUT_DESC="语音输入"
    fi

    if [ "$DESKTOP" = "gnome" ]; then
        print_info "检测到 GNOME 桌面，自动配置 Super+V 快捷键..."

        # 获取当前的自定义快捷键列表
        current_bindings=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

        # 添加我们的快捷键路径
        new_binding="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input/"

        # 更新快捷键列表
        if [[ "$current_bindings" == "@as []" ]] || [[ "$current_bindings" == "[]" ]]; then
            # 空列表，直接设置
            gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$new_binding']"
        else
            # 已有快捷键，追加
            updated_bindings="${current_bindings%, *}, '$new_binding']"
            updated_bindings="${updated_bindings#[}"
            gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[$updated_bindings"
        fi

        # 配置快捷键详情
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$new_binding \
            name "$SHORTCUT_DESC"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$new_binding \
            command "$SHORTCUT_CMD"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$new_binding \
            binding '<Super>v'

        print_success "已自动配置 Super+V 快捷键"
    else
        print_warning "检测到非 GNOME 桌面环境"
        echo ""
        echo "请手动配置快捷键："
        echo "  名称: $SHORTCUT_DESC"
        echo "  命令: $SHORTCUT_CMD"
        echo "  快捷键: Super+V"
        echo ""
        case $DESKTOP in
            kde)
                echo "配置位置: 系统设置 → 快捷键 → 自定义快捷键"
                ;;
            xfce)
                echo "配置位置: 设置 → 键盘 → 应用程序快捷键"
                ;;
            *)
                echo "请参考你的桌面环境文档配置快捷键"
                ;;
        esac
    fi

    # 8. 安装完成
    print_header "🎉 安装完成！"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  📦 安装内容"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "1️⃣  项目文件："
    echo "   • 主程序: $PROJECT_DIR/voice_input.py"
    echo "   • 虚拟环境: $PROJECT_DIR/venv/"
    echo "   • 文档: $PROJECT_DIR/README.md"
    echo ""

    if [ "$DAEMON_ENABLED" = true ]; then
        echo "2️⃣  守护进程服务（已启动）："
        echo "   • 服务文件: ~/.config/systemd/user/voice-input-daemon.service"
        echo "   • 当前状态: ${GREEN}运行中${NC}"
        echo "   • 查看状态: systemctl --user status voice-input-daemon"
        echo "   • 查看日志: journalctl --user -u voice-input-daemon -f"
    else
        echo "2️⃣  运行模式："
        echo "   • 普通模式（4-5秒启动）"
        echo "   • 启动守护进程: systemctl --user start voice-input-daemon"
    fi
    echo ""

    echo "3️⃣  快捷键："
    if [ "$DESKTOP" = "gnome" ]; then
        echo "   • ${GREEN}已自动配置${NC} Super+V"
    else
        echo "   • ${YELLOW}需手动配置${NC} Super+V"
    fi
    echo ""

    echo "4️⃣  界面模式："
    if [ "$TK_AVAILABLE" = true ]; then
        echo "   • ${GREEN}图形界面 (Tkinter)${NC}"
    else
        echo "   • ${YELLOW}终端模式${NC}"
        echo "     提示: 安装 python3-tk 可启用图形界面"
    fi
    echo ""

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🎯 使用方法"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    if [ "$DESKTOP" = "gnome" ]; then
        echo "✅ 按 Super+V 开始使用！"
    else
        echo "⚠️  请先配置快捷键，然后按 Super+V 使用"
    fi
    echo ""
    echo "或使用命令行："
    echo "  cd $PROJECT_DIR"
    if [ "$DAEMON_ENABLED" = true ]; then
        echo "  ./voice_input.py --trigger    # 触发守护进程 (<0.5秒)"
    else
        echo "  ./voice_input.py              # 普通模式 (4-5秒)"
    fi
    echo ""
    echo "🧪 测试安装："
    echo "  $PROJECT_DIR/voice_input.py"
    echo ""
    echo "📖 查看文档："
    echo "  $PROJECT_DIR/README.md"
    echo ""
    echo "🗑️  卸载："
    echo "  $PROJECT_DIR/setup.sh uninstall"
    echo ""
}

# ========== 卸载功能 ==========
do_uninstall() {
    print_header "Voice Input 卸载程序"
    echo ""
    echo "这将删除以下内容："
    echo "  • Python 虚拟环境: $PROJECT_DIR/venv/"
    echo "  • systemd 服务"
    echo "  • 快捷键配置（GNOME）"
    echo ""
    echo "保留以下内容："
    echo "  • 项目文件: $PROJECT_DIR/"
    echo "  • Whisper 模型缓存: ~/.cache/whisper/"
    echo ""

    read -p "确定要卸载? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "卸载已取消"
        exit 0
    fi

    echo ""
    echo "开始卸载..."
    echo ""

    # 1. 停止并删除 systemd 服务
    if systemctl --user is-active voice-input-daemon &> /dev/null; then
        systemctl --user stop voice-input-daemon
        print_success "已停止守护进程"
    fi

    if systemctl --user is-enabled voice-input-daemon &> /dev/null; then
        systemctl --user disable voice-input-daemon
        print_success "已禁用守护进程自启动"
    fi

    if [ -f "$HOME/.config/systemd/user/voice-input-daemon.service" ]; then
        rm -f "$HOME/.config/systemd/user/voice-input-daemon.service"
        systemctl --user daemon-reload
        print_success "已删除 systemd 服务文件"
    fi

    # 2. 删除虚拟环境
    if [ -d "$PROJECT_DIR/venv" ]; then
        rm -rf "$PROJECT_DIR/venv"
        print_success "已删除 Python 虚拟环境"
    fi

    # 3. 删除快捷键配置（仅 GNOME）
    DESKTOP=$(detect_desktop)
    if [ "$DESKTOP" = "gnome" ]; then
        print_info "检测到 GNOME 桌面，删除快捷键配置..."

        # 删除我们的快捷键
        current_bindings=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
        new_binding="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input/"

        # 从列表中移除
        updated_bindings=$(echo "$current_bindings" | sed "s|'$new_binding'||g" | sed "s|, ,|,|g" | sed "s|\[, |\[|g" | sed "s|, \]|\]|g")

        if [[ "$updated_bindings" == "[]" ]] || [[ "$updated_bindings" == "[ ]" ]]; then
            gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[]"
        else
            gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$updated_bindings"
        fi

        print_success "已删除 GNOME 快捷键配置"
    else
        print_warning "非 GNOME 桌面，请手动删除快捷键配置"
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ✓ 卸载完成"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "如需彻底清理，请手动删除："
    echo "  • 项目目录: rm -rf $PROJECT_DIR"
    echo "  • Whisper 缓存: rm -rf ~/.cache/whisper"
    echo ""
}

# ========== 主入口 ==========
case "${1:-}" in
    install)
        do_install
        ;;
    uninstall)
        do_uninstall
        ;;
    *)
        echo "用法: $0 {install|uninstall}"
        echo ""
        echo "命令:"
        echo "  install    - 安装语音输入工具"
        echo "  uninstall  - 卸载语音输入工具"
        echo ""
        echo "示例:"
        echo "  $0 install"
        echo "  $0 uninstall"
        exit 1
        ;;
esac
