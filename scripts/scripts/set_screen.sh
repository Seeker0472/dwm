#!/usr/bin/env bash
:<<!
  设置屏幕分辨率的脚本(xrandr命令的封装)
  one: 只展示一个内置屏幕 
  two: 左边展示外接屏幕 
  check: 检测显示器连接状态是否变化 变化则自动调整输出情况
!

INNER_PORT=eDP-1
MODE=LR
# [ "$(xrandr | grep '3440x1440')" ] && MODE=H$MODE

__setbg() {
    feh --randomize --bg-fill ~/Pictures/wallpaper/*.png
}

__get_inner_view() {
    case "$MODE" in
        ONE) echo "--output $INNER_PORT --mode 2560x1600 --pos 0x0 --scale 1x1 " ;;
        LR) echo "--output $INNER_PORT --mode 2560x1600 --pos 0x561 --scale 0.999x0.999 " ;;
    esac
}

__get_outer_view() {
    outport=$1
    case "$MODE" in
        LR) echo "--output $outport --scale 1.5x1.5 --mode 2560x1440 --pos 2558x0" ;;
    esac
}

__get_off_views() {
    for sc in $(xrandr | grep 'connected' | awk '{print $1}'); do echo "--output $sc --off "; done
}

one() {
    MODE=ONE
    xrandr $(__get_off_views) $(__get_inner_view)
    __setbg
}

two() {
    OUTPORT_CONNECTED=$(xrandr | grep -v $INNER_PORT | grep -w 'connected' | awk '{print $1}')
    [ ! "$OUTPORT_CONNECTED" ] && one && return
    xrandr $(__get_off_views)
    xrandr $(__get_inner_view) $(__get_outer_view $OUTPORT_CONNECTED)
    __setbg
}

check() {
    CONNECTED_PORTS=$(xrandr | grep -w 'connected' | awk '{print $1}' | wc -l)
    CONNECTED_MONITORS=$(xrandr --listmonitors | sed 1d | awk '{print $4}' | wc -l)
    [ $CONNECTED_PORTS -gt $CONNECTED_MONITORS ] && two
    [ $CONNECTED_PORTS -lt $CONNECTED_MONITORS ] && one
    :
}

case $1 in
    one) one ;;
    two) two ;;
    *) check ;;
esac
