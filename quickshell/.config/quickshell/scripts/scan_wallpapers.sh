#!/bin/bash

# Scan wallpapers in ~/Pictures/Wallpapers or custom directory and output JSON
WALLPAPER_DIR="${1:-$HOME/Pictures/Wallpapers}"

python3 -c "
import os, json, sys

raw_dir = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] else '~/Pictures/Wallpapers'
dir_path = os.path.expanduser(raw_dir)
if not os.path.isdir(dir_path):
    # Fallback to ~/pix if ~/Pictures/Wallpapers does not exist
    fallback = os.path.expanduser('~/pix')
    if os.path.isdir(fallback):
        dir_path = fallback
exts = ('.jpg', '.jpeg', '.png', '.webp', '.gif', '.mp4')
files = []

if os.path.isdir(dir_path):
    for f in sorted(os.listdir(dir_path)):
        if any(f.lower().endswith(e) for e in exts) and not f.startswith('.'):
            full = os.path.join(dir_path, f)
            is_live = f.lower().endswith(('.mp4', '.gif'))
            files.append({
                'name': f,
                'path': full,
                'isLive': is_live
            })

print(json.dumps(files))
" "$WALLPAPER_DIR"
