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

  // Dedup rapid identical resends (common "2 popups every time" cause)
  property string _lastSig: ""
  property int _lastTime: 0

  function notifSig(n) {
    try {
      return (n.appName || "") + "|" + (n.summary || "") + "|" + (n.body || "");
    } catch (e) {
      return "";
    }
  }

  function isEmptyNotif(n) {
    try {
      var s = ((n.summary || "").replace(/<[^>]*>/g, "")).trim();
      var b = ((n.body || "").replace(/<[^>]*>/g, "")).trim();
      if (s || b)
        return false;
      // Keep image-only notifications (e.g. screenshots)
      if (n.image)
        return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  NotificationServer {
    id: server
    bodySupported: true
    imageSupported: true
    actionsSupported: true
    bodyMarkupSupported: true
    onNotification: function (n) {
      // Drop blank spam: no summary + no body + no image.
      // These render as empty cards in toasts + center pill.
      if (isEmptyNotif(n)) {
        console.log("[NotifCenter] dropping empty notification from:", n.appName);
        try {
          n.tracked = false;
        } catch (e) {}
        try {
          n.dismiss();
        } catch (e) {}
        return;
      }
      // Drop instant duplicates (same app+summary+body within 1.5s)
      var sig = notifSig(n);
      var now = Date.now();
      if (sig && sig === root._lastSig && (now - root._lastTime) < 1500) {
        console.log("[NotifCenter] dropping duplicate notification:", sig);
        try {
          n.tracked = false;
        } catch (e) {}
        try {
          n.dismiss();
        } catch (e) {}
        return;
      }
      root._lastSig = sig;
      root._lastTime = now;
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
  // Plain array of tracked Notification objects for ListView/Repeater models.
  // NOTE: `tracked` above is an ObjectModel (of non-visual objects) and cannot
  // be used directly as a ListView model with a separate delegate — that is
  // why the control-center list stayed empty. Use `trackedList` instead.
  readonly property var trackedList: server.trackedNotifications.values
  readonly property int count: trackedList.length

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
      pillTimer.interval = 1000; // 1s display duration
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
      pillTimer.interval = 1000;
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
    var list = trackedList ? trackedList.slice(0) : [];
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
    interval: 1000
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
