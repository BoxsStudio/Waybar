#!/bin/bash
# Uninstall Waybar config and restore backups

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Waybar Config Uninstaller ===${NC}"
echo ""

# Remove weather city config
if [ -f ~/.config/waybar/.weather_city ]; then
    rm ~/.config/waybar/.weather_city
    echo -e "${GREEN}✓ Удалён файл настройки города${NC}"
fi

# Remove weather command
if [ -f ~/.local/bin/weather ]; then
    rm ~/.local/bin/weather
    echo -e "${GREEN}✓ Удалена команда 'weather'${NC}"
fi

# Restore original waybar config (if backup exists)
if [ -f ~/.config/waybar/config.backup ]; then
    mv ~/.config/waybar/config.backup ~/.config/waybar/config
    echo -e "${GREEN}✓ Восстановлена оригинальная конфигурация Waybar${NC}"
else
    echo -e "${YELLOW}⚠ Резервная копия config.backup не найдена${NC}"
fi

# Remove desktop widget from hyprland.conf
HYPR_CONF=~/.config/hypr/hyprland.conf
if [ -f "$HYPR_CONF" ] && grep -q "desktop-widget" "$HYPR_CONF"; then
    sed -i '/# Desktop clock\/weather widget/d' "$HYPR_CONF"
    sed -i '/desktop-widget.sh/d' "$HYPR_CONF"
    echo -e "${GREEN}✓ Удалён автозапуск виджета из Hyprland${NC}"
fi

# Kill running desktop widget
pkill -f "desktop-widget.sh" 2>/dev/null && echo -e "${GREEN}✓ Виджет на рабочем столе остановлен${NC}"

# Restart waybar
pkill waybar 2>/dev/null; waybar >/dev/null 2>&1 &
echo -e "${GREEN}✓ Waybar перезапущен${NC}"

echo ""
echo -e "${GREEN}Удаление завершено.${NC}"
echo -e "Пакеты (waybar, yad, curl и др.) можно удалить вручную: ${YELLOW}sudo pacman -Rns waybar yad${NC}"
