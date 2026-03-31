#!/bin/bash

WALLDIR="$HOME/pix"

if command -v rofi &> /dev/null; then
    launcher="rofi -dmenu -i -p 'Select Wallpaper'"
else
    launcher="wofi --dmenu --prompt 'Select Wallpaper'"
fi

choice=$(ls "$WALLDIR" | $launcher)

[ -z "$choice" ] && exit

WALL="$WALLDIR/$choice"

awww img "$WALL" --transition-type center --transition-fps 120 --transition-duration 1

matugen image "$WALL"  --source-color-index 0
wal -i "$WALL"


pkill waybar
waybar &

echo "$WALL" > ~/.cache/current_wallpaper
