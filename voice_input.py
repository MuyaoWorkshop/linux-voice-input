#!/usr/bin/env python3
"""
语音输入工具 - 基于 OpenAI Whisper 离线识别

三种运行模式:
  python voice_input.py          # 普通模式 (4-5秒启动)
  python voice_input.py --daemon # 守护进程模式 (常驻后台)
  python voice_input.py --trigger # 触发守护进程 (<0.5秒启动)

快捷键建议: Super+V
"""

import whisper
import pyaudio
import wave
import tempfile
import os
import subprocess
import sys
import time
import numpy as np
import socket
import json
import signal
import select
import argparse

# 尝试导入 Tkinter
USE_TKINTER = False
try:
    import tkinter as tk
    from tkinter import ttk
    USE_TKINTER = True
except ImportError:
    USE_TKINTER = False

# 尝试导入 OpenCC 用于繁简转换
try:
    from opencc import OpenCC
    OPENCC_AVAILABLE = True
except ImportError:
    OPENCC_AVAILABLE = False

# ========== 配置参数 ==========
WHISPER_MODEL = "base"  # 可选: tiny, base, small, medium, large
LANGUAGE = "zh"         # 中文识别
SAMPLE_RATE = 16000     # 采样率
CHANNELS = 1            # 单声道
CHUNK = 1024            # 音频块大小
RECORD_SECONDS = 60     # 最长录音时长（秒）
SILENCE_THRESHOLD = 800 # 静音阈值（普通模式）
SILENCE_THRESHOLD_DAEMON = 600  # 静音阈值（守护进程模式）
SILENCE_DURATION = 2.0  # 静音持续时间（秒）判定为结束

# Socket 配置
SOCKET_PATH = "/tmp/voice_input_daemon.sock"

# UI 配置常量
WINDOW_WIDTH = 700
WINDOW_HEIGHT = 300
WINDOW_HEIGHT_BORDERLESS = 280
FONT_FAMILY = "Helvetica"
FONT_SIZE_TITLE = 16
FONT_SIZE_VOLUME = 11
FONT_SIZE_TEXT = 12
FONT_SIZE_TIP = 10
COLOR_BG = '#f8f8f8'
COLOR_BORDER = '#d0d0d0'
COLOR_TEXT_PRIMARY = '#1d1d1f'
COLOR_TEXT_SECONDARY = '#86868b'
COLOR_SUCCESS = '#34c759'
COLOR_ERROR = '#ff3b30'
COLOR_PROGRESS_BG = '#e5e5e7'
VOLUME_BAR_LENGTH = 500
VOLUME_BAR_THICKNESS = 18
AUTO_CLOSE_DELAY = 1000  # 窗口自动关闭延迟（毫秒）


