# Waybar Config for Hyprland

Кастомная конфигурация Waybar для Arch Linux с Hyprland. Включает в себя модули погоды (с Яндекса), музыки, системных индикаторов и виджет на рабочий стол.

## Особенности

- **Модули**: рабочие столы Hyprland, батарея, CPU, часы, погода, музыка, звук, сеть
- **Погода**: автоматически получает температуру с Яндекс.Погоды
- **Виджет на рабочем столе**: отображает время, дату и погоду через yad
- **Иконки**: используются Nerd Fonts (батарея, звук, сеть и др.)
- **Японские цифры**: для индикации рабочих столов (一, 二, 三...)

## Необходимые пакеты (Arch Linux)

```bash
sudo pacman -S waybar yad curl playerctl pavucontrol grim slurp
```

Для иконок установи шрифт Nerd Fonts (например, `ttf-jetbrains-mono-nerd`):
```bash
sudo pacman -S ttf-jetbrains-mono-nerd
```

## Установка

### Автоматическая (рекомендуется)
```bash
chmod +x install.sh
./install.sh
```

### Ручная
1. Скопируй файлы в `~/.config/waybar/`:
```bash
cp -r * ~/.config/waybar/
```

2. Сделай скрипты исполняемыми:
```bash
chmod +x ~/.config/waybar/scripts/*.sh
chmod +x ~/.config/waybar/wallpaper.sh
chmod +x ~/.config/waybar/settings-launcher.sh
```

3. Добавь автозапуск виджета в `~/.config/hypr/hyprland.conf`:
```
exec-once = ~/.config/waybar/scripts/desktop-widget.sh &
```

4. Перезапусти Waybar:
```bash
pkill waybar; waybar &
```

## Структура файлов

```
Waybar/
├── config              # Основная конфигурация Waybar
├── style.css           # Стили Waybar
├── settings-style.css  # Стили для меню настроек
├── settings-launcher.sh
├── settings-popup.sh
├── wallpaper.sh
├── scripts/
│   ├── weather-ya.sh   # Погода с Яндекса
│   ├── desktop-widget.sh # Виджет на рабочий стол
│   ├── music.sh
│   ├── music-cover.sh
│   └── music-status.sh
├── install.sh          # Скрипт автоустановки
└── README.md
```

## Настройка погоды

По умолчанию используется Москва. Для другого города отредактируй `scripts/weather-ya.sh`:
```bash
CITY="${1:-moscow}"  # Замени moscow на свой город
```

## Лицензия

MIT
