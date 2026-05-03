#!/bin/bash

# Weather script using wttr.in (reliable) with weather condition icons
# Usage: weather-ya.sh [city]
#   or:  weather-ya.sh set [city]  - save city to config

CONFIG_DIR="$HOME/.config/waybar"
CITY_CONFIG="$CONFIG_DIR/.weather_city"

# If "set" argument: save city to config file
if [ "$1" = "set" ] && [ -n "$2" ]; then
    echo "$2" > "$CITY_CONFIG"
    echo "City set to: $2"
    exit 0
fi

# Read city from config or use argument or default to moscow
if [ -n "$1" ]; then
    CITY="$1"
elif [ -f "$CITY_CONFIG" ]; then
    CITY=$(cat "$CITY_CONFIG")
else
    CITY="moscow"
fi

# Get temperature and condition from wttr.in
WEATHER_DATA=$(curl -s "wttr.in/$CITY?format=%t|%C" 2>/dev/null)

if [ -z "$WEATHER_DATA" ]; then
    echo "󰖃 N/A"
    exit 0
fi

TEMP=$(echo "$WEATHER_DATA" | cut -d'|' -f1 | tr -d '+')
CONDITION=$(echo "$WEATHER_DATA" | cut -d'|' -f2 | tr '[:upper:]' '[:lower:]')

# Weather condition icons
case "$CONDITION" in
    *sunny*|*clear*)     ICON="󰖙" ;;
    *partly cloudy*)     ICON="󰖦" ;;
    *cloudy*)            ICON="󰖨" ;;
    *overcast*)          ICON="󰖨" ;;
    *rain*|*drizzle*)    ICON="󰖺" ;;
    *shower*)            ICON="󰖽" ;;
    *thunder*)           ICON="󰖪" ;;
    *snow*|*blizzard*)   ICON="󰖤" ;;
    *sleet*)             ICON="󰖥" ;;
    *fog*|*mist*)        ICON="󰖑" ;;
    *wind*)              ICON="󰖄" ;;
    *)                   ICON="󰖃" ;;
esac

echo "$ICON $TEMP"
