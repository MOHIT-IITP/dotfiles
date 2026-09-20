pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Nightlight state managing hyprsunset process and temperature
Singleton {
  id: root

  property bool active: false
  property int temperature: 4000 // Kelvin (warm 3000K .. cooler 6000K)

  function checkStatus() {
    statusProc.running = true;
  }

  function toggle() {
    if (active) {
      active = false;
      stopProc.running = true;
    } else {
      active = true;
      startProc.command = ["bash", "-c", "pkill -x hyprsunset; hyprsunset -t " + temperature + " > /dev/null 2>&1 &"];
      startProc.running = true;
    }
  }

  function setTemperature(temp) {
    temperature = Math.max(2500, Math.min(6500, temp));
    if (active) {
      startProc.command = ["bash", "-c", "pkill -x hyprsunset; hyprsunset -t " + temperature + " > /dev/null 2>&1 &"];
      startProc.running = true;
    }
  }

  // Check if hyprsunset is running
  Process {
    id: statusProc
    command: ["pgrep", "-x", "hyprsunset"]
    running: true
    onExited: function(code, status) {
      root.active = (code === 0);
    }
  }

  // Start hyprsunset process
  Process {
    id: startProc
    running: false
    onExited: function() {
      root.checkStatus();
    }
  }

  // Stop hyprsunset process
  Process {
    id: stopProc
    command: ["pkill", "-x", "hyprsunset"]
    running: false
    onExited: function() {
      root.checkStatus();
    }
  }

  // Periodic poll every 5s to keep sync if toggled externally
  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: root.checkStatus()
  }
}
