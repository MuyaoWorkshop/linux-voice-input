# 更新日志

所有重要的项目变更都会记录在这个文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.1.0] - 2025-12-23

### 新增功能 🚀

#### 守护进程模式（性能优化）
- ✨ **极速启动**：离线 Whisper 支持守护进程模式，启动速度从 4-5 秒提升到 **<0.5 秒**（提升 87.5%）
- 📊 **实时反馈界面**：
  - 🎤 实时音量条显示（`🎤 [████████░░] 60%`）
  - ⏸️ 静音倒计时（`静音检测中... 还剩 2.1 秒`）
  - 📈 识别进度提示
- 🔄 **一键模式切换**：新增 `switch_mode.sh` 脚本，支持守护进程模式与普通模式自由切换
- 🤖 **systemd 集成**：开机自启动，崩溃自动重启
- ⚡ **CPU 优化**：使用 `select()` 优化，空闲时 CPU 占用从 10% 降至 **1.6%**

**新增文件**：
- `local/voice_input_daemon.py` - 守护进程主程序
- `local/voice_input_trigger.py` - 快速触发器
- `local/voice_input_fast.sh` - 守护进程模式启动脚本
- `local/switch_mode.sh` - 模式切换工具
- `~/.config/systemd/user/voice-input-daemon.service` - systemd 服务配置

**架构改进**：
- 采用客户端-服务器架构（Unix Domain Socket 通信）
- JSON Lines 协议实现实时状态推送
- 守护进程预加载模型，客户端零等待

#### 音频处理优化
- 🔧 **修复音量检测 Bug**：使用 `numpy.frombuffer` 正确解析 int16 音频数据（之前误用 `list()` 导致计算错误）
- 🎯 **优化静音阈值**：从 500 调整为 600（基于 int16 范围）
- ⏱️ **延长录音时长**：从 10 秒提升到 60 秒
- ⏸️ **优化停顿检测**：从 2 秒延长到 3 秒，避免思考时被打断

#### 繁简转换
- 🈲 **自动繁简转换**：集成 OpenCC，解决 Whisper 输出繁体字问题
- 📝 **可选依赖**：`opencc-python-reimplemented` 作为可选依赖，未安装时自动降级

### 改进

#### 文档更新
- 📚 **新增技术文档**：`docs/DAEMON_OPTIMIZATION.md` - 详细讲解守护进程优化过程（从问题分析到性能优化，适合初学者学习）
- 📖 **更新所有文档**：README、QUICKSTART、INSTALL 全面更新，添加守护进程模式说明
- 📊 **新增对比表**：在 README 中详细对比普通模式 vs 守护进程模式

#### 用户体验
- ✅ **更清晰的状态提示**：录音、识别、完成各阶段都有明确反馈
- 📈 **耗时显示**：显示识别耗时和总耗时，便于用户了解性能
- 🎨 **美化输出**：使用 Unicode 字符和 emoji 提升终端显示效果

### 修复

- 🐛 **修复音量计算错误**：使用正确的 int16 数组计算，而非错误的字节列表
- 🐛 **修复 WebSocket 关闭错误**：正确处理连接关闭，避免 "Broken pipe" 错误
- 🐛 **修复 Ctrl+C 中断**：改进信号处理，确保优雅退出

### 性能数据

| 指标 | 普通模式 | 守护进程模式 | 提升 |
|------|---------|-------------|------|
| **启动速度** | 4-5 秒 | <0.5 秒 | **87.5%** ↑ |
| **CPU（空闲）** | 0% | 1.6% | 可忽略 |
| **内存（常驻）** | 0 MB | 900 MB | - |
| **用户体验** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 显著提升 |

### 技术亮点

- **Unix Socket**：本地 IPC，安全高效
- **select() I/O 多路复用**：降低 CPU 占用（10% → 1.6%）
- **systemd 用户服务**：开机自启动、崩溃自动重启
- **实时状态流**：JSON Lines 协议，客户端实时显示进度
- **临时文件安全**：使用 `tempfile` 模块，录音文件自动清理

---

## [1.0.0] - 2025-12-22

### 首次发布 🎉

#### 新增
- ✨ 离线 Whisper 语音识别方案
  - 支持 OpenAI Whisper 多种模型（tiny/base/small/medium）
  - 完全本地处理，保护隐私
  - 自动复制到剪贴板

- ✨ 讯飞云 API 语音识别方案
  - 实时流式识别，延迟 <500ms
  - 自动添加标点符号
  - 无时长限制，支持长文本输入
  - 准确率 95%+

- 🔧 双快捷键支持
  - `Super+V` - 离线 Whisper
  - `Super+Shift+V` - 讯飞云

- 📦 完整的安装和配置工具
  - `setup_xfyun.sh` - 讯飞云自动配置脚本
  - 虚拟环境自动管理（virtualenvwrapper + direnv）
  - GNOME 快捷键自动配置

- 📚 完整的中文文档
  - README.md - 项目总览和快速开始
  - local/INSTALL.md - 离线方案完整安装指南
  - local/QUICKSTART.md - 离线方案快速开始
  - xfyun/XFYUN_GUIDE.md - 讯飞云完整配置指南
  - xfyun/XFYUN_QUICKSTART.md - 讯飞云快速开始

- 🔒 安全特性
  - API 密钥存储在 config.ini（已加入 .gitignore）
  - 提供 config.ini.example 模板
  - SSH 多账号配置指南

#### 技术栈
- Python 3.8+
- OpenAI Whisper
- PyAudio
- WebSocket (websocket-client)
- xclip

#### 已测试环境
- ✅ Debian 12
- ✅ GNOME 桌面环境

其他 Linux 发行版（Ubuntu/Arch/Fedora 等）理论上也可用，但未经测试。

---

## [未来计划]

### 计划中的功能
- [ ] 支持更多桌面环境（KDE、XFCE）
- [ ] 图形化配置界面
- [ ] 支持英文识别
- [ ] 浏览器插件（Chrome/Firefox）
- [ ] 自动降级（讯飞云失败时自动切换到离线）
- [ ] 识别历史记录
- [ ] 自定义词库
- [ ] 语音命令（如"删除上一句"）

### 欢迎贡献
如果你有好的想法或发现了bug，欢迎：
- 提交 Issue: https://github.com/MuyaoWorkshop/linux-voice-input/issues
- 提交 Pull Request

---

## 版本说明

- **[主版本号]**：不兼容的API更改
- **[次版本号]**：向下兼容的功能新增
- **[修订号]**：向下兼容的问题修正

示例：
- 1.0.0 → 1.0.1：修复bug
- 1.0.1 → 1.1.0：添加新功能
- 1.1.0 → 2.0.0：重大更新，可能不兼容
