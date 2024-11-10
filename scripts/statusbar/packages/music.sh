#!/usr/bin/env bash
# music 脚本

tempfile=/tmp/dwm_bar_temp

this=_music
icon_color="^c#3B102B^^b#6873790x88^"
text_color="^c#3B102B^^b#6873790x99^"
signal=$(echo "^s$this^" | sed 's/_//')

[ ! "$(command -v mpc)" ] && echo command not found: mpc && return

update() {
    music_text="$(mpc current)"
    icon=" 󰝚 "
    # if $music_text=~"\""; then
    #     text=$(echo $music_text | sed -e "s/\"\\\\\"/g")
    # else
    if [[ $music_text == *\"* ]]; then
    text=$(echo "$music_text" | sed 's/\"//g')
    else
        text=" $music_text "
    fi
    [ "$(mpc status | grep "paused")" ] && icon=" 󰐎 "

    sed -i '/^export '$this'=.*$/d' $tempfile
    [ ! "$music_text" ] && return
    printf "export %s=\"%s%s%s%s%s\"\n" $this "$signal" "$icon_color" "$icon" "$text_color" "$text" >> $tempfile
}

click() {
    case "$1" in
        L) mpc toggle ;;
        R) mpc toggle ;;
        U) mpc prev ;;
        D) mpc next ;;
    esac
}

# TODO

case "$1" in
    # click) click $2 ;;
    # notify) notify ;;
    # *) update ;;
esac