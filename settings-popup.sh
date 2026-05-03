#!/usr/bin/env bash

set -u
set -o pipefail

exec >> /tmp/waybar-settings.log 2>&1

echo "popup: $(date '+%F %T')"
echo "runtime: ${XDG_RUNTIME_DIR:-unset}"
echo "display: ${WAYLAND_DISPLAY:-unset}"

TITLE="Waybar Settings"
TEMP_DIR="${XDG_RUNTIME_DIR:-/tmp}"
STATE_FILE="$TEMP_DIR/waybar-settings-state"
CONFIG_DIR="/home/boxs/.config/waybar"

# Apply custom GTK theme
export GTK_DATA_PREFIX="/usr/share:/usr/local/share"
export GTK_THEME="Catppuccin-Mocha-Standard-Blue-Dark"

# Apply custom CSS through GTK3
if [ -f "$CONFIG_DIR/settings-style.css" ]; then
  mkdir -p "$HOME/.config/gtk-3.0"
  cp "$CONFIG_DIR/settings-style.css" "$HOME/.config/gtk-3.0/gtk.css"
fi

notify() {
  notify-send "$TITLE" "$1"
}

bt_power() {
  bluetoothctl show 2>/dev/null | awk '/Powered:/ {print $2; exit}'
}

bt_status_text() {
  if [ "$(bt_power)" = "yes" ]; then
    printf 'On'
  else
    printf 'Off'
  fi
}

default_sink() {
  pactl get-default-sink 2>/dev/null || true
}

sink_label() {
  local sink
  sink="$(default_sink)"
  if [ -n "$sink" ]; then
    printf '%s' "$sink"
  else
    printf 'Unavailable'
  fi
}

brightness_value() {
  brightnessctl info 2>/dev/null | sed -n 's/.*(\([0-9]\+%\)).*/\1/p' | tr -d '%'
}

get_volume() {
  pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '\d+(?=%)' | head -1 || echo "0"
}

set_volume() {
  local vol=$1
  pactl set-sink-volume @DEFAULT_SINK@ "${vol}%" >/dev/null 2>&1
}

get_wifi_status() {
  local status
  status="$(nmcli radio wifi 2>/dev/null)" || status="unknown"

  if [ "$status" = "enabled" ]; then
    local ssid
    ssid="$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2)"
    if [ -n "$ssid" ]; then
      echo "Connected: $ssid"
    else
      echo "Enabled (no connection)"
    fi
  elif [ "$status" = "disabled" ]; then
    echo "Disabled"
  else
    echo "Unknown"
  fi
}

toggle_wifi() {
  local status
  status="$(nmcli radio wifi 2>/dev/null)" || return 1

  if [ "$status" = "enabled" ]; then
    nmcli radio wifi off >/dev/null 2>&1 && notify "WiFi disabled"
  else
    nmcli radio wifi on >/dev/null 2>&1 && notify "WiFi enabled"
  fi
}

get_wifi_list() {
  local result=""
  mapfile -t networks < <(nmcli -t -f ssid,signal dev wifi list 2>/dev/null | sort -t: -k2 -nr | head -10)

  for line in "${networks[@]}"; do
    local ssid signal
    ssid="${line%%:*}"
    signal="${line##*:}"

    if [ -z "$ssid" ]; then
      continue
    fi

    result+="$ssid (${signal}%)!"
  done

  echo "$result" | sed 's/!$//'
}

get_audio_sinks() {
  pactl list short sinks 2>/dev/null | awk -F '\t' '{print $2}'
}

get_audio_list() {
  local current
  current="$(default_sink)"
  local result=""
  while IFS= read -r sink; do
    if [ "$sink" = "$current" ]; then
      result+="$sink (current)!"
    else
      result+="$sink!"
    fi
  done < <(get_audio_sinks)
  echo "$result" | sed 's/!$//'
}

get_bluetooth_devices() {
  local result=""
  mapfile -t devices < <(bluetoothctl paired-devices 2>/dev/null)

  for line in "${devices[@]}"; do
    local rest mac name state
    rest="${line#Device }"
    mac="${rest%% *}"
    name="${rest#"$mac "}"
    state="$(bluetoothctl info "$mac" 2>/dev/null | awk '/Connected:/ {print $2; exit}')"

    if [ "$state" = "yes" ]; then
      result+="$name (connected)!"
    else
      result+="$name!"
    fi
  done

  echo "$result" | sed 's/!$//'
}

# Get MAC address by device name
get_bt_mac_by_name() {
  local target_name="$1"
  local target_mac=""
  
  mapfile -t devices < <(bluetoothctl paired-devices 2>/dev/null)
  
  for line in "${devices[@]}"; do
    local rest mac name
    rest="${line#Device }"
    mac="${rest%% *}"
    name="${rest#"$mac "}"
    
    # Remove " (connected)" suffix if present in target
    local clean_name="$target_name"
    clean_name="${clean_name% (connected)}"
    
    if [ "$name" = "$clean_name" ]; then
      target_mac="$mac"
      break
    fi
  done
  
  echo "$target_mac"
}

