#!/usr/bin/env python3
"""Deploy only the Hyprland profile; dry-run unless --apply is supplied."""
import argparse
import datetime
import json
from pathlib import Path
import shutil

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--apply', action='store_true')
args = parser.parse_args()
source = Path(__file__).resolve().parents[1]
repo = source.parent
home = Path.home()
base = home / '.local/share/end4-vendetta'
if repo != base / 'repo':
    raise SystemExit('Clone this branch to ~/.local/share/end4-vendetta/repo first.')
config = home / '.config/hypr'
files = ['hyprland.lua', 'workspace-rules.lua', 'session-start.sh', 'session-autostart-guard.py',
         'monitors.py', 'browser.sh', 'launcher.sh', 'keybindings.sh', 'keybindings.txt', 'logout-menu.sh']
print('Deploy:', ', '.join(files), 'and wofi/waybar/mako; isolated Quickshell settings and palette.')
print('Existing Hyprland files will be backed up. No KDE, drivers or login manager changes.')
if not args.apply:
    print('Plan only; use --apply after provisioning the private runtime.')
    raise SystemExit(0)
for name in ['quickshell', 'kitty', 'grim', 'cliphist']:
    if not (base / 'runtime/usr/bin' / name).is_file():
        raise SystemExit('Missing private runtime binary: ' + name)
backup = home / '.local/state/end4-vendetta' / ('deploy-backup-' + datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
backup.mkdir(parents=True)
if config.exists():
    shutil.copytree(config, backup / 'hypr', symlinks=True)
config.mkdir(parents=True, exist_ok=True)
for name in files:
    shutil.copy2(source / name, config / name)
for name in ['wofi', 'waybar', 'mako']:
    shutil.copytree(source / name, config / name, dirs_exist_ok=True)
for p in config.rglob('*.in'):
    p.with_suffix('').write_text(p.read_text().replace('@HOME@', str(home)))
(config / 'hyprpaper.conf').write_text((source / 'hyprpaper.conf.in').read_text().replace('@HOME@',str(home)))
shell = config / 'end4-session/quickshell/ii'
shell.parent.mkdir(parents=True, exist_ok=True)
if shell.is_symlink() or shell.is_file(): shell.unlink()
elif shell.exists(): shutil.move(str(shell), str(backup / 'quickshell-ii'))
shell.symlink_to(repo / 'dots/.config/quickshell/ii', target_is_directory=True)
settings = config / 'end4-session/illogical-impulse/config.json'
settings.parent.mkdir(parents=True, exist_ok=True)
if not settings.exists():
    text = (source / 'config.json').read_text().replace('@WALLPAPER@',str(source/'wallpaper.png')).replace('@KITTY@',str(source/'kitty'))
    json.loads(text)
    settings.write_text(text)
palette = home / '.local/state/end4-vendetta/quickshell/user/generated/colors.json'
palette.parent.mkdir(parents=True, exist_ok=True)
if palette.exists(): shutil.copy2(palette, backup/'colors.json')
shutil.copy2(source/'colors.json',palette)
units = home / '.config/systemd/user'
units.mkdir(parents=True,exist_ok=True)
unit = 'hyprland-app-autostart.target'
if (units/unit).exists(): shutil.copy2(units/unit,backup/unit)
shutil.copy2(source/'systemd/user'/unit, units/unit)
print('Backup:', backup)
print('Next: install optional Fcitx service/helpers per RESTORE.md; systemctl --user daemon-reload; log into Hyprland.')
