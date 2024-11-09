# 打印菜单
call_menu() {
    echo ' set wallpaper'
    echo '艹 update statusbar'
    # [ "$(sudo docker ps | grep v2raya)" ] && echo ' close v2raya' || echo ' open v2raya'
    [ "$(docker ps | grep windows)" ] && echo '󰖳 shutdown windows' || echo '󰖳 open windows'
    [ "$(ps aux | grep picom | grep -v 'grep\|rofi\|nvim')" ] && echo ' close picom' || echo ' open picom'
}

# 执行菜单
execute_menu() {
    case $1 in
    ' set wallpaper')
        feh --randomize --bg-fill ~/Pictures/wallpaper/*.png
        ;;
    '艹 update statusbar')
        coproc (/home/seeker/Develop/dwm/statusbar/statusbar.sh updateall >/dev/null 2>&1)
        ;;
    # ' open v2raya')
    #     coproc (sudo docker restart v2raya > /dev/null && /home/seeker/Develop/dwm/statusbar/statusbar.sh updateall > /dev/null)
    #     ;;
    # ' close v2raya')
    #     coproc (sudo docker stop v2raya > /dev/null && /home/seeker/Develop/dwm/statusbar/statusbar.sh updateall > /dev/null)
    #     ;;
    '󰖳 open windows')
        docker start 5880dec702c4
        ;;
    '󰖳 shutdown windows')
        docker stop 5880dec702c4
        ;;
    ' open picom')
        coproc (picom --experimental-backends --config $DWM_SCRIPTS_DIR/conf/picom.conf >/dev/null 2>&1)
        ;;
    ' close picom')
        pkill -f picom
        ;;
    esac
}

execute_menu "$(call_menu | rofi -dmenu -p "")"
