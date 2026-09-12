#!/bin/bash

WALLPAPER_DIR="$HOME/pix"

SELECTED=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) |
  while read -r img; do
    echo -en "$img\0icon\x1f$img\n"
  done |
  rofi -dmenu \
    -i \
    -p "  Wallpaper" \
    -show-icons \
    -theme-str 'listview { columns: 3; } element-icon { size: 100px; }')

if [ -n "$SELECTED" ]; then
  awww img "$SELECTED" --transition-type center --transition-duration 3 --transition-fps 120 
  wal -i $SELECTED
  matugen image $SELECTED --source-color-index 0 -m dark
fi
