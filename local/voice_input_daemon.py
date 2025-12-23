#!/usr/bin/env python3
"""
语音输入守护进程 - 常驻后台，快速响应
预加载 Whisper 模型，通过 Unix Socket 接收录音请求
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
import threading
import json
import signal
import select

# 尝试导入 OpenCC 用于繁简转换
try:
    from opencc import OpenCC
    OPENCC_AVAILABLE = True
except ImportError:
    OPENCC_AVAILABLE = False

# 配置参数
WHISPER_MODEL = "base"  # 可选: tiny, base, small, medium, large
LANGUAGE = "zh"         # 中文识别
SAMPLE_RATE = 16000     # 采样率
CHANNELS = 1            # 单声道
CHUNK = 1024            # 音频块大小
RECORD_SECONDS = 60     # 最长录音时长（秒）
SILENCE_THRESHOLD = 600 # 静音阈值（基于 int16 音量，范围 0-32767）
SILENCE_DURATION = 3.0  # 静音持续时间（秒）判定为结束

# Socket 配置
SOCKET_PATH = "/tmp/voice_input_daemon.sock"

class VoiceInputDaemon:
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

        # 初始化 Socket
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

            # 正确计算音量：将字节流转换为 int16 数组
            audio_data = np.frombuffer(data, dtype=np.int16)
            volume = np.abs(audio_data).mean()

            if volume > SILENCE_THRESHOLD:
                if not started_speaking:
                    print("✓ 检测到声音，开始记录...")
                    started_speaking = True
                    if status_conn:
                        self.send_status(status_conn, "speaking", "✓ 检测到声音，开始记录...")
                silent_chunks = 0
                print(".", end="", flush=True)

                # 实时发送音量状态给客户端（每10个chunk发一次，减少开销）
                if status_conn and i % 10 == 0:
                    # 计算音量百分比（0-100）
                    volume_percent = min(100, int(volume / 50))  # 假设5000为最大音量
                    self.send_status(status_conn, "recording_active", f"volume:{volume_percent}")

            elif started_speaking:
                silent_chunks += 1
                # 发送静音计数
                if status_conn and silent_chunks % 5 == 0:
                    remaining = SILENCE_DURATION - (silent_chunks * CHUNK / SAMPLE_RATE)
                    if remaining > 0:
                        self.send_status(status_conn, "recording_silence", f"silence:{remaining:.1f}")

            # 如果已经开始说话，且静音超过阈值，停止录音
            if started_speaking and silent_chunks > max_silent_chunks:
                print(f"\n✓ 检测到 {SILENCE_DURATION} 秒静音，停止录音")
                if status_conn:
                    self.send_status(status_conn, "recording_stopped", f"✓ 检测到 {SILENCE_DURATION} 秒静音，停止录音")
                break

        if not started_speaking:
            print("\n录音结束（未检测到声音）")
        else:
            print("\n录音结束")

        # 停止并关闭流
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
            fp16=False  # CPU 模式必须设为 False
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
            pass  # 忽略发送失败

    def handle_request(self, conn):
        """处理一次录音请求"""
        with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as tmp_file:
            audio_file = tmp_file.name

        total_start = time.time()

        try:
            # 1. 录音
            self.send_status(conn, "recording", f"🎤 开始录音... (停顿{SILENCE_DURATION}秒自动结束)")
            self.record_audio(audio_file, status_conn=conn)

            # 2. 识别
            self.send_status(conn, "recognizing", "⏳ 正在识别...")
            text = self.transcribe(audio_file)

            # 3. 复制到剪贴板
            if text:
                self.send_status(conn, "copying", f"📋 识别结果: {text}")
                self.copy_to_clipboard(text)

                # 显示总耗时
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
            # 清理临时文件
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

        # 设置文件权限（仅当前用户可访问）
        os.chmod(SOCKET_PATH, 0o600)

        print(f"✓ Socket 服务器已启动")
        print(f"✓ 守护进程运行中，按 Ctrl+C 退出\n")

        while self.running:
            try:
                # 使用 select 等待连接，超时 1 秒以便响应中断信号
                # 这样在没有连接时 CPU 占用接近 0%
                readable, _, _ = select.select([self.socket], [], [], 1.0)

                if not readable:
                    # 超时，没有新连接，继续循环检查 self.running
                    continue

                # 有新连接
                conn, addr = self.socket.accept()

                # 收到连接请求
                print(f"\n{'='*60}")
                print(f"📥 收到录音请求 ({time.strftime('%H:%M:%S')})")
                print(f"{'='*60}")

                # 处理请求（在主线程中处理，避免多个录音请求冲突）
                # 保持连接打开，实时发送状态给客户端
                try:
                    self.handle_request(conn)
                finally:
                    # 处理完成后关闭连接
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

def signal_handler(signum, frame):
    """处理系统信号"""
    print(f"\n收到信号 {signum}，正在退出...")
    sys.exit(0)

def main():
    # 注册信号处理器
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    daemon = VoiceInputDaemon()

    try:
        daemon.start_server()
    except Exception as e:
        print(f"\n❌ 守护进程错误: {e}", file=sys.stderr)
        daemon.shutdown()
        sys.exit(1)
    finally:
        daemon.shutdown()

if __name__ == "__main__":
    main()
