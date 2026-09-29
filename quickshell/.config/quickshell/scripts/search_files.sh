#!/bin/bash
# Fast file search for Quickshell file launcher.
# Usage: search_files.sh <query> [base_dir] [limit]
# Outputs one absolute path per line (up to <limit>).
QUERY="${1:-}"
BASE="${2:-$HOME}"
LIMIT="${3:-60}"

# Empty query: list visible top-level entries of $BASE (dirs first, then files)
if [ -z "$QUERY" ]; then
  ls -1 --group-directories-first "$BASE" 2>/dev/null | head -n "$LIMIT" | while IFS= read -r f; do
    p="$BASE/$f"
    if [ -d "$p" ]; then printf 'd\t%s\n' "$p"; else printf 'f\t%s\n' "$p"; fi
  done
  exit 0
fi

if command -v fd >/dev/null 2>&1; then
  fd -i -H -a --max-results "$LIMIT" \
    -E '.git' -E '.cache' -E '.mozilla' -E '.local/share/Trash' \
    -E '__pycache__' -E 'node_modules' -E '.npm' -E '.cargo' \
    "$QUERY" "$BASE" 2>/dev/null | head -n "$LIMIT" | while IFS= read -r p; do
    if [ -d "$p" ]; then printf 'd\t%s\n' "$p"; else printf 'f\t%s\n' "$p"; fi
  done
else
  # Fallback: case-insensitive find, pruned for speed
  find "$BASE" -maxdepth 5 \( -name '.cache' -o -name '.git' -o -name 'node_modules' -o -name '__pycache__' \) -prune -o -iname "*${QUERY}*" -print 2>/dev/null | head -n "$LIMIT" | while IFS= read -r p; do
    if [ -d "$p" ]; then printf 'd\t%s\n' "$p"; else printf 'f\t%s\n' "$p"; fi
  done
fi
