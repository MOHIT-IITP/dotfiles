#!/bin/bash

IMG="$1"
RESIZE="$2"

# Map UI mode to awww --resize value: crop (Fill) | fit | stretch | no (Center)
case "$RESIZE" in
    fit|stretch|no|crop) ;;
    center) RESIZE="no" ;;
    fill|expand|"") RESIZE="crop" ;;
    *) RESIZE="crop" ;;
esac

if [ -n "$IMG" ] && [ -f "$IMG" ]; then
    awww img "$IMG" --resize "$RESIZE" --transition-duration 6 --transition-type wave --transition-angle 45 --transition-wave 30,20 --transition-step 120 --transition-fps 60
    wal -i "$IMG"
    matugen image "$IMG" --source-color-index 0 -m dark

    pkill swaync
    swaync > /dev/null 2>&1 &

    notify-send "Theme Applied" "Wallpaper set to $(basename "$IMG")"
fi
