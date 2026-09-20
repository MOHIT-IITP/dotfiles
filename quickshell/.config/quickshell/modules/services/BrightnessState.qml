pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Controls display brightness via brightnessctl with fallback
Singleton {
  id: root

  property real brightness: 0.8
  property string _rawOut: ""

  function setBrightness(v) {
    var clamped = Math.max(0.02, Math.min(1.0, v));
    brightness = clamped;
    var pct = Math.round(clamped * 100);
    setProc.command = ["brightnessctl", "set", pct + "%"];
    setProc.running = true;
  }

  function refresh() {
    _rawOut = "";
    if (getProc.running) getProc.running = false;
    getProc.running = true;
  }

  Process {
    id: getProc
    command: ["brightnessctl", "-m"]
    running: true

    stdout: SplitParser {
      onRead: data => {
        root._rawOut += data;
      }
    }

    onExited: function (code, status) {
      if (root._rawOut) {
        // Output format: device,class,curr,pct%,max
        var parts = root._rawOut.trim().split(",");
        if (parts.length >= 4) {
          var pctStr = parts[3].replace("%", "").trim();
          var parsed = parseFloat(pctStr);
          if (!isNaN(parsed)) {
            root.brightness = Math.max(0, Math.min(1, parsed / 100.0));
          }
        }
      }
      root._rawOut = "";
    }
  }

  Process {
    id: setProc
    running: false
  }

  Component.onCompleted: {
    refresh();
  }
}
