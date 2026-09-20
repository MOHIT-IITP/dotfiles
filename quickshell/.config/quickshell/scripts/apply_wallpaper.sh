#!/bin/bash

IMG="$1"

if [ -n "$IMG" ] && [ -f "$IMG" ]; then
    awww img "$IMG" --transition-type center --transition-duration 3 --transition-fps 120
    wal -i "$IMG"
    matugen image "$IMG" --source-color-index 0 -m dark

    pkill swaync
    swaync > /dev/null 2>&1 &

    notify-send "Theme Applied" "Wallpaper set to $(basename "$IMG")"
fi
