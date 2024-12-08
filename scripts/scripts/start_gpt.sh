#!/usr/bin/env bash
#TDOD
cd ~/HomePath/aider
# 启动 kitty 并获取其窗口 ID
kitty --class FGN sh -c 'exec aider --env-file ~/HomePath/aider/.env' &
# sleep 0.2  # 等待窗口启动
# window_id=$(xdotool search --class FGN | head -n 1)

# # 调整窗口大小和位置
# xdotool windowsize "$window_id" 1600 1200  # 设置宽度和高度