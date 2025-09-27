
#!/bin/bash

choice=$(printf "⏻ Poweroff\n Reboot\n Logout" | rofi -dmenu -i -p "Power Menu")

case "$choice" in
    *Logout) hyprctl dispatch exit ;;
    *Reboot) systemctl reboot ;;
    *Poweroff) systemctl poweroff ;;
esac
