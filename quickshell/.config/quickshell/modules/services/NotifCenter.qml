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

  // Notification inbox (history list) expanded in the center bar.
  // Toggled via IPC `qs ipc call mohiitp notifInbox` (Super+Ctrl+N).
  property bool inboxOpen: false

  function toggleInbox() {
    inboxOpen = !inboxOpen;
  }

  function openInbox() {
    inboxOpen = true;
  }

  function closeInbox() {
    inboxOpen = false;
  }

  // Map a notification sender to a CCIcon kind (Nerd Font glyph).
  // Used as the icon fallback when the theme has no app icon.
  function iconKindFor(n) {
    if (!n) return "bell";
    var app = ((n.appName || "") + " " + (n.appIcon || "")).toLowerCase();
    if (app.indexOf("chrome") !== -1 || app.indexOf("chromium") !== -1) return "chrome";
    if (app.indexOf("firefox") !== -1) return "firefox";
    if (app.indexOf("zen") !== -1) return "firefox";
    if (app.indexOf("discord") !== -1 || app.indexOf("vesktop") !== -1 || app.indexOf("webcord") !== -1) return "discord";
    if (app.indexOf("spotify") !== -1) return "spotify";
    if (app.indexOf("telegram") !== -1) return "telegram";
    if (app.indexOf("whatsapp") !== -1) return "whatsapp";
    if (app.indexOf("slack") !== -1) return "slack";
    if (app.indexOf("steam") !== -1) return "steam";
    if (app.indexOf("blueman") !== -1 || app.indexOf("bluetooth") !== -1) return "bt";
    if (app.indexOf("network") !== -1 || app.indexOf("nm-") !== -1 || app.indexOf("wpa_") !== -1) return "wifi";
    if (app.indexOf("volume") !== -1 || app.indexOf("audio") !== -1 || app.indexOf("pavu") !== -1 || app.indexOf("pipewire") !== -1 || app.indexOf("wireplumber") !== -1) return "speaker";
    if (app.indexOf("screenshot") !== -1 || app.indexOf("flameshot") !== -1 || app.indexOf("grim") !== -1 || app.indexOf("swappy") !== -1 || app.indexOf("hyprshot") !== -1) return "camera";
    if (app.indexOf("vscode") !== -1 || app.indexOf("vscodium") !== -1 || app.indexOf("code") !== -1 || app.indexOf("neovim") !== -1 || app.indexOf("nvim") !== -1) return "vscode";
    if (app.indexOf("terminal") !== -1 || app.indexOf("kitty") !== -1 || app.indexOf("ghostty") !== -1 || app.indexOf("alacritty") !== -1 || app.indexOf("foot") !== -1 || app.indexOf("wezterm") !== -1) return "terminal";
    if (app.indexOf("mail") !== -1 || app.indexOf("thunderbird") !== -1 || app.indexOf("gmail") !== -1 || app.indexOf("mutt") !== -1) return "mail";
    if (app.indexOf("github") !== -1) return "github";
    if (app.indexOf("music") !== -1) return "music";
    if (app.indexOf("battery") !== -1 || app.indexOf("power") !== -1 || app.indexOf("upower") !== -1) return "power";
    return "bell";
  }

  // Resolve a displayable icon source for a notification.
  // Handles three cases Quickshell.iconPath alone does not:
  //  1. Chrome/Chromium send appIcon as a file:// URL to a temp logo.png
  //     (e.g. "file:///tmp/com.google.Chrome.scoped_dir.XXX/logo.png").
  //     Passing that through iconPath mangles it, so use it directly.
  //  2. Absolute paths ("/...") are also used directly.
  //  3. Plain theme names go through iconPath; on miss return "" so the
  //     caller shows the CCIcon glyph fallback (iconKindFor) instead of a
  //     generic "image-missing" icon.
  function iconSourceFor(n) {
    if (!n) return "";
    try {
      var a = ((n.appIcon || "") + "").trim();
      if (a !== "") {
        if (a.indexOf("file://") === 0 || a.charAt(0) === "/")
          return a;
        var p = Quickshell.iconPath(a, "");
        if (p && (p + "") !== "")
          return p;
        // Theme miss — try well-known names derived from appName before
        // giving up (lets the real product logo show instead of a glyph).
        var app = ((n.appName || "") + "").toLowerCase();
        var cands = [];
        if (app.indexOf("chrome") !== -1 || app.indexOf("chromium") !== -1)
          cands = ["google-chrome", "google-chrome-stable", "chromium", "chrome"];
        else if (app.indexOf("firefox") !== -1 || app.indexOf("zen") !== -1)
          cands = ["firefox", "zen"];
        else if (app.indexOf("discord") !== -1 || app.indexOf("vesktop") !== -1)
          cands = ["discord", "vesktop"];
        else if (app.indexOf("telegram") !== -1)
          cands = ["telegram"];
        else if (app.indexOf("spotify") !== -1)
          cands = ["spotify"];
        for (var i = 0; i < cands.length; ++i) {
          var q = Quickshell.iconPath(cands[i], "");
          if (q && (q + "") !== "")
            return q;
        }
        return "";
      }
      // No appIcon at all — still try the well-known theme name so the
      // real logo shows; otherwise "" triggers the glyph fallback.
      var app2 = ((n.appName || "") + "").toLowerCase();
      if (app2.indexOf("chrome") !== -1 || app2.indexOf("chromium") !== -1) {
        var qc = Quickshell.iconPath("google-chrome", "");
        if (qc && (qc + "") !== "")
          return qc;
      }
      return "";
    } catch (e) {
      return "";
    }
  }

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

  function toggleDnd() {    dnd = !dnd;
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
      pillTimer.interval = 2800; // 2.8s display duration
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