show_main() {
  local bt_state bright current_audio bt_devices volume wifi_status wifi_list

  bt_state="$(bt_power)"
  bright="$(brightness_value)"
  [ -n "$bright" ] || bright=50
  current_audio="$(default_sink)"
  bt_devices="$(get_bluetooth_devices)"
  volume="$(get_volume)"
  [ -n "$volume" ] || volume=50
  wifi_status="$(get_wifi_status)"
  wifi_list="$(get_wifi_list)"

  local bt_button
  if [ "$bt_state" = "yes" ]; then
    bt_button="Disable BT"
  else
    bt_button="Enable BT"
  fi

  local audio_list
  audio_list="$(get_audio_list)"

  local result
  result="$(yad \
    --no-headers \
    --on-top \
    --skip-taskbar \
    --sticky \
    --width=420 \
    --height=380 \
    --title="Settings" \
    --window-icon=preferences-system \
    --form \
    --separator="|" \
    --text="<span font='14' weight='bold' color='#89b4fa'>⚙ Settings</span>\n" \
    --field="<span color='#f9e2af'>🔆 Brightness</span>:SCL" "$bright" \
    --field="<span color='#a6e3a1'>🔊 Volume</span>:SCL" "$volume" \
    --field="<span color='#89b4fa'>🎵 Audio Output</span>:CB" "$audio_list" \
    --field="<span color='#fab387'>📶 WiFi Network</span>:CB" "$wifi_list" \
    --field="<span color='#cba6f7'>🫧 Bluetooth</span>:CB" "$bt_devices" \
    --button="<span color='#fab387'>📶 WiFi</span>:5" \
    --button="<span color='#cba6f7'>🫧 $bt_button</span>:10" \
    --button="<span color='#a6e3a1'>💾 Save</span>:0" \
    --button="<span color='#f38ba8'>✖ Close</span>:1" 2>&1)" || {
    return
  }

  case $? in
    5)
      toggle_wifi
      ;;
    10)
      if [ "$bt_state" = "yes" ]; then
        bluetoothctl power off >/dev/null 2>&1 && notify "Bluetooth turned off"
      else
        bluetoothctl power on >/dev/null 2>&1 && notify "Bluetooth turned on"
      fi
      ;;
    0)
      local new_bright new_volume new_audio new_wifi new_bt
      new_bright="$(echo "$result" | cut -d'|' -f1)"
      new_volume="$(echo "$result" | cut -d'|' -f2)"
      new_audio="$(echo "$result" | cut -d'|' -f3 | sed 's/ (current).*//')"
      new_wifi="$(echo "$result" | cut -d'|' -f4 | sed 's/ (.*//')"
      new_bt="$(echo "$result" | cut -d'|' -f5 | sed 's/ (connected).*//' | sed 's/|.*//')"

      if [ -n "$new_bright" ] && [ "$new_bright" != "$bright" ]; then
        brightnessctl set "${new_bright}%" >/dev/null 2>&1
        notify "Brightness: ${new_bright}%"
      fi

      if [ -n "$new_volume" ] && [ "$new_volume" != "$volume" ]; then
        set_volume "$new_volume"
        notify "Volume: ${new_volume}%"
      fi

      if [ -n "$new_audio" ] && [ "$new_audio" != "$current_audio" ]; then
        pactl set-default-sink "$new_audio" >/dev/null 2>&1
        pactl list short sink-inputs 2>/dev/null | awk '{print $1}' | while read -r input_id; do
          [ -n "$input_id" ] && pactl move-sink-input "$input_id" "$new_audio" >/dev/null 2>&1
        done
        notify "Audio: $new_audio"
      fi

      if [ -n "$new_wifi" ] && [ "$new_wifi" != "Unknown" ]; then
        nmcli device wifi connect "$new_wifi" >/dev/null 2>&1
        notify "Connecting to: $new_wifi"
      fi

      if [ -n "$new_bt" ]; then
        local bt_mac
        # Remove " (connected)" suffix if present
        local bt_name_clean="${new_bt% (connected)}"
        bt_mac="$(get_bt_mac_by_name "$bt_name_clean")"
        
        if [ -n "$bt_mac" ]; then
          local bt_current_state
          bt_current_state="$(bluetoothctl info "$bt_mac" 2>/dev/null | awk '/Connected:/ {print $2; exit}')"
          if [ "$bt_current_state" = "yes" ]; then
            bluetoothctl disconnect "$bt_mac" >/dev/null 2>&1 && notify "Disconnected: $bt_name_clean"
          else
            bluetoothctl connect "$bt_mac" >/dev/null 2>&1 && notify "Connected: $bt_name_clean"
          fi
        else
          notify "Device not found: $bt_name_clean"
        fi
      fi
      ;;
  esac
}

main() {
  while true; do
    show_main
    [ $? -eq 1 ] && exit 0
  done
}

main
