# 更新日志

所有重要的项目变更都会记录在这个文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

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
