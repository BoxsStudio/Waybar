#!/usr/bin/env bash

{
  echo "launcher: $(date '+%F %T')"
  echo "hyprctl: $(command -v hyprctl)"
} >> /tmp/waybar-settings.log 2>&1

export XDG_RUNTIME_DIR="/run/user/1000"
export WAYLAND_DISPLAY="wayland-1"
export GTK_THEME="Catppuccin-Mocha-Standard-Blue-Dark"

# Apply custom CSS
CONFIG_DIR="/home/boxs/.config/waybar"
if [ -f "$CONFIG_DIR/settings-style.css" ]; then
  mkdir -p "$HOME/.config/gtk-3.0"
  cp "$CONFIG_DIR/settings-style.css" "$HOME/.config/gtk-3.0/gtk.css"
fi

# Get screen resolution
resolution=$(hyprctl monitors 2>/dev/null | grep "resolution" | head -1 | awk '{print $2}' | cut -d'x' -f1)
[ -z "$resolution" ] && resolution=1920

# Calculate position: right side, directly under waybar
# Menu width: 420, waybar height: 38 + margin = 46
menu_x=$((resolution - 430))
menu_y=46

# Dropdown menu attached to waybar in top-right corner
hyprctl dispatch exec "[float; noborder; pin; size 420 380; position $menu_x $menu_y] /usr/bin/bash /home/boxs/.config/waybar/settings-popup.sh"
