# 常见问题 FAQ

本文档汇总了用户常见的问题和解决方案。

## 📑 目录

- [安装相关](#安装相关)
- [配置相关](#配置相关)
- [使用相关](#使用相关)
- [性能相关](#性能相关)
- [讯飞云方案](#讯飞云方案)
- [离线Whisper方案](#离线whisper方案)
- [其他问题](#其他问题)

---

## 安装相关

### Q1: 支持哪些Linux发行版？

**A**: 理论上支持所有主流Linux发行版。

**已测试环境：**
- ✅ Debian 12 + GNOME

**其他发行版：**
- Ubuntu/Arch/Fedora/openSUSE 等理论上可用，但未经测试
- Fedora/CentOS 需手动调整包管理器命令（apt → dnf/yum）
- openSUSE 需手动调整包管理器命令（apt → zypper）

**主要要求：**
- Python 3.8+
- GNOME/KDE/XFCE 等桌面环境

### Q2: Python版本要求？

**A**:
- **最低要求**: Python 3.8
- **推荐版本**: Python 3.10 或 3.11
- **不支持**: Python 2.x, Python 3.7 及更低版本

检查Python版本：
```bash
python3 --version
```

### Q3: 需要多少磁盘空间？

**A**:
- **讯飞云方案**: 约 200MB（Python包）
- **离线Whisper**:
  - tiny模型: 约 500MB
  - base模型: 约 1GB
  - small模型: 约 2GB
  - medium模型: 约 5GB

建议预留至少 3GB 空闲空间。

### Q4: 安装时提示"权限被拒绝"

**A**:
```bash
# 检查脚本权限
ls -la ~/bin/tools/voice_input/*/*.sh

# 添加执行权限
chmod +x ~/bin/tools/voice_input/*/*.sh
chmod +x ~/bin/tools/voice_input/*/*.py
```

### Q5: pip install 失败，提示网络错误

**A**:
```bash
# 方法1：使用国内镜像源
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple package-name

# 方法2：配置pip永久使用镜像
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 方法3：重试并增加超时
pip install --timeout=100 package-name
```

---

## 配置相关

### Q6: 虚拟环境是什么？为什么需要？

**A**:
虚拟环境是独立的Python运行环境，避免不同项目的依赖冲突。

好处：
- ✅ 不影响系统Python
- ✅ 项目依赖隔离
- ✅ 方便管理和卸载

你不需要深入理解，跟着文档操作即可。

### Q7: 虚拟环境未激活

**A**:
```bash
# 激活项目虚拟环境
cd ~/bin/tools/voice_input
source venv/bin/activate

# 检查是否在虚拟环境中
which python
# 应显示: ~/bin/tools/voice_input/venv/bin/python
```

### Q8: 快捷键不工作

**A**: 检查：

1. **脚本路径是否正确**
   ```bash
   cat ~/.config/autostart/*.desktop
   # 或
   gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings
   ```

2. **脚本是否有执行权限**
   ```bash
   chmod +x ~/bin/tools/voice_input/*/*.sh
   ```

3. **是否在GNOME环境**
   ```bash
   echo $XDG_CURRENT_DESKTOP
   # 应显示: GNOME 或包含GNOME
   ```

4. **快捷键是否冲突**
   - 进入 设置 → 键盘 → 查看和自定义快捷键
   - 搜索 Super+V 或 Super+Shift+V
   - 删除冲突的快捷键

### Q9: KDE/XFCE如何配置快捷键？

**A**:

**KDE:**
```
设置 → 快捷键 → 自定义快捷键 → 新建 → 全局快捷键 → 命令/URL
名称: 语音输入（讯飞云）
触发器: Meta+Shift+V
动作: /home/用户名/bin/tools/voice_input/xfyun/voice_input_wrapper_xfyun.sh
```

**XFCE:**
```
设置 → 键盘 → 应用程序快捷键 → 添加
命令: /home/用户名/bin/tools/voice_input/xfyun/voice_input_wrapper_xfyun.sh
快捷键: Super+Shift+V
```

---

## 使用相关

### Q10: 无法录音/"无法打开麦克风"

**A**:

**步骤1：检查麦克风硬件**
```bash
# 列出音频设备
arecord -l

# 测试录音
arecord -d 5 test.wav
aplay test.wav
```

**步骤2：检查权限**
```bash
# 查看音频组
groups

# 如果没有audio组，添加用户
sudo usermod -aG audio $USER
# 需要重新登录生效
```

**步骤3：检查PulseAudio**
```bash
# 重启PulseAudio
pulseaudio --kill
pulseaudio --start

# 或使用图形界面
pavucontrol
```

### Q11: 识别结果无法粘贴

**A**:

**原因**: xclip未安装或剪贴板问题

**解决**:
```bash
# 安装xclip
sudo apt install xclip

# 测试剪贴板
echo "测试" | xclip -selection clipboard
xclip -selection clipboard -o
# 应输出"测试"

# 如果使用Wayland
sudo apt install wl-clipboard
```

### Q12: 识别准确率低，经常识别错误

**A**:

**提高准确率的方法：**

1. **环境优化**
   - 在安静的环境使用
   - 关闭风扇、空调等噪音源
   - 使用指向性麦克风

2. **说话技巧**
   - 吐字清晰
   - 速度适中（不要太快或太慢）
   - 避免方言，使用普通话
   - 避免口头禅（嗯、啊等）

3. **技术调整**
   - 讯飞云：检查网络连接
   - 离线Whisper：升级模型（tiny → base → small）
   - 调整麦克风增益（不要过高，避免失真）

4. **切换方案**
   - 如果离线识别不准，切换到讯飞云
   - 如果讯飞云不准，检查网络或API配额

### Q13: 如何添加自定义词汇？

**A**:

**讯飞云方案：**
1. 登录讯飞控制台：https://console.xfyun.cn/
2. 进入"语音听写（流式）"服务
3. 服务管理 → 个性化热词
4. 添加专业词汇、人名、地名等

**离线Whisper方案：**
目前不支持自定义词汇，由模型自动识别。

---

## 性能相关

### Q14: 离线识别很慢（超过10秒）

**A**:

**原因**: CPU性能不足，模型太大

**解决方案：**

1. **换用更小的模型**
   ```bash
   # 编辑脚本
   nano ~/bin/tools/voice_input/local/voice_input.py

   # 修改这一行
   model = whisper.load_model("tiny")  # 改为 tiny
   ```

2. **关闭其他程序**
   - 识别时关闭浏览器、IDE等占用CPU的程序

3. **性能对比**
   | 模型 | 准确率 | 速度（4核CPU） |
   |------|--------|---------------|
   | tiny | ~80% | 2-3秒 |
   | base | ~85% | 4-5秒 |
   | small | ~90% | 8-12秒 |
   | medium | ~95% | 20-30秒 |

### Q15: 讯飞云识别延迟高

**A**:

**检查网络**:
```bash
# 测试延迟
ping api.xfyun.cn

# 测试下载速度
wget -O /dev/null http://speedtest.tele2.net/10MB.zip
```

**解决方案：**
- 切换到更稳定的网络
- 使用有线连接代替WiFi
- 检查是否使用了VPN/代理

### Q16: 系统卡顿/CPU占用过高

**A**:

**离线方案：**
```bash
# 使用top查看CPU占用
top

# 降低优先级
nice -n 10 ~/bin/tools/voice_input/local/voice_input.py
```

**讯飞云方案：**
- 通常不会导致卡顿
- 如果卡顿，检查是否有其他程序占用资源

---

## 讯飞云方案

### Q17: 如何获取API密钥？

**A**:

1. 注册账号：https://www.xfyun.cn/
2. 登录控制台：https://console.xfyun.cn/
3. 创建应用
4. 开通"语音听写（流式版）"服务
5. 获取 APPID、APISecret、APIKey

详细步骤见：[docs/XFYUN.md](XFYUN.md)

### Q18: 连接失败，错误代码10105

**A**:

**原因**: API密钥错误

**解决**:
```bash
# 检查配置文件
cat ~/bin/tools/voice_input/xfyun/config.ini

# 确认：
# 1. APPID、APISecret、APIKey 是否正确
# 2. 没有多余的空格
# 3. 没有引号

# 重新配置
cd ~/bin/tools/voice_input/xfyun
./setup_xfyun.sh
```

### Q19: 错误代码11200，授权失败

**A**:

**原因**: IP白名单限制

**解决**:
1. 登录讯飞控制台
2. 进入应用设置
3. IP白名单 → 添加 `0.0.0.0/0`（允许所有IP）
4. 或添加你的公网IP

### Q20: 免费额度够用吗？会收费吗？

**A**:

**免费额度：**
- 每天 500 次调用
- 每次最长 60 秒
- 对个人用户完全够用

**计费说明：**
- 超过免费额度后才收费
- 收费标准：约 0.0025元/次
- 即使收费，成本也极低

**监控用量：**
```
控制台 → 用量统计
```

### Q21: 识别结果重复/乱码

**A**:

**已在最新版本修复**

如果仍有问题：
```bash
# 更新代码
cd ~/bin/tools/voice_input
git pull

# 重新测试
cd xfyun
./voice_input_xfyun.py
```

---

## 离线Whisper方案

### Q22: 首次使用很慢，一直在下载

**A**:

**正常现象**

首次使用会自动下载模型：
- tiny: 约 75MB
- base: 约 145MB
- small: 约 488MB
- medium: 约 1.5GB

下载完成后会自动缓存，以后就很快了。

缓存位置：`~/.cache/whisper/`

### Q23: 模型下载失败

**A**:

**手动下载：**

1. 访问：https://github.com/openai/whisper/blob/main/whisper/__init__.py
2. 找到模型URL
3. 手动下载到 `~/.cache/whisper/`

或使用国内镜像：
```bash
# 使用镜像站下载
wget https://mirror.ghproxy.com/https://github.com/openai/whisper/...
```

### Q24: 识别没有标点符号

**A**:

**正常现象**

Whisper 离线模型不支持自动添加标点。

**解决方案：**
- 切换到讯飞云方案（自动带标点）
- 手动添加标点
- 使用第三方标点恢复工具

### Q25: 只能识别10秒？

**A**:

**是的，当前设计如此**

**原因：**
- 避免内存占用过高
- 实时性考虑

**如需长文本：**
- 使用讯飞云方案（无时长限制）
- 或分段录音，多次识别

---

## 其他问题

### Q26: 支持英文识别吗？

**A**:

**Whisper支持：**
```python
# 修改脚本指定英文
model = whisper.load_model("base")
result = model.transcribe("audio.wav", language="en")
```

**讯飞云：**
- 需要在控制台切换语言为英文
- 或使用讯飞的英文识别服务

### Q27: 支持方言吗？

**A**:

**讯飞云：**
- 支持多种方言（粤语、四川话、东北话等）
- 在控制台"识别语种列表"中添加

**Whisper：**
- 主要支持普通话
- 方言识别效果较差

### Q28: 可以在服务器上使用吗（无桌面）？

**A**:

可以，但需要修改：

1. **去掉xclip依赖**（服务器无剪贴板）
2. **去掉快捷键**（无桌面环境）
3. **直接输出到文件**

```python
# 修改为直接保存
with open("result.txt", "w") as f:
    f.write(result_text)
```

### Q29: 如何贡献代码？

**A**:

1. Fork项目
2. 创建特性分支：`git checkout -b feature/xxx`
3. 提交代码：`git commit -am 'Add xxx'`
4. 推送分支：`git push origin feature/xxx`
5. 提交Pull Request

详见：CONTRIBUTING.md（待添加）

### Q30: 项目未来计划？

**A**:

查看 [CHANGELOG.md](../CHANGELOG.md) 的"未来计划"部分。

主要包括：
- 图形化界面
- 更多桌面环境支持
- 浏览器插件
- 自动降级
- 识别历史记录

---

## 🐛 问题未解决？

如果以上FAQ没有解决你的问题：

1. **查看详细文档**
   - [README.md](../README.md)
   - [docs/LOCAL.md](LOCAL.md)
   - [docs/XFYUN.md](XFYUN.md)

2. **提交Issue**
   - [GitHub Issues](https://github.com/MuyaoWorkshop/linux-voice-input/issues)
   - [Gitee Issues](https://gitee.com/muyaoworkshop/linux-voice-input/issues)

3. **提交时请包含**
   - 操作系统和版本
   - Python版本
   - 完整的错误信息
   - 复现步骤
   - 已尝试的解决方法

---

**最后更新**: 2025-12-22
