#!/usr/bin/env python3
"""
语音输入工具 - 讯飞云 API 版本
使用讯飞实时语音识别服务，实时转换语音为文字
"""

import pyaudio
import websocket
import json
import base64
import hmac
import hashlib
from urllib.parse import urlencode
from datetime import datetime
from time import mktime
from wsgiref.handlers import format_date_time
import subprocess
import sys
import os
import threading
import configparser
import time

# 配置参数
SAMPLE_RATE = 16000     # 采样率
CHANNELS = 1            # 单声道
CHUNK = 1280            # 音频块大小（讯飞推荐 1280 字节，对应 40ms）
FORMAT = pyaudio.paInt16

# 讯飞 API 配置
STATUS_FIRST_FRAME = 0  # 第一帧标识
STATUS_CONTINUE_FRAME = 1  # 中间帧标识
STATUS_LAST_FRAME = 2   # 最后一帧标识

class XFVoiceInput:
    def __init__(self, appid, api_key, api_secret):
        self.appid = appid
        self.api_key = api_key
        self.api_secret = api_secret

        self.ws = None
        self.audio = None
        self.stream = None
        self.result_text = ""
        self.is_recording = True
        self.end_frame_sent = False  # 标记是否已发送结束帧
        self.is_interrupted = False  # 标记是否被用户中断

    def create_url(self):
        """生成带鉴权的 WebSocket URL"""
        # 生成 RFC1123 格式的时间戳
        now = datetime.now()
        date = format_date_time(mktime(now.timetuple()))

        # 拼接签名原文
        signature_origin = f"host: iat-api.xfyun.cn\n"
        signature_origin += f"date: {date}\n"
        signature_origin += f"GET /v2/iat HTTP/1.1"

        # 使用 hmac-sha256 算法进行加密
        signature_sha = hmac.new(
            self.api_secret.encode('utf-8'),
            signature_origin.encode('utf-8'),
            digestmod=hashlib.sha256
        ).digest()
        signature_sha_base64 = base64.b64encode(signature_sha).decode('utf-8')

        # 构建 authorization
        authorization_origin = f'api_key="{self.api_key}", '
        authorization_origin += f'algorithm="hmac-sha256", '
        authorization_origin += f'headers="host date request-line", '
        authorization_origin += f'signature="{signature_sha_base64}"'
        authorization = base64.b64encode(authorization_origin.encode('utf-8')).decode('utf-8')

        # 构建请求参数
        params = {
            "authorization": authorization,
            "date": date,
            "host": "iat-api.xfyun.cn"
        }

        # 拼接 URL
        url = f"wss://iat-api.xfyun.cn/v2/iat?{urlencode(params)}"
        return url

    def on_message(self, ws, message):
        """接收 WebSocket 消息"""
        try:
            data = json.loads(message)
            code = data['code']

            if code != 0:
                print(f"❌ 错误: {data['message']} (code={code})")
                self.is_recording = False
                ws.close()
                return

            # 解析识别结果（参考官方demo的简单处理方式）
            result = data['data']['result']
            if result:
                ws_list = result['ws']

                # 提取当前这条消息的文本
                current_segment = ""
                for ws_item in ws_list:
                    for cw in ws_item['cw']:
                        current_segment += cw['w']

                # 简单追加（官方demo方式）
                self.result_text += current_segment

                # 实时显示
                print(f"\r识别中: {self.result_text}", end="", flush=True)

            # 检查是否结束
            if data['data']['status'] == 2:
                self.is_recording = False
                self.end_frame_sent = True  # 服务器已结束，不需要再发送结束帧
                # 最后更新一次 result_text 确保完整
                if self.result_text:
                    print(f"\n")  # 换行

        except Exception as e:
            print(f"\n❌ 解析结果出错: {e}")
            self.is_recording = False
            ws.close()

    def on_error(self, ws, error):
        """WebSocket 错误处理"""
        # 忽略用户中断或正常关闭导致的错误
        if self.is_interrupted:
            return

        error_str = str(error) if error else ""
        # 忽略连接关闭相关的错误（这些是正常退出的副作用）
        if error and error_str and "Connection is already closed" not in error_str:
            print(f"\n❌ 连接错误: {error}")
        self.is_recording = False

    def on_close(self, ws, close_status_code, close_msg):
        """WebSocket 关闭"""
        self.is_recording = False

    def on_open(self, ws):
        """WebSocket 连接建立"""
        def run():
            # 发送开始参数
            frame_size = CHUNK
            interval = 0.04  # 40ms
            status = STATUS_FIRST_FRAME

            try:
                # 打开音频流
                self.audio = pyaudio.PyAudio()
                self.stream = self.audio.open(
                    format=FORMAT,
                    channels=CHANNELS,
                    rate=SAMPLE_RATE,
                    input=True,
                    frames_per_buffer=CHUNK
                )

                print("🎤 开始录音... (按 Ctrl+C 停止)\n")

                while self.is_recording:
                    # 读取音频数据
                    audio_data = self.stream.read(CHUNK, exception_on_overflow=False)

                    # 构建发送数据
                    if status == STATUS_FIRST_FRAME:
                        # 第一帧携带参数
                        data = {
                            "common": {"app_id": self.appid},
                            "business": {
                                "language": "zh_cn",
                                "domain": "iat",
                                "accent": "mandarin",
                                "vad_eos": 10000  # 静音超时 10000ms (10秒)
                                # 不使用 wpgs 动态修正，避免重复文本
                            },
                            "data": {
                                "status": STATUS_FIRST_FRAME,
                                "format": "audio/L16;rate=16000",
                                "encoding": "raw",
                                "audio": base64.b64encode(audio_data).decode('utf-8')
                            }
                        }
                        ws.send(json.dumps(data))
                        status = STATUS_CONTINUE_FRAME
                    else:
                        # 中间帧
                        data = {
                            "data": {
                                "status": STATUS_CONTINUE_FRAME,
                                "format": "audio/L16;rate=16000",
                                "encoding": "raw",
                                "audio": base64.b64encode(audio_data).decode('utf-8')
                            }
                        }
                        ws.send(json.dumps(data))

                    # 控制发送速率，匹配音频采集速率 (40ms per chunk)
                    time.sleep(0.04)

            except KeyboardInterrupt:
                print("\n\n用户停止录音")
                self.is_interrupted = True  # 标记为用户中断
            except Exception as e:
                print(f"\n❌ 录音错误: {e}")
            finally:
                # 设置停止标志
                self.is_recording = False

                # 发送结束帧（只发送一次）
                if not self.end_frame_sent:
                    try:
                        data = {
                            "data": {
                                "status": STATUS_LAST_FRAME,
                                "format": "audio/L16;rate=16000",
                                "encoding": "raw",
                                "audio": ""
                            }
                        }
                        ws.send(json.dumps(data))
                        self.end_frame_sent = True
                        # 给服务器一点时间处理结束帧
                        time.sleep(0.2)
                    except Exception:
                        pass  # 连接已关闭，忽略

                # 关闭音频流
                if self.stream:
                    try:
                        self.stream.stop_stream()
                        self.stream.close()
                    except Exception:
                        pass
                if self.audio:
                    try:
                        self.audio.terminate()
                    except Exception:
                        pass

                # 关闭 WebSocket
                try:
                    ws.close()
                except Exception:
                    pass

        # 启动录音线程
        thread = threading.Thread(target=run)
        thread.start()

    def copy_to_clipboard(self, text):
        """将文字复制到剪贴板"""
        if not text:
            print("\n\n未识别到文字")
            return

        print(f"\n\n识别结果: {text}")

        try:
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
        try:
            print("正在连接讯飞语音识别服务...")

            # 创建 WebSocket URL
            url = self.create_url()

            # 创建 WebSocket 连接
            # websocket.enableTrace(True)  # 调试时启用
            self.ws = websocket.WebSocketApp(
                url,
                on_message=self.on_message,
                on_error=self.on_error,
                on_close=self.on_close,
                on_open=self.on_open
            )

            print("✓ 连接成功\n")

            # 运行 WebSocket
            self.ws.run_forever()

            # 复制结果到剪贴板
            self.copy_to_clipboard(self.result_text)

        except KeyboardInterrupt:
            print("\n\n用户取消")
            if self.ws:
                self.ws.close()
        except Exception as e:
            print(f"\n❌ 错误: {e}", file=sys.stderr)
            import traceback
            traceback.print_exc()