# ========== UI 组件 ==========
class VoiceInputUI:
    """语音输入 UI 界面（自动选择 Tkinter 或终端模式）"""

    def __init__(self, mode="auto", title="语音输入", borderless=False, stop_callback=None):
        self.title = title
        self.borderless = borderless
        self.stop_callback = stop_callback

        # 支持环境变量控制 UI 模式
        env_mode = os.getenv('VOICE_INPUT_UI_MODE', '').lower()
        if env_mode in ['gui', 'terminal']:
            mode = env_mode

        # 自动选择模式
        if mode == "auto":
            self.mode = "gui" if USE_TKINTER else "terminal"
        elif mode == "gui" and not USE_TKINTER:
            print("⚠️  Tkinter 不可用，降级为终端模式")
            self.mode = "terminal"
        else:
            self.mode = mode

        # 初始化对应的 UI
        if self.mode == "gui":
            self._init_gui()
        else:
            self._init_terminal()

    def _init_gui(self):
        """初始化 Tkinter GUI"""
        self.root = tk.Tk()
        self.root.title(f"🎤 {self.title}")

        # 窗口设置
        self.root.attributes('-topmost', True)
        self.root.resizable(False, False)

        # 无边框模式
        if self.borderless:
            self.root.overrideredirect(True)
            self.root.configure(bg=COLOR_BORDER)

        # 居中显示
        window_width = WINDOW_WIDTH
        window_height = WINDOW_HEIGHT if not self.borderless else WINDOW_HEIGHT_BORDERLESS
        screen_width = self.root.winfo_screenwidth()
        screen_height = self.root.winfo_screenheight()
        x = (screen_width - window_width) // 2
        y = (screen_height - window_height) // 2
        self.root.geometry(f"{window_width}x{window_height}+{x}+{y}")

        # 强制获取焦点
        self.root.update()
        self.root.lift()
        self.root.focus_force()

        # 绑定 Esc 键停止录音
        if self.stop_callback:
            self.root.bind('<Escape>', lambda e: self.stop_callback())
            self.root.bind('<Control-c>', lambda e: self.stop_callback())

        # 设置样式
        style = ttk.Style()
        style.theme_use('clam')

        # 创建内容容器
        if self.borderless:
            content_frame = tk.Frame(self.root, bg=COLOR_BG, highlightthickness=0)
            content_frame.pack(fill=tk.BOTH, expand=True, padx=2, pady=2)
            parent = content_frame
        else:
            parent = self.root
            self.root.configure(bg=COLOR_BG)

        # 状态标签
        self.status_label = tk.Label(
            parent,
            text="🎤 正在录音...",
            font=(FONT_FAMILY, FONT_SIZE_TITLE),
            fg=COLOR_TEXT_PRIMARY,
            bg=COLOR_BG,
            wraplength=660,
            justify=tk.CENTER
        )
        self.status_label.pack(pady=18)

        # 音量条容器
        volume_frame = tk.Frame(parent, bg=COLOR_BG)
        volume_frame.pack(pady=14)

        tk.Label(
            volume_frame,
            text="音量",
            font=(FONT_FAMILY, FONT_SIZE_VOLUME),
            fg=COLOR_TEXT_SECONDARY,
            bg=COLOR_BG,
            width=4
        ).pack(side=tk.LEFT, padx=(20, 10))

        # 音量进度条
        self.volume_bar = ttk.Progressbar(
            volume_frame,
            length=VOLUME_BAR_LENGTH,
            mode='determinate',
            style='Apple.Horizontal.TProgressbar'
        )
        self.volume_bar.pack(side=tk.LEFT, padx=10)

        # 配置进度条样式
        style.configure(
            'Apple.Horizontal.TProgressbar',
            troughcolor=COLOR_PROGRESS_BG,
            background=COLOR_SUCCESS,
            borderwidth=0,
            thickness=VOLUME_BAR_THICKNESS
        )

        # 百分比标签
        self.volume_label = tk.Label(
            volume_frame,
            text="0%",
            font=(FONT_FAMILY, FONT_SIZE_VOLUME),
            width=8,
            anchor=tk.W,
            fg=COLOR_SUCCESS,
            bg=COLOR_BG
        )
        self.volume_label.pack(side=tk.LEFT, padx=(10, 25))

        # 识别文本
        self.text_label = tk.Label(
            parent,
            text="",
            font=(FONT_FAMILY, FONT_SIZE_TEXT),
            wraplength=660,
            fg=COLOR_TEXT_PRIMARY,
            bg=COLOR_BG,
            justify=tk.CENTER
        )
        self.text_label.pack(pady=14)

        # 提示文本
        tip_text = "按 Esc 或 Ctrl+C 停止录音" if self.stop_callback else "按 Ctrl+C 停止录音"
        self.tip_label = tk.Label(
            parent,
            text=tip_text,
            font=(FONT_FAMILY, FONT_SIZE_TIP),
            fg=COLOR_TEXT_SECONDARY,
            bg=COLOR_BG
        )
        self.tip_label.pack(pady=10)

        # 窗口关闭时的处理
        self.root.protocol("WM_DELETE_WINDOW", self._on_close)

    def _init_terminal(self):
        """初始化终端模式"""
        print(f"🎤 {self.title}")
        print("=" * 50)

    def update_volume(self, volume):
        """更新音量显示"""
        if self.mode == "gui":
            try:
                self.volume_bar['value'] = volume
                self.volume_label.config(text=f"{int(volume)}%")
                self.root.update()
            except:
                pass
        else:
            bar_length = 30
            filled = int(volume / 100 * bar_length)
            bar = "▓" * filled + "░" * (bar_length - filled)
            print(f"\r音量: {bar} {int(volume):3d}%", end="", flush=True)

    def update_text(self, text):
        """更新识别文本"""
        if self.mode == "gui":
            try:
                self.text_label.config(text=text)
                self.root.update()
            except:
                pass
        else:
            print(f"\n识别中: {text}")

    def show_status(self, status, color=None):
        """显示状态信息"""
        if self.mode == "gui":
            try:
                self.status_label.config(text=status)
                if color:
                    self.status_label.config(fg=color)
                self.root.update()
            except:
                pass
        else:
            print(f"\n{status}")

    def show_result(self, text, success=True):
        """显示最终结果"""
        if self.mode == "gui":
            try:
                if success:
                    self.status_label.config(text="✅ 识别完成", fg=COLOR_SUCCESS)
                    self.text_label.config(text=text, fg=COLOR_TEXT_PRIMARY)
                else:
                    self.status_label.config(text="❌ 识别失败", fg=COLOR_ERROR)
                    self.text_label.config(text=text, fg=COLOR_ERROR)

                delay_seconds = AUTO_CLOSE_DELAY / 1000
                self.tip_label.config(text=f"窗口将在 {delay_seconds:.0f} 秒后自动关闭...", fg=COLOR_TEXT_SECONDARY)
                self.root.update()

                # 自动关闭
                self.root.after(AUTO_CLOSE_DELAY, self.close)
            except:
                pass
        else:
            if success:
                print(f"\n\n✅ 识别完成\n结果: {text}")
            else:
                print(f"\n\n❌ 识别失败\n错误: {text}")

    def show_error(self, error_msg):
        """显示错误信息"""
        self.show_result(error_msg, success=False)

    def _on_close(self):
        """窗口关闭时的处理"""
        try:
            self.root.quit()
            self.root.destroy()
        except:
            pass
        os._exit(0)

    def close(self):
        """关闭 UI"""
        if self.mode == "gui":
            try:
                self.root.quit()
                self.root.destroy()
            except:
                pass
        else:
            print("\n" + "=" * 50)


