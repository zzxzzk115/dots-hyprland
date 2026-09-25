#!/bin/sh
exec wofi --dmenu --prompt 'Hyprland shortcuts (Meta = Super)' --width 760 --height 620 < "$HOME/.config/hypr/keybindings.txt"
