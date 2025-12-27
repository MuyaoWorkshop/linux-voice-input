#!/bin/bash
# 语音输入工具卸载脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  语音输入工具 - 卸载程序${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo -e "${YELLOW}警告: 此操作将：${NC}"
echo "  - 停止并删除守护进程"
echo "  - 删除快捷键配置"
echo "  - 删除虚拟环境"
echo "  - 保留 Whisper 模型缓存（位于 ~/.cache/whisper/）"
echo "  - 保留讯飞云配置（位于 xfyun/config.json）"
echo ""

read -p "确认卸载？[y/N] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "取消卸载"
    exit 0
fi

echo ""
echo -e "${YELLOW}[1/4] 停止守护进程...${NC}"

# 停止并禁用守护进程
if systemctl --user is-active --quiet voice-input-daemon 2>/dev/null; then
    systemctl --user stop voice-input-daemon
    echo -e "${GREEN}✓${NC} 守护进程已停止"
else
    echo "  守护进程未运行"
fi

if systemctl --user is-enabled --quiet voice-input-daemon 2>/dev/null; then
    systemctl --user disable voice-input-daemon
    echo -e "${GREEN}✓${NC} 守护进程已禁用"
fi

# 删除 systemd service 文件
SERVICE_FILE="$HOME/.config/systemd/user/voice-input-daemon.service"
if [ -f "$SERVICE_FILE" ]; then
    rm -f "$SERVICE_FILE"
    systemctl --user daemon-reload
    echo -e "${GREEN}✓${NC} Service 文件已删除"
fi

echo ""
echo -e "${YELLOW}[2/4] 删除快捷键配置...${NC}"

# 获取当前快捷键列表
CURRENT=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

# 删除 voice-input-local
if echo "$CURRENT" | grep -q "voice-input-local"; then
    # 从列表中移除 voice-input-local
    NEW_LIST=$(echo "$CURRENT" | sed "s|, '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-local/'||g" | sed "s|'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-local/', ||g" | sed "s|'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-local/'||g")
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$NEW_LIST"

    # 删除配置
    dconf reset /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-local/name 2>/dev/null || true
    dconf reset /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-local/command 2>/dev/null || true
    dconf reset /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-local/binding 2>/dev/null || true

    echo -e "${GREEN}✓${NC} 本地方案快捷键已删除"
fi

# 删除 voice-input-xfyun
if echo "$CURRENT" | grep -q "voice-input-xfyun"; then
    # 从列表中移除 voice-input-xfyun
    CURRENT=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
    NEW_LIST=$(echo "$CURRENT" | sed "s|, '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-xfyun/'||g" | sed "s|'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-xfyun/', ||g" | sed "s|'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-xfyun/'||g")
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$NEW_LIST"

    # 删除配置
    dconf reset /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-xfyun/name 2>/dev/null || true
    dconf reset /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-xfyun/command 2>/dev/null || true
    dconf reset /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input-xfyun/binding 2>/dev/null || true

    echo -e "${GREEN}✓${NC} 讯飞云方案快捷键已删除"
fi

# 兼容旧版本的 voice-input 快捷键
if echo "$CURRENT" | grep -q "voice-input/"; then
    CURRENT=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
    NEW_LIST=$(echo "$CURRENT" | sed "s|, '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input/'||g" | sed "s|'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input/', ||g" | sed "s|'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input/'||g")
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$NEW_LIST"

    dconf reset /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input/name 2>/dev/null || true
    dconf reset /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input/command 2>/dev/null || true
    dconf reset /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input/binding 2>/dev/null || true

    echo -e "${GREEN}✓${NC} 旧版本快捷键已删除"
fi

echo ""
echo -e "${YELLOW}[3/4] 删除虚拟环境...${NC}"

if [ -d "$SCRIPT_DIR/venv" ]; then
    rm -rf "$SCRIPT_DIR/venv"
    echo -e "${GREEN}✓${NC} 虚拟环境已删除"
else
    echo "  虚拟环境不存在"
fi

echo ""
echo -e "${YELLOW}[4/4] 清理符号链接...${NC}"

if [ -L "$SCRIPT_DIR/voice_input_wrapper.sh" ]; then
    rm -f "$SCRIPT_DIR/voice_input_wrapper.sh"
    echo -e "${GREEN}✓${NC} voice_input_wrapper.sh 已删除"
fi

if [ -L "$SCRIPT_DIR/voice_input_wrapper_xfyun.sh" ]; then
    rm -f "$SCRIPT_DIR/voice_input_wrapper_xfyun.sh"
    echo -e "${GREEN}✓${NC} voice_input_wrapper_xfyun.sh 已删除"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  卸载完成！${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo "已保留的文件："
echo "  - Whisper 模型缓存: ~/.cache/whisper/"
echo "  - 讯飞云配置: $SCRIPT_DIR/xfyun/config.json"
echo "  - 项目源代码: $SCRIPT_DIR/"
echo ""

read -p "是否删除 Whisper 模型缓存（~140MB）？[y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "$HOME/.cache/whisper" ]; then
        rm -rf "$HOME/.cache/whisper"
        echo -e "${GREEN}✓${NC} Whisper 模型缓存已删除"
    fi
fi

echo ""
read -p "是否删除讯飞云配置？[y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f "$SCRIPT_DIR/xfyun/config.json" ]; then
        rm -f "$SCRIPT_DIR/xfyun/config.json"
        echo -e "${GREEN}✓${NC} 讯飞云配置已删除"
    fi
fi

echo ""
echo -e "${BLUE}提示：${NC}"
echo "  如需完全删除项目，请手动删除目录："
echo -e "  ${BLUE}rm -rf $SCRIPT_DIR${NC}"
