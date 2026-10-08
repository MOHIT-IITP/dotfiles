pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Reminder service for the media-card reminder view.
// Each reminder: { id, title, totalSeconds, remainingSeconds }.
// Ticks every second while reminders exist; on expiry fires a
// system notification (picked up by NotifCenter toasts) + sound.
Singleton {
  id: root

  property var reminders: []
  property int _nextId: 1

  // True while the user is typing in the reminder card. The bar window
  // uses this to grab exclusive keyboard focus (layer-shell defaults to
  // None, so TextInputs would otherwise never receive keystrokes).
  property bool editing: false
  property bool promptOpen: false

  function openPrompt(): void {
    promptOpen = true;
  }

  function closePrompt(): void {
    promptOpen = false;
  }

  function togglePrompt(): void {
    if (promptOpen) closePrompt();
    else openPrompt();
  }

  function toggle(): void {
    togglePrompt();
  }

  readonly property int count: reminders.length

  readonly property bool hasFinished: {
    for (var i = 0; i < reminders.length; ++i) {
      if (reminders[i] && reminders[i].finished) return true;
    }
    return false;
  }

  // The reminder expiring soonest (prioritizing finished reminders).
  readonly property var soonest: {
    var best = null;
    for (var i = 0; i < reminders.length; ++i) {
      var r = reminders[i];
      if (!r) continue;
      if (r.finished) return r;
      if (!best || (r.remainingSeconds || 0) < (best.remainingSeconds || 0))
        best = r;
    }
    return best;
  }

  readonly property int soonestRemainingSeconds: soonest ? (soonest.remainingSeconds || 0) : 0
  readonly property int soonestTotalSeconds: soonest ? (soonest.totalSeconds || 0) : 0
  readonly property bool soonestFinished: soonest ? Boolean(soonest.finished) : false

  // 0..1 fraction elapsed for the soonest reminder.
  readonly property real soonestProgress: {
    if (soonestFinished) return 1.0;
    if (soonestTotalSeconds <= 0) return 0;
    return 1 - (soonestRemainingSeconds / soonestTotalSeconds);
  }

  // 1..0 fraction remaining for the soonest reminder (1 = full remaining, 0 = expired)
  readonly property real soonestRemaining: {
    if (soonestFinished) return 0;
    if (soonestTotalSeconds <= 0) return 0;
    return Math.max(0, Math.min(1, soonestRemainingSeconds / soonestTotalSeconds));
  }

  // Format MM:SS or H:MM:SS for soonest reminder
  readonly property string soonestFormatted: {
    var s = soonest;
    if (!s) return "00:00";
    if (s.finished) return "00:00";
    var sec = Math.max(0, s.remainingSeconds || 0);
    var h = Math.floor(sec / 3600);
    var m = Math.floor((sec % 3600) / 60);
    var r = sec % 60;
    if (h > 0) {
      return h + ":" + (m < 10 ? "0" + m : "" + m) + ":" + (r < 10 ? "0" + r : "" + r);
    }
    return (m < 10 ? "0" + m : "" + m) + ":" + (r < 10 ? "0" + r : "" + r);
  }

  // Compact remaining label for the collapsed badge: "45s" / "10m" / "2h".
  function fmtCompact(s) {
    s = Math.max(0, Math.ceil(Number(s) || 0));
    if (s < 60) return s + "s";
    var m = Math.ceil(s / 60);
    if (m < 60) return m + "m";
    return Math.floor(m / 60) + "h";
  }

  function fmt(s) {
    s = Math.max(0, Math.round(s));
    var h = Math.floor(s / 3600);
    var m = Math.floor((s % 3600) / 60);
    var r = s % 60;
    var mm = (m < 10 ? "0" + m : "" + m);
    var rr = (r < 10 ? "0" + r : "" + r);
    if (h > 0)
      return h + ":" + mm + ":" + rr;
    return mm + ":" + rr;
  }

  function sanitize(t) {
    var s = ((t ?? "") + "").replace(/[\r\n]+/g, " ").trim();
    // Avoid breaking the bash single-quoted notify command.
    s = s.replace(/'/g, "’");
    if (s.length === 0)
      s = "Reminder";
    if (s.length > 120)
      s = s.slice(0, 120);
    return s;
  }

  function addReminder(title, minutes) {
    var m = Math.round(Number(minutes));
    if (isNaN(m))
      m = 10;
    m = Math.max(1, Math.min(1440, m));
    var entry = {
      id: root._nextId++,
      title: sanitize(title),
      totalSeconds: m * 60,
      remainingSeconds: m * 60,
      finished: false
    };
    reminders = reminders.concat([entry]);
  }

  function cancelReminder(rid) {
    reminders = reminders.filter(function (r) {
      return r && r.id !== rid;
    });
  }

  function dismiss(rid) {
    cancelReminder(rid);
  }

  function dismissAllFinished() {
    reminders = reminders.filter(function (r) {
      return r && !r.finished;
    });
  }

  function clearAll() {
    reminders = [];
  }

  Timer {
    id: tick
    interval: 1000
    repeat: true
    running: root.reminders.length > 0
    onTriggered: {
      var newlyExpired = [];
      var next = [];
      for (var i = 0; i < root.reminders.length; ++i) {
        var r = root.reminders[i];
        if (!r) continue;
        if (r.finished) {
          next.push(r);
          continue;
        }
        var left = (r.remainingSeconds || 0) - 1;
        if (left <= 0) {
          newlyExpired.push(r.title || "Reminder");
          next.push({
            id: r.id,
            title: r.title,
            totalSeconds: r.totalSeconds,
            remainingSeconds: 0,
            finished: true
          });
        } else {
          next.push({
            id: r.id,
            title: r.title,
            totalSeconds: r.totalSeconds,
            remainingSeconds: left,
            finished: false
          });
        }
      }
      root.reminders = next;
      if (newlyExpired.length > 0) {
        root.notifyExpired(newlyExpired);
      }
    }
  }

  function notifyExpired(titles) {
    var msg = titles.join("; ").replace(/'/g, "’");
    if (msg.length > 200)
      msg = msg.slice(0, 200);
    notifyProc.command = ["bash", "-c", "notify-send 'Reminder' '" + msg + "' 2>/dev/null; paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null || paplay /usr/share/sounds/freedesktop/stereo/bell.oga 2>/dev/null || true"];
    notifyProc.running = true;
  }

  Process {
    id: notifyProc
    running: false
  }
}
