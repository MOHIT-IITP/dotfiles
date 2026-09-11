#!/usr/bin/env bash

dir="$HOME/.config/rofi/type-2"
theme='style-15'

## Run
pkill rofi || rofi \
    -show drun \
    -theme ${dir}/${theme}.rasi
