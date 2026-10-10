#!/usr/bin/env bash

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

MODE="${1:-display}"

play_sound() {
  if command -v canberra-gtk-play &>/dev/null; then
    canberra-gtk-play -i camera-shutter &>/dev/null &
  elif command -v paplay &>/dev/null && [ -f "/usr/share/sounds/freedesktop/stereo/camera-shutter.oga" ]; then
    paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga &>/dev/null &
  elif command -v pw-play &>/dev/null && [ -f "/usr/share/sounds/freedesktop/stereo/camera-shutter.oga" ]; then
    pw-play /usr/share/sounds/freedesktop/stereo/camera-shutter.oga &>/dev/null &
  fi
}

get_latest_file() {
  find "$DIR" -maxdepth 1 -name "*.png" -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -n1 | cut -d' ' -f2-
}

case "$MODE" in
  last)
    LATEST="$(get_latest_file)"
    if [ -n "$LATEST" ] && [ -f "$LATEST" ]; then
      echo "$LATEST"
    else
      echo "$DIR"
    fi
    exit 0
    ;;

  open)
    TARGET="${2:-$(get_latest_file)}"
    if [ -f "$TARGET" ]; then
      xdg-open "$TARGET" &>/dev/null &
    fi
    exit 0
    ;;

  open-dir)
    xdg-open "$DIR" &>/dev/null &
    exit 0
    ;;
esac

BEFORE_LATEST="$(get_latest_file)"

case "$MODE" in
  display)
    sleep 0.35
    hyprshot -m output -m active -o "$DIR" 2>/dev/null || hyprshot -m output -o "$DIR" 2>/dev/null || true
    ;;

  window)
    sleep 0.35
    hyprshot -m window -o "$DIR" 2>/dev/null || true
    ;;

  area)
    sleep 0.35
    hyprshot -m region -o "$DIR" 2>/dev/null || true
    ;;
esac

AFTER_LATEST="$(get_latest_file)"

if [ -n "$AFTER_LATEST" ] && [ -f "$AFTER_LATEST" ] && [ "$AFTER_LATEST" != "$BEFORE_LATEST" ]; then
  play_sound
  echo "$AFTER_LATEST"
fi
