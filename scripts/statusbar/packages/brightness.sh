#!/usr/bin/env bash

tempfile=/tmp/dwm_bar_temp
configfile=/tmp/dwm_config_temp
touch $configfile
this=_brightness
signal=$(echo "^s$this^" | sed 's/_//')

current_screen=""
brightness_hardware=true
# TODO
icon_color="^c#3B001B^^b#4865660x88^"
# text_color="^c#3B001B^^b#4865660x99^"
text_color=$icon_color
declare -A Cur_Brightness_x
Brightness_laptop=0
Brightness_extern=0
Locked=false
Changed=false
# switch HardWare/Software
hardware_software_switch(){
    get_last_status
    if [ "$brightness_hardware" = "true" ];then
        brightness_hardware=false
        notify-send -r 9528  "Adjusting Software Brightness Using xrandr"
    else
        brightness_hardware=true
        notify-send -r 9528  "Adjusting HardWare Brightness Using ddcutil/brightnessctl"
    fi
    update_last_status $Brightness_extern
}
#get lock
get_lock_status(){
    source $configfile
    Locked=$_locked
    Changed=$_changed
    brightness_hardware=$_brightness_hardware
}

get_ext_brightness(){
    result_ddc=$(ddcutil getvcp 10)
    if [ $? -eq 0 ]; then
        result_ddc=$(echo result_ddc| awk -F'current value = ' '{print $2}' | awk '{print $1}'| sed 's/,//g')
    else
        result_ddc=0
    fi
    Brightness_extern=$result_ddc
}

