# 语音输入工具

Linux 桌面语音转文字解决方案，提供**离线**和**在线**两种方案。

## 方案选择

### 📦 方案对比

| 特性 | 离线 Whisper | 讯飞云 API |
|------|-------------|------------|
| **识别速度** | ⭐⭐ 延迟 3-5秒 | ⭐⭐⭐⭐⭐ 实时 <500ms |
| **准确率** | ⭐⭐⭐⭐ 85% | ⭐⭐⭐⭐⭐ 95%+ |
| **时长限制** | ⭐⭐ 10秒 | ⭐⭐⭐⭐⭐ 无限制 |
| **标点符号** | ❌ 无 | ✅ 自动添加 |
| **网络需求** | ✅ 完全离线 | ⚠️ 需要联网 |
| **隐私性** | ⭐⭐⭐⭐⭐ 本地处理 | ⭐⭐ 数据上传 |
| **费用** | ✅ 完全免费 | ⭐⭐⭐⭐ 基本免费 |

### 🎯 使用建议

**推荐：混合使用**
- **日常使用** → 讯飞云（90%场景）- 快速、准确、长文本
- **隐私保护** → 离线 Whisper（10%场景）- 敏感内容、离线环境

**配置双快捷键：**
- `Super + Shift + V` → 讯飞云
- `Super + V` → 离线 Whisper

## 📂 方案文档

### 方案一：离线 Whisper（基础方案）

📁 目录：`local/`

- **[完整安装指南](./local/INSTALL.md)** - 详细安装步骤和故障排查
- **[快速开始](./local/QUICKSTART.md)** - 5分钟快速部署

**适合场景：**
- 完全离线环境
- 隐私敏感内容
- 作为云服务的备选方案

### 方案二：讯飞云 API（推荐方案）

📁 目录：`xfyun/`

- **[完整配置指南](./xfyun/XFYUN_GUIDE.md)** - API注册、密钥获取、详细配置
- **[快速开始](./xfyun/XFYUN_QUICKSTART.md)** - 3分钟快速配置

**适合场景：**
- 日常办公、笔记输入
- 长文本连续输入
- 对准确率要求高
- 需要实时反馈

---

## 快速开始

### 新用户（推荐流程）

1. **先安装离线方案**（基础环境）
   ```bash
   # 查看详细步骤
   cat ~/bin/tools/voice_input/local/INSTALL.md
   ```

2. **再配置讯飞云**（日常主力）
   ```bash
   cd ~/bin/tools/voice_input/xfyun
   ./setup_xfyun.sh
   ```

3. **配置双快捷键**
   - Super+V → 离线
   - Super+Shift+V → 讯飞云

### 已有离线方案用户

直接添加讯飞云方案：
```bash
cd ~/bin/tools/voice_input/xfyun
./setup_xfyun.sh
```

---

## 使用方法

### 快捷键（推荐）

**讯飞云（日常使用）：**
1. 按 `Super + Shift + V`
2. 对着麦克风连续说话（可以很长）
3. 按 `Ctrl + C` 停止
4. 自动复制到剪贴板
5. 按 `Ctrl + V` 粘贴

**离线 Whisper（隐私保护）：**
1. 按 `Super + V`
2. 对着麦克风说话（10秒内）
3. 停顿 2 秒自动结束
4. 自动复制到剪贴板
5. 按 `Ctrl + V` 粘贴

### 命令行

```bash
# 讯飞云
cd ~/bin/tools/voice_input/xfyun
./voice_input_xfyun.py

# 离线 Whisper
cd ~/bin/tools/voice_input/local
./voice_input.py
```

---

## 工作流程对比

### 讯飞云（实时流式）
```
Super+Shift+V → 弹出终端 → 🎤开始录音 → 持续说话 → 实时显示结果 → Ctrl+C停止 → ✓复制 → Ctrl+V粘贴
```

### 离线 Whisper（批量识别）
```
Super+V → 弹出终端 → 🎤录音 → 说话 → 停顿2秒 → 识别中... → ✓复制 → Ctrl+V粘贴
```

---

## 配置和优化

详细的配置调整和使用技巧请查看各方案文档：

