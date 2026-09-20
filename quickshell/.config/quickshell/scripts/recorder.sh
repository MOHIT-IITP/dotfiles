#!/usr/bin/env bash
# Screen recording backend script for Quickshell on Wayland / Hyprland

CMD="$1"
shift

RECORD_DIR="${XDG_VIDEOS_DIR:-$HOME/Videos}/Recordings"
mkdir -p "$RECORD_DIR"
PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/quickshell_recorder.pid"

is_running() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE" 2>/dev/null)
        if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
            return 0
        fi
    fi
    pgrep -x gpu-screen-recorder >/dev/null 2>&1 || pgrep -x wf-recorder >/dev/null 2>&1 || pgrep -x wl-screenrec >/dev/null 2>&1
}

case "$CMD" in
    status)
        if is_running; then
            echo '{"isRecording": true}'
        else
            echo '{"isRecording": false}'
        fi
        ;;

    start)
        if is_running; then
            echo '{"status": "already_running"}'
            exit 0
        fi

        AUDIO="${1:-both}"
        FILENAME="recording_$(date +%Y-%m-%d_%H-%M-%S).mp4"
        OUTPATH="$RECORD_DIR/$FILENAME"

        # Primary recorder: gpu-screen-recorder (hardware NVENC, mixed audio tracks)
        if command -v gpu-screen-recorder >/dev/null 2>&1; then
            AUDIO_ARGS=()
            if [ "$AUDIO" = "mic" ]; then
                AUDIO_ARGS=(-a "default_input")
            elif [ "$AUDIO" = "desktop" ]; then
                AUDIO_ARGS=(-a "default_output")
            elif [ "$AUDIO" = "both" ]; then
                # Merge desktop and microphone into a single mixed audio track
                AUDIO_ARGS=(-a "default_output|default_input")
            fi

            nohup gpu-screen-recorder -w screen -f 60 -q high "${AUDIO_ARGS[@]}" -o "$OUTPATH" >/dev/null 2>&1 &
            echo $! > "$PID_FILE"

        elif command -v wf-recorder >/dev/null 2>&1; then
            AUDIO_ARGS=""
            if [ "$AUDIO" = "mic" ] || [ "$AUDIO" = "both" ]; then
                AUDIO_ARGS="--audio"
            fi
            nohup wf-recorder $AUDIO_ARGS -f "$OUTPATH" >/dev/null 2>&1 &
            echo $! > "$PID_FILE"

        elif command -v wl-screenrec >/dev/null 2>&1; then
            AUDIO_ARGS=""
            if [ "$AUDIO" = "mic" ] || [ "$AUDIO" = "both" ]; then
                AUDIO_ARGS="--audio"
            fi
            nohup wl-screenrec $AUDIO_ARGS -f "$OUTPATH" >/dev/null 2>&1 &
            echo $! > "$PID_FILE"

        else
            notify-send "Screen Recorder" "No recorder found (please install gpu-screen-recorder or wf-recorder)" -i dialog-error
            echo '{"status": "no_recorder"}'
            exit 1
        fi

        notify-send "Screen Recorder" "Fullscreen recording started..." -i media-record
        echo '{"status": "started", "file": "'"$OUTPATH"'"}'
        ;;

    stop)
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE" 2>/dev/null)
            if [ -n "$PID" ]; then
                kill -SIGINT "$PID" 2>/dev/null || kill -INT "$PID" 2>/dev/null
            fi
            rm -f "$PID_FILE"
        fi
        pkill -SIGINT -x gpu-screen-recorder 2>/dev/null || pkill -SIGINT -x wf-recorder 2>/dev/null || pkill -SIGINT -x wl-screenrec 2>/dev/null
        sleep 0.6
        notify-send "Screen Recorder" "Recording saved to ~/Videos/Recordings" -i video-x-generic
        echo '{"status": "stopped"}'
        ;;

    list)
        python3 - "$RECORD_DIR" <<'EOF'
import sys
import os
import json
from datetime import datetime

rdir = sys.argv[1]
if not os.path.exists(rdir):
    print("[]")
    sys.exit(0)

entries = []
valid_exts = {".mp4", ".mkv", ".webm", ".mov"}

for f in os.listdir(rdir):
    ext = os.path.splitext(f)[1].lower()
    if ext in valid_exts:
        fpath = os.path.join(rdir, f)
        try:
            st = os.stat(fpath)
            size_mb = round(st.st_size / (1024 * 1024), 1)
            size_str = f"{size_mb} MB" if size_mb >= 1 else f"{round(st.st_size / 1024)} KB"
            dt = datetime.fromtimestamp(st.st_mtime)
            date_str = dt.strftime("%m-%d %H:%M")
            entries.append({
                "name": f,
                "path": fpath,
                "size": size_str,
                "date": date_str,
                "mtime": st.st_mtime
            })
        except Exception:
            pass

entries.sort(key=lambda x: x["mtime"], reverse=True)
print(json.dumps(entries[:15]))
EOF
        ;;

    open-dir)
        xdg-open "$RECORD_DIR" >/dev/null 2>&1 &
        ;;

    play)
        FILE="$1"
        if [ -n "$FILE" ] && [ -f "$FILE" ]; then
            if command -v mpv >/dev/null 2>&1; then
                nohup mpv "$FILE" >/dev/null 2>&1 &
            else
                xdg-open "$FILE" >/dev/null 2>&1 &
            fi
        fi
        ;;

    clear)
        rm -rf "${RECORD_DIR:?}"/*
        echo '{"status": "cleared"}'
        ;;

    *)
        echo '{"error": "unknown_command"}'
        ;;
esac
