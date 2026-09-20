#!/usr/bin/env bash
set -euo pipefail
case ${XDG_CURRENT_DESKTOP:-} in *Hyprland*|*hyprland*) echo 'Log out of Hyprland before restoring.' >&2; exit 1;; esac
state="$HOME/.local/state/end4-vendetta"
backup=$(cat "$state/last-backup")
[[ -d "$backup/hypr" ]] || exit 1
saved="$state/before-rollback-$(date +%Y%m%d-%H%M%S)"
mv "$HOME/.config/hypr" "$saved"
cp -a "$backup/hypr" "$HOME/.config/hypr"
printf 'Original Hyprland restored. Previous configuration saved at %s\n' "$saved"