### 离线 Whisper 配置
- **模型选择** - tiny/base/small/medium
- **语言设置** - 中文/英文/自动检测
- **录音参数** - 时长、静音检测阈值
- **性能优化** - CPU占用、内存管理

📖 详见：[local/INSTALL.md](./local/INSTALL.md)

### 讯飞云配置
- **API 密钥管理** - 安全存储、权限设置
- **网络优化** - 连接超时、重试策略
- **识别参数** - 方言、领域定制
- **费用管理** - 额度监控、成本优化

📖 详见：[xfyun/XFYUN_GUIDE.md](./xfyun/XFYUN_GUIDE.md)

---

## 常见问题

### 快速排查

| 问题 | 解决方案 | 详细文档 |
|------|---------|----------|
| 离线方案首次很慢 | 正常，下载模型需时 | [local/INSTALL.md](./local/INSTALL.md) |
| 讯飞连接失败 | 检查密钥和网络 | [xfyun/XFYUN_GUIDE.md](./xfyun/XFYUN_GUIDE.md) |
| 识别不准确 | 升级模型或换方案 | 各方案文档 |
| 无法录音 | 检查麦克风权限 | 两个方案通用 |
| 快捷键不工作 | 检查脚本路径和权限 | [local/INSTALL.md](./local/INSTALL.md) |

### 方案选择建议

**何时用讯飞云？**
- ✅ 日常办公、笔记
- ✅ 长文本输入
- ✅ 需要标点符号
- ✅ 要求高准确率

**何时用离线 Whisper？**
- ✅ 隐私敏感内容
- ✅ 离线环境
- ✅ 短句输入
- ✅ 不想依赖网络

详细问题排查请查看各方案的文档。

---

## 项目结构

```
~/bin/tools/voice_input/
├── README.md                    # 本文件（总览）
├── .envrc                       # direnv 配置
│
├── local/                       # 离线 Whisper 方案
│   ├── voice_input.py           # 主程序
│   ├── voice_input_wrapper.sh   # 快捷键脚本
│   ├── INSTALL.md               # 完整安装指南
│   └── QUICKSTART.md            # 快速开始
│
└── xfyun/                       # 讯飞云 API 方案
    ├── voice_input_xfyun.py     # 主程序
    ├── voice_input_wrapper_xfyun.sh  # 快捷键脚本
    ├── setup_xfyun.sh           # 自动配置脚本
    ├── config.ini.example       # 配置文件模板
    ├── XFYUN_GUIDE.md           # 完整配置指南
    └── XFYUN_QUICKSTART.md      # 快速开始

~/.virtualenvs/voice_input/      # Python 虚拟环境（共享）
├── bin/python
└── lib/python3.x/site-packages/
    ├── whisper/                 # Whisper 离线模型
    ├── torch/                   # PyTorch
    ├── pyaudio/                 # 音频录制
    └── websocket/               # WebSocket 客户端
```

## 技术栈

### 离线方案
- **语音识别**: [OpenAI Whisper](https://github.com/openai/whisper)
- **深度学习**: PyTorch (CPU mode)
- **音频录制**: PyAudio
- **系统集成**: xclip

### 讯飞云方案
- **语音识别**: [讯飞开放平台](https://www.xfyun.cn/)
- **通信协议**: WebSocket
- **音频录制**: PyAudio
- **系统集成**: xclip

### 共同依赖
- **环境管理**: virtualenvwrapper + direnv
- **桌面环境**: GNOME (其他桌面需调整快捷键配置)
- **系统**: Linux (Debian/Ubuntu)

---

## 总结

这个项目提供了**灵活的混合方案**：

1. **离线 Whisper** - 隐私保护，完全本地
2. **讯飞云 API** - 实时准确，体验最佳

推荐配置双快捷键，根据场景灵活切换，兼顾效率和隐私。

**快速开始：**
```bash
# 1. 安装离线方案（基础）
cat ~/bin/tools/voice_input/local/QUICKSTART.md

# 2. 配置讯飞云（增强）
cd ~/bin/tools/voice_input/xfyun
./setup_xfyun.sh
```

---

## 支持与反馈

- **项目地址**: https://github.com/MuyaoWorkshop/linux-voice-input
- **问题反馈**: https://github.com/MuyaoWorkshop/linux-voice-input/issues
- **文档更新**: 2025-12-22
