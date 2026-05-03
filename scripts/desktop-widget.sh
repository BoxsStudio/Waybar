#!/bin/bash
# Desktop widget: clock, date and weather via yad

get_weather() {
    TEMP=$(curl -s "wttr.in/?format=%t" 2>/dev/null | tr -d '+')
    echo "${TEMP:-N/A}°"
}

while true; do
    pkill -f "yad --title=desktop-widget" 2>/dev/null
    yad --title="desktop-widget" --no-buttons --undecorated --skip-taskbar \
        --sticky --on-top --posx=20 --posy=20 --width=200 --height=100 \
        --timeout=5 --timeout-indicator=none \
        --text="<span font='16'>$(date '+%H:%M:%S')</span>
<span font='12'>$(date '+%A, %d %B')</span>
<span font='14'>🌡 $(get_weather)</span>" &
    sleep 5
done