# ========== 普通模式 ==========
class VoiceInputNormal:
    """普通模式 - 每次启动时加载模型"""

    def __init__(self):
        # 创建 UI
        self.ui = VoiceInputUI(mode="auto", title="语音输入 (离线)", borderless=True)

        self.ui.show_status("⏳ 正在加载模型...")
        print("正在加载 Whisper 模型...")
        self.model = whisper.load_model(WHISPER_MODEL)
        print(f"模型加载完成: {WHISPER_MODEL}")

        # 初始化繁简转换器
        if OPENCC_AVAILABLE:
            self.cc = OpenCC('t2s')
            print("繁简转换: 已启用")
        else:
            self.cc = None

        self.ui.show_status("🎤 正在录音...")

    def record_audio(self, filename):
        """录制音频，检测静音自动停止"""
        audio = pyaudio.PyAudio()

        stream = audio.open(
            format=pyaudio.paInt16,
            channels=CHANNELS,
            rate=SAMPLE_RATE,
            input=True,
            frames_per_buffer=CHUNK
        )

        print(f"\n🎤 开始录音... (说话后停顿{SILENCE_DURATION}秒自动结束，最长{RECORD_SECONDS}秒)")

        frames = []
        silent_chunks = 0
        max_silent_chunks = int(SILENCE_DURATION * SAMPLE_RATE / CHUNK)
        started_speaking = False

        for i in range(0, int(SAMPLE_RATE / CHUNK * RECORD_SECONDS)):
            data = stream.read(CHUNK)
            frames.append(data)

            audio_data = np.frombuffer(data, dtype=np.int16)
            volume = np.abs(audio_data).mean()

            # 更新 UI 音量显示
            volume_percent = min(100, (volume / 3000) * 100)
            self.ui.update_volume(volume_percent)

            if volume > SILENCE_THRESHOLD:
                if not started_speaking:
                    print("\n✓ 检测到声音，开始记录...")
                    self.ui.show_status("🎤 正在录音... (检测到声音)")
                    started_speaking = True
                silent_chunks = 0
                print(".", end="", flush=True)
            elif started_speaking:
                silent_chunks += 1
                remaining = max(0, SILENCE_DURATION - (silent_chunks * CHUNK / SAMPLE_RATE))
                if remaining > 0:
                    self.ui.show_status(f"🎤 录音中... (静音 {remaining:.1f}s 后结束)")

            if started_speaking and silent_chunks > max_silent_chunks:
                print(f"\n✓ 检测到 {SILENCE_DURATION} 秒静音，停止录音")
                self.ui.show_status("✓ 录音结束")
                break

        if not started_speaking:
            print("\n录音结束（未检测到声音）")
        else:
            print("\n录音结束")

        stream.stop_stream()
        stream.close()
        audio.terminate()

        # 保存为 WAV 文件
        wf = wave.open(filename, 'wb')
        wf.setnchannels(CHANNELS)
        wf.setsampwidth(audio.get_sample_size(pyaudio.paInt16))
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(b''.join(frames))
        wf.close()

    def transcribe(self, audio_file):
        """使用 Whisper 转录音频"""
        self.ui.show_status("⏳ 正在识别...")
        print("\n⏳ 正在识别...")
        start_time = time.time()

        result = self.model.transcribe(
            audio_file,
            language=LANGUAGE,
            fp16=False
        )
        text = result["text"].strip()

        # 繁体转简体
        if self.cc and text:
            text = self.cc.convert(text)

        elapsed = time.time() - start_time
        print(f"✓ 识别完成 (耗时 {elapsed:.1f} 秒)")

        return text

    def copy_to_clipboard(self, text):
        """将文字复制到剪贴板"""
        if not text:
            print("未识别到文字")
            self.ui.show_result("未识别到文字", success=False)
            return False

        print(f"\n识别结果: {text}")

        try:
            process = subprocess.Popen(['xclip', '-selection', 'clipboard'],
                                      stdin=subprocess.PIPE)
            process.communicate(input=text.encode('utf-8'))
            print("\n✓ 已复制到剪贴板，可使用 Ctrl+V 粘贴")
            self.ui.show_result(f"{text}\n\n已复制到剪贴板", success=True)
            return True
        except FileNotFoundError:
            error_msg = "未找到 xclip 命令\n请安装: sudo apt install xclip"
            print(f"❌ 错误: {error_msg}", file=sys.stderr)
            self.ui.show_error(error_msg)
            return False
        except Exception as e:
            error_msg = f"复制失败: {e}"
            print(f"❌ {error_msg}", file=sys.stderr)
            self.ui.show_error(error_msg)
            return False

    def run(self):
        """主流程"""
        with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as tmp_file:
            audio_file = tmp_file.name

        total_start = time.time()

        try:
            # 1. 录音
            self.record_audio(audio_file)

            # 2. 识别
            text = self.transcribe(audio_file)

            # 3. 复制到剪贴板
            self.copy_to_clipboard(text)

            # 显示总耗时
            total_elapsed = time.time() - total_start
            print(f"\n⏱️  总耗时: {total_elapsed:.1f} 秒")

            time.sleep(1)

        except KeyboardInterrupt:
            print("\n\n用户取消")
            self.ui.show_error("用户取消")
            time.sleep(1)
        except Exception as e:
            error_msg = f"发生错误: {e}"
            print(f"\n❌ {error_msg}", file=sys.stderr)
            self.ui.show_error(error_msg)
            time.sleep(2)
        finally:
            if os.path.exists(audio_file):
                os.remove(audio_file)
            self.ui.close()


