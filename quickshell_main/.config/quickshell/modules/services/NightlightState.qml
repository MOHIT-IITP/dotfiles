pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Nightlight state controlling hyprsunset via hyprctl.
// The hyprsunset daemon stays running persistently; we only switch
// between `temperature <K>` (on) and `identity` (off).
// The old pkill/spawn + pgrep approach raced (pgrep ran before the
// respawned daemon appeared) and couldn't tell "daemon running idle"
// apart from "filter enabled", so the button flicked back / showed
// the wrong state.
Singleton {
  id: root

  property bool active: false
  property int temperature: 4000 // Kelvin (warm 3000K .. cooler 6000K)

  function toggle() {
    if (active) {
      active = false;
      offProc.running = true;
    } else {
      active = true;
      applyTemp();
    }
  }

  function setTemperature(temp) {
    temperature = Math.max(2500, Math.min(6500, temp));
    if (active) {
      applyTemp();
    }
  }

  function applyTemp() {
    // Make sure the daemon exists, then set the temperature.
    // ensureProc chains into onProc on exit.
    if (ensureProc.running) {
      return;
    }
    if (onProc.running) {
      onProc.running = false;
    }
    onProc.command = ["hyprctl", "hyprsunset", "temperature", String(temperature)];
    ensureProc.running = true;
  }

  // Ensure daemon is alive, then apply temperature
  Process {
    id: ensureProc
    command: ["bash", "-c", "pgrep -x hyprsunset >/dev/null 2>&1 || (hyprsunset >/dev/null 2>&1 &)"]
    running: false
    onExited: function() {
      // Small delay so a freshly spawned daemon is ready for hyprctl
      applyTimer.restart();
    }
  }

  Timer {
    id: applyTimer
    interval: 400
    repeat: false
    onTriggered: {
      if (root.active && !onProc.running) {
        onProc.running = true;
      }
    }
  }

  // Enable filter to current temperature
  Process {
    id: onProc
    running: false
  }

  // Disable filter, leave daemon running
  Process {
    id: offProc
    command: ["hyprctl", "hyprsunset", "identity"]
    running: false
  }

  // Make sure the daemon exists at shell startup (without changing the screen)
  Component.onCompleted: {
    bootEnsure.running = true;
  }

  Process {
    id: bootEnsure
    command: ["bash", "-c", "pgrep -x hyprsunset >/dev/null 2>&1 || (hyprsunset >/dev/null 2>&1 &)"]
    running: false
  }
}
