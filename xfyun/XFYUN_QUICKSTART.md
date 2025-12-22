# 讯飞语音识别 - 5分钟快速开始

最快速度体验讯飞云语音识别。

## 前提条件

- 已完成离线方案的基础安装（virtualenvwrapper、direnv、系统依赖）
- 有网络连接
- 已注册讯飞账号并获取 API 密钥

## 快速配置（3步骤）

### 1. 安装依赖（30秒）

```bash
cd ~/bin/tools/voice_input/xfyun
workon voice_input
pip install websocket-client
```

### 2. 配置密钥（1分钟）

**方式A：使用配置脚本（推荐）**

```bash
cd ~/bin/tools/voice_input/xfyun
./setup_xfyun.sh
```

根据提示输入 API 密钥，选择快捷键模式即可。

**方式B：手动配置**

```bash
cd ~/bin/tools/voice_input/xfyun
cp config.ini.example config.ini
nano config.ini  # 填入你的真实密钥
chmod 600 config.ini
```

### 3. 测试（30秒）

```bash
cd ~/bin/tools/voice_input/xfyun
./voice_input_xfyun.py
```

对着麦克风说话，按 Ctrl+C 停止。应该看到实时识别结果。

## 获取 API 密钥

如果还没有 API 密钥：

1. 访问：https://www.xfyun.cn/
2. 注册/登录账号
3. 进入控制台：https://console.xfyun.cn/
4. 创建应用 → 开通"语音听写（流式版）"
5. 获取 APPID、APISecret、APIKey

详细步骤见 [XFYUN_GUIDE.md](./XFYUN_GUIDE.md)

## 快捷键使用

### 双快捷键模式（推荐）

- **Super+Shift+V** → 讯飞云（日常使用）
  - 实时识别
  - 高准确率
  - 自动标点
  - 无时长限制

- **Super+V** → 离线 Whisper（隐私保护）
  - 完全离线
  - 敏感内容
  - 无网络环境

### 单快捷键模式

- **Super+V** → 讯飞云（已替换）

## 对比测试

打开文本编辑器，分别测试：

**测试讯飞云：**
```
按 Super+Shift+V → 说："今天天气很好，我们去公园散步吧。" → 按 Ctrl+C
```

**测试离线：**
```
按 Super+V → 说："今天天气很好" → 停顿2秒自动结束
```

对比识别速度和准确率的差异。

## 常见问题

### Q: 连接失败？

**A**: 检查：
1. 网络连接是否正常
2. API 密钥是否正确（注意没有多余空格）
3. 是否已开通"语音听写（流式版）"服务

### Q: 提示"未找到 websocket"？

**A**: 重新安装依赖：
```bash
workon voice_input
pip install websocket-client
```

### Q: 识别结果没有标点？

**A**: 确认开通的是"流式版"而非普通版。

### Q: 免费额度够用吗？

**A**: 个人用户每天 500 次，每次最长 60 秒，基本足够。

## 下一步

- 详细配置指南：[XFYUN_GUIDE.md](./XFYUN_GUIDE.md)
- 完整使用手册：[README.md](../README.md)
- 离线方案文档：[local/INSTALL.md](../local/INSTALL.md)

---

完成！现在你可以使用 **Super+Shift+V** 进行快速语音输入了。

## 支持与反馈

- **项目地址**: https://github.com/MuyaoWorkshop/linux-voice-input
- **问题反馈**: https://github.com/MuyaoWorkshop/linux-voice-input/issues
