#!/bin/bash

# Configuration
WALLPAPER_DIR="$HOME/pix/wall"  
LOG_FILE="$HOME/.cache/wallpaper_changer.log"

# Function to log messages
log_message() {
    echo "$(date): $1" >> "$LOG_FILE"
}

# Function to change wallpaper
change_wallpaper() {
    # Get random wallpaper
    wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)
    
    if [[ -n "$wallpaper" ]]; then
        log_message "Changing wallpaper to: $wallpaper"
        
        # Set wallpaper using swww
        swww img "$wallpaper" --transition-type center --transition-fps 120 --transition-duration 3

        # Generate colors with matugen
        sleep 3  # Wait for wallpaper to set
        matugen image "$wallpaper" --mode dark
        
        log_message "Wallpaper and colors updated successfully"
    else
        log_message "No wallpapers found in $WALLPAPER_DIR"
    fi
}

# Run once
log_message "Wallpaper changer started"
change_wallpaper

