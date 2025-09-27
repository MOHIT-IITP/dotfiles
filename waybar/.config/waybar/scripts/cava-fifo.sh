#!/bin/bash

# Configuration
CAVA_FIFO="/tmp/cava_fifo"
CONFIG_DIR="$HOME/.config/cava"
CONFIG_FILE="$CONFIG_DIR/config"
BAR_LENGTH=10

# Create necessary directories and files
mkdir -p "$CONFIG_DIR"

# Create FIFO if it doesn't exist
if [ ! -p "$CAVA_FIFO" ]; then
    mkfifo "$CAVA_FIFO"
fi

# Create cava configuration
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

# Check if cava is already running
if ! pgrep -x cava > /dev/null; then
    # Start cava in background
    cava -p "$CONFIG_FILE" > /dev/null 2>&1 &
fi

# Default output
echo '{"text": "▁▁▁▁▁▁▁▁▁▁", "class": "custom-cava-idle"}'

# Read from FIFO and convert to waybar format
{
    # Set a timeout to handle possible errors
    sleep 0.5
    
    while read -t 1 line; do
        # Convert cava output to unicode bars
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
        
        # Output in waybar json format
        if [[ "$bars" != "▁▁▁▁▁▁▁▁▁▁" ]]; then
            echo "{\"text\": \"$bars\", \"class\": \"playing\"}"
        else
            echo "{\"text\": \"$bars\", \"class\": \"with-audio\"}"
        fi
    done < "$CAVA_FIFO"
} &

# Wait a bit to ensure the reading process has started
sleep 1

# Keep the script running - this is needed for Waybar modules
wait
