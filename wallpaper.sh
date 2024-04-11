#!/bin/sh

WALLPAPER=$(find ~/Pictures/Wallpaper -type f | shuf -n 1)

hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper "eDP-1,$WALLPAPER"
hyprctl hyprpaper unload "$WALLPAPER"