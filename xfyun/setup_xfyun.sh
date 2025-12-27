#!/bin/bash
# 讯飞语音识别快速配置脚本

set -e

echo "========================================="
echo "  讯飞语音识别 - 快速配置脚本"
echo "========================================="
echo ""

# 获取项目根目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 检查虚拟环境
if [ -z "$VIRTUAL_ENV" ] && [ ! -d "$PROJECT_DIR/venv" ]; then
    echo "❌ 错误: 虚拟环境不存在"
    echo "请先运行项目根目录的 install.sh 创建虚拟环境"
    exit 1
fi

# 激活虚拟环境
if [ -z "$VIRTUAL_ENV" ]; then
    echo "激活虚拟环境..."
    source "$PROJECT_DIR/venv/bin/activate"
fi

# 安装依赖
echo "1. 安装 Python 依赖包..."
pip install websocket-client -q

# 创建配置文件
echo ""
echo "2. 配置 API 密钥..."
echo ""

CONFIG_FILE="$HOME/bin/tools/voice_input/xfyun/config.ini"

if [ -f "$CONFIG_FILE" ]; then
    echo "⚠️  配置文件已存在: $CONFIG_FILE"
    read -p "是否覆盖? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "跳过配置文件创建"
        CONFIG_FILE=""
    fi
fi

if [ -n "$CONFIG_FILE" ]; then
    echo "请输入讯飞 API 密钥（从 https://console.xfyun.cn/ 获取）："
    echo ""

    read -p "APPID: " APPID
    read -p "APISecret: " APISecret
    read -p "APIKey: " APIKey

    # 创建配置文件
    cat > "$CONFIG_FILE" << EOF
[xfyun]
# 讯飞语音识别 API 配置
# 从 https://console.xfyun.cn/ 获取

APPID = $APPID
APISecret = $APISecret
APIKey = $APIKey
EOF

    # 设置权限
    chmod 600 "$CONFIG_FILE"
    echo ""
    echo "✓ 配置文件已创建: $CONFIG_FILE"
fi

# 添加到 .gitignore
echo ""
echo "3. 配置 Git 忽略..."
GITIGNORE="$HOME/bin/tools/voice_input/.gitignore"
if [ ! -f "$GITIGNORE" ] || ! grep -q "config.ini" "$GITIGNORE"; then
    echo "config.ini" >> "$GITIGNORE"
    echo "✓ 已添加 config.ini 到 .gitignore"
else
    echo "✓ config.ini 已在 .gitignore 中"
fi

# 配置快捷键
echo ""
echo "4. 配置 GNOME 快捷键..."
echo ""
echo "选择配置方式："
echo "  1) 双快捷键模式（推荐）"
echo "     - Super+V: 离线 Whisper"
echo "     - Super+Shift+V: 讯飞云"
echo "  2) 单快捷键模式"
echo "     - Super+V: 讯飞云（替换原有）"
echo "  3) 跳过"
echo ""
read -p "请选择 (1/2/3): " -n 1 -r
echo ""

case $REPLY in
    1)
        echo "配置双快捷键..."

        # 获取现有快捷键列表
        CURRENT=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

        # 添加新的快捷键
        if [[ "$CURRENT" == "@as []" ]]; then
            NEW_LIST="['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice-cloud/']"
        else
            # 移除最后的 ]
            TEMP="${CURRENT%]}"
            NEW_LIST="${TEMP}, '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice-cloud/']"
        fi

        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$NEW_LIST"

        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice-cloud/ \
name "Voice Input (讯飞云)"

        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice-cloud/ \
command "$HOME/bin/tools/voice_input/xfyun/voice_input_wrapper_xfyun.sh"

        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice-cloud/ \
binding '<Shift><Super>v'

        echo "✓ 已配置快捷键 Super+Shift+V"
        ;;
    2)
        echo "替换原快捷键为讯飞云..."

        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice/ \
command "$HOME/bin/tools/voice_input/xfyun/voice_input_wrapper_xfyun.sh"

        echo "✓ Super+V 已替换为讯飞云版本"
        ;;
    3)
        echo "跳过快捷键配置"
        ;;
    *)
        echo "无效选择，跳过快捷键配置"
        ;;
esac

# 完成
echo ""
echo "========================================="
echo "  配置完成！"
echo "========================================="
echo ""
echo "📋 快速测试："
echo ""
echo "  cd ~/bin/tools/voice_input/xfyun"
echo "  ./voice_input_xfyun.py"
echo ""
echo "📖 详细文档："
echo "  - 讯飞方案指南: ~/bin/tools/voice_input/xfyun/XFYUN_GUIDE.md"
echo "  - 使用说明: ~/bin/tools/voice_input/README.md"
echo ""
echo "🎤 使用快捷键："
if [[ $REPLY == "1" ]]; then
    echo "  - Super+Shift+V: 讯飞云（实时、准确）"
    echo "  - Super+V: 离线 Whisper（隐私保护）"
elif [[ $REPLY == "2" ]]; then
    echo "  - Super+V: 讯飞云"
fi
echo ""
