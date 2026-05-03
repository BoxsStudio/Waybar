# Waybar Config for Hyprland

**Автор:** BoxsStudio

Кастомная конфигурация Waybar для Arch Linux с Hyprland. Включает в себя модули погоды (с Яндекса), музыки, системных индикаторов и виджет на рабочий стол.

## Особенности

- **Модули**: рабочие столы Hyprland, батарея, CPU, часы, погода, музыка, звук, сеть
- **Погода**: автоматически получает температуру с Яндекс.Погоды
- **Виджет на рабочем столе**: отображает время, дату и погоду через yad
- **Иконки**: используются Nerd Fonts (батарея, звук, сеть и др.)
- **Римские цифры**: для индикации рабочих столов (I, II, III...)

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
├── .local/bin/
│   └── weather         # Команда для смены города погоды
├── install.sh          # Скрипт автоустановки
└── README.md
```

## Настройка погоды

По умолчанию используется Москва. Изменить город можно через команду `weather` (устанавливается в `~/.local/bin/weather`):

```bash
weather              # Показать погоду для текущего города
weather orenburg     # Показать погоду для Оренбурга (без сохранения)
weather set orenburg # Установить Оренбург как город по умолчанию
weather get          # Показать текущий сохранённый город
```

После `weather set <city>` Waybar автоматически перезапустится с новым городом.

Вручную можно отредактировать файл `~/.config/waybar/.weather_city` или скрипт `scripts/weather-ya.sh`.
