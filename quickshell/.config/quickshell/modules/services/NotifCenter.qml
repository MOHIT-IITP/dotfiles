pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Io
import QtQuick

// Notification daemon: tracks incoming notifications, manages Do Not Disturb (DND),
// and delivers incoming notifications directly into the Center Date/Time Pill.
Singleton {
  id: root

  property bool dnd: false

  // Live active notification displayed in Center Pill
  property var currentNotification: null
  property var notificationQueue: []
  property bool showNotificationPill: currentNotification !== null
  property bool isHovered: false

  NotificationServer {
    id: server
    bodySupported: true
    imageSupported: true
    actionsSupported: true
    bodyMarkupSupported: true
    onNotification: function (n) {
      n.tracked = true;
      // When notification is closed externally or dismissed
      n.closed.connect(function () {
        hidePopup(n);
        if (root.currentNotification === n) {
          root.nextNotification();
        }
      });
      // Suppress when DND is enabled
      if (!root.dnd) {
        showPopup(n);
      }
    }
  }

  readonly property var tracked: server.trackedNotifications
  readonly property int count: server.trackedNotifications.values.length

  // Live toast queue (subset of tracked)
  property var popups: []
  readonly property int popupCount: popups.length

  function toggleDnd() {
    dnd = !dnd;
    if (dnd) {
      popups = [];
      notificationQueue = [];
      currentNotification = null;
      pillTimer.stop();
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

    // Display in Center Bar Pill
    if (!currentNotification) {
      currentNotification = n;
      pillTimer.interval = 2800; // 2.8s display duration (2-3s)
      pillTimer.restart();
    } else if (currentNotification !== n) {
      if (notificationQueue.indexOf(n) === -1) {
        var nq = notificationQueue.slice(0);
        nq.push(n);
        notificationQueue = nq;
      }
    }
  }

  function hidePopup(n) {
    popups = popups.filter(function (x) {
      return x !== n;
    });
    if (notificationQueue.indexOf(n) !== -1) {
      notificationQueue = notificationQueue.filter(function (x) {
        return x !== n;
      });
    }
    if (currentNotification === n) {
      nextNotification();
    }
  }

  function nextNotification() {
    if (notificationQueue.length > 0) {
      var nq = notificationQueue.slice(0);
      currentNotification = nq.shift();
      notificationQueue = nq;
      pillTimer.interval = 2800;
      pillTimer.restart();
    } else {
      currentNotification = null;
      pillTimer.stop();
    }
  }

  function dismissCurrent() {
    if (currentNotification) {
      var n = currentNotification;
      hidePopup(n);
      try { n.tracked = false; } catch (e) {}
      try { n.dismiss(); } catch (e) {}
    } else {
      nextNotification();
    }
  }

  function activateCurrent() {
    if (currentNotification) {
      var n = currentNotification;
      hidePopup(n);
      try {
        if (n.actions && n.actions.length > 0) {
          n.actions[0].trigger();
        }
      } catch (e) {}
      try { n.tracked = false; } catch (e) {}
      try { n.dismiss(); } catch (e) {}
    } else {
      nextNotification();
    }
  }

  function dismissNotification(n) {
    if (!n) return;
    hidePopup(n);
    try { n.tracked = false; } catch (e) {}
    try { n.dismiss(); } catch (e) {}
  }

  function clearAll() {
    popups = [];
    notificationQueue = [];
    currentNotification = null;
    pillTimer.stop();
    var list = (server.trackedNotifications && server.trackedNotifications.values) ? server.trackedNotifications.values : [];
    var ns = [];
    for (var j = 0; j < list.length; ++j) {
      if (list[j]) ns.push(list[j]);
    }
    for (var i = 0; i < ns.length; ++i) {
      var n = ns[i];
      if (n) {
        try { n.dismiss(); } catch (e) {}
        try { n.tracked = false; } catch (e) {}
      }
    }
  }

  Timer {
    id: pillTimer
    interval: 2800
    repeat: false
    running: false
    onTriggered: {
      if (root.isHovered) {
        interval = 1200;
        restart();
      } else {
        root.nextNotification();
      }
    }
  }

  Process {
    id: dndProc
    running: false
  }
}