# 获取当前的各个参数(Slow)
get_current_status(){
    #Wait Unlock
    while true; do
        get_lock_status
        if [ "$Locked" = "true" ]; then
            sleep 1
        else
            break
        fi
    done
    # get data except brightness of Ext display
    get_last_status
    # Brightness_extern=$(ddcutil getvcp 10| awk -F'current value = ' '{print $2}' | awk '{print $1}'| sed 's/,//g')
    get_ext_brightness
}
# get data (Ext display from tempfile)
get_last_status() {
    get_lock_status
    Cur_Brightness_x=()
    Brightness_laptop=$(cat /sys/class/backlight/intel_backlight/brightness)
    _brightness_extern=0
    source $configfile
    Brightness_extern=$(echo "$_brightness_extern" | tr -d '\n')
    brightness_hardware=$_brightness_hardware
    screens=$(xrandr --query | grep " connected")
    while read -r screen; do
        screen_name=$(echo $screen | awk '{print $1}')
        brightness=$(xrandr --verbose --current | grep ^"$screen_name" -A5| tail -n1| awk -F'Brightness: ' '{print $2}')
        Cur_Brightness_x[$screen_name]=$brightness
    done <<< "$screens"
}
#update conf file param is ext brightness
update_last_status() {
    Brightness_extern=0
    # if no parm
    if [[ $# -eq 0 ]]; then
        #等待Unlock
        while true; do
            get_lock_status
            if [ "$Locked" = "true" ]; then
                sleep 1
            else
                break
            fi
        done
        #get Ext brightness
        # Brightness_extern=$(ddcutil getvcp 10| awk -F'current value = ' '{print $2}' | awk '{print $1}'| sed 's/,//g')
        get_ext_brightness
    else
        Brightness_extern=$1
    fi
    sed -i '/^export _brightness_extern=.*$/d' $configfile
    sed -i '/^export _brightness_hardware=.*$/d' $configfile
    printf "export _brightness_extern=%d\n" $Brightness_extern >> $configfile
    printf "export _brightness_hardware=%b\n" $brightness_hardware >> $configfile
    #update lock and changed
    update_lock
}

update_lock() {
    sed -i '/^export _locked=.*$/d' $configfile
    sed -i '/^export _changed=.*$/d' $configfile
    printf "export _locked=%b\n" $Locked >> $configfile
    printf "export _changed=%b\n" $Changed >> $configfile
}

#update status bar
update_bar(){
    icon="󰃟 "
    text=$Brightness_laptop
    #Have Ext Brightness??TODO!!!
    if [ -n "$Brightness_extern" ] && [ $Brightness_extern != 0 ]; then
        icon="󰳲 "
        text=$(echo "$Brightness_extern" | tr -d '\n')
    fi
    sed -i '/^export '$this'=.*$/d' $tempfile
    printf "export %s='%s%s%s%s%s'\n" $this "$signal" "$icon_color" "$icon" "$text_color" "$text" >> $tempfile
}
#Update All to current(Slow for Ext Display)
update() {
    get_current_status;
    update_bar;
}
send_notify(){
    notify_str="Brightness\n"
    notify_str="${notify_str}laptop: ${Brightness_laptop}/5818\n"
    notify_str="${notify_str}extern: ${Brightness_extern}\n"
    notify_str="${notify_str}---------------------\n"
    # 遍历所有键值对
    for key in "${!Cur_Brightness_x[@]}"; do
        # echo "$key: ${Cur_Brightness_x[$key]}"
        notify_str="${notify_str}${key}: ${Cur_Brightness_x[$key]}\n"
    done
    # echo $notify_str
    notify-send -r 9528 "$(echo -e $notify_str)"
}
#notify called by dwm
notify() {
    get_last_status;
    update_bar;
    send_notify;
    update_last_status;
}
change_ext_briteness(){
    #wait 2s for change
    while true; do
        sleep 2
        get_lock_status
        if [ "$Changed" != "true" ]; then
            break
        fi
        Changed=false
        update_lock
    done
    get_last_status
    ddcutil setvcp 10 $((Brightness_extern))
    Locked=false
    update_lock;
}
inc_brightness(){
    # get status
    get_current_screen;
    get_last_status;
    if [ "$brightness_hardware" = "true" ];then
        if [ "$current_screen" = "eDP-1" ]; then
            #internel screen
            brightnessctl set +1%
            update_bar
            send_notify
        else
            #Externel Screen
            Brightness_extern=$((Brightness_extern + 5))
            # Ensuer less then 100
            if [ $Brightness_extern -gt 100 ]; then
                Brightness_extern=100
            fi
            # Display result
            update_bar
            send_notify
            # Lock
            if [ "$Locked" != "true" ];then
                Locked=true
                Changed=false
                update_last_status $Brightness_extern;
                change_ext_briteness
            else
                Changed=true
                update_last_status $Brightness_extern;
            fi
        fi
    else
        #Software Brightness
        brightness_new=$((Cur_Brightness_x[current_screen]))
        brightness_new=$(echo "${Cur_Brightness_x[$current_screen]} 0.1" | awk '{printf "%.1f", $1 + $2}')
        xrandr --output $current_screen --brightness $brightness_new
        update_bar
        send_notify
    fi
}
#Dec
dec_brightness(){
    get_current_screen;
    get_last_status;
    if [ "$brightness_hardware" = "true" ];then
        if [ "$current_screen" = "eDP-1" ]; then
            brightnessctl set 1%-
            update_bar
            send_notify
        else
            Brightness_extern=$((Brightness_extern - 5))
            # ensure lager then 1
            if [ $Brightness_extern -lt 1 ]; then
                Brightness_extern=1
            fi
            update_bar
            send_notify
            if [ "$Locked" != "true" ];then
                Locked=true
                Changed=false
                update_last_status $Brightness_extern;
                change_ext_briteness
            else
                Changed=true
                update_last_status $Brightness_extern;
            fi
        fi
    else
        brightness_new=$((Cur_Brightness_x[current_screen]))
        brightness_new=$(echo "${Cur_Brightness_x[$current_screen]} 0.1" | awk '{printf "%.1f", $1 - $2}')
        xrandr --output $current_screen --brightness $brightness_new
        update_bar
        send_notify
    fi
}

get_current_screen(){
    # 获取鼠标位置
    eval $(xdotool getmouselocation --shell)

    # 获取屏幕信息
    screens=$(xrandr --query | grep " connected")

    # 遍历每个屏幕
    while read -r screen; do
        # 从屏幕信息中提取屏幕名称和位置
        screen_name=$(echo $screen | awk '{print $1}')
        screen_info=$(echo $screen | grep -oP '\d+x\d+\+\d+\+\d+')
        
        # 提取屏幕的宽高和位置
        width=$(echo $screen_info | cut -d'x' -f1)
        height=$(echo $screen_info | cut -d'x' -f2 | cut -d'+' -f1)
        x_offset=$(echo $screen_info | cut -d'+' -f2)
        y_offset=$(echo $screen_info | cut -d'+' -f3)

        # 判断鼠标是否在当前屏幕上
        if (( X >= x_offset && X < (x_offset + width) && Y >= y_offset && Y < (y_offset + height) )); then
            # echo "Mouse is on screen: $screen_name"
            current_screen=$screen_name
        fi
    done <<< "$screens"
}

click() {
    case "$1" in
        L) notify                                           ;; 
        # M) pactl set-sink-mute @DEFAULT_SINK@ toggle        ;; 
        R) hardware_software_switch ;; 
        U) inc_brightness;  ;; 
        D) dec_brightness;  ;; 
    esac
}

case "$1" in
    click) click $2 ;;
    notify) notify ;;
    *) update ;;
esac

