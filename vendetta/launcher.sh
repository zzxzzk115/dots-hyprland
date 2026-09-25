#!/usr/bin/env bash
qs="$HOME/.local/share/end4-vendetta/repo/vendetta/qs"
if "$qs" -c ii ipc call search toggle >/dev/null 2>&1; then exit 0; fi
exec wofi --conf "$HOME/.config/hypr/wofi/config" --style "$HOME/.config/hypr/wofi/style.css"
