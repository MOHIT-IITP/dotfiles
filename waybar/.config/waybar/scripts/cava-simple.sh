#!/bin/bash

# Prevent broken pipe errors
trap '' SIGPIPE

# Cleanup function to remove FIFO and stop cava on exit
cleanup() {
    pkill -x cava
    rm -f "$CAVA_FIFO"
}
trap cleanup EXIT

# Configuration
CAVA_FIFO="/tmp/cava_fifo"
CONFIG_DIR="$HOME/.config/cava"
CONFIG_FILE="$CONFIG_DIR/config"
BAR_LENGTH=10

# Create config directory
mkdir -p "$CONFIG_DIR"

# Create FIFO if it doesn't exist
if [ ! -p "$CAVA_FIFO" ]; then
    mkfifo "$CAVA_FIFO"
fi

# Generate cava config
cat > "$CONFIG_FILE" << EOF
[general]
bars = $BAR_LENGTH
framerate = 30

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = $CAVA_FIFO
data_format = ascii
ascii_max_range = 7
EOF

# Start cava if not running
if ! pgrep -x cava > /dev/null; then
    cava -p "$CONFIG_FILE" > /dev/null 2>&1 &
fi

# Default idle state
echo '{"text": "▁▁▁▁▁▁▁▁▁▁", "class": "custom-cava-idle"}'

# Read cava output and convert to Waybar JSON
while read -t 1 line < "$CAVA_FIFO"; do
    bars=""
    for i in $(seq 1 $BAR_LENGTH); do
        value=$(echo "$line" | cut -d';' -f$i)

        case $value in
            0) bar="▁" ;;
            1) bar="▂" ;;
            2) bar="▃" ;;
            3) bar="▄" ;;
            4) bar="▅" ;;
            5) bar="▆" ;;
            6) bar="▇" ;;
            7) bar="█" ;;
            *) bar="▁" ;;
        esac

        bars="${bars}${bar}"
    done

    # Output to Waybar
    if [[ "$bars" != "▁▁▁▁▁▁▁▁▁▁" ]]; then
        echo "{\"text\": \"$bars\", \"class\": \"playing\"}"
    else
        echo "{\"text\": \"$bars\", \"class\": \"with-audio\"}"
    fi
done

