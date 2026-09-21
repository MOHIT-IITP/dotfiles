#!/usr/bin/env bash
# Clipboard history management script for Quickshell

CMD="$1"
shift

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/quickshell"
THUMB_DIR="$CACHE_DIR/cliphist-thumbs"
mkdir -p "$CACHE_DIR" "$THUMB_DIR"
FALLBACK_FILE="$CACHE_DIR/clipboard_history.txt"
MAGICK_DIR="$(dirname "$0")/magick-policy"
export MAGICK_CONFIGURE_PATH="$MAGICK_DIR"

case "$CMD" in
  watch-text)
    if command -v cliphist >/dev/null 2>&1 && command -v wl-paste >/dev/null 2>&1; then
      exec wl-paste --type text --watch cliphist store
    elif command -v wl-paste >/dev/null 2>&1; then
      touch "$FALLBACK_FILE"
      exec wl-paste --type text --watch bash -c '
        txt="$(cat)"
        [ -z "$txt" ] && exit 0
        tmp="$(mktemp)"
        printf "%s\n" "$txt" > "$tmp"
        if [ -f "'"$FALLBACK_FILE"'" ]; then
          grep -v -x -F "$txt" "'"$FALLBACK_FILE"'" | head -n 300 >> "$tmp"
        fi
        mv "$tmp" "'"$FALLBACK_FILE"'"
      '
    fi
    ;;

  watch-image)
    if command -v cliphist >/dev/null 2>&1 && command -v wl-paste >/dev/null 2>&1; then
      exec wl-paste --type image --watch cliphist store
    fi
    ;;

  thumbs)
    if command -v cliphist >/dev/null 2>&1 && command -v magick >/dev/null 2>&1; then
      list="$(cliphist list 2>/dev/null | tr -d '\0')"
      ids="$(mktemp)"
      have="$(mktemp)"
      trap 'rm -f "$ids" "$have"' EXIT

      printf '%s\n' "$list" | cut -f1 | sort -n > "$ids"

      if [ -s "$ids" ]; then
        find "$THUMB_DIR" -maxdepth 1 -type f -name '*.png' -printf '%f\n' 2>/dev/null \
          | sed 's/\.png$//' | sort -n > "$have"
        comm -23 "$have" "$ids" 2>/dev/null | while IFS= read -r id; do
          rm -f "$THUMB_DIR/$id.png"
        done
      fi

      printf '%s\n' "$list" | awk -F '\t' '/\[\[ binary data / && /(png|jpg|jpeg|gif|bmp|webp)/ {print $1}' | while IFS= read -r id; do
        thumb="$THUMB_DIR/$id.png"
        [ -s "$thumb" ] && continue
        if cliphist decode "$id" 2>/dev/null | magick - -strip -resize 128x128 "png:$thumb.tmp" 2>/dev/null; then
          if [ -s "$thumb.tmp" ]; then
            mv "$thumb.tmp" "$thumb"
          else
            rm -f "$thumb.tmp"
          fi
        else
          rm -f "$thumb.tmp"
        fi
      done
    fi
    ;;

  list)
    if command -v cliphist >/dev/null 2>&1; then
      cliphist list | tr -d '\0'
    elif [ -f "$FALLBACK_FILE" ]; then
      cat "$FALLBACK_FILE"
    fi
    ;;

  copy)
    RAW="$*"
    if command -v cliphist >/dev/null 2>&1; then
      printf "%s\n" "$RAW" | cliphist decode | wl-copy
    elif command -v wl-copy >/dev/null 2>&1; then
      printf "%s" "$RAW" | wl-copy
    fi
    ;;

  delete)
    RAW="$*"
    if command -v cliphist >/dev/null 2>&1; then
      printf "%s\n" "$RAW" | cliphist delete
    elif [ -f "$FALLBACK_FILE" ]; then
      tmp="$(mktemp)"
      grep -v -x -F "$RAW" "$FALLBACK_FILE" > "$tmp"
      mv "$tmp" "$FALLBACK_FILE"
    fi
    ;;

  wipe)
    if command -v cliphist >/dev/null 2>&1; then
      cliphist wipe
    fi
    rm -rf "$THUMB_DIR"/* 2>/dev/null || true
    if [ -f "$FALLBACK_FILE" ]; then
      > "$FALLBACK_FILE"
    fi
    ;;

  *)
    exit 1
    ;;
esac
