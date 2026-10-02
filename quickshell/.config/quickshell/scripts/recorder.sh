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
    # NOTE: pgrep/pkill -x cannot match gpu-screen-recorder (comm is
    # truncated to 15 chars and pgrep refuses long patterns), so use -f.
    pgrep -f "[g]pu-screen-recorder -w" >/dev/null 2>&1 || pgrep -x wf-recorder >/dev/null 2>&1 || pgrep -x wl-screenrec >/dev/null 2>&1
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
        MODE="${2:-fullscreen}"
        GEOM_INPUT="${3:-}"
        GEOM=""
        REGION=""

        # Resolve recording area when requested
        if [ "$MODE" = "area" ]; then
            if [ -n "$GEOM_INPUT" ]; then
                GEOM="$GEOM_INPUT"
            else
                if ! command -v slurp >/dev/null 2>&1; then
                    notify-send "Screen Recorder" "Area recording needs 'slurp' (not found)" -i dialog-error
                    echo '{"status": "no_slurp"}'
                    exit 1
                fi
                notify-send "Screen Recorder" "Select an area to record..." -i media-record
                # Let the panel click settle/close so the release event is not
                # swallowed by slurp as an empty selection (mirrors screenshot.sh).
                sleep 0.4
                # Quickshell spawns us with stdin as an open pipe: slurp must NOT
                # inherit it (it never maps its overlay while stdin is an open
                # pipe), so redirect from /dev/null explicitly.
                if command -v timeout >/dev/null 2>&1; then
                    GEOM=$(timeout 60 slurp </dev/null 2>/dev/null)
                else
                    GEOM=$(slurp </dev/null 2>/dev/null)
                fi
                if [ -z "$GEOM" ]; then
                    echo '{"status": "cancelled"}'
                    exit 2
                fi
            fi
            # Convert slurp "X,Y WxH" -> gpu-screen-recorder "WxH+X+Y"
            # e.g. "12,34 800x600" -> "800x600+12+34"
            X=$(echo "$GEOM" | cut -d',' -f1)
            REST=$(echo "$GEOM" | cut -d',' -f2)
            Y=$(echo "$REST" | cut -d' ' -f1)
            WH=$(echo "$REST" | cut -d' ' -f2)
            if [ -z "$X" ] || [ -z "$Y" ] || [ -z "$WH" ]; then
                echo '{"status": "cancelled"}'
                exit 2
            fi
            REGION="${WH}+${X}+${Y}"
        fi

        FILENAME="recording_$(date +%Y-%m-%d_%H-%M-%S).mp4"
        OUTPATH="$RECORD_DIR/$FILENAME"
        REC_LOG="${XDG_RUNTIME_DIR:-/tmp}/quickshell_recorder.log"

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

            if [ "$MODE" = "area" ]; then
                # New syntax: region passed directly via -w (bare -region is deprecated)
                nohup gpu-screen-recorder -w "$REGION" -f 60 -q high "${AUDIO_ARGS[@]}" -o "$OUTPATH" >"$REC_LOG" 2>&1 &
            else
                nohup gpu-screen-recorder -w screen -f 60 -q high "${AUDIO_ARGS[@]}" -o "$OUTPATH" >"$REC_LOG" 2>&1 &
            fi
            echo $! > "$PID_FILE"

        elif command -v wf-recorder >/dev/null 2>&1; then
            AUDIO_ARGS=""
            if [ "$AUDIO" = "mic" ] || [ "$AUDIO" = "both" ]; then
                AUDIO_ARGS="--audio"
            fi
            if [ "$MODE" = "area" ]; then
                # wf-recorder takes slurp geometry directly: "X,Y WxH"
                # shellcheck disable=SC2086
                nohup wf-recorder $AUDIO_ARGS -g "$GEOM" -f "$OUTPATH" >/dev/null 2>&1 &
            else
                # shellcheck disable=SC2086
                nohup wf-recorder $AUDIO_ARGS -f "$OUTPATH" >/dev/null 2>&1 &
            fi
            echo $! > "$PID_FILE"

        elif command -v wl-screenrec >/dev/null 2>&1; then
            AUDIO_ARGS=""
            if [ "$AUDIO" = "mic" ] || [ "$AUDIO" = "both" ]; then
                AUDIO_ARGS="--audio"
            fi
            if [ "$MODE" = "area" ]; then
                # shellcheck disable=SC2086
                nohup wl-screenrec $AUDIO_ARGS --geometry "$GEOM" -f "$OUTPATH" >/dev/null 2>&1 &
            else
                # shellcheck disable=SC2086
                nohup wl-screenrec $AUDIO_ARGS -f "$OUTPATH" >/dev/null 2>&1 &
            fi
            echo $! > "$PID_FILE"

        else
            notify-send "Screen Recorder" "No recorder found (please install gpu-screen-recorder or wf-recorder)" -i dialog-error
            echo '{"status": "no_recorder"}'
            exit 1
        fi

        if [ "$MODE" = "area" ]; then
            notify-send "Screen Recorder" "Area recording started ($GEOM)..." -i media-record
        else
            notify-send "Screen Recorder" "Fullscreen recording started..." -i media-record
        fi
        # Validate the recorder actually survived startup (e.g. bad region).
        # Errors were previously silent: UI showed REC, then flipped to IDLE.
        sleep 1.2
        if ! is_running; then
            ERR=$(tail -n 5 "$REC_LOG" 2>/dev/null | tr '\n' ' ' | cut -c1-200)
            notify-send "Screen Recorder" "Recording failed to start. ${ERR:-See $REC_LOG}" -i dialog-error
            rm -f "$PID_FILE"
            echo '{"status": "failed"}'
            exit 1
        fi
        echo '{"status": "started", "file": "'"$OUTPATH"'", "mode": "'"$MODE"'", "geometry": "'"$GEOM"'"}'
        ;;

    select-area)
        if ! command -v slurp >/dev/null 2>&1; then
            notify-send "Screen Recorder" "Area selection needs 'slurp' (not found)" -i dialog-error
            echo '{"status": "no_slurp"}'
            exit 1
        fi
        # Let the panel click settle so the release event is not swallowed
        # by slurp as an empty selection (mirrors screenshot.sh).
        sleep 0.4
        # Time-box the picker so an abandoned selection cannot wedge the UI.
        # NOTE: stdin redirect is required (see select-area).
        if command -v timeout >/dev/null 2>&1; then
            GEOM=$(timeout 60 slurp </dev/null 2>/dev/null)
        else
            GEOM=$(slurp </dev/null 2>/dev/null)
        fi
        if [ -z "$GEOM" ]; then
            echo '{"status": "cancelled"}'
            exit 2
        fi
        X=$(echo "$GEOM" | cut -d',' -f1)
        REST=$(echo "$GEOM" | cut -d',' -f2)
        Y=$(echo "$REST" | cut -d' ' -f1)
        WH=$(echo "$REST" | cut -d' ' -f2)
        REGION="${WH}+${X}+${Y}"
        echo '{"status": "selected", "geometry": "'"$GEOM"'", "region": "'"$REGION"'"}'
        ;;

    stop)
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE" 2>/dev/null)
            if [ -n "$PID" ]; then
                kill -SIGINT "$PID" 2>/dev/null || kill -INT "$PID" 2>/dev/null
            fi
            rm -f "$PID_FILE"
        fi
        pkill -SIGINT -f "[g]pu-screen-recorder -w" 2>/dev/null || pkill -SIGINT -x wf-recorder 2>/dev/null || pkill -SIGINT -x wl-screenrec 2>/dev/null
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
