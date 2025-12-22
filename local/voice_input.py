#!/usr/bin/env python3
"""
语音输入工具 - 基于 OpenAI Whisper
使用麦克风录音，转换为文字后复制到剪贴板
"""

import whisper
import pyaudio
import wave
import tempfile
import os
import subprocess
import sys

# 配置参数
WHISPER_MODEL = "base"  # 可选: tiny, base, small, medium, large
LANGUAGE = "zh"         # 中文识别
SAMPLE_RATE = 16000     # 采样率
CHANNELS = 1            # 单声道
CHUNK = 1024            # 音频块大小
RECORD_SECONDS = 10     # 最长录音时长（秒）
SILENCE_THRESHOLD = 500 # 静音阈值（可调整）
SILENCE_DURATION = 2.0  # 静音持续时间（秒）判定为结束

class VoiceInput:
    def __init__(self):
        print("正在加载 Whisper 模型...")
        self.model = whisper.load_model(WHISPER_MODEL)
        print(f"模型加载完成: {WHISPER_MODEL}")

    def record_audio(self, filename):
        """录制音频，检测静音自动停止"""
        audio = pyaudio.PyAudio()

        # 打开音频流
        stream = audio.open(
            format=pyaudio.paInt16,
            channels=CHANNELS,
            rate=SAMPLE_RATE,
            input=True,
            frames_per_buffer=CHUNK
        )

        print("\n🎤 开始录音... (说话后停顿2秒自动结束)")

        frames = []
        silent_chunks = 0
        max_silent_chunks = int(SILENCE_DURATION * SAMPLE_RATE / CHUNK)
        started_speaking = False

        for i in range(0, int(SAMPLE_RATE / CHUNK * RECORD_SECONDS)):
            data = stream.read(CHUNK)
            frames.append(data)

            # 计算音量
            audio_data = list(data)
            if len(audio_data) > 0:
                volume = sum(abs(b) for b in audio_data) / len(audio_data)

                if volume > SILENCE_THRESHOLD:
                    started_speaking = True
                    silent_chunks = 0
                    print(".", end="", flush=True)
                elif started_speaking:
                    silent_chunks += 1

                # 如果已经开始说话，且静音超过阈值，停止录音
                if started_speaking and silent_chunks > max_silent_chunks:
                    print("\n检测到静音，停止录音")
                    break

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
        print("正在识别...")
        result = self.model.transcribe(
            audio_file,
            language=LANGUAGE,
            fp16=False  # CPU 模式必须设为 False
        )
        return result["text"].strip()

    def copy_to_clipboard(self, text):
        """将文字复制到剪贴板"""
        if not text:
            print("未识别到文字")
            return

        print(f"\n识别结果: {text}")

        try:
            # 将文字复制到剪贴板
            process = subprocess.Popen(['xclip', '-selection', 'clipboard'],
                                      stdin=subprocess.PIPE)
            process.communicate(input=text.encode('utf-8'))
            print("\n✓ 已复制到剪贴板，可使用 Ctrl+V 粘贴")

        except FileNotFoundError:
            print("❌ 错误: 未找到 xclip 命令，请安装: sudo apt install xclip", file=sys.stderr)
        except Exception as e:
            print(f"❌ 复制失败: {e}", file=sys.stderr)

    def run(self):
        """主流程"""
        # 创建临时音频文件
        with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as tmp_file:
            audio_file = tmp_file.name

        try:
            # 1. 录音
            self.record_audio(audio_file)

            # 2. 识别
            text = self.transcribe(audio_file)

            # 3. 复制到剪贴板
            self.copy_to_clipboard(text)

        finally:
            # 清理临时文件
            if os.path.exists(audio_file):
                os.remove(audio_file)

def main():
    try:
        voice_input = VoiceInput()
        voice_input.run()
    except KeyboardInterrupt:
        print("\n\n用户取消")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ 错误: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
