#!/usr/bin/env bash
set -u
[[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] || exit 0
choice=$(printf 'Cancel\nLog out of Hyprland\n' | wofi --dmenu --prompt 'Session' --width 360 --height 160 --style "$HOME/.config/hypr/wofi/style.css") || exit 0
if [[ "$choice" == 'Log out of Hyprland' ]]; then
    hyprctl dispatch 'hl.dsp.exit()'
fi
