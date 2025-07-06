#!/bin/bash

# Get focused window info
WINDOW_INFO=$(hyprctl activewindow -j)

if [ "$WINDOW_INFO" = "null" ] || [ -z "$WINDOW_INFO" ]; then
  echo '{"text": "", "class": "empty"}'
  exit 0
fi

CLASS=$(echo "$WINDOW_INFO" | jq -r '.class // empty')
TITLE=$(echo "$WINDOW_INFO" | jq -r '.title // empty')

# Truncate title if too long
if [ ${#TITLE} -gt 25 ]; then
  TITLE="${TITLE:0:25}..."
fi

# Map class to icons (you can customize these)
case "$CLASS" in
"firefox" | "Firefox")
  ICON=""
  ;;
"code" | "Code")
  ICON=""
  ;;
"discord" | "Discord")
  ICON="󰙯"
  ;;
"spotify" | "Spotify")
  ICON=""
  ;;
"kitty" | "alacritty")
  ICON=""
  ;;
"nautilus" | "thunar")
  ICON=""
  ;;
*)
  ICON=""
  ;;
esac

echo "{\"text\": \"$ICON $TITLE\", \"class\": \"focused-window\"}"
