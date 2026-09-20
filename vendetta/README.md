# Vendetta — Hyprland-only end-4 profile

Black/crimson end-4 Quickshell desktop with a generated V for Vendetta wallpaper
and a separate, decoration-free Kitty terminal. Based on upstream commit 2f0c8bf.

This profile intentionally retains the existing Hyprland 0.56 Lua window/input
configuration, integrating end-4's shell rather than running the broad upstream
installer. No KDE, Konsole, GTK, SDDM, boot or GPU-driver configuration is installed.

## Installed layout

- Source: `~/.local/share/end4-vendetta/repo`, branch `vendetta`.
- Private runtime: `~/.local/share/end4-vendetta/runtime`.
- Hyprland: `~/.config/hypr/hyprland.lua` and `session-start.sh`.
- Shell configuration: `~/.config/hypr/end4-session/illogical-impulse/config.json`.
- Palette: `~/.local/state/end4-vendetta/quickshell/user/generated/colors.json`.
- Session log: `~/.local/state/end4-vendetta/session.log`.
- Backup location is recorded in `~/.local/state/end4-vendetta/last-backup`.

The runtime was extracted from the configured CachyOS repositories, including
Quickshell 0.3.1, Kitty 0.48.2, their missing dependencies, cliphist, grim,
hyprpicker, brightnessctl and ddcutil. It is private to this profile and is not
managed by system pacman updates. After Qt/system upgrades, refresh this runtime
if library compatibility changes. Material Symbols Rounded is loaded privately
from Google's material-design-icons variable font; normal UI fonts use Noto Sans.

## Keys

| Shortcut | Action |
|---|---|
| Super+Enter | Kitty, no titlebar |
| Super+D | end-4 search |
| Super+Shift+D | fallback Wofi launcher |
| Super+Tab | workspace overview |
| Super+N | controls and notifications |
| Super+A | left sidebar |
| Super+I | end-4 settings |
| Super+Q | close window |
| Super+V | toggle floating |
| Super+1…9 | switch workspace |
| Super+Shift+1…9 | move window |
| Super+Shift+Escape | logout menu |

Wallpaper selection changes only the shell wallpaper. Automatic recoloring of
applications, Qt, GTK, editor and terminal is disabled. Dark/red is pinned.
KDE-conflict killing and first-run wallpaper replacement are disabled. Minor
upstream fixes handle the notification monitor setting, workspace padding and
invalid/virtual-monitor brightness values.

## Customize

Edit `vendetta/kitty.conf` for the terminal. Edit the installed `config.json` for
the shell layout. Edit `vendetta/colors.json`, then copy it to the installed
palette path above. The shell watches the palette for changes. Track deliberate
changes on this branch; merge upstream updates explicitly and review the theme
script and startup changes before applying them.

No automatic suspend/idle-lock daemon is enabled. Optional upstream features
such as OCR, AI, translation and screen recording are not provisioned by this
minimal profile. Keep the license notices from upstream when sharing changes.

## Roll back

Log out of Hyprland, enter KDE, and run `vendetta/rollback.sh`. It preserves the
current Hyprland directory alongside the backup and restores the original one.
It does not change KDE or delete the fork/runtime.
