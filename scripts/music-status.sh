#!/usr/bin/env bash

while true; do
    player=$(playerctl --list-all 2>/dev/null | head -1)
    if [ -z "$player" ]; then
        echo "🎵"
    else
        status=$(playerctl -p "$player" status 2>/dev/null)
        case "$status" in
            "Playing") echo "▶" ;;
            "Paused") echo "⏸" ;;
            *) echo "🎵" ;;
        esac
    fi
    sleep 1
done