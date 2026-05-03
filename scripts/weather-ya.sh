#!/bin/bash

# Weather script using Yandex Weather
# City can be passed as argument, default: moscow
CITY="${1:-moscow}"

get_weather() {
    # Fetch Yandex Weather page and extract temperature
    # Using Yandex Weather API-like endpoint or scraping
    URL="https://yandex.ru/weather/city/$CITY"
    
    # Try to get temperature from Yandex Weather
    # Using curl with user agent to avoid blocking
    TEMP=$(curl -s -A "Mozilla/5.0" "$URL" | grep -oP 'temperature.*?[-+]?\d+' | head -1 | grep -oP '[-+]?\d+' | head -1)
    
    if [ -z "$TEMP" ]; then
        # Fallback: try wttr.in if Yandex fails
        TEMP=$(curl -s "wttr.in/$CITY?format=%t" 2>/dev/null | tr -d '+')
    fi
    
    if [ -z "$TEMP" ]; then
        echo "N/A"
        return
    fi
    
    # Add degree symbol and icon based on temperature
    if [ "$TEMP" -gt 0 ] 2>/dev/null; then
        echo "󰖃 +$TEMP°"
    else
        echo "󰖃 $TEMP°"
    fi
}

# Update interval: output weather
get_weather
