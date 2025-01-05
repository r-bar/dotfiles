#!/bin/bash

img=${1:-/usr/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png}

#Uses output image with Swaylock
swaylock \
--image "$img" \
--indicator-caps-lock \
--ignore-empty-password \
--show-failed-attempts \
--show-keyboard-layout \
--font=Ubuntu \
--inside-color 1b1b1b \
--inside-clear-color eeeeee \
--ring-color 3B758C \
--ring-clear-color 9fca56 \
--ring-ver-color 2980b9 \
--daemonize
