#!/bin/bash

# Desktop widget: clock, date and weather from Yandex
# Uses yad to create a floating desktop widget

get_weather() {
    # Try Yandex Weather first
    TEMP=$(curl -s -A "Mozilla/5.0 (X11; Linux x86_64)" "https://yandex.ru/weather/" | \
           grep -oP '"temperature":\s*[-+]?\d+' | head -1 | grep -oP '[-+]?\d+')
    
    if [ -z "$TEMP" ]; then
        TEMP=$(curl -s "wttr.in/?format=%t" 2>/dev/null | tr -d '+')
    fi
    
    if [ -n "$TEMP" ]; then
        echo "$TEMP°"
    else
        echo "N/A"
    fi
}

while true; do
    DATE=$(date '+%A, %d %B')
    TIME=$(date '+%H:%M:%S')
    WEATHER=$(get_weather)
    
    # Kill previous yad window
    pkill -f "yad --title=desktop-widget" 2>/dev/null
    
    # Show widget using yad
    yad --title="desktop-widget" \
        --no-buttons \
        --undecorated \
        --skip-taskbar \
        --sticky \
        --on-top \
        --posx=20 \
        --posy=20 \
        --width=200 \
        --height=100 \
        --timeout=5 \
        --text="<span font='16'>$TIME</span>\n<span font='12'>$DATE</span>\n<span font='14'>🌡 $WEATHER</span>" \
        --timeout-indicator=none &
    
    sleep 5
done
