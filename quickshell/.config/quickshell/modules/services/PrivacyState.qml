pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Privacy usage state: polls privacy.sh for camera / microphone consumers.
// cameraActive -> solid yellow dot, micActive -> solid green dot in ClockPill.
Singleton {
  id: root

  property bool cameraActive: false
  property bool micActive: false
  property var cameraApps: []
  property var micApps: []

  property string _raw: ""

  function check() {
    _raw = "";
    if (!proc.running) {
      proc.running = true;
    }
  }

  Timer {
    id: pollTimer
    interval: 2000
    repeat: true
    running: true
    onTriggered: {
      root.check();
    }
  }

  Process {
    id: proc
    command: ["bash", "/home/mohiitp/.config/quickshell/scripts/privacy.sh"]
    running: false

    stdout: SplitParser {
      splitMarker: "\n"
      onRead: data => {
        if (data) {
          root._raw += data;
        }
      }
    }

    onExited: function(code, status) {
      try {
        if (root._raw && root._raw.trim() !== "") {
          var res = JSON.parse(root._raw.trim());
          root.cameraActive = !!res.camera;
          root.micActive = !!res.mic;
          root.cameraApps = res.cameraApps || [];
          root.micApps = res.micApps || [];
        }
      } catch (e) {}
      root._raw = "";
    }
  }

  Component.onCompleted: {
    root.check();
  }
}
