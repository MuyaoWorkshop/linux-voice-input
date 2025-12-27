# 讯飞云方案 - 完整指南

基于讯飞开放平台的在线语音识别服务，实时准确，体验优秀。

## 目录

- [方案特点](#方案特点)
- [快速开始](#快速开始)
- [注册与配置](#注册与配置)
- [安装步骤](#安装步骤)
- [使用方法](#使用方法)
- [费用说明](#费用说明)
- [常见问题](#常见问题)

---

## 方案特点

### 核心优势

1. **实时流式识别** - 边说边出结果，无需等待
2. **超高准确率** - 中文识别业内领先，准确率 95%+
3. **智能标点** - 自动添加逗号、句号等标点符号
4. **无时长限制** - 支持长文本连续输入
5. **免费额度充足** - 个人使用完全够用

### 与离线方案对比

| 对比项 | 讯飞云 API | 离线 Whisper |
|--------|------------|--------------|
| **识别速度** | ⭐⭐⭐⭐⭐ 实时（<500ms） | ⭐⭐ 延迟（3-5秒） |
| **准确率** | ⭐⭐⭐⭐⭐ 95%+ | ⭐⭐⭐⭐ 85% |
| **时长限制** | ⭐⭐⭐⭐⭐ 无限制 | ⭐⭐ 10秒 |
| **标点符号** | ⭐⭐⭐⭐⭐ 自动添加 | ❌ 无标点 |
| **流式识别** | ⭐⭐⭐⭐⭐ 边说边出 | ❌ 不支持 |
| **网络需求** | ⚠️ 需要联网 | ✅ 完全离线 |
| **隐私性** | ⚠️ 数据上传 | ✅ 本地处理 |
| **费用** | ⭐⭐⭐⭐ 基本免费 | ⭐⭐⭐⭐⭐ 完全免费 |

---

## 快速开始

### 前提条件

- 已完成基础环境配置（Python、系统依赖等）
- 有网络连接
- 准备注册讯飞账号

### 3步快速配置

#### 1. 使用配置脚本（推荐）

```bash
cd /home/wanps/bin/tools/voice_input
./install.sh
```

安装时选择：
- `2) 仅安装讯飞云` 或 `3) 安装双方案`
- 按提示配置 API 密钥
- 选择快捷键模式

#### 2. 或使用 XFYun 配置脚本

如果已有基础环境：

```bash
cd /home/wanps/bin/tools/voice_input/xfyun
./setup_xfyun.sh
```

根据提示：
- 安装依赖（websocket-client）
- 输入 API 密钥（APPID、APISecret、APIKey）
- 配置快捷键（双快捷键 / 单快捷键）

#### 3. 测试

```bash
cd /home/wanps/bin/tools/voice_input/xfyun
./voice_input_xfyun.py
```

对着麦克风说话，按 Ctrl+C 停止，应该看到实时识别结果。

---

## 注册与配置

### 获取 API 密钥

#### 1. 注册账号

访问：**https://www.xfyun.cn/**

- 点击右上角 **"注册"**
- 使用手机号注册或微信扫码登录
- 建议使用手机号注册（方便接收验证码）

**可选但建议**完成实名认证：
- 登录后点击右上角头像 → "账号管理" → "实名认证"
- 填写姓名和身份证号
- 上传身份证照片

**好处：**
- 提高免费调用量
- 解锁更多功能
- 获取更稳定的服务

#### 2. 创建应用

登录后，进入控制台：https://console.xfyun.cn/

1. 点击 **"创建新应用"**
2. 填写应用信息：
   ```
   应用名称：语音输入工具
   应用类别：个人应用
   应用平台：Linux
   应用描述：个人语音转文字输入工具
   ```
3. 点击 **"提交"** 创建应用

#### 3. 开通服务

1. 在应用列表中找到刚创建的应用
2. 点击应用名称进入详情页
3. 点击左侧菜单 **"语音听写（流式版）"**
4. 点击 **"开通服务"** 按钮
5. 阅读并同意服务协议

**重要提示：**
- 选择 **"流式版"** 而不是普通版
- 流式版支持实时识别，体验更好

#### 4. 获取密钥

开通服务后，你会看到三个重要的密钥：

```
APPID:      xxxxxxxx（8位字符）
APISecret:  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx（32位字符）
APIKey:     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx（32位字符）
```

**⚠️ 重要：请妥善保管这三个密钥，不要泄露！**

密钥位置：
```
控制台 → 我的应用 → [你的应用名] → 语音听写（流式版） → 接口详情
```

---

## 安装步骤

### 使用统一安装脚本（推荐）

```bash
cd /home/wanps/bin/tools/voice_input
./install.sh
```

选择方案时选 `2) 仅安装讯飞云` 或 `3) 安装双方案`。

### 手动安装

如果需要手动控制：

#### 1. 安装依赖

```bash
cd /home/wanps/bin/tools/voice_input
source venv/bin/activate
pip install websocket-client pyaudio
```

#### 2. 配置密钥

**方法一：使用配置脚本**

```bash
cd xfyun
./setup_xfyun.sh
```

**方法二：手动创建配置文件**

```bash
cd /home/wanps/bin/tools/voice_input/xfyun
nano config.ini
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

保存文件并设置权限：

```bash
chmod 600 config.ini
```

#### 3. 配置快捷键

**方案 A：双快捷键模式（推荐）**

为讯飞版本配置不同的快捷键（`Super+Shift+V`）：

```bash
# 获取现有快捷键列表
CURRENT=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

# 添加新的快捷键路径
if [[ "$CURRENT" == "@as []" ]]; then
    NEW_LIST="['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice-cloud/']"
else
    TEMP="${CURRENT%]}"
    NEW_LIST="${TEMP}, '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice-cloud/']"
fi

gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$NEW_LIST"

# 配置讯飞云快捷键
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice-cloud/ \
name "Voice Input (讯飞云)"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice-cloud/ \
command "/home/wanps/bin/tools/voice_input/xfyun/voice_input_wrapper_xfyun.sh"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-voice-cloud/ \
binding '<Shift><Super>v'
```

**快捷键分配：**
- `Super + V` → 离线 Whisper（隐私保护）
- `Super + Shift + V` → 讯飞云（快速准确）

**方案 B：单快捷键模式**

直接将原来的快捷键改为讯飞版本：

```bash
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:\
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voice-input/ \
command "/home/wanps/bin/tools/voice_input/xfyun/voice_input_wrapper_xfyun.sh"
```

---

## 使用方法

### 命令行测试

```bash
cd /home/wanps/bin/tools/voice_input/xfyun
source ../venv/bin/activate
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

### 使用步骤

1. 按快捷键启动
2. 对着麦克风连续说话（可以很长）
3. 实时显示识别结果
4. 按 `Ctrl + C` 停止
5. 自动复制到剪贴板
6. 按 `Ctrl + V` 粘贴到任何应用

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
1. 检查 `xfyun/config.ini` 中的密钥是否正确
2. 确认已开通 "语音听写（流式版）" 服务
3. 重新复制粘贴密钥，避免多余空格

```bash
# 检查配置文件
cat /home/wanps/bin/tools/voice_input/xfyun/config.ini

# 重新配置
cd /home/wanps/bin/tools/voice_input/xfyun
./setup_xfyun.sh
```

### Q2: 报错 "11200" 授权错误

**原因：** IP 白名单限制

**解决：**
1. 登录讯飞控制台
2. 进入应用 → IP白名单设置
3. 添加 `0.0.0.0/0`（允许所有IP）或添加你的公网IP

### Q3: 识别没有标点符号

**原因：** 可能使用了普通版而非流式版

**解决：**
确保开通的是 **"语音听写（流式版）"** 而不是 "语音听写"

### Q4: 识别速度慢或延迟高

**原因：** 网络连接问题

**解决：**
```bash
# 测试网络延迟
ping api.xfyun.cn

# 测试下载速度
wget -O /dev/null http://speedtest.tele2.net/10MB.zip
```

**优化方案：**
- 切换到更稳定的网络
- 使用有线连接代替WiFi
- 检查是否使用了VPN/代理

### Q5: 提示"未找到 websocket"

**原因：** 依赖未安装

**解决：**
```bash
cd /home/wanps/bin/tools/voice_input
source venv/bin/activate
pip install websocket-client
```

### Q6: 免费额度够用吗？

**A**: 个人用户每天 500 次，每次最长 60 秒，基本足够。

**监控用量：**
```
控制台 → 用量统计
```

### Q7: 可以同时使用两个方案吗？

**可以！** 建议配置：
- `Super + V` → 离线方案（隐私敏感）
- `Super + Shift + V` → 讯飞云（日常使用）

根据场景自由切换。

### Q8: 识别结果不准确

**优化方法：**
1. 在安静环境使用
2. 使用质量好的麦克风
3. 说话清晰，速度适中
4. 检查网络连接稳定性

### Q9: 支持方言吗？

讯飞支持多种方言，但需要在控制台开通对应服务：
- 粤语
- 四川话
- 河南话
- 东北话
- 等等

默认使用普通话。

### Q10: 网络断开怎么办？

脚本会自动检测网络连接：
- 如果连接失败，提示错误信息
- 手动切换到离线方案

---

## 何时使用讯飞云？

✅ 日常办公、笔记输入
✅ 需要长文本输入
✅ 对准确率要求高
✅ 需要实时反馈
✅ 网络环境良好

## 何时使用离线 Whisper？

✅ 完全离线环境
✅ 隐私敏感内容
✅ 短句快速输入
✅ 不想依赖网络

---

## 我的建议

**日常使用讯飞云作为主力，离线 Whisper 作为备选。**

配置双快捷键：
- 90% 的场景用讯飞（快、准、长）
- 10% 的场景用离线（隐私、离线）

---

## 技术参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| 音频格式 | pcm, raw | 原始音频流 |
| 采样率 | 16000 Hz | 推荐值，支持 8000 Hz |
| 声道 | 1（单声道） | 固定值 |
| 位深度 | 16 bit | 固定值 |
| 语言 | zh_cn | 中文普通话 |
| 标点 | 1（开启） | 自动添加标点 |

---

## 支持

- **官方文档**: https://www.xfyun.cn/doc/asr/voicedictation/API.html
- **控制台**: https://console.xfyun.cn/
- **项目地址**: https://github.com/MuyaoWorkshop/linux-voice-input
- **问题反馈**: https://github.com/MuyaoWorkshop/linux-voice-input/issues
- **常见问题**: [FAQ.md](FAQ.md)
