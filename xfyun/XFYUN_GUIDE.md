# 讯飞语音识别 - 完整配置指南

本指南将帮助你从零开始配置讯飞实时语音识别 API。

## 目录

- [方案优势](#方案优势)
- [注册账号](#注册账号)
- [创建应用获取密钥](#创建应用获取密钥)
- [安装配置](#安装配置)
- [使用方法](#使用方法)
- [费用说明](#费用说明)
- [常见问题](#常见问题)

---

## 方案优势

### 与离线方案对比

| 对比项 | 讯飞云 API | 离线 Whisper |
|--------|------------|--------------|
| **识别速度** | ⭐⭐⭐⭐⭐ 实时（<500ms） | ⭐⭐ 延迟（3-5秒） |
| **准确率** | ⭐⭐⭐⭐⭐ 95%+ | ⭐⭐⭐⭐ 85% |
| **时长限制** | ⭐⭐⭐⭐⭐ 无限制 | ⭐⭐ 10秒 |
| **标点符号** | ⭐⭐⭐⭐⭐ 自动添加 | ⭐⭐ 无标点 |
| **流式识别** | ⭐⭐⭐⭐⭐ 边说边出 | ❌ 不支持 |
| **网络需求** | ⚠️ 需要联网 | ✅ 完全离线 |
| **隐私性** | ⚠️ 数据上传 | ✅ 本地处理 |
| **费用** | ⭐⭐⭐⭐ 基本免费 | ⭐⭐⭐⭐⭐ 完全免费 |

### 核心优势

1. **实时流式识别** - 边说边出结果，无需等待
2. **超高准确率** - 中文识别业内领先
3. **智能标点** - 自动添加逗号、句号等
4. **无时长限制** - 支持长文本连续输入
5. **免费额度充足** - 个人使用完全够用

---

## 注册账号

### 1. 访问讯飞开放平台

打开浏览器访问：**https://www.xfyun.cn/**

### 2. 注册账号

点击右上角 **"注册"** 按钮：

- 可以使用手机号注册
- 或使用微信扫码登录
- 建议使用手机号注册（方便接收验证码）

**填写信息：**
```
手机号：你的手机号
验证码：点击获取并填写
密码：设置一个密码
```

### 3. 实名认证（可选但建议）

注册后建议完成实名认证：
- 登录后点击右上角头像
- 选择 "账号管理" → "实名认证"
- 填写姓名和身份证号
- 上传身份证照片

**好处：**
- 提高免费调用量
- 解锁更多功能
- 获取更稳定的服务

---

## 创建应用获取密钥

### 1. 进入控制台

登录后，点击右上角 **"控制台"**：
https://console.xfyun.cn/

### 2. 创建新应用

1. 点击 **"创建新应用"** 按钮
2. 填写应用信息：

```
应用名称：语音输入工具
应用类别：个人应用（或其他类别）
应用平台：Linux
应用描述：个人语音转文字输入工具
```

3. 点击 **"提交"** 创建应用

### 3. 开通语音听写服务

1. 在应用列表中找到刚创建的应用
2. 点击应用名称进入详情页
3. 点击左侧菜单 **"语音听写（流式版）"**
4. 点击 **"开通服务"** 按钮
5. 阅读并同意服务协议

**重要提示：**
- 选择 **"流式版"** 而不是普通版
- 流式版支持实时识别，体验更好

### 4. 获取 API 密钥

开通服务后，你会看到三个重要的密钥：

```
APPID:      xxxxxxxx（8位字符）
APISecret:  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx（32位字符）
APIKey:     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx（32位字符）
```

**⚠️ 重要：请妥善保管这三个密钥，不要泄露！**

可以点击 **"复制"** 按钮将它们保存到本地文件。

### 5. 截图示例位置

密钥位置：
```
控制台 → 我的应用 → [你的应用名] → 语音听写（流式版） → 接口详情
```

在该页面可以看到：
- APPID
- APISecret
- APIKey
- 接口调用量统计
- 接口文档链接

---

## 安装配置

### 1. 安装依赖

```bash
# 进入虚拟环境
cd ~/bin/tools/voice_input
workon voice_input

# 安装讯飞 WebSocket 客户端依赖
pip install websocket-client
```

### 2. 配置密钥

创建配置文件（密钥不会上传到代码仓库）：

```bash
cd ~/bin/tools/voice_input
nano config.ini  # 或使用其他编辑器
```

填入以下内容（替换成你的真实密钥）：

```ini
[xfyun]
# 讯飞语音识别 API 配置
# 从 https://console.xfyun.cn/ 获取

APPID = 你的APPID
APISecret = 你的APISecret
APIKey = 你的APIKey
```

保存文件并设置权限（仅自己可读）：

```bash
chmod 600 config.ini
```

### 3. 添加到 .gitignore

如果使用 Git，避免密钥泄露：

```bash
echo "config.ini" >> .gitignore
```

### 4. 下载讯飞脚本

将 `voice_input_xfyun.py` 脚本放到项目目录：

```bash
cd ~/bin/tools/voice_input
# 脚本文件已创建（见下文）
chmod +x voice_input_xfyun.py
```

### 5. 创建快捷键包装脚本

创建或修改 `voice_input_wrapper_xfyun.sh`：

```bash
#!/bin/bash
# 讯飞语音输入包装脚本

gnome-terminal --title="语音输入 (讯飞)" --geometry=80x20 -- bash -c "
    source ~/.virtualenvs/voice_input/bin/activate
    python3 ~/bin/tools/voice_input/voice_input_xfyun.py
    echo ''
    read -p '按回车关闭窗口...'
"
```

设置权限：

```bash
chmod +x voice_input_wrapper_xfyun.sh
```

### 6. 配置快捷键

#### 方案 A：新增快捷键（推荐）

为讯飞版本配置不同的快捷键（如 `Super+Shift+V`）：

```bash
# 添加讯飞版本快捷键
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
"['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice-local/', \
'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice-cloud/']"

# 配置讯飞版本（Super+Shift+V）
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice-cloud/ \
name "Voice Input (讯飞云)"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice-cloud/ \
command "/home/$USER/bin/tools/voice_input/voice_input_wrapper_xfyun.sh"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice-cloud/ \
binding '<Shift><Super>v'
```

**快捷键分配：**
- `Super + V` → 离线 Whisper（隐私保护）
- `Super + Shift + V` → 讯飞云（快速准确）

#### 方案 B：替换原快捷键

直接将原来的快捷键改为讯飞版本：

```bash
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice/ \
command "/home/$USER/bin/tools/voice_input/voice_input_wrapper_xfyun.sh"
```

---

## 使用方法

### 命令行测试

```bash
cd ~/bin/tools/voice_input
./voice_input_xfyun.py
```

**预期输出：**
```
正在连接讯飞语音识别服务...
✓ 连接成功

🎤 开始录音... (按 Ctrl+C 停止)
...
(实时显示识别结果)
...

识别结果: 今天天气很好，我们去公园散步吧。

✓ 已复制到剪贴板，可使用 Ctrl+V 粘贴
```

### 快捷键使用

**方案 A (双快捷键)：**
- 按 `Super + Shift + V` → 使用讯飞云识别
- 按 `Super + V` → 使用离线识别

**方案 B (单快捷键)：**
- 按 `Super + V` → 使用讯飞云识别

### 使用技巧

1. **连续输入**
   - 可以一直说话，不用停顿
   - 系统会实时显示识别结果
   - 按 Ctrl+C 停止并复制到剪贴板

2. **标点符号**
   - 讯飞会自动添加标点
   - 也可以明确说"逗号"、"句号"、"问号"

3. **数字识别**
   - 自动识别为阿拉伯数字
   - 如："二零二五年" → "2025年"

4. **英文识别**
   - 中英混合效果很好
   - 如："打开 Chrome 浏览器"

---

## 费用说明

### 免费额度

**个人认证用户：**
- 每天 500 次调用
- 每次最长 60 秒
- 合计每天最多 30,000 秒（8.3 小时）

**企业认证用户：**
- 每天 5000 次调用

### 付费价格

如果免费额度不够（实际很少有个人用户超额）：

- **按次计费**：0.0005 元/次（1000次 = 0.5元）
- **按时长计费**：0.06 元/分钟

**实际消费示例：**
- 每天使用 30 次，每次 30 秒
- 全部使用付费：0.0005 × 30 = 0.015 元/天
- 每月：0.45 元

**结论：基本可以忽略不计。**

### 查看用量

在控制台可以实时查看：
```
控制台 → 我的应用 → [你的应用] → 用量统计
```

可以看到：
- 今日调用次数
- 本月调用次数
- 调用成功率
- 费用消耗

---

## 常见问题

### Q1: 连接失败，报错 "10105"

**原因：** APPID、APIKey 或 APISecret 错误

**解决：**
1. 检查 `config.ini` 中的密钥是否正确
2. 确认已开通 "语音听写（流式版）" 服务
3. 重新复制粘贴密钥，避免多余空格

### Q2: 报错 "11200" 授权错误

**原因：** IP 白名单限制

**解决：**
1. 登录控制台
2. 进入应用 → IP白名单设置
3. 添加 `0.0.0.0/0`（允许所有IP）或添加你的公网IP

### Q3: 识别没有标点符号

**原因：** 可能使用了普通版而非流式版

**解决：**
确保开通的是 **"语音听写（流式版）"** 而不是 "语音听写"

### Q4: 识别速度慢或延迟高

**原因：** 网络连接问题

**解决：**
1. 检查网络连接
2. 尝试更换网络（4G/5G、WiFi）
3. 使用国内网络（讯飞服务器在国内）

### Q5: 免费额度用完了

**查看用量：**
```
控制台 → 用量统计
```

**解决：**
1. 等待第二天重置（每天凌晨重置）
2. 开通付费（费用极低）
3. 降级使用离线 Whisper

### Q6: 可以同时使用两个方案吗？

**可以！** 建议配置：
- `Super + V` → 离线方案（隐私敏感）
- `Super + Shift + V` → 讯飞云（日常使用）

根据场景自由切换。

### Q7: 网络断开怎么办？

脚本会自动检测网络连接：
- 如果连接失败，提示错误信息
- 手动切换到离线方案

未来可以实现自动降级。

### Q8: 识别结果不准确

**优化方法：**
1. 在安静环境使用
2. 使用质量好的麦克风
3. 说话清晰，速度适中
4. 调整音频采样率（默认 16000Hz）

### Q9: 如何查看详细日志？

编辑 `voice_input_xfyun.py`，启用调试模式：

```python
DEBUG = True  # 设置为 True
```

会显示：
- WebSocket 连接日志
- 音频发送日志
- 识别结果详情
- 错误堆栈信息

### Q10: 支持方言吗？

讯飞支持多种方言，但需要在控制台开通对应服务：
- 粤语
- 四川话
- 河南话
- 东北话
- 等等

默认使用普通话。

---

## 对比总结

### 何时使用讯飞云？

✅ 日常办公、笔记输入
✅ 需要长文本输入
✅ 对准确率要求高
✅ 需要实时反馈
✅ 网络环境良好

### 何时使用离线 Whisper？

✅ 完全离线环境
✅ 隐私敏感内容
✅ 短句快速输入
✅ 不想依赖网络

### 我的建议

**日常使用讯飞云作为主力，离线 Whisper 作为备选。**

配置双快捷键：
- 90% 的场景用讯飞（快、准、长）
- 10% 的场景用离线（隐私、离线）

---

## 附录

### 讯飞 API 官方文档

- 控制台：https://console.xfyun.cn/
- 流式语音听写文档：https://www.xfyun.cn/doc/asr/voicedictation/API.html
- SDK 下载：https://www.xfyun.cn/sdk/
- 技术支持：https://www.xfyun.cn/services/

### 技术参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| 音频格式 | pcm, raw | 原始音频流 |
| 采样率 | 16000 Hz | 推荐值，支持 8000 Hz |
| 声道 | 1（单声道） | 固定值 |
| 位深度 | 16 bit | 固定值 |
| 语言 | zh_cn | 中文普通话 |
| 标点 | 1（开启） | 自动添加标点 |

### 项目文件结构

```
~/bin/tools/voice_input/
├── README.md                      # 项目总览文档
├── .envrc                         # direnv 配置
│
├── local/                         # 离线 Whisper 方案
│   ├── voice_input.py             # 主程序
│   ├── voice_input_wrapper.sh     # 快捷键脚本
│   ├── INSTALL.md                 # 安装指南
│   └── QUICKSTART.md              # 快速开始
│
└── xfyun/                         # 讯飞云 API 方案 ⭐
    ├── voice_input_xfyun.py       # 主程序 ⭐
    ├── voice_input_wrapper_xfyun.sh  # 快捷键脚本 ⭐
    ├── setup_xfyun.sh             # 自动配置脚本 ⭐
    ├── config.ini                 # API 密钥配置 ⭐
    ├── config.ini.example         # 配置模板
    ├── XFYUN_GUIDE.md             # 本文件 ⭐
    └── XFYUN_QUICKSTART.md        # 快速开始 ⭐
```

---

**完成！** 现在你可以开始使用讯飞语音识别了。

**下一步：** 参照本指南注册账号、获取密钥、安装配置，然后测试使用。

有任何问题请参考 [常见问题](#常见问题) 章节。

---

## 支持与反馈

- **项目地址**: https://github.com/MuyaoWorkshop/linux-voice-input
- **问题反馈**: https://github.com/MuyaoWorkshop/linux-voice-input/issues
- **文档更新**: 2025-12-22
