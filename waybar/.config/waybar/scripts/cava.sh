#!/bin/bash
# Config
BAR_LENGTH=10
CAVA_CONFIG_FILE="$HOME/.config/cava/config"
TEMP_LOG="/tmp/cava_waybar.log"

# Log function for debugging
log() {
    echo "[$(date)]: $1" >> "$TEMP_LOG"
}

log "Script started"

# Check if cava is installed
if ! command -v cava &> /dev/null; then
    log "Cava is not installed"
    echo '{"text": "Cava not installed", "tooltip": "Please install cava", "class": "error"}'
    exit 1
fi

# Create temporary config if it doesn't exist
if [ ! -f "$CAVA_CONFIG_FILE" ]; then
    log "Creating config file"
    mkdir -p "$(dirname "$CAVA_CONFIG_FILE")"
    cat > "$CAVA_CONFIG_FILE" << EOF
[general]
bars = $BAR_LENGTH
framerate = 30

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF
fi

# Check audio status
check_audio() {
    pactl list sinks | grep -q "State: RUNNING"
    return $?
}

# Function to convert cava output to waybar format
process_cava_output() {
    while read -r line; do
        # Log raw output for debugging
        log "Raw output: $line"
        
        # Convert cava raw output to unicode bars
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
        
        # Check if audio is playing
        if check_audio; then
            class="playing"
        else
            class="with-audio"
        fi
        
        # Output in waybar json format
        echo "{\"text\": \"$bars\", \"class\": \"$class\"}"
    done
}

# Main execution
log "Starting cava process"
# Default output if cava fails
echo '{"text": "▁▁▁▁▁▁▁▁▁▁", "class": "custom-cava-idle"}'

# Execute cava and process its output
cava -p "$CAVA_CONFIG_FILE" 2>> "$TEMP_LOG" | process_cava_output

log "Script ended unexpectedly"
echo '{"text": "▁▁▁▁▁▁▁▁▁▁", "class": "custom-cava-idle"}'ava_waybar_output
