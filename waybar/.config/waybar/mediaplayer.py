#!/usr/bin/env python3
import json
import subprocess
import sys

def parse_metadata(player=None):
    cmd = ["playerctl"]
    if player:
        cmd += ["--player", player]
    cmd += [
        "metadata",
        "--format",
        '{"text": "{{artist}} - {{title}}", "tooltip": "Album: {{album}}\\nTitle: {{title}}\\nArtist: {{artist}}", "alt": "{{status}}", "class": "{{status}}"}'
    ]

    try:
        metadata = subprocess.check_output(cmd, text=True)
        return json.loads(metadata)
    except subprocess.CalledProcessError:
        return {
            "text": "No media",
            "tooltip": "No active media players",
            "alt": "stopped",
            "class": "stopped"
        }
    except json.JSONDecodeError:
        return {
            "text": "Error",
            "tooltip": "Error parsing player metadata",
            "alt": "error",
            "class": "error"
        }

if __name__ == "__main__":
    player = None
    if len(sys.argv) > 1 and sys.argv[1].startswith("--player="):
        player = sys.argv[1].split("=")[1]

    try:
        print(json.dumps(parse_metadata(player)))
    except Exception as e:
        error_data = {
            "text": "Error",
            "tooltip": f"Error: {str(e)}",
            "alt": "error",
            "class": "error"
        }
        print(json.dumps(error_data))
