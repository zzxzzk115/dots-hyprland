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
| Super+T | toggle floating |
| Super+V | clipboard history |
| Super+B | Edge browser |
| Super+Space / Super+Ctrl+Enter | application launcher |
| Super+Print | region screenshot; plain Print is unbound |
| Super+Ctrl+K | shortcut reference |
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

## September 2026 configuration sync

This branch preserves the main local desktop changes, including the existing
network/media work. It is configuration source, not a full-machine backup.
Do not run the broad upstream installer to apply this profile.

- Monitor hotplug: disable the internal panel when an external display is active,
  restore it after disconnect, and set XWayland font DPI from active scaling.
  `monitors.py` includes a Philips 27M2N5800P / HDMI-A-1 override for
  3840×2160@119.88 at scale 1.666667. Adjust this on other machines.
- ML4W-style application bindings, shortcut reference, launcher fallback, and
  browser/terminal wrappers that isolate private runtime libraries.
- A compositor lifetime guard controls XDG autostart and cleans up after logout.
- Quickshell remaining-quota indicator, network throughput, Cider favorites,
  OmniLyrics integration and expanded media controls.
- Optional ChatGPT scaling wrapper, WinBoat EXE launcher and Plasma quota widget.

### Deployment map

Keep the repository at `~/.local/share/end4-vendetta/repo`, with the separately
provisioned runtime at the sibling `runtime` directory. Back up before deploying.
This sync does not reinstall or reload the current desktop.

