pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Io
import QtQuick

// Notification daemon: tracks incoming notifications for the
// control center, queues pop-up toasts, and manages Do Not Disturb (DND).
Singleton {
  id: root

  property bool dnd: false

  NotificationServer {
    id: server
    bodySupported: true
    imageSupported: true
    onNotification: function (n) {
      n.tracked = true;
      // drop the toast when the notification goes away elsewhere
      n.closed.connect(function () {
        hidePopup(n);
      });
      // Suppress popup toasts when DND is enabled
      if (!root.dnd) {
        showPopup(n);
      }
    }
  }

  readonly property var tracked: server.trackedNotifications
  readonly property int count: server.trackedNotifications.values.length

  // Live toast queue (subset of tracked, auto-hidden by timer)
  property var popups: []
  readonly property int popupCount: popups.length

  function toggleDnd() {
    dnd = !dnd;
    if (dnd) {
      // Clear any currently active popups on screen
      popups = [];
    }
    // Sync with external daemons if running
    dndProc.command = ["bash", "-c", "if command -v swaync-client >/dev/null 2>&1; then swaync-client -d -s " + (dnd ? "true" : "false") + "; elif command -v dunstctl >/dev/null 2>&1; then dunstctl set-paused " + (dnd ? "true" : "false") + "; fi"];
    dndProc.running = true;
  }

  function showPopup(n) {
    if (root.dnd) return;
    var q = popups.filter(function (x) {
      return x !== n;
    });
    while (q.length >= 4)
      q.shift();
    q.push(n);
    popups = q;
  }

  function hidePopup(n) {
    popups = popups.filter(function (x) {
      return x !== n;
    });
  }

  function clearAll() {
    popups = [];
    var ns = server.trackedNotifications.values;
    for (var i = 0; i < ns.length; ++i) {
      if (ns[i])
        ns[i].dismiss();
    }
  }

  Process {
    id: dndProc
    running: false
  }
}
