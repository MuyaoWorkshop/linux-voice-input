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

            # 生成轻量级触发器脚本（极速启动）
            print_info "正在生成触发器脚本 trigger.py..."
            cat > "$PROJECT_DIR/trigger.py" << 'TRIGGER_EOF'
#!/usr/bin/env python3
"""语音输入触发器 - 极速启动 (<0.1秒)"""
import os, sys, socket, json, time

# Tkinter
USE_TKINTER = False
try:
    import tkinter as tk
    from tkinter import ttk
    USE_TKINTER = True
except ImportError:
    pass

SOCKET_PATH = "/tmp/voice_input_daemon.sock"

# UI 配置
WINDOW_WIDTH, WINDOW_HEIGHT = 700, 280
FONT_FAMILY, FONT_SIZE_TITLE, FONT_SIZE_VOLUME, FONT_SIZE_TEXT, FONT_SIZE_TIP = "Helvetica", 16, 11, 12, 10
COLOR_BG, COLOR_BORDER, COLOR_TEXT_PRIMARY, COLOR_TEXT_SECONDARY = '#f8f8f8', '#d0d0d0', '#1d1d1f', '#86868b'
COLOR_SUCCESS, COLOR_ERROR, COLOR_PROGRESS_BG = '#34c759', '#ff3b30', '#e5e5e7'
VOLUME_BAR_LENGTH, VOLUME_BAR_THICKNESS, AUTO_CLOSE_DELAY = 420, 18, 1000

class VoiceInputUI:
    def __init__(self):
        self.mode = "gui" if USE_TKINTER else "terminal"
        if self.mode == "gui": self._init_gui()
        else: print("🎤 语音输入 (快速模式)\n" + "="*50)

    def _init_gui(self):
        self.root = tk.Tk()
        self.root.title("🎤 语音输入")
        self.root.attributes('-topmost', True)
        self.root.resizable(False, False)
        self.root.overrideredirect(True)
        self.root.configure(bg=COLOR_BORDER)
        x, y = (self.root.winfo_screenwidth()-WINDOW_WIDTH)//2, (self.root.winfo_screenheight()-WINDOW_HEIGHT)//2
        self.root.geometry(f"{WINDOW_WIDTH}x{WINDOW_HEIGHT}+{x}+{y}")
        self.root.update(); self.root.lift(); self.root.focus_force()

        style = ttk.Style(); style.theme_use('clam')
        frame = tk.Frame(self.root, bg=COLOR_BG, highlightthickness=0)
        frame.pack(fill=tk.BOTH, expand=True, padx=2, pady=2)

        self.status_label = tk.Label(frame, text="🎤 正在录音...", font=(FONT_FAMILY, FONT_SIZE_TITLE),
                                     fg=COLOR_TEXT_PRIMARY, bg=COLOR_BG, wraplength=660, justify=tk.CENTER)
        self.status_label.pack(pady=18)

        vf = tk.Frame(frame, bg=COLOR_BG); vf.pack(pady=14)
        tk.Label(vf, text="音量", font=(FONT_FAMILY, FONT_SIZE_VOLUME), fg=COLOR_TEXT_SECONDARY,
                bg=COLOR_BG, width=4).pack(side=tk.LEFT, padx=(20,10))
        self.volume_bar = ttk.Progressbar(vf, length=VOLUME_BAR_LENGTH, mode='determinate',
                                         style='Apple.Horizontal.TProgressbar')
        self.volume_bar.pack(side=tk.LEFT, padx=10)
        style.configure('Apple.Horizontal.TProgressbar', troughcolor=COLOR_PROGRESS_BG,
                       background=COLOR_SUCCESS, borderwidth=0, thickness=VOLUME_BAR_THICKNESS)
        self.volume_label = tk.Label(vf, text="0%", font=(FONT_FAMILY, FONT_SIZE_VOLUME),
                                     width=8, anchor=tk.W, fg=COLOR_SUCCESS, bg=COLOR_BG)
        self.volume_label.pack(side=tk.LEFT, padx=(10,25))

        self.text_label = tk.Label(frame, text="", font=(FONT_FAMILY, FONT_SIZE_TEXT),
                                   wraplength=660, fg=COLOR_TEXT_PRIMARY, bg=COLOR_BG, justify=tk.CENTER)
        self.text_label.pack(pady=14)

        self.tip_label = tk.Label(frame, text="按 Ctrl+C 停止录音",
                                 font=(FONT_FAMILY, FONT_SIZE_TIP), fg=COLOR_TEXT_SECONDARY, bg=COLOR_BG)
        self.tip_label.pack(pady=10)
        self.root.protocol("WM_DELETE_WINDOW", lambda: (self.root.destroy(), os._exit(0)))

    def update_volume(self, v):
        if self.mode == "gui":
            try: self.volume_bar['value'], self.volume_label['text'] = v, f"{int(v)}%"; self.root.update()
            except: pass
        else:
            bar = "▓"*int(v/100*30) + "░"*(30-int(v/100*30))
            print(f"\r音量: {bar} {int(v):3d}%", end="", flush=True)

    def show_status(self, s, c=None):
        if self.mode == "gui":
            try: self.status_label.config(text=s, fg=c or COLOR_TEXT_PRIMARY); self.root.update()
            except: pass
        else: print(f"\n{s}")

    def show_result(self, text, success=True):
        if self.mode == "gui":
            try:
                self.status_label.config(text="✅ 识别完成" if success else "❌ 识别失败",
                                        fg=COLOR_SUCCESS if success else COLOR_ERROR)
                self.text_label.config(text=text, fg=COLOR_TEXT_PRIMARY if success else COLOR_ERROR)
                self.tip_label.config(text=f"窗口将在 {AUTO_CLOSE_DELAY/1000:.0f} 秒后自动关闭...", fg=COLOR_TEXT_SECONDARY)
                self.root.update(); self.root.after(AUTO_CLOSE_DELAY, self.close)
            except: pass
        else: print(f"\n\n{'✅ 识别完成' if success else '❌ 识别失败'}\n结果: {text}")

    def close(self):
        if self.mode == "gui":
            try: self.root.quit(); self.root.destroy()
            except: pass
        else: print("\n" + "="*50)

