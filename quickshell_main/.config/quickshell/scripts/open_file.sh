#!/bin/bash
# Open files from the Quickshell file launcher.
# Usage: open_file.sh <path> [open|reveal]
#  open   (default): dirs -> thunar (fallback xdg-open); photos -> gthumb (fallback xdg-open); else xdg-open
#  reveal: open parent folder in thunar (fallback xdg-open)
TARGET="$1"
MODE="${2:-open}"

reveal() {
  local t="$1"
  if [ ! -d "$t" ]; then
    t="$(dirname "$t")"
  fi
  if command -v thunar >/dev/null 2>&1; then
    exec thunar "$t"
  else
    exec xdg-open "$t"
  fi
}

if [ "$MODE" = "reveal" ]; then
  reveal "$TARGET"
fi

if [ -d "$TARGET" ]; then
  reveal "$TARGET"
fi

lower="$(printf '%s' "${TARGET##*.}" | tr '[:upper:]' '[:lower:]')"
case "$lower" in
  jpg|jpeg|png|webp|gif|bmp|tif|tiff|svg|heic|heif|avif)
    if command -v gthumb >/dev/null 2>&1; then
      exec gthumb "$TARGET"
    else
      exec xdg-open "$TARGET"
    fi
    ;;
  *)
    exec xdg-open "$TARGET"
    ;;
esac
