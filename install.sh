#!/bin/bash

# Waybar Config Installer for Arch Linux + Hyprland
# Автоматическая установка конфигурации Waybar

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Waybar Config Installer ===${NC}"
echo ""

# Проверка дистрибутива
if ! grep -q "Arch" /etc/os-release 2>/dev/null; then
    echo -e "${YELLOW}Внимание: скрипт предназначен для Arch Linux${NC}"
    read -p "Продолжить? (y/n): " confirm
    [[ "$confirm" != "y" ]] && exit 1
fi

# Установка пакетов
echo -e "${GREEN}[1/4] Установка необходимых пакетов...${NC}"
sudo pacman -S --needed --noconfirm waybar yad curl playerctl pavucontrol grim slurp ttf-jetbrains-mono-nerd 2>/dev/null || \
    echo -e "${YELLOW}Некоторые пакеты уже установлены${NC}"

# Создание директории
echo -e "${GREEN}[2/4] Копирование конфигурации...${NC}"
mkdir -p ~/.config/waybar/scripts

# Копирование файлов
cp -f config ~/.config/waybar/
cp -f style.css settings-style.css ~/.config/waybar/
cp -f settings-launcher.sh settings-popup.sh wallpaper.sh ~/.config/waybar/
cp -f scripts/* ~/.config/waybar/scripts/

# Установка прав
echo -e "${GREEN}[3/4] Установка прав доступа...${NC}"
chmod +x ~/.config/waybar/scripts/*.sh
chmod +x ~/.config/waybar/wallpaper.sh
chmod +x ~/.config/waybar/settings-launcher.sh

# Настройка Hyprland
echo -e "${GREEN}[4/4] Настройка автозапуска в Hyprland...${NC}"
HYPR_CONF=~/.config/hypr/hyprland.conf
if [ -f "$HYPR_CONF" ]; then
    if ! grep -q "desktop-widget" "$HYPR_CONF"; then
        echo '' >> "$HYPR_CONF"
        echo '# Desktop clock/weather widget' >> "$HYPR_CONF"
        echo 'exec-once = ~/.config/waybar/scripts/desktop-widget.sh &' >> "$HYPR_CONF"
        echo -e "${GREEN}Добавлен автозапуск виджета в Hyprland${NC}"
    else
        echo -e "${YELLOW}Автозапуск уже настроен${NC}"
    fi
else
    echo -e "${YELLOW}Файл hyprland.conf не найден, пропускаем${NC}"
fi

# Перезапуск Waybar
echo ""
echo -e "${GREEN}Установка завершена!${NC}"
read -p "Перезапустить Waybar сейчас? (y/n): " restart
if [[ "$restart" == "y" ]]; then
    pkill waybar 2>/dev/null || true
    waybar > /dev/null 2>&1 &
    echo -e "${GREEN}Waybar перезапущен${NC}"
fi

echo ""
echo -e "${GREEN}Готово! Конфигурация установлена в ~/.config/waybar/${NC}"
echo -e "Виджет на рабочем столе запустится при следующем входе в Hyprland"
echo -e "Или запусти вручную: ${YELLOW}bash ~/.config/waybar/scripts/desktop-widget.sh &${NC}"
