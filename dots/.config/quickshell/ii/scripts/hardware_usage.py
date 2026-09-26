"""Small, bounded NVIDIA and root-filesystem sampler for the bar."""
from pathlib import Path
import csv
import json
import shutil
import subprocess

result = {"gpu": None, "disk": None, "cpuTemperature": None}
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
# Use CPU package sensors, never ACPI, Wi-Fi or disk temperatures.
package_temperatures = []
for device in Path("/sys/class/hwmon").glob("hwmon*"):
    try:
        if (device / "name").read_text().strip() not in ("coretemp", "k10temp", "zenpower"):
            continue
        for sensor in device.glob("temp*_input"):
            try:
                label = sensor.with_name(sensor.name.replace("_input", "_label")).read_text().strip()
                if not (label.startswith("Package id") or label in ("Tctl", "Tdie")):
                    continue
                temperature = float(sensor.read_text().strip()) / 1000
                if -20 <= temperature <= 150:
                    package_temperatures.append(temperature)
            except (OSError, ValueError):
                continue
    except OSError:
        continue
if package_temperatures:
    result["cpuTemperature"] = max(package_temperatures)
print(json.dumps(result))
