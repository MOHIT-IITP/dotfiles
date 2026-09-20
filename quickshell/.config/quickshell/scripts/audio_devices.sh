#!/usr/bin/env bash
# Audio input and output device manager for Quickshell

CMD="$1"
shift

python3 - "$CMD" "$@" <<'EOF'
import sys
import json
import subprocess
import re

def run_cmd(cmd):
    try:
        res = subprocess.run(cmd, capture_output=True, text=True, timeout=2)
        return res.returncode, res.stdout
    except Exception:
        return -1, ""

def get_default_nodes():
    default_sink = ""
    default_source = ""
    rc, out = run_cmd(["pactl", "info"])
    if rc == 0:
        for line in out.splitlines():
            if "Default Sink:" in line:
                default_sink = line.split(":", 1)[1].strip()
            elif "Default Source:" in line:
                default_source = line.split(":", 1)[1].strip()
    return default_sink, default_source

def list_devices_pactl(kind):
    # kind: 'sinks' or 'sources'
    def_sink, def_source = get_default_nodes()
    target_def = def_sink if kind == "sinks" else def_source

    rc, out = run_cmd(["pactl", "-f", "json", "list", kind])
    if rc == 0 and out.strip():
        try:
            items = json.loads(out)
            devices = []
            for item in items:
                name = item.get("name", "")
                props = item.get("properties", {})
                desc = (
                    item.get("description")
                    or props.get("node.nick")
                    or props.get("device.description")
                    or props.get("alsa.name")
                    or props.get("device.nick")
                    or name
                )
                
                # Filter out monitor sources if looking for mic sources
                if kind == "sources" and (".monitor" in name or props.get("device.class") == "monitor"):
                    continue

                node_id = props.get("object.id") or item.get("index") or 0
                try:
                    node_id = int(node_id)
                except Exception:
                    pass

                is_default = (name == target_def)
                devices.append({
                    "id": node_id,
                    "name": name,
                    "description": str(desc),
                    "isDefault": is_default
                })
            if devices:
                return devices
        except Exception:
            pass

    # Fallback to wpctl status
    rc, out = run_cmd(["wpctl", "status"])
    if rc == 0:
        devices = []
        target_section = "Sinks:" if kind == "sinks" else "Sources:"
        in_section = False
        for line in out.splitlines():
            if target_section in line:
                in_section = True
                continue
            if in_section:
                # Check for section end
                if re.match(r'^\s*[├└]─\s+[A-Za-z]', line) or (re.match(r'^\s*$', line) and devices):
                    if not re.search(r'│\s*[*]?\s*\d+\.', line):
                        break
                m = re.search(r'([*]?)\s*(\d+)\.\s+(.*?)(?:\s+\[.*\])?$', line)
                if m:
                    is_def = (m.group(1) == "*")
                    node_id = int(m.group(2))
                    desc = m.group(3).strip()
                    desc = re.sub(r'\[vol:.*?\]', '', desc).strip()
                    devices.append({
                        "id": node_id,
                        "name": str(node_id),
                        "description": desc,
                        "isDefault": is_def
                    })
        if devices:
            return devices

    return []

cmd = sys.argv[1] if len(sys.argv) > 1 else ""
arg = sys.argv[2] if len(sys.argv) > 2 else ""

if cmd == "sinks":
    devs = list_devices_pactl("sinks")
    print(json.dumps(devs))

elif cmd == "sources":
    devs = list_devices_pactl("sources")
    print(json.dumps(devs))

elif cmd == "set-sink":
    if arg:
        if arg.isdigit():
            run_cmd(["wpctl", "set-default", arg])
            run_cmd(["pactl", "set-default-sink", arg])
        else:
            run_cmd(["pactl", "set-default-sink", arg])
            run_cmd(["wpctl", "set-default", arg])
    print("ok")

elif cmd == "set-source":
    if arg:
        if arg.isdigit():
            run_cmd(["wpctl", "set-default", arg])
            run_cmd(["pactl", "set-default-source", arg])
        else:
            run_cmd(["pactl", "set-default-source", arg])
            run_cmd(["wpctl", "set-default", arg])
    print("ok")

else:
    print(json.dumps([]))
EOF
