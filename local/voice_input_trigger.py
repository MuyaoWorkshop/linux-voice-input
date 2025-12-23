#!/usr/bin/env python3
"""
语音输入触发器 - 发送录音请求给守护进程
快捷键调用此脚本，实现快速启动
"""

import socket
import sys
import os
import json

SOCKET_PATH = "/tmp/voice_input_daemon.sock"

def draw_volume_bar(volume_percent):
    """绘制音量条"""
    bar_length = 30
    filled = int(bar_length * volume_percent / 100)
    bar = "█" * filled + "░" * (bar_length - filled)
    return f"🎤 [{bar}] {volume_percent}%"

def trigger_voice_input():
    """向守护进程发送录音请求，并实时显示状态"""
    if not os.path.exists(SOCKET_PATH):
        print("❌ 守护进程未运行")
        print("   请先启动守护进程：")
        print("   systemctl --user start voice-input-daemon")
        return False

    try:
        # 连接到守护进程
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.connect(SOCKET_PATH)

        print("✓ 已连接到守护进程\n")

        # 发送请求
        sock.sendall(b"RECORD")

        # 接收并显示状态更新
        buffer = ""
        recording_active = False

        while True:
            try:
                # 接收数据
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

                            # 根据不同状态显示不同效果
                            if status == 'recording_active':
                                # 实时音量显示
                                if ':' in message:
                                    volume = int(message.split(':')[1])
                                    volume_bar = draw_volume_bar(volume)
                                    print(f"\r{volume_bar}", end="", flush=True)
                                    recording_active = True

                            elif status == 'recording_silence':
                                # 静音倒计时
                                if ':' in message:
                                    remaining = message.split(':')[1]
                                    print(f"\r⏸️  静音检测中... 还剩 {remaining} 秒", end="", flush=True)

                            elif status == 'speaking':
                                # 开始说话
                                if recording_active:
                                    print()  # 换行
                                print(message)
                                recording_active = True

                            elif status == 'recording_stopped':
                                # 录音停止
                                if recording_active:
                                    print()  # 换行
                                print(message)
                                recording_active = False

                            elif status in ['recording', 'recognizing', 'copying']:
                                # 阶段切换
                                if recording_active:
                                    print()  # 换行
                                    recording_active = False
                                print(message)

                            elif status in ['done', 'error']:
                                # 完成或错误
                                if recording_active:
                                    print()  # 换行
                                print(message)
                                sock.close()
                                return status == 'done'

                            else:
                                # 其他消息
                                if message:
                                    print(message)

                        except json.JSONDecodeError:
                            pass  # 忽略无效的 JSON

            except socket.timeout:
                continue
            except Exception as e:
                print(f"\n❌ 接收状态时出错: {e}")
                break

        sock.close()
        return True

    except ConnectionRefusedError:
        print("❌ 无法连接到守护进程")
        print("   请检查守护进程是否正在运行")
        return False
    except Exception as e:
        print(f"❌ 错误: {e}")
        return False

if __name__ == "__main__":
    success = trigger_voice_input()
    sys.exit(0 if success else 1)
