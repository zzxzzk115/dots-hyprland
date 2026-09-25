#!/usr/bin/env bash
set -u
[[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] || exit 0
case ${XDG_CURRENT_DESKTOP:-} in *Hyprland*|*hyprland*) ;; *) exit 0 ;; esac
base="$HOME/.local/share/end4-vendetta"
mkdir -p "$HOME/.local/state/end4-vendetta"
dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE
systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE
systemctl --user daemon-reload
# Initialize X11 DPI before starting desktop applications.
python3 "$HOME/.config/hypr/monitors.py"
python3 "$HOME/.config/hypr/session-autostart-guard.py" &
if ! pgrep -u "$(id -u)" -f '^/usr/lib/polkit-kde-authentication-agent-1' >/dev/null; then
    /usr/lib/polkit-kde-authentication-agent-1 &
fi
"$base/repo/vendetta/qs" -c ii > "$HOME/.local/state/end4-vendetta/session.log" 2>&1 &
shell_pid=$!
wl-paste --type text --watch "$base/repo/vendetta/clipboard-store" &
text_watcher=$!
wl-paste --type image --watch "$base/repo/vendetta/clipboard-store" &
image_watcher=$!
if ! pgrep -u "$(id -u)" -x fcitx5 >/dev/null; then fcitx5 -d; fi
wait "$shell_pid"
kill "$text_watcher" "$image_watcher" 2>/dev/null || true
# If the shell cannot start, retain a usable launcher, wallpaper, bar and notifications.
hyprctl -j monitors >/dev/null 2>&1 || exit 0
waybar --config "$HOME/.config/hypr/waybar/config.jsonc" --style "$HOME/.config/hypr/waybar/style.css" &
hyprpaper &
mako --config "$HOME/.config/hypr/mako/config" &
