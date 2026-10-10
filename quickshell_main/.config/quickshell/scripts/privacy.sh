#!/usr/bin/env bash
# Camera / microphone usage probe for the Quickshell center-bar privacy dots.
# Prints a single JSON line: {"camera": bool, "mic": bool, "cameraApps": [], "micApps": []}
#
# Camera: any process holding /dev/video* open (found via /proc fd scan, so no
#   dependency on lsof/fuser; also catches xdg-desktop-portal while streaming).
# Mic: any PipeWire/Pulse capture stream on a NON-monitor source, ignoring our
#   own nxt-cava visualizer (it permanently captures the sink monitor, which is
#   desktop audio, not the microphone).

python3 - <<'EOF'
import json
import glob
import os
import subprocess

NOT_MUSIC_IGNORE = {"cava"}


def run(cmd, timeout=3):
    try:
        res = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return res.returncode, res.stdout
    except Exception:
        return -1, ""


# ---------------- microphone ----------------
mic = False
mic_apps = []

rc, out = run(["pactl", "-f", "json", "list", "source-outputs"])
outputs = []
if rc == 0 and out.strip():
    try:
        outputs = json.loads(out)
    except Exception:
        outputs = []

# Indexes of monitor sources (desktop-audio capture, not a mic).
monitors = set()
rc, out = run(["pactl", "-f", "json", "list", "sources"])
if rc == 0 and out.strip():
    try:
        for s in json.loads(out):
            name = s.get("name", "")
            if ".monitor" in name:
                monitors.add(s.get("index"))
                monitors.add(str(s.get("index")))
    except Exception:
        pass

for o in outputs:
    props = o.get("properties", {}) if isinstance(o, dict) else {}
    app = props.get("application.name", "") or props.get("node.name", "")
    binary = props.get("application.process.binary", "")
    # Our own visualizer captures the sink monitor permanently; never a mic.
    if binary in NOT_MUSIC_IGNORE or app == "cava":
        continue
    if props.get("stream.capture.sink") == "true":
        continue
    if o.get("source") in monitors:
        continue
    mic = True
    if app:
        mic_apps.append(str(app))

# ---------------- camera ----------------
camera = False
cam_apps = []

videos = glob.glob("/dev/video*")
if videos:
    targets = set()
    for v in videos:
        targets.add(v)
        try:
            targets.add(os.path.realpath(v))
        except Exception:
            pass
    try:
        pids = [p for p in os.listdir("/proc") if p.isdigit()]
    except Exception:
        pids = []
    for pid in pids:
        fd_dir = "/proc/%s/fd" % pid
        try:
            fds = os.listdir(fd_dir)
        except Exception:
            continue
        hit = False
        for fd in fds:
            try:
                link = os.readlink(os.path.join(fd_dir, fd))
            except Exception:
                continue
            # readlink gives e.g. "/dev/video0"; deleted devices show " (deleted)".
            if link.split(" ")[0] in targets:
                hit = True
                break
        if hit:
            try:
                with open("/proc/%s/comm" % pid) as f:
                    comm = f.read().strip()
            except Exception:
                comm = pid
            camera = True
            cam_apps.append(comm)

print(json.dumps({
    "camera": camera,
    "mic": mic,
    "cameraApps": sorted(set(cam_apps)),
    "micApps": sorted(set(mic_apps)),
}))
EOF
