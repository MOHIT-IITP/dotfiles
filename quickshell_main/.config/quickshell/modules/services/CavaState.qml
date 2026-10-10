pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Live audio levels from cava (music AND video).
// Desktop feed captures the monitor of the default sink, so any app producing
// sound (players, browsers, games) drives the visualizer accurately.
// While screen recording, a second cava feed captures the microphone and the
// exposed `values` are the per-bar max of both, so the red center-bar
// visualizer reacts to system AND mic audio.
Singleton {
  id: root

  property int bars: 5
  property var desktopValues: [0, 0, 0, 0, 0]
  property var micValues: [0, 0, 0, 0, 0]

  readonly property string configPath: "/home/mohiitp/.config/quickshell/modules/services/cava.conf"
  readonly property string micConfigPath: "/home/mohiitp/.config/quickshell/modules/services/cava-mic.conf"

  // True while a screen recording is in progress.
  readonly property bool recording: RecorderState.isRecording
  // Mic feed is wanted when the recording includes microphone audio.
  readonly property bool wantMic: recording && (RecorderState.currentAudio === "mic" || RecorderState.currentAudio === "both")
  // Desktop feed runs for the normal visualizer AND during recording (red bars).
  readonly property bool wantDesktop: SettingsState.musicVisualizer || recording

  // Combined levels: desktop alone normally, per-bar max(desktop, mic) while
  // recording with mic. Center bar (`ClockPill.barHeights`) reads this.
  readonly property var values: {
    var d = root.desktopValues;
    var m = root.micValues;
    var useMic = root.wantMic;
    var out = [];
    for (var i = 0; i < root.bars; ++i) {
      var dv = (d && d.length > i) ? d[i] : 0;
      if (useMic) {
        var mv = (m && m.length > i) ? m[i] : 0;
        out.push(Math.max(dv, mv));
      } else {
        out.push(dv);
      }
    }
    return out;
  }

  function zero(n) {
    var z = [];
    for (var i = 0; i < root.bars; ++i)
      z.push(0);
    return z;
  }

  function reset() {
    root.desktopValues = zero();
    root.micValues = zero();
  }

  function resetDesktop() {
    root.desktopValues = zero();
  }

  function resetMic() {
    root.micValues = zero();
  }

  Connections {
    target: SettingsState
    function onMusicVisualizerChanged() {
      // Visualizer disabled and not recording: park the desktop feed flat.
      // During recording the feed must keep running for the red bars.
      if (!SettingsState.musicVisualizer && !root.recording)
        root.resetDesktop();
    }
  }

  Connections {
    target: RecorderState
    function onIsRecordingChanged() {
      if (RecorderState.isRecording) {
        if (root.wantMic)
          root.startMicFeed();
      } else {
        micProc.running = false;
        micSetupProc.running = false;
        root.resetMic();
        // Recording over and visualizer off: park the desktop feed flat.
        if (!SettingsState.musicVisualizer)
          root.resetDesktop();
      }
    }
    function onCurrentAudioChanged() {
      // Mic (un)muted mid-recording: start/stop the mic feed accordingly.
      if (RecorderState.isRecording) {
        if (root.wantMic) {
          if (!micProc.running && !micSetupProc.running)
            root.startMicFeed();
        } else {
          micProc.running = false;
          root.resetMic();
        }
      }
    }
  }

  // Resolve the live default mic and stamp it into cava-mic.conf, then spawn
  // the mic feed. Derived from cava.conf so tuning stays in one place.
  function startMicFeed() {
    root.resetMic();
    if (micSetupProc.running)
      micSetupProc.running = false;
    if (micProc.running)
      micProc.running = false;
    micSetupProc.running = true;
  }

  Timer {
    id: restartTimer
    interval: 1000
    repeat: false
    onTriggered: {
      if (root.wantDesktop && !cavaProc.running)
        cavaProc.running = true;
    }
  }

  Timer {
    id: micRestartTimer
    interval: 1500
    repeat: false
    onTriggered: {
      if (root.wantMic && !micProc.running && !micSetupProc.running)
        root.startMicFeed();
    }
  }

  Process {
    id: cavaProc
    command: ["cava", "-p", root.configPath]
    running: root.wantDesktop

    stdout: SplitParser {
      onRead: data => {
        if (!data || data.indexOf(";") === -1)
          return;
        var parts = data.split(";");
        var out = [];
        for (var i = 0; i < parts.length && out.length < root.bars; ++i) {
          var p = parts[i].trim();
          if (p === "")
            continue;
          var v = parseInt(p, 10);
          if (isNaN(v))
            return;
          out.push(Math.max(0, Math.min(100, v)));
        }
        if (out.length === root.bars)
          root.desktopValues = out;
      }
    }

    onExited: {
      // cava missing/crashed or audio backend hiccup: fall flat and retry.
      root.resetDesktop();
      if (root.wantDesktop)
        restartTimer.restart();
    }
  }

  // One-shot: bake the current default mic into cava-mic.conf.
  Process {
    id: micSetupProc
    running: false
    command: ["bash", "-c", "SRC=$(pactl get-default-source 2>/dev/null); [ -n \"$SRC\" ] || exit 1; sed \"s|^source.*|source = $SRC|\" \"" + root.configPath + "\" | sed \"s|^sensitivity.*|sensitivity = 120|\" > \"" + root.micConfigPath + "\""]

    onExited: function (code, status) {
      if (code === 0 && root.wantMic) {
        if (micProc.running)
          micProc.running = false;
        micProc.running = true;
      } else if (root.wantMic) {
        micRestartTimer.restart();
      }
    }
  }

  Process {
    id: micProc
    command: ["cava", "-p", root.micConfigPath]
    running: false

    stdout: SplitParser {
      onRead: data => {
        if (!data || data.indexOf(";") === -1)
          return;
        var parts = data.split(";");
        var out = [];
        for (var i = 0; i < parts.length && out.length < root.bars; ++i) {
          var p = parts[i].trim();
          if (p === "")
            continue;
          var v = parseInt(p, 10);
          if (isNaN(v))
            return;
          out.push(Math.max(0, Math.min(100, v)));
        }
        if (out.length === root.bars)
          root.micValues = out;
      }
    }

    onExited: {
      root.resetMic();
      if (root.wantMic)
        micRestartTimer.restart();
    }
  }
}
