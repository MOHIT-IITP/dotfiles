pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Countdown timer service for the center-bar Timer view.
// Left-swipe flow: Clock -> Timer -> Weather. Timer keeps running
// even when the pill collapses.
Singleton {
  id: root

  property bool open: false
  function toggle(): void { open = !open; }
  function openView(): void { open = true; }
  function closeView(): void { open = false; }

  property int selectedMinutes: 22
  property bool running: false
  property bool paused: false
  property int remainingSeconds: 0
  property int totalSeconds: 0
  property bool finished: false

  readonly property string selectedLabel: {
    var m = selectedMinutes;
    return (m < 10 ? "0" + m : "" + m) + ":00";
  }

  readonly property string formatted: {
    var s = running || paused ? remainingSeconds : selectedMinutes * 60;
    if (finished) s = 0;
    var m = Math.floor(s / 60);
    var r = s % 60;
    return (m < 10 ? "0" + m : "" + m) + ":" + (r < 10 ? "0" + r : "" + r);
  }

  readonly property real progress: {
    if (totalSeconds <= 0) return 0;
    if (finished) return 1;
    if (!running && !paused) return 0;
    return 1 - (remainingSeconds / totalSeconds);
  }

  function setMinutes(m): void {
    var v = Math.round(m);
    if (isNaN(v)) return;
    v = Math.max(1, Math.min(120, v));
    if (running || paused) return;
    selectedMinutes = v;
    finished = false;
  }

  function adjust(by): void {
    setMinutes(selectedMinutes + by);
  }

  function start(): void {
    if (running) return;
    if (paused) {
      paused = false;
      running = true;
      return;
    }
    totalSeconds = Math.max(60, selectedMinutes * 60);
    remainingSeconds = totalSeconds;
    finished = false;
    running = true;
    paused = false;
  }

  function pause(): void {
    if (!running) return;
    running = false;
    paused = true;
  }

  function resume(): void {
    if (!paused) return;
    paused = false;
    running = true;
  }

  function cancel(): void {
    running = false;
    paused = false;
    finished = false;
    remainingSeconds = 0;
    totalSeconds = 0;
  }

  function dismissDone(): void {
    finished = false;
    cancel();
  }

  Timer {
    id: tick
    interval: 1000
    repeat: true
    running: root.running
    onTriggered: {
      if (root.remainingSeconds > 0) {
        root.remainingSeconds -= 1;
      }
      if (root.remainingSeconds <= 0) {
        root.remainingSeconds = 0;
        root.running = false;
        root.paused = false;
        root.finished = true;
        root.notifyDone();
      }
    }
  }

  function notifyDone(): void {
    notifyProc.command = ["bash", "-c", "notify-send 'Timer' 'Time is up!' 2>/dev/null; paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null || paplay /usr/share/sounds/freedesktop/stereo/bell.oga 2>/dev/null || true"];
    notifyProc.running = true;
  }

  Process {
    id: notifyProc
    running: false
  }
}
