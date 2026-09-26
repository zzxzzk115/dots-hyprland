"""Small, bounded NVIDIA and root-filesystem sampler for the bar."""
import csv
import json
import shutil
import subprocess

result = {"gpu": None, "disk": None}
try:
    disk = shutil.disk_usage("/")
    result["disk"] = {"used": disk.used, "free": disk.free, "total": disk.total,
                      "usage": disk.used / disk.total if disk.total else 0}
except OSError:
    pass
try:
    sample = subprocess.run(
        ["nvidia-smi", "--query-gpu=name,utilization.gpu,memory.used,memory.total,temperature.gpu",
         "--format=csv,noheader,nounits"], capture_output=True, text=True, timeout=3, check=True)
    row = next(csv.reader(sample.stdout.splitlines()))
    result["gpu"] = {"name": row[0].strip(), "usage": float(row[1]) / 100,
                     "memoryUsed": float(row[2]), "memoryTotal": float(row[3]),
                     "temperature": float(row[4])}
except (OSError, subprocess.SubprocessError, ValueError, IndexError, StopIteration):
    pass
print(json.dumps(result))
