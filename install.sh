#!/bin/bash
# 语音输入工具安装脚本 - 支持双方案（本地 Whisper + 讯飞云）

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}========================================"
echo "  语音输入工具 - 安装程序"
echo "  支持双方案：本地 Whisper + 讯飞云"
echo "========================================${NC}\n"

# 1. 检查系统依赖
echo -e "${YELLOW}[1/7] 检查系统依赖...${NC}"

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}错误: 未找到 python3${NC}"
    echo "请先安装: sudo apt install python3 python3-venv"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo -e "${GREEN}✓ Python 版本: $PYTHON_VERSION${NC}"

# 检查其他依赖
MISSING_DEPS=()
command -v xclip &> /dev/null || MISSING_DEPS+=("xclip")
dpkg -l | grep -q portaudio19-dev || MISSING_DEPS+=("portaudio19-dev")

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo -e "${YELLOW}缺少系统依赖: ${MISSING_DEPS[*]}${NC}"
    echo "安装命令: sudo apt install ${MISSING_DEPS[*]}"
    read -p "是否继续安装（可能导致录音或剪贴板功能异常）？[y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""

# 2. 创建虚拟环境
echo -e "${YELLOW}[2/7] 创建虚拟环境...${NC}"
if [ -d "venv" ]; then
    echo -e "${YELLOW}虚拟环境已存在${NC}"
    read -p "是否重新创建？[y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf venv
        python3 -m venv venv
        echo -e "${GREEN}✓ 虚拟环境重新创建完成${NC}"
    else
        echo "使用现有虚拟环境"
    fi
else
    python3 -m venv venv
    echo -e "${GREEN}✓ 虚拟环境创建成功${NC}"
fi
echo ""

# 3. 安装双方案
echo -e "${YELLOW}[3/6] 安装方案...${NC}"
echo -e "${BLUE}将安装双方案（本地 Whisper + 讯飞云）${NC}"
echo "  - 本地方案: 完全离线，隐私保护"
echo "  - 讯飞云: 在线识别，高精度"
echo ""

# 4. 安装 Python 依赖
echo -e "${YELLOW}[4/6] 安装 Python 依赖...${NC}"
source venv/bin/activate

# 升级 pip
echo "升级 pip..."
pip install -q --upgrade pip

# 安装双方案依赖
echo "安装本地 Whisper 依赖..."
pip install -q openai-whisper pyaudio numpy
pip install -q opencc-python-reimplemented || echo -e "${YELLOW}  警告: OpenCC 安装失败（可选）${NC}"

echo "安装讯飞云依赖..."
pip install -q websocket-client

echo -e "${GREEN}✓ Python 依赖安装完成${NC}\n"

# 5. 下载模型和配置
echo -e "${YELLOW}[5/6] 下载模型和配置...${NC}"

# 检查模型是否已存在
MODEL_PATH="$HOME/.cache/whisper/base.pt"
if [ -f "$MODEL_PATH" ]; then
    echo -e "${GREEN}✓ Whisper base 模型已存在，跳过下载${NC}"
else
    echo "下载 Whisper base 模型（约 140MB）..."
    python3 -c "import whisper; whisper.load_model('base')" 2>&1 | grep -v "FutureWarning" || true
    echo -e "${GREEN}✓ Whisper 模型下载完成${NC}"
fi

# 选择本地方案模式
echo ""
echo "本地方案模式选择："
echo "1) 守护进程模式（启动快 <0.5秒，常驻内存 ~450MB）"
echo "2) 普通模式（启动慢 ~10秒，按需加载）"
read -p "请选择 [1-2，默认 1]: " MODE_CHOICE
MODE_CHOICE=${MODE_CHOICE:-1}

DAEMON_ENABLED=false
if [ "$MODE_CHOICE" = "1" ]; then
    DAEMON_ENABLED=true
    SERVICE_FILE="$HOME/.config/systemd/user/voice-input-daemon.service"
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

    systemctl --user daemon-reload
    systemctl --user enable voice-input-daemon
    systemctl --user start voice-input-daemon

    echo -e "${GREEN}✓ 守护进程模式已启用${NC}"
else
    # 如果守护进程存在，停止它
    if systemctl --user is-active --quiet voice-input-daemon 2>/dev/null; then
        systemctl --user stop voice-input-daemon
        systemctl --user disable voice-input-daemon
        echo -e "${GREEN}✓ 守护进程已停止${NC}"
    fi
    echo -e "${GREEN}✓ 普通模式已启用${NC}"
fi

