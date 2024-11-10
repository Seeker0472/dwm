#!/usr/bin/env bash
# 依赖包： i3lock-color

i3lock \
    --blur 5 \
    --bar-indicator \
    --bar-pos y+h \
    --bar-direction 1 \
    --bar-max-height 50 \
    --bar-base-width 50 \
    --bar-color 00000022 \
    --keyhl-color ffffffcc \
    --bar-periodic-step 50 \
    --bar-step 20 \
    --redraw-thread \
    --clock \
    --force-clock \
    --time-pos x+5:y+h-100 xdotool\
    --time-color ffffffff \
    --time-size 110 \
    --date-pos tx:ty+40 \
    --date-color ffffffff \
    --date-align 1 \
    --time-align 1 \
    --date-size 30 \
    --ringver-color ffffff00 \
    --ringwrong-color ffffff88 \
    --status-pos x+5:y+h-16 \
    --verif-align 1 \
    --wrong-align 1 \
    --verif-color ffffffff \
    --wrong-color ffffffff \
    --modif-pos -50:-50
xdotool mousemove_relative 1 1 # 该命令用于解决自动锁屏后未展示锁屏界面的问题(移动一下鼠标)