| Source under vendetta/ | Destination |
|---|---|
| hyprland.lua, workspace-rules.lua, session-start.sh, session-autostart-guard.py, monitors.py | ~/.config/hypr/ |
| browser.sh, launcher.sh, keybindings.sh, keybindings.txt, logout-menu.sh | ~/.config/hypr/ |
| waybar/, wofi/, mako/ | corresponding directories in ~/.config/hypr/ |
| systemd/user/hyprland-app-autostart.target | ~/.config/systemd/user/ |
| optional/bin/* | ~/.local/bin/ (choose integrations individually) |
| systemd/user/codex-usage.service and codex-usage.timer | ~/.config/systemd/user/ (quota only) |
| optional/plasma/local.workbench.codexusage/ | ~/.local/share/plasma/plasmoids/ (optional KDE widget) |
| optional/applications/*.desktop.in | ~/.local/share/applications/*.desktop after rendering |

Render `@HOME@` in `.in` files to your absolute home directory, removing `.in`.
`hyprpaper.conf.in` is the fallback wallpaper configuration. Render `@WALLPAPER@`
and `@KITTY@` in `config.json` to the absolute paths in this repository, then merge
these defaults into `~/.config/hypr/end4-session/illogical-impulse/config.json`.
Keep its sibling `quickshell/ii` linked to `dots/.config/quickshell/ii`. Preserve
other existing preferences; do not copy expanded personal shell state into Git.

After installing units, use `systemctl --user daemon-reload`. The session script
starts the Hyprland autostart target; do not enable it globally for KDE. Enable
the optional quota timer with `systemctl --user enable --now codex-usage.timer`.

### Optional integration requirements

Quota: an installed ChatGPT/Codex app at `/usr/lib/chatgpt/resources/codex` and
an existing login. Quickshell, Waybar and the optional Plasma widget show remaining
quota, with details on hover/click. No login or quota cache is committed.
The ChatGPT wrapper assumes `/usr/bin/chatgpt`, uses scaled XWayland on Hyprland,
and keeps the normal launch path on KDE.

Cider favorites reads an existing local API token from `CIDER_TOKEN_FILE` or
`~/.config/omnilyrics/cider-token`. No token is included. OmniLyrics needs its
separately built CLI; set `OMNILYRICS_EXECUTABLE`, or use the local build path in
`services/OmniLyrics.qml`. This repository does not install either application.

WinBoat: an existing configured container named `WinBoat`, running Docker daemon,
FreeRDP 3, Python/PyYAML, kdialog and notify-send. Credentials are read at runtime
and sent over stdin, not stored in this repo. Render the desktop template, update
the desktop database, and optionally use `xdg-mime default winboat-exe.desktop`
for each of `application/vnd.microsoft.portable-executable`,
`application/x-ms-dos-executable`, `application/x-msdownload`. This association
is shared by KDE and Hyprland. It shares the EXE's folder read/write and supplies
no GPU acceleration. Live launch was verified; cold start was only simulated.

### Isolation and excluded state

The original machine masks the user `mako.service` to prevent it from replacing
Plasma notifications; the Hyprland fallback starts Mako directly. This mask is
not deployed automatically because other machines may intentionally use Mako.
Automatic global GTK/Qt/browser recoloring stays disabled. Edge profile databases
are not included.

CUDA/Nsight/JetBrains packages and GPU permission policies are outside this
dotfiles sync. So are runtime binaries, Windows images, browser/login databases,
personal tasks/notes, lyrics caches, API tokens and KDE panel placement.


## Workspace categories (scheme A)

`workspace-rules.lua` is loaded by the Hyprland config. Install both files together.
New non-floating, non-modal main windows are assigned once with `silent`; existing
windows and manually moved windows are not periodically rearranged. Unknown apps,
terminals and Dolphin stay where opened. Workspace numbers and navigation keys
remain unchanged; Super+0 selects workspace 10.

| Workspace | Category | Examples |
|---|---|---|
| 1 | Browser | Edge, Firefox, Chromium |
| 2 | Development | CLion/JetBrains, VS Code, CMake GUI |
| 3 | Terminal/system | System Monitor, System Settings, Remmina; terminals stay local |
| 4 | Research | Zotero, Obsidian, Okular, TeXstudio |
| 5 | Graphics | Godot, Blender, RenderDoc, Nsight |
| 6 | AI | ChatGPT, Codex, Claude |
| 7 | Communication | WeChat, QQ, Discord, Feishu, Telegram |
| 8 | Office/Windows | LibreOffice, WPS, meetings, WinBoat |
| 9 | Entertainment | Cider, Spotify, Steam, video players |
| 10 | Temporary | No automatic assignments |

Browser-hosted Jupyter/AI tools remain with the browser. Native app identifiers
can vary with packaging; extend the class expressions using `hyprctl clients -j`.
WinBoat defaults to workspace 8; a Cells of Division initial-title exception goes
to 9 if its RemoteApp main window is non-floating and already has that title at
creation. Other Windows games need specific rules. Dialogs intentionally do not
match, leaving their normal compositor/application placement intact.

Validation: the compositor accepted all rules with no configuration errors. Ten
temporary Kitty windows with representative app IDs verified routes 1–9 and the
unclassified fallback, with no active-workspace change. These tests validate rule
behavior, not every application's actual startup identifier or dialog behavior.


Workspace display names are now Browser, Development, System, Research, Graphics,
AI, Communication, Office, Entertainment and Temporary (IDs 1–10 unchanged).
The compact bar retains its icons/numbers and shows the category on hover.

Optional `code` wrapper expects the Microsoft stable archive unpacked under
`~/.local/opt/vscode-1.139.1/VSCode-linux-x64`; render `code.desktop.in` as above.
This is a user-local installation, not a pacman-managed package; update the
archive directory and launcher/icon paths when upgrading. Native Wayland on
Hyprland was verified, with the actual Code window opening on workspace 2.
The `linuxqq` wrapper similarly isolates shell environment and selects Wayland
only on Hyprland; its expected app directory is version-specific. Neither
application binary nor its personal settings are committed.


## Screenshot modes

- Super+Print opens the selector (plain Print remains unbound).
- Super+Shift+Print opens explicit window selection; click a window to copy it.
- Super+Ctrl+Print copies the focused monitor immediately.
- The toolbar offers Region, Window, Current Screen and Circle. Current Screen
  captures the monitor containing that toolbar; this is not a multi-monitor mosaic.
- Inside the selector: R = Region, W = Window, F = capture current screen.
  Escape or right-click cancels. Selection copies to the clipboard, or also saves
  to the configured screenSnip.savePath when that preference is set.

Window mode ignores content-region detection and uses exact window bounds,
clipped to the selected monitor. It does not recover pixels hidden behind other
windows. Optional content detection failures no longer throw JSON parse errors.
An empty click keeps the picker open. Right-click now cancels rather than opening
an optional external editor. New screenshot requests first dismiss the old overlay.

Validated live: toolbar layout, window-picker layer creation, switching from the
picker to focused-monitor capture (3840×2160 PNG), region open/cancel, and Hyprland
configuration loading. Multi-monitor and manual window-click capture still need
user validation on the intended layout.