# 讯飞云配置提示
echo ""
echo -e "${BLUE}讯飞云配置：${NC}"
echo "稍后可运行 ./xfyun/setup_xfyun.sh 配置 API 密钥"

echo ""

# 6. 配置快捷键
echo -e "${YELLOW}[6/6] 配置快捷键（可选）...${NC}"
read -p "是否自动配置 GNOME 快捷键？[y/N] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 确定本地方案使用哪个脚本
    if [ "$DAEMON_ENABLED" = true ]; then
        LOCAL_SCRIPT="$SCRIPT_DIR/local/voice_input_fast.sh"
    else
        LOCAL_SCRIPT="$SCRIPT_DIR/local/voice_input_wrapper.sh"
    fi
    XFYUN_SCRIPT="$SCRIPT_DIR/xfyun/voice_input_wrapper_xfyun.sh"

    echo "配置双方案快捷键："
    echo "  Super+V       → 本地 Whisper"
    echo "  Super+Shift+V → 讯飞云"

    # 获取当前快捷键列表
    CURRENT=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

    # 添加 voice-input-local
    if ! echo "$CURRENT" | grep -q "voice-input-local"; then
        if [[ "$CURRENT" == "@as []" ]]; then
            NEW_LIST="['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-local/']"
        else
            TEMP="${CURRENT%]}"
            NEW_LIST="${TEMP}, '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-local/']"
        fi
        CURRENT="$NEW_LIST"
    fi

    # 添加 voice-input-xfyun
    if ! echo "$CURRENT" | grep -q "voice-input-xfyun"; then
        TEMP="${CURRENT%]}"
        NEW_LIST="${TEMP}, '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-xfyun/']"
        CURRENT="$NEW_LIST"
    fi

    # 设置快捷键列表
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$CURRENT"

    # 配置本地方案快捷键
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-local/ name '语音输入(本地)'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-local/ command "$LOCAL_SCRIPT"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-local/ binding '<Super>v'

    # 配置讯飞云快捷键
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-xfyun/ name '语音输入(讯飞云)'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-xfyun/ command "$XFYUN_SCRIPT"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-xfyun/ binding '<Shift><Super>v'

    echo -e "${GREEN}✓ 快捷键配置完成${NC}"
else
    echo "跳过快捷键配置"
fi

echo ""

# 7. 完成
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  安装完成！${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "已安装方案：双方案（本地 Whisper + 讯飞云）"
echo ""

echo -e "${GREEN}本地 Whisper:${NC}"
if [ "$DAEMON_ENABLED" = true ]; then
    echo -e "  - 模式: ${BLUE}守护进程（快速启动）${NC}"
    echo -e "  - 快捷键: ${BLUE}Super+V${NC}"
    echo -e "  - 守护进程管理: ${BLUE}systemctl --user status/stop/start voice-input-daemon${NC}"
else
    echo -e "  - 模式: ${BLUE}普通模式${NC}"
    echo -e "  - 快捷键: ${BLUE}Super+V${NC}"
fi
echo -e "  - 模式切换: ${BLUE}./local/switch_mode.sh${NC}"
echo ""

echo -e "${GREEN}讯飞云:${NC}"
echo -e "  - 快捷键: ${BLUE}Super+Shift+V${NC}"
echo -e "  - API配置: ${BLUE}./xfyun/setup_xfyun.sh${NC}"
echo ""

echo -e "${BLUE}下一步操作：${NC}"
echo ""
echo "1. 配置讯飞云 API 密钥（首次使用讯飞云时）:"
echo -e "   ${BLUE}cd xfyun && ./setup_xfyun.sh${NC}"
echo ""
echo "2. 测试语音输入:"
echo -e "   本地: 按 ${BLUE}Super+V${NC}"
echo -e "   讯飞云: 按 ${BLUE}Super+Shift+V${NC}"
echo ""
echo "3. 切换本地方案模式:"
echo -e "   ${BLUE}./local/switch_mode.sh${NC}"
echo ""
echo "4. 查看详细文档:"
echo -e "   总览: ${BLUE}README.md${NC}"
echo -e "   本地方案: ${BLUE}docs/LOCAL.md${NC}"
echo -e "   讯飞云方案: ${BLUE}docs/XFYUN.md${NC}"
echo -e "   常见问题: ${BLUE}docs/FAQ.md${NC}"
echo ""
echo "5. 卸载:"
echo -e "   ${BLUE}./uninstall.sh${NC}"

echo ""
echo -e "${YELLOW}提示: 所有脚本都使用项目目录下的 venv/ 虚拟环境${NC}"
