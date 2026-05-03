#!/usr/bin/env bash

interval=1

get_player() {
    playerctl --list-all 2>/dev/null | head -1
}

get_status() {
    local player=$1
    playerctl status -p "$player" 2>/dev/null
}

while true; do
    player=$(get_player)
    
    if [ -z "$player" ]; then
        echo "⏸ No player"
    else
        status=$(get_status "$player")
        
        case "$status" in
            "Playing")
                icon="♫ Playing"
                ;;
            "Paused")
                icon="⏸ Paused"
                ;;
            *)
                icon="⏹ $status"
                ;;
        esac
        echo "$icon"
    fi
    
    sleep "$interval"
done