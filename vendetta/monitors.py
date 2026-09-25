#!/usr/bin/env python3
import json,subprocess,fcntl,os
from pathlib import Path
if 'hyprland' not in os.environ.get('XDG_CURRENT_DESKTOP', '').lower():
 raise SystemExit
lock=open(Path(os.environ['XDG_RUNTIME_DIR'])/'vendetta-monitors.lock','w')
try:fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
except BlockingIOError:raise SystemExit
monitors=json.loads(subprocess.check_output(['hyprctl','-j','monitors','all'],text=True))
external=[m for m in monitors if not m['name'].startswith(('eDP','LVDS')) and not m.get('disabled',False)]
def apply(spec):
 fields=','.join(k+'='+('true' if v is True else 'false' if v is False else str(v) if isinstance(v,(int,float)) else json.dumps(v)) for k,v in spec.items())
 subprocess.run(['hyprctl','eval','hl.monitor({'+fields+'})'],check=True)
for m in external:
 if m['name']=='HDMI-A-1' and m['model']=='27M2N5800P':
  if abs(m['refreshRate']-119.88)>.1 or abs(m['scale']-1.666667)>.001:
   apply(dict(output=m['name'],mode='3840x2160@119.88',position='0x0',scale=1.666667))
for m in monitors:
 if m['name'].startswith(('eDP','LVDS')):
  disabled=bool(external)
  if bool(m.get('disabled',False))!=disabled:
   if disabled:apply(dict(output=m['name'],disabled=True))
   else:apply(dict(output=m['name'],disabled=False,mode='preferred',position='0x0',scale='auto'))

# XWayland windows render at native resolution. Supply the matching font/UI
# DPI so Steam and X11 input-method panels follow the active monitor scale.
active = json.loads(subprocess.check_output(['hyprctl', '-j', 'monitors'], text=True))
active = [m for m in active if not m.get('disabled', False)]
if active and os.environ.get('DISPLAY'):
    dpi = round(96 * max(float(m['scale']) for m in active))
    current = subprocess.run(['xrdb', '-query'], capture_output=True, text=True, timeout=5)
    value = next((line.split(':', 1)[1].strip() for line in current.stdout.splitlines()
                  if line.startswith('Xft.dpi:')), '')
    if current.returncode == 0 and value != str(dpi):
        subprocess.run(['xrdb', '-merge', '-nocpp'], input=f'Xft.dpi: {dpi}\n',
                       text=True, check=True, timeout=5)
