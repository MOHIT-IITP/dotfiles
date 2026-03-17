#!/usr/bin/env bash

killall -q polybar

# Load pywal colors into xrdb
xrdb -merge ~/.cache/wal/colors.Xresources

# Launch bar
polybar main &
