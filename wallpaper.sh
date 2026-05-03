#!/bin/bash

# Папка с обоями
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
mkdir -p "$WALLPAPER_DIR"

# Функция для вывода логов
log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

# Скачать случайный фон из Wallhaven API
log "Подключение к Wallhaven API..."
api_url="https://wallhaven.cc/api/v1/search?sorting=random&order=desc&purity=100&categories=111&ratios=16x9"
response=$(curl -s --max-time 10 -H "User-Agent: Mozilla/5.0" "$api_url")

# Извлечь path и заменить экранированные слэши
image_url=$(echo "$response" | grep -oP '(?<="path":")[^"]*' | head -1 | sed 's/\\\//\//g')

log "Скачанный URL: $image_url"

if [ -n "$image_url" ] && [ "$image_url" != "null" ]; then
    log "Удаляю старые обои в $WALLPAPER_DIR"
    rm -f "$WALLPAPER_DIR"/wallhaven_*.png
    rm -f "$WALLPAPER_DIR"/current-wallpaper.png
    filename="$WALLPAPER_DIR/wallhaven_$(date +%s).png"
    log "Сохраняю в: $filename"
    
    curl -s --max-time 30 -o "$filename" "$image_url"
    
    if [ -f "$filename" ] && [ -s "$filename" ]; then
        log "Файл успешно скачан: $(du -h "$filename" | cut -f1)"
        
        if command -v awww &> /dev/null; then
            log "Проверка awww-daemon..."
            mkdir -p "$HOME/.cache/awww"
            if ! pgrep -x "awww-daemon" > /dev/null; then
                log "Запускаю awww-daemon..."
                awww-daemon &
                sleep 1
            fi
            log "Устанавливаю обой через awww..."
            awww img "$filename" 2>/dev/null
            if [ $? -eq 0 ]; then
                log "Фон успешно установлен через awww"
            else
                log "Ошибка: awww не смог установить фон"
            fi
        elif command -v swaybg &> /dev/null; then
            log "Устанавливаю обой через swaybg..."
            pkill swaybg 2>/dev/null
            sleep 1
            swaybg -i "$filename" -m fill &
            log "Фон успешно установлен через swaybg"
        elif command -v feh &> /dev/null; then
            log "Устанавливаю обой через feh..."
            DISPLAY=:0 feh --bg-scale "$filename" 2>/dev/null
            if [ $? -eq 0 ]; then
                log "Фон успешно установлен через feh"
            else
                log "Ошибка: feh не смог установить фон"
            fi
        else
            log "Ошибка: ни один поддерживаемый инструмент не найден (awww, swaybg, feh)"
        fi
    else
        log "Ошибка: файл не скачан или пуст"
    fi
else
    log "Ошибка: не удалось получить URL обоя с Wallhaven"
fi