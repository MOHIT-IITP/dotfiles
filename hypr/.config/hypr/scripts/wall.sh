#!/bin/bash

WALLDIR="$HOME/pix"

if command -v rofi &> /dev/null; then
    launcher="rofi -dmenu -i -show-icons -theme ~/.config/rofi/wallpaper.rasi -p 'WALLPAPERS'"
else
    launcher="wofi --dmenu --prompt 'Select Wallpaper'"
fi

choice=$(find "$WALLDIR" -type f | while read -r img; do
    echo -en "$(basename "$img")\0icon\x1f$img\n"
done | eval $launcher)

[ -z "$choice" ] && exit

WALL="$WALLDIR/$choice"

wal -i "$WALL"

echo "$WALL" > ~/.cache/current_wallpaper
