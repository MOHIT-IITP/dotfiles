pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Live audio levels from cava (music AND video).
// Captures the monitor of the default sink, so any app producing
// sound (players, browsers, games) drives the visualizer accurately.
// Exposes `values` as an array of 0..100, one entry per bar.
Singleton {
  id: root

  property int bars: 5
  property var values: [0, 0, 0, 0, 0]
  readonly property string configPath: "/home/mohiitp/.config/quickshell/modules/services/cava.conf"

  function reset() {
    var z = [];
    for (var i = 0; i < root.bars; ++i)
      z.push(0);
    root.values = z;
  }

  Connections {
    target: SettingsState
    function onMusicVisualizerChanged() {
      if (!SettingsState.musicVisualizer)
        root.reset();
    }
  }

  Timer {
    id: restartTimer
    interval: 1000
    repeat: false
    onTriggered: {
      if (SettingsState.musicVisualizer && !cavaProc.running)
        cavaProc.running = true;
    }
  }

  Process {
    id: cavaProc
    command: ["cava", "-p", root.configPath]
    running: SettingsState.musicVisualizer

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
          root.values = out;
      }
    }

    onExited: {
      // cava missing/crashed or audio backend hiccup: fall flat and retry.
      root.reset();
      if (SettingsState.musicVisualizer)
        restartTimer.restart();
    }
  }
}