def trigger():
    if not os.path.exists(SOCKET_PATH):
        ui = VoiceInputUI()
        msg = "守护进程未运行\n请先启动: systemctl --user start voice-input-daemon"
        print(f"❌ {msg}"); ui.show_result(msg, False); time.sleep(2); ui.close()
        return False

    try:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.connect(SOCKET_PATH); sock.sendall(b"RECORD")
        ui = VoiceInputUI()
        print("✓ 已连接到守护进程\n"); ui.show_status("🎤 正在录音...")

        buffer, recording_active = "", False
        while True:
            data = sock.recv(1024)
            if not data: break
            buffer += data.decode('utf-8')

            while '\n' in buffer:
                line, buffer = buffer.split('\n', 1)
                if not line.strip(): continue
                try:
                    d = json.loads(line)
                    msg, st = d.get('message',''), d.get('status','')

                    if st == 'recording_active' and ':' in msg:
                        v = int(msg.split(':')[1]); ui.update_volume(v)
                        bar = "█"*int(v/100*30) + "░"*(30-int(v/100*30))
                        print(f"\r🎤 [{bar}] {v}%", end="", flush=True)
                        recording_active = True
                    elif st == 'recording_silence' and ':' in msg:
                        r = msg.split(':')[1]
                        ui.show_status(f"🎤 录音中... (静音 {r}s 后结束)")
                        print(f"\r⏸️  静音检测中... 还剩 {r} 秒", end="", flush=True)
                    elif st == 'speaking':
                        if recording_active: print()
                        ui.show_status("🎤 正在录音... (检测到声音)"); print(msg); recording_active = True
                    elif st == 'recording_stopped':
                        if recording_active: print()
                        ui.show_status("✓ 录音结束"); print(msg); recording_active = False
                    elif st in ['recording','recognizing','copying']:
                        if recording_active: print(); recording_active = False
                        if st == 'recognizing': ui.show_status("⏳ 正在识别...")
                        elif st == 'copying': ui.show_status("✓ 正在复制...")
                        print(msg)
                    elif st in ['done','error']:
                        if recording_active: print()
                        print(msg)
                        ui.show_result(msg, st=='done'); time.sleep(1 if st=='done' else 2)
                        ui.close(); sock.close()
                        return st == 'done'
                    elif msg: print(msg)
                except: pass
        sock.close(); ui.close()
        return True
    except Exception as e:
        ui = VoiceInputUI()
        msg = f"错误: {e}"; print(f"❌ {msg}"); ui.show_result(msg, False); time.sleep(2); ui.close()
        return False

if __name__ == "__main__": sys.exit(0 if trigger() else 1)
TRIGGER_EOF
            chmod +x "$PROJECT_DIR/trigger.py"
            print_success "触发器脚本已生成: trigger.py (极速启动 <0.1秒)"
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
        SHORTCUT_CMD="$PROJECT_DIR/trigger.py"
        SHORTCUT_DESC="语音输入 (快速模式 <0.1秒)"
    else
        SHORTCUT_CMD="$PROJECT_DIR/voice_input.py"
        SHORTCUT_DESC="语音输入 (普通模式)"
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
        echo -e "   • 当前状态: ${GREEN}运行中${NC}"
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
        echo -e "   • ${GREEN}已自动配置${NC} Super+V"
    else
        echo -e "   • ${YELLOW}需手动配置${NC} Super+V"
    fi
    echo ""

    echo "4️⃣  界面模式："
    if [ "$TK_AVAILABLE" = true ]; then
        echo -e "   • ${GREEN}图形界面 (Tkinter)${NC}"
    else
        echo -e "   • ${YELLOW}终端模式${NC}"
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