# ========== 守护进程模式 ==========
class VoiceInputDaemon:
    """守护进程模式 - 常驻后台，快速响应"""

    def __init__(self):
        print("🚀 启动语音输入守护进程...")
        print(f"⏳ 正在加载 Whisper 模型 ({WHISPER_MODEL})...")
        start_time = time.time()

        self.model = whisper.load_model(WHISPER_MODEL)
        elapsed = time.time() - start_time
        print(f"✓ 模型加载完成 (耗时 {elapsed:.1f} 秒)")

        # 初始化繁简转换器
        if OPENCC_AVAILABLE:
            self.cc = OpenCC('t2s')
            print("✓ 繁简转换: 已启用")
        else:
            self.cc = None
            print("⚠ 繁简转换: 未启用")

        self.socket = None
        self.running = True

        print(f"✓ 守护进程就绪，等待录音请求...")
        print(f"   Socket: {SOCKET_PATH}")

    def record_audio(self, filename, status_conn=None):
        """录制音频，检测静音自动停止"""
        audio = pyaudio.PyAudio()

        stream = audio.open(
            format=pyaudio.paInt16,
            channels=CHANNELS,
            rate=SAMPLE_RATE,
            input=True,
            frames_per_buffer=CHUNK
        )

        print(f"\n🎤 开始录音... (停顿{SILENCE_DURATION}秒自动结束，最长{RECORD_SECONDS}秒)")

        frames = []
        silent_chunks = 0
        max_silent_chunks = int(SILENCE_DURATION * SAMPLE_RATE / CHUNK)
        started_speaking = False

        for i in range(0, int(SAMPLE_RATE / CHUNK * RECORD_SECONDS)):
            data = stream.read(CHUNK)
            frames.append(data)

            audio_data = np.frombuffer(data, dtype=np.int16)
            volume = np.abs(audio_data).mean()

            if volume > SILENCE_THRESHOLD_DAEMON:
                if not started_speaking:
                    print("✓ 检测到声音，开始记录...")
                    started_speaking = True
                    if status_conn:
                        self.send_status(status_conn, "speaking", "✓ 检测到声音，开始记录...")
                silent_chunks = 0
                print(".", end="", flush=True)

                # 实时发送音量状态
                if status_conn and i % 10 == 0:
                    volume_percent = min(100, int(volume / 50))
                    self.send_status(status_conn, "recording_active", f"volume:{volume_percent}")

            elif started_speaking:
                silent_chunks += 1
                if status_conn and silent_chunks % 5 == 0:
                    remaining = SILENCE_DURATION - (silent_chunks * CHUNK / SAMPLE_RATE)
                    if remaining > 0:
                        self.send_status(status_conn, "recording_silence", f"silence:{remaining:.1f}")

            if started_speaking and silent_chunks > max_silent_chunks:
                print(f"\n✓ 检测到 {SILENCE_DURATION} 秒静音，停止录音")
                if status_conn:
                    self.send_status(status_conn, "recording_stopped", f"✓ 检测到 {SILENCE_DURATION} 秒静音，停止录音")
                break

        if not started_speaking:
            print("\n录音结束（未检测到声音）")
        else:
            print("\n录音结束")

        stream.stop_stream()
        stream.close()
        audio.terminate()

        # 保存为 WAV 文件
        wf = wave.open(filename, 'wb')
        wf.setnchannels(CHANNELS)
        wf.setsampwidth(audio.get_sample_size(pyaudio.paInt16))
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(b''.join(frames))
        wf.close()

    def transcribe(self, audio_file):
        """使用 Whisper 转录音频"""
        print("\n⏳ 正在识别...")
        start_time = time.time()

        result = self.model.transcribe(
            audio_file,
            language=LANGUAGE,
            fp16=False
        )
        text = result["text"].strip()

        # 繁体转简体
        if self.cc and text:
            text = self.cc.convert(text)

        elapsed = time.time() - start_time
        print(f"✓ 识别完成 (耗时 {elapsed:.1f} 秒)")

        return text

    def copy_to_clipboard(self, text):
        """将文字复制到剪贴板"""
        if not text:
            print("未识别到文字")
            return False

        print(f"\n识别结果: {text}")

        try:
            process = subprocess.Popen(['xclip', '-selection', 'clipboard'],
                                      stdin=subprocess.PIPE)
            process.communicate(input=text.encode('utf-8'))
            print("\n✓ 已复制到剪贴板，可使用 Ctrl+V 粘贴")
            return True
        except FileNotFoundError:
            print("❌ 错误: 未找到 xclip 命令", file=sys.stderr)
            return False
        except Exception as e:
            print(f"❌ 复制失败: {e}", file=sys.stderr)
            return False

    def send_status(self, conn, status, message=""):
        """向客户端发送状态更新"""
        try:
            data = json.dumps({"status": status, "message": message}) + "\n"
            conn.sendall(data.encode('utf-8'))
        except:
            pass

    def handle_request(self, conn):
        """处理一次录音请求"""
        with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as tmp_file:
            audio_file = tmp_file.name

        total_start = time.time()

        try:
            # 1. 录音
            self.send_status(conn, "recording", f"🎤 开始录音...")
            self.record_audio(audio_file, status_conn=conn)

            # 2. 识别
            self.send_status(conn, "recognizing", "⏳ 正在识别...")
            text = self.transcribe(audio_file)

            # 3. 复制到剪贴板
            if text:
                self.send_status(conn, "copying", f"📋 识别结果: {text}")
                self.copy_to_clipboard(text)

                total_elapsed = time.time() - total_start
                self.send_status(conn, "done", f"✓ 完成！总耗时: {total_elapsed:.1f}秒")
            else:
                self.send_status(conn, "done", "⚠️ 未识别到文字")

            return True
        except Exception as e:
            self.send_status(conn, "error", f"❌ 错误: {e}")
            print(f"\n❌ 处理请求失败: {e}", file=sys.stderr)
            return False
        finally:
            if os.path.exists(audio_file):
                os.remove(audio_file)

    def start_server(self):
        """启动 Socket 服务器"""
        # 清理旧的 socket 文件
        if os.path.exists(SOCKET_PATH):
            os.remove(SOCKET_PATH)

        # 创建 Unix Domain Socket
        self.socket = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.socket.bind(SOCKET_PATH)
        self.socket.listen(1)

        # 设置文件权限
        os.chmod(SOCKET_PATH, 0o600)

        print(f"✓ Socket 服务器已启动")
        print(f"✓ 守护进程运行中，按 Ctrl+C 退出\n")

        while self.running:
            try:
                # 使用 select 等待连接
                readable, _, _ = select.select([self.socket], [], [], 1.0)

                if not readable:
                    continue

                conn, addr = self.socket.accept()

                print(f"\n{'='*60}")
                print(f"📥 收到录音请求 ({time.strftime('%H:%M:%S')})")
                print(f"{'='*60}")

                try:
                    self.handle_request(conn)
                finally:
                    try:
                        conn.close()
                    except:
                        pass

                print(f"\n{'='*60}")
                print(f"✓ 请求处理完成，等待下次录音...")
                print(f"{'='*60}\n")

            except KeyboardInterrupt:
                print("\n\n收到中断信号，正在关闭...")
                break
            except Exception as e:
                print(f"\n❌ Socket 错误: {e}", file=sys.stderr)

    def shutdown(self):
        """关闭守护进程"""
        self.running = False
        if self.socket:
            self.socket.close()
        if os.path.exists(SOCKET_PATH):
            os.remove(SOCKET_PATH)
        print("✓ 守护进程已关闭")


