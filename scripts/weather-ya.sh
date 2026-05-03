#!/bin/bash
# Weather script using wttr.in with emoji icons
# Usage: weather-ya.sh [city] | weather-ya.sh set [city]

CONFIG_DIR="$HOME/.config/waybar"
CITY_CONFIG="$CONFIG_DIR/.weather_city"

set_city() {
    [ -z "$1" ] && echo "Usage: $0 set <city>" && exit 1
    echo "$1" > "$CITY_CONFIG"
    echo "City set to: $1"
    pkill waybar 2>/dev/null; waybar >/dev/null 2>&1 &
    exit 0
}

[ "$1" = "set" ] && set_city "$2"

CITY="${1:-$(cat "$CITY_CONFIG" 2>/dev/null || echo "moscow")}"

WEATHER=$(curl -s "wttr.in/$CITY?format=%t|%C" 2>/dev/null)
[ -z "$WEATHER" ] && echo "🌡 N/A" && exit 0

TEMP=$(echo "$WEATHER" | cut -d'|' -f1 | tr -d '+')
COND=$(echo "$WEATHER" | cut -d'|' -f2 | tr ' [:upper:]' '_[:lower:]')

case "$COND" in
    *sunny*|*clear*)        ICON="☀️" ;;
    *partly_cloudy*)        ICON="⛅" ;;
    *cloudy*|*overcast*)    ICON="☁️" ;;
    *rain*|*drizzle*)       ICON="🌧️" ;;
    *shower*)               ICON="🌦️" ;;
    *thunder*)              ICON="⛈️" ;;
    *snow*|*blizzard*)      ICON="❄️" ;;
    *sleet*)                ICON="🌨️" ;;
    *fog*|*mist*)           ICON="🌫️" ;;
    *wind*)                 ICON="💨" ;;
    *)                      ICON="🌡️" ;;
esac

echo "$ICON $TEMP"
