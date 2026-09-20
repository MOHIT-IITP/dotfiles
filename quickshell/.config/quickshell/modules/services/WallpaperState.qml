pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Wallpaper state: scans ~/pix, tracks filter, current selection, and executes wallpaper changer.
Singleton {
  id: root

  property bool open: false
  property string dirPath: {
    var f = SettingsState.wallpaperFolder;
    if (!f || f === "") f = "~/Pictures/Wallpapers";
    if (f.indexOf("~") === 0) f = f.replace("~", "/home/mohiitp");
    return f;
  }
  property string filter: "all" // "all" | "still" | "live"
  property var allWallpapers: []
  property int currentIndex: 0
  property bool isApplying: false
  property string lastApplied: ""

  onDirPathChanged: {
    refresh();
  }

  onOpenChanged: {
    if (open) {
      refresh();
    }
  }

  Timer {
    interval: 3000
    repeat: true
    running: root.open
    onTriggered: root.refresh()
  }

  readonly property var filteredWallpapers: {
    var list = [];
    for (var i = 0; i < allWallpapers.length; ++i) {
      var item = allWallpapers[i];
      if (!item) continue;
      if (filter === "all") {
        list.push(item);
      } else if (filter === "still" && !item.isLive) {
        list.push(item);
      } else if (filter === "live" && item.isLive) {
        list.push(item);
      }
    }
    return list;
  }

  readonly property var currentWallpaper: {
    if (filteredWallpapers.length > 0 && currentIndex >= 0 && currentIndex < filteredWallpapers.length) {
      return filteredWallpapers[currentIndex];
    }
    return null;
  }

  function toggle() {
    open = !open;
    if (open) {
      refresh();
    }
  }

  function close() {
    open = false;
  }

  function setFilter(f) {
    filter = f;
    currentIndex = 0;
  }

  function selectIndex(idx) {
    if (idx >= 0 && idx < filteredWallpapers.length) {
      currentIndex = idx;
    }
  }

  function next() {
    if (filteredWallpapers.length > 0) {
      currentIndex = (currentIndex + 1) % filteredWallpapers.length;
    }
  }

  function prev() {
    if (filteredWallpapers.length > 0) {
      currentIndex = (currentIndex - 1 + filteredWallpapers.length) % filteredWallpapers.length;
    }
  }

  function refresh() {
    if (scanProcess.running) {
      scanProcess.running = false;
    }
    scanProcess.command = ["/home/mohiitp/.config/quickshell/scripts/scan_wallpapers.sh", root.dirPath];
    scanProcess.running = true;
  }

  function applyCurrent() {
    if (currentWallpaper && currentWallpaper.path) {
      applyWallpaper(currentWallpaper.path);
    }
  }

  function applyWallpaper(path) {
    if (!path) return;
    lastApplied = path;
    isApplying = true;
    applyProcess.command = ["/home/mohiitp/.config/quickshell/scripts/apply_wallpaper.sh", path];
    applyProcess.running = true;
  }

  // Scan wallpapers process
  Process {
    id: scanProcess
    command: ["/home/mohiitp/.config/quickshell/scripts/scan_wallpapers.sh", root.dirPath]
    running: true

    stdout: SplitParser {
      onRead: data => {
        try {
          var parsed = JSON.parse(data);
          if (Array.isArray(parsed)) {
            root.allWallpapers = parsed;
            if (root.currentIndex >= parsed.length) {
              root.currentIndex = 0;
            }
          }
        } catch (e) {
          console.log("Error parsing wallpapers JSON: " + e);
        }
      }
    }
  }

  // Apply wallpaper process
  Process {
    id: applyProcess
    running: false
    onExited: function(code, status) {
      root.isApplying = false;
    }
  }
}
