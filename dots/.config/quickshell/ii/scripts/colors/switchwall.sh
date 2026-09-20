#!/usr/bin/env bash
# Vendetta: wallpaper changes never modify GTK, Qt, KDE or editor themes.
set -euo pipefail
python3 - "$@" <<'PY'
import json, os, sys
from pathlib import Path
path=Path(os.environ['XDG_CONFIG_HOME'])/'illogical-impulse/config.json'
config=json.loads(path.read_text())
for arg in sys.argv[1:]:
    image=Path(arg).expanduser()
    if image.is_file() and image.suffix.lower() in {'.png','.jpg','.jpeg','.webp','.avif'}:
        config.setdefault('background',{})['wallpaperPath']=str(image.resolve())
        path.write_text(json.dumps(config,indent=2)+'\n')
        break
PY
