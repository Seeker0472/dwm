#!/usr/bin/env bash

tempfile=$(cd $(dirname $0);cd ..;pwd)/temp

this=_icons
color="^c#2D1B46^^b#5555660x66^"
signal=$(echo "^s$this^" | sed 's/_//')

with_v2raya() {
    [ "$(ps aux | grep -v grep | grep 'v2raya')" ] && icons=(${icons[@]} "󰌆")
}

with_bluetooth() {
    # Bluetooth Mac
    [ ! "$(command -v bluetoothctl)" ] && echo command not found: bluetoothctl && return
    [ "$(bluetoothctl info E9:AA:D7:74:C2:32 | grep 'Connected: yes')" ] && icons=(${icons[@]} "󰦋")
    [ "$(bluetoothctl info 0C:AE:BD:AF:94:55 | grep 'Connected: yes')" ] && icons=(${icons[@]} "󰥰")
}
try_connect(){
    bluetoothctl connect 0C:AE:BD:AF:94:55
}

update() {
    icons=("󰚰")
    with_v2raya
    with_bluetooth

    text=" ${icons[@]} "

    sed -i '/^export '$this'=.*$/d' $tempfile
    printf "export %s='%s%s%s'\n" $this "$signal" "$color" "$text" >> $tempfile
}

notify() {
    texts=""
    [ "$(ps aux | grep -v grep | grep 'v2raya')" ] && texts="$texts\n󱡻 v2raya 已启动"
    [ "$(bluetoothctl info E9:AA:D7:74:C2:32 | grep 'Connected: yes')" ] && texts="$texts\n󰦋 MX590 已链接"
    [ "$(bluetoothctl info D3:06:D1:95:40:6C | grep 'Connected: yes')" ] && texts="$texts\n󰌌 VGN-3 已链接"
    [ "$(bluetoothctl info 0C:AE:BD:AF:94:55 | grep 'Connected: yes')" ] && texts="$texts\n󰥰 W820NB 已链接"
    [ "$texts" != "" ] && notify-send "󱱨 Info" "$texts" -r 9527
}

call_menu() {
    case $(echo -e ' 关机\n 重启\n󰒲 休眠\n 锁定' | rofi -dmenu -window-title power) in
        " 关机") poweroff ;;
        " 重启") reboot ;;
        "󰒲 休眠") systemctl hibernate ;;
        " 锁定") $(cd $(dirname $0);cd ../../;pwd)/blurlock.sh ;;
    esac
}

click() {
    case "$1" in
        L) notify; feh --randomize --bg-fill ~/Pictures/wallpaper/*.png ; try_connect ;;
        R) call_menu ;;
    esac
}

case "$1" in
    click) click $2 ;;
    notify) notify ;;
    *) update ;;
esac
