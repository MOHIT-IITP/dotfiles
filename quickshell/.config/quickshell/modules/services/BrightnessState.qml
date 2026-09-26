pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Controls display brightness.
// Laptops: brightnessctl backlight device.
// Desktops (no /sys/class/backlight): DDC/CI via ddcutil VCP 10.
Singleton {
  id: root

  property real brightness: 0.8
  property string backend: "auto" // "backlight" | "ddcutil" | "none"
  property string device: ""
  property bool busy: false
  property bool available: true
  property string _rawOut: ""
  property real _pending: -1

  function _clamp(v) {
    return Math.max(0.02, Math.min(1.0, v));
  }

  function setBrightness(v) {
    var clamped = _clamp(v);
    brightness = clamped;
    if (backend === "ddcutil") {
      // Debounce: ddcutil takes ~0.5s per call, coalesce drag events.
      _pending = clamped;
      if (!busy) {
        flushTimer.restart();
      }
    } else if (backend === "backlight") {
      var pct = Math.round(clamped * 100);
      if (setProc.running) setProc.running = false;
      if (device !== "") {
        setProc.command = ["brightnessctl", "-d", device, "set", pct + "%"];
      } else {
        setProc.command = ["brightnessctl", "-c", "backlight", "set", pct + "%"];
      }
      setProc.running = true;
    } else if (backend === "auto") {
      // Backend not detected yet: optimistically try both, detect will correct.
      _pending = clamped;
      detect();
    }
  }

  function refresh() {
    if (backend === "ddcutil") {
      _rawOut = "";
      if (getProc.running) getProc.running = false;
      getProc.command = ["ddcutil", "getvcp", "10", "--brief"];
      getProc.running = true;
    } else if (backend === "backlight") {
      _rawOut = "";
      if (getProc.running) getProc.running = false;
      if (device !== "") {
        getProc.command = ["brightnessctl", "-d", device, "-m"];
      } else {
        getProc.command = ["brightnessctl", "-c", "backlight", "-m"];
      }
      getProc.running = true;
    } else {
      detect();
    }
  }

  function detect() {
    _rawOut = "";
    if (detectProc.running) detectProc.running = false;
    detectProc.running = true;
  }

  Timer {
    id: flushTimer
    interval: 250
    repeat: false
    onTriggered: {
      if (root._pending < 0 || root.busy) return;
      var pct = Math.round(root._pending * 100);
      root._pending = -1;
      root.busy = true;
      if (setProc.running) setProc.running = false;
      setProc.command = ["ddcutil", "setvcp", "10", pct.toString()];
      setProc.running = true;
    }
  }

  Process {
    id: detectProc
    command: ["bash", "-c", "dev=$(ls /sys/class/backlight/ 2>/dev/null | head -n1); if [ -n \"$dev\" ]; then echo \"backlight:$dev\"; elif command -v ddcutil >/dev/null 2>&1 && ddcutil detect --brief 2>/dev/null | grep -q '^Display'; then echo 'ddcutil'; else echo 'none'; fi"]
    running: false

    stdout: SplitParser {
      onRead: data => {
        var line = (data || "").trim();
        if (line.indexOf("backlight:") === 0) {
          root.backend = "backlight";
          root.device = line.substring(10).trim();
          root.available = true;
          root.refresh();
        } else if (line === "ddcutil") {
          root.backend = "ddcutil";
          root.available = true;
          root.refresh();
        } else if (line === "none") {
          root.backend = "none";
          root.available = false;
        }
      }
    }
  }

  Process {
    id: getProc
    running: false

    stdout: SplitParser {
      onRead: data => {
        root._rawOut += data + "\n";
      }
    }

    onExited: function (code, status) {
      if (code !== 0) {
        root._rawOut = "";
        return;
      }
      if (root.backend === "ddcutil") {
        // Brief format: "VCP 10 C <current> <max>"
        var lines = root._rawOut.trim().split("\n");
        for (var i = 0; i < lines.length; ++i) {
          var p = lines[i].trim().split(/\s+/);
          // ["VCP","10","C","32","100"]
          if (p.length >= 5 && p[0] === "VCP" && p[1] === "10") {
            var cur = parseFloat(p[3]);
            var max = parseFloat(p[4]);
            if (!isNaN(cur) && !isNaN(max) && max > 0) {
              root.brightness = Math.max(0, Math.min(1, cur / max));
            }
            break;
          }
        }
      } else {
        // brightnessctl -m: device,class,curr,pct%,max (first backlight line wins)
        var blines = root._rawOut.trim().split("\n");
        for (var j = 0; j < blines.length; ++j) {
          var parts = blines[j].trim().split(",");
          if (parts.length >= 4) {
            var pctStr = parts[3].replace("%", "").trim();
            var parsed = parseFloat(pctStr);
            if (!isNaN(parsed)) {
              root.brightness = Math.max(0, Math.min(1, parsed / 100.0));
              break;
            }
          }
        }
      }
      root._rawOut = "";
    }
  }

  Process {
    id: setProc
    running: false
    onExited: function (code, status) {
      if (root.backend === "ddcutil") {
        root.busy = false;
        // Flush coalesced drag updates.
        if (root._pending >= 0) {
          flushTimer.restart();
        }
      }
    }
  }

  Component.onCompleted: {
    detect();
  }
}
