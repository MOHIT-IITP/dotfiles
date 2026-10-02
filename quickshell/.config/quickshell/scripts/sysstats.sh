#!/usr/bin/env bash
# One-shot system stats snapshot for Quickshell SysStats (instant, no sleep).
# Prints a single JSON line: raw CPU counters (QML diffs them), memory/swap
# from /proc/meminfo, disk usage of /, and max thermal zone temp in °C.
python3 - <<'EOF'
import json

out = {}

try:
    with open("/proc/stat") as f:
        p = f.readline().split()
    vals = list(map(int, p[1:8]))
    out["cpuTotal"] = sum(vals)
    out["cpuIdle"] = vals[3] + vals[4]
except Exception:
    out["cpuTotal"] = 0
    out["cpuIdle"] = 0

try:
    mem = {}
    with open("/proc/meminfo") as f:
        for line in f:
            k, v = line.split(":", 1)
            mem[k.strip()] = int(v.split()[0])
    out["memTotalKB"] = mem.get("MemTotal", 0)
    out["memAvailKB"] = mem.get("MemAvailable", 0)
    out["swapTotalKB"] = mem.get("SwapTotal", 0)
    out["swapFreeKB"] = mem.get("SwapFree", 0)
except Exception:
    out["memTotalKB"] = 0
    out["memAvailKB"] = 0
    out["swapTotalKB"] = 0
    out["swapFreeKB"] = 0

try:
    import os
    st = os.statvfs("/")
    total = st.f_blocks * st.f_frsize
    avail = st.f_bavail * st.f_frsize
    out["diskTotalB"] = total
    out["diskUsedB"] = total - avail
except Exception:
    out["diskTotalB"] = 0
    out["diskUsedB"] = 0

try:
    import glob
    import os
    temps = []
    for z in glob.glob("/sys/class/thermal/thermal_zone*/temp"):
        try:
            with open(z) as f:
                t = int(f.read().strip())
            # millidegree vs degree heuristic
            temps.append(t // 1000 if t > 1000 else t)
        except Exception:
            pass
    # Fallback: hwmon sensors (e.g. k10temp Tctl on AMD, coretemp on Intel).
    if not temps:
        best = None
        for inp in glob.glob("/sys/class/hwmon/hwmon*/temp*_input"):
            try:
                with open(inp) as f:
                    t = int(f.read().strip())
                t = t // 1000 if t > 1000 else t
                label = ""
                try:
                    with open(inp.replace("_input", "_label")) as f:
                        label = f.read().strip().lower()
                except Exception:
                    pass
                if not (-20 < t < 125):
                    continue
                temps.append(t)
                if label in ("tctl", "tdie", "package id 0", "physical id 0"):
                    best = t
            except Exception:
                pass
        if best is not None:
            temps = [best]
    # Throw out absurd readings, take the max sane one.
    sane = [t for t in temps if -20 < t < 125]
    out["cpuTemp"] = max(sane) if sane else -1
except Exception:
    out["cpuTemp"] = -1

print(json.dumps(out))
EOF
