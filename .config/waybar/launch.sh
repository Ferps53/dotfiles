#!/bin/sh

killall .waybar-wrapped

waybar -c ~/.config/waybar/config.jsonc &
-s ~/.config/waybar/style.css