def load_config():
    """从配置文件加载 API 密钥"""
    config_file = os.path.join(os.path.dirname(__file__), 'config.ini')

    if not os.path.exists(config_file):
        print("❌ 错误: 配置文件不存在")
        print(f"请创建配置文件: {config_file}")
        print("\n配置文件格式：")
        print("[xfyun]")
        print("APPID = 你的APPID")
        print("APISecret = 你的APISecret")
        print("APIKey = 你的APIKey")
        print("\n请参考 XFYUN_GUIDE.md 获取 API 密钥")
        sys.exit(1)

    config = configparser.ConfigParser()
    config.read(config_file)

    try:
        appid = config.get('xfyun', 'APPID').strip()
        api_secret = config.get('xfyun', 'APISecret').strip()
        api_key = config.get('xfyun', 'APIKey').strip()

        if not appid or not api_secret or not api_key:
            raise ValueError("配置项不能为空")

        return appid, api_secret, api_key

    except Exception as e:
        print(f"❌ 错误: 配置文件格式错误 - {e}")
        print(f"请检查配置文件: {config_file}")
        sys.exit(1)

def main():
    try:
        # 加载配置
        appid, api_secret, api_key = load_config()

        # 创建语音输入实例
        voice_input = XFVoiceInput(appid, api_key, api_secret)

        # 运行
        voice_input.run()

    except KeyboardInterrupt:
        print("\n\n用户取消")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ 错误: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
