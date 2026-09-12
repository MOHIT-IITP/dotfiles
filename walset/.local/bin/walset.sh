# #!/bin/bash
#
# WALL_DIR="$HOME/pix"
#
#
# CWD="$(pwd)"
#
# cd "$WALL_DIR" || exit
#
# IFS=$'\n'
#
# SELECTED_WALL=$(for a in *.jpg *.png; do echo -en "$a\0icon\x1f$a\n" ; done | rofi -dmenu -p "" )
#
#
# if [ -n "$SELECTED_WALL" ]; then
#     walset-backend "$SELECTED_WALL"
# fi
#
# cd "$CWD"


#!/bin/bash

WALL_DIR="$HOME/pix"

cd "$WALL_DIR" || exit 1

SELECTED_WALL=$(
    for a in *.jpg *.jpeg *.png; do
        [ -f "$a" ] || continue
        printf '%s\0icon\x1f%s\n' "$a" "$a"
    done |
    rofi -dmenu -p ""
)

if [ -n "$SELECTED_WALL" ]; then
    walset-backend "$WALL_DIR/$SELECTED_WALL"
fi