# ========== 触发器模式 ==========
def draw_volume_bar(volume_percent):
    """绘制音量条"""
    bar_length = 30
    filled = int(bar_length * volume_percent / 100)
    bar = "█" * filled + "░" * (bar_length - filled)
    return f"🎤 [{bar}] {volume_percent}%"


def trigger_daemon():
    """触发守护进程执行录音"""
    ui = VoiceInputUI(mode="auto", title="语音输入 (快速模式)", borderless=True)

    if not os.path.exists(SOCKET_PATH):
        error_msg = "守护进程未运行\n请先运行: python voice_input.py --daemon"
        print(f"❌ {error_msg}")
        ui.show_error(error_msg)
        time.sleep(2)
        ui.close()
        return False

    try:
        # 连接到守护进程
        ui.show_status("⏳ 连接守护进程...")
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.connect(SOCKET_PATH)

        print("✓ 已连接到守护进程\n")
        ui.show_status("🎤 正在录音...")

        # 发送请求
        sock.sendall(b"RECORD")

        # 接收并显示状态更新
        buffer = ""
        recording_active = False

        while True:
            try:
                data = sock.recv(1024)
                if not data:
                    break

                buffer += data.decode('utf-8')

                # 处理完整的 JSON 行
                while '\n' in buffer:
                    line, buffer = buffer.split('\n', 1)
                    if line.strip():
                        try:
                            status_data = json.loads(line)
                            message = status_data.get('message', '')
                            status = status_data.get('status', '')

                            if status == 'recording_active':
                                if ':' in message:
                                    volume = int(message.split(':')[1])
                                    ui.update_volume(volume)
                                    volume_bar = draw_volume_bar(volume)
                                    print(f"\r{volume_bar}", end="", flush=True)
                                    recording_active = True

                            elif status == 'recording_silence':
                                if ':' in message:
                                    remaining = message.split(':')[1]
                                    ui.show_status(f"🎤 录音中... (静音 {remaining}s 后结束)")
                                    print(f"\r⏸️  静音检测中... 还剩 {remaining} 秒", end="", flush=True)

                            elif status == 'speaking':
                                if recording_active:
                                    print()
                                ui.show_status("🎤 正在录音... (检测到声音)")
                                print(message)
                                recording_active = True

                            elif status == 'recording_stopped':
                                if recording_active:
                                    print()
                                ui.show_status("✓ 录音结束")
                                print(message)
                                recording_active = False

                            elif status in ['recording', 'recognizing', 'copying']:
                                if recording_active:
                                    print()
                                    recording_active = False
                                if status == 'recognizing':
                                    ui.show_status("⏳ 正在识别...")
                                elif status == 'copying':
                                    ui.show_status("✓ 正在复制...")
                                print(message)

                            elif status in ['done', 'error']:
                                if recording_active:
                                    print()
                                print(message)

                                if status == 'done':
                                    ui.show_result(message, success=True)
                                    time.sleep(1)
                                else:
                                    ui.show_error(message)
                                    time.sleep(2)

                                ui.close()
                                sock.close()
                                return status == 'done'

                            else:
                                if message:
                                    print(message)

                        except json.JSONDecodeError:
                            pass

            except socket.timeout:
                continue
            except Exception as e:
                print(f"\n❌ 接收状态时出错: {e}")
                break

        sock.close()
        ui.close()
        return True

    except ConnectionRefusedError:
        error_msg = "无法连接到守护进程\n请检查守护进程是否正在运行"
        print(f"❌ {error_msg}")
        ui.show_error(error_msg)
        time.sleep(2)
        ui.close()
        return False
    except Exception as e:
        error_msg = f"错误: {e}"
        print(f"❌ {error_msg}")
        ui.show_error(error_msg)
        time.sleep(2)
        ui.close()
        return False


