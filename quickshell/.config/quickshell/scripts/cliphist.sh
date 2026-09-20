#!/usr/bin/env bash
# Clipboard history management script for Quickshell

CMD="$1"
shift

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/quickshell"
mkdir -p "$CACHE_DIR"
FALLBACK_FILE="$CACHE_DIR/clipboard_history.txt"

case "$CMD" in
  watch)
    if command -v cliphist >/dev/null 2>&1 && command -v wl-paste >/dev/null 2>&1; then
      exec wl-paste --type text --watch cliphist store
    elif command -v wl-paste >/dev/null 2>&1; then
      # Fallback watcher when cliphist binary is not installed
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

  list)
    if command -v cliphist >/dev/null 2>&1; then
      cliphist list
    elif [ -f "$FALLBACK_FILE" ]; then
      cat "$FALLBACK_FILE"
    fi
    ;;

  copy)
    RAW="$*"
    if command -v cliphist >/dev/null 2>&1; then
      # If raw contains an ID tab prefix from cliphist list
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
    if [ -f "$FALLBACK_FILE" ]; then
      > "$FALLBACK_FILE"
    fi
    ;;

  *)
    exit 1
    ;;
esac
