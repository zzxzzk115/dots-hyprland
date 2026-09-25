#!/usr/bin/env python3
"""Tie XDG autostart to the actual compositor, including unclean logout."""
import os
import subprocess
import time

signature = os.environ.get('HYPRLAND_INSTANCE_SIGNATURE')
if not signature:
    raise SystemExit(0)

def compositor_alive():
    try:
        return subprocess.run(['hyprctl', '-j', 'monitors'],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=3).returncode == 0
    except (OSError, subprocess.TimeoutExpired):
        return False

if not compositor_alive():
    raise SystemExit(0)
subprocess.run(['systemctl', '--user', 'start', 'hyprland-app-autostart.target'], check=True)
while compositor_alive():
    time.sleep(1)
# Never stop a newer Hyprland session that has already taken over.
manager_env = subprocess.check_output(['systemctl', '--user', 'show-environment'], text=True)
current = next((s.split('=', 1)[1] for s in manager_env.splitlines()
                if s.startswith('HYPRLAND_INSTANCE_SIGNATURE=')), None)
if current is None or current == signature:
    subprocess.run(['systemctl', '--user', 'stop', 'hyprland-app-autostart.target'], check=True)