# ========== 信号处理 ==========
def signal_handler(signum, frame):
    """处理系统信号"""
    print(f"\n收到信号 {signum}，正在退出...")
    sys.exit(0)


# ========== 主入口 ==========
def main():
    parser = argparse.ArgumentParser(
        description='语音输入工具 - 基于 OpenAI Whisper 离线识别',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
运行模式:
  python voice_input.py          普通模式 (4-5秒启动)
  python voice_input.py --daemon 守护进程模式 (常驻后台)
  python voice_input.py --trigger 触发守护进程 (<0.5秒启动)

快捷键建议: Super+V
        '''
    )

    group = parser.add_mutually_exclusive_group()
    group.add_argument('--daemon', action='store_true',
                      help='启动守护进程模式（常驻后台，预加载模型）')
    group.add_argument('--trigger', action='store_true',
                      help='触发守护进程执行录音（需要先启动守护进程）')

    args = parser.parse_args()

    # 注册信号处理器
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    try:
        if args.daemon:
            # 守护进程模式
            daemon = VoiceInputDaemon()
            try:
                daemon.start_server()
            except Exception as e:
                print(f"\n❌ 守护进程错误: {e}", file=sys.stderr)
                daemon.shutdown()
                sys.exit(1)
            finally:
                daemon.shutdown()

        elif args.trigger:
            # 触发器模式
            success = trigger_daemon()
            sys.exit(0 if success else 1)

        else:
            # 普通模式（默认）
            voice = VoiceInputNormal()
            voice.run()

    except KeyboardInterrupt:
        print("\n\n用户取消")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ 错误: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
