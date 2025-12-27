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

# 3. 选择要安装的方案
echo -e "${YELLOW}[3/7] 选择安装方案...${NC}"
echo "1) 仅安装本地 Whisper（完全离线，隐私保护）"
echo "2) 仅安装讯飞云（在线识别，高精度）"
echo "3) 安装双方案（推荐，灵活切换）"
echo ""
read -p "请选择 [1-3，默认 3]: " CHOICE
CHOICE=${CHOICE:-3}

INSTALL_LOCAL=false
INSTALL_XFYUN=false

case $CHOICE in
    1)
        INSTALL_LOCAL=true
        echo -e "${BLUE}将安装: 本地 Whisper${NC}"
        ;;
    2)
        INSTALL_XFYUN=true
        echo -e "${BLUE}将安装: 讯飞云${NC}"
        ;;
    3)
        INSTALL_LOCAL=true
        INSTALL_XFYUN=true
        echo -e "${BLUE}将安装: 双方案${NC}"
        ;;
    *)
        echo -e "${RED}无效选择${NC}"
        exit 1
        ;;
esac
echo ""

# 4. 安装 Python 依赖
echo -e "${YELLOW}[4/7] 安装 Python 依赖...${NC}"
source venv/bin/activate

# 升级 pip
echo "升级 pip..."
pip install -q --upgrade pip

# 安装本地方案依赖
if [ "$INSTALL_LOCAL" = true ]; then
    echo "安装本地 Whisper 依赖..."
    pip install -q openai-whisper pyaudio numpy
    pip install -q opencc-python-reimplemented || echo -e "${YELLOW}  警告: OpenCC 安装失败（可选）${NC}"
fi

# 安装讯飞云依赖
if [ "$INSTALL_XFYUN" = true ]; then
    echo "安装讯飞云依赖..."
    pip install -q websocket-client pyaudio
fi

echo -e "${GREEN}✓ Python 依赖安装完成${NC}\n"

# 5. 下载模型和配置
echo -e "${YELLOW}[5/7] 配置各方案...${NC}"

# 配置本地 Whisper
if [ "$INSTALL_LOCAL" = true ]; then
    # 检查模型是否已存在
    MODEL_PATH="$HOME/.cache/whisper/base.pt"
    if [ -f "$MODEL_PATH" ]; then
        echo -e "${GREEN}✓ Whisper base 模型已存在，跳过下载${NC}"
    else
        echo "下载 Whisper base 模型（约 140MB）..."
        python3 -c "import whisper; whisper.load_model('base')" 2>&1 | grep -v "FutureWarning" || true
        echo -e "${GREEN}✓ Whisper 模型下载完成${NC}"
    fi

    # 询问是否配置守护进程
    echo ""
    read -p "是否启用守护进程模式（快速启动）？[y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
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

        echo -e "${GREEN}✓ 守护进程已启动${NC}"
    fi
fi

# 配置讯飞云
if [ "$INSTALL_XFYUN" = true ]; then
    echo ""
    echo -e "${BLUE}讯飞云配置：${NC}"
    echo "稍后可运行 ./xfyun/setup_xfyun.sh 配置 API 密钥"
fi

echo ""

# 6. 配置快捷键
echo -e "${YELLOW}[6/6] 配置快捷键（可选）...${NC}"
read -p "是否自动配置 GNOME 快捷键？[y/N] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 确定使用哪个脚本
    if [ "$INSTALL_LOCAL" = true ] && [ "$INSTALL_XFYUN" = true ]; then
        echo "检测到双方案，请选择默认快捷键："
        echo "1) 本地 Whisper (普通模式)"
        echo "2) 本地 Whisper (快速模式，需守护进程)"
        echo "3) 讯飞云"
        read -p "选择 [1-3]: " KEY_CHOICE

        case $KEY_CHOICE in
            1) WRAPPER_SCRIPT="$SCRIPT_DIR/local/voice_input_wrapper.sh" ;;
            2) WRAPPER_SCRIPT="$SCRIPT_DIR/local/voice_input_fast.sh" ;;
            3) WRAPPER_SCRIPT="$SCRIPT_DIR/xfyun/voice_input_wrapper_xfyun.sh" ;;
            *) WRAPPER_SCRIPT="$SCRIPT_DIR/local/voice_input_wrapper.sh" ;;
        esac
    elif [ "$INSTALL_LOCAL" = true ]; then
        WRAPPER_SCRIPT="$SCRIPT_DIR/local/voice_input_wrapper.sh"
    else
        WRAPPER_SCRIPT="$SCRIPT_DIR/xfyun/voice_input_wrapper_xfyun.sh"
    fi

    echo "配置快捷键为: Super+V"

    # 配置 GNOME 快捷键
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input/']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input/ name '语音输入'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input/ command "$WRAPPER_SCRIPT"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input/ binding '<Super>v'

    echo -e "${GREEN}✓ 快捷键配置完成 (Super+V)${NC}"
else
    echo "跳过快捷键配置"
fi

echo ""

# 7. 完成
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  安装完成！${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "已安装的方案："
if [ "$INSTALL_LOCAL" = true ]; then
    echo -e "  ${GREEN}✓${NC} 本地 Whisper"
    echo -e "    - 普通模式: ${BLUE}$SCRIPT_DIR/local/voice_input_wrapper.sh${NC}"
    echo -e "    - 快速模式: ${BLUE}$SCRIPT_DIR/local/voice_input_fast.sh${NC} (需守护进程)"
    echo -e "    - 模式切换: ${BLUE}$SCRIPT_DIR/local/switch_mode.sh${NC}"
fi
if [ "$INSTALL_XFYUN" = true ]; then
    echo -e "  ${GREEN}✓${NC} 讯飞云"
    echo -e "    - 使用: ${BLUE}$SCRIPT_DIR/xfyun/voice_input_wrapper_xfyun.sh${NC}"
    echo -e "    - 配置: ${BLUE}$SCRIPT_DIR/xfyun/setup_xfyun.sh${NC}"
fi

echo ""
echo -e "${BLUE}下一步操作：${NC}"

STEP=1
if [ "$INSTALL_XFYUN" = true ]; then
    echo -e "${STEP}. 配置讯飞云 API 密钥:"
    echo -e "   ${BLUE}cd xfyun && ./setup_xfyun.sh${NC}"
    echo ""
    STEP=$((STEP + 1))
fi

echo -e "${STEP}. 测试语音输入:"
if [ "$INSTALL_LOCAL" = true ]; then
    echo -e "   ${BLUE}./local/voice_input_wrapper.sh${NC}"
fi
if [ "$INSTALL_XFYUN" = true ]; then
    echo -e "   ${BLUE}./xfyun/voice_input_wrapper_xfyun.sh${NC}"
fi
echo ""
STEP=$((STEP + 1))

echo -e "${STEP}. 查看详细文档:"
echo -e "   总览: ${BLUE}README.md${NC}"
if [ "$INSTALL_LOCAL" = true ]; then
    echo -e "   本地方案: ${BLUE}local/QUICKSTART.md${NC}"
fi
if [ "$INSTALL_XFYUN" = true ]; then
    echo -e "   讯飞云: ${BLUE}xfyun/XFYUN_QUICKSTART.md${NC}"
fi

echo ""
echo -e "${YELLOW}提示: 所有脚本都使用项目目录下的 venv/ 虚拟环境${NC}"
