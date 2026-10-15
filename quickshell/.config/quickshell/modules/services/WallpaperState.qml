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

  // NOTE: no periodic auto-refresh while open. The previous 3s poll replaced
  // allWallpapers with a brand-new array even when nothing changed, which
  // rebuilt every filmstrip delegate and flashed all thumbs black (~1s async
  // re-decode with cache:false). Refresh now happens on open / folder change /
  // manual button only; trash() already updates the list optimistically.

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
    if (filteredWallpapers.length > 0 && currentIndex < filteredWallpapers.length - 1) {
      currentIndex++;
    }
  }

  function prev() {
    if (filteredWallpapers.length > 0 && currentIndex > 0) {
      currentIndex--;
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
    var mode = SettingsState.wallpaperResizeMode || "crop";
    applyProcess.command = ["/home/mohiitp/.config/quickshell/scripts/apply_wallpaper.sh", path, mode];
    applyProcess.running = true;
  }

  function trash(path) {
    if (!path) return;
    trashProcess.command = ["gio", "trash", path];
    trashProcess.running = true;
    // Optimistic removal so the strip reacts instantly; a failed trash
    // refreshes from disk to restore the entry (see trashProcess.onExited).
    var kept = [];
    for (var i = 0; i < allWallpapers.length; ++i) {
      if (allWallpapers[i] && allWallpapers[i].path !== path)
        kept.push(allWallpapers[i]);
    }
    allWallpapers = kept;
    if (currentIndex >= filteredWallpapers.length)
      currentIndex = Math.max(0, filteredWallpapers.length - 1);
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
            // Diff guard: assigning a new array identity rebuilds the whole
            // Repeater (every Image re-decodes async -> black flash). Skip the
            // assignment when the scan found nothing new.
            var same = parsed.length === root.allWallpapers.length;
            if (same) {
              for (var i = 0; i < parsed.length; ++i) {
                var a = root.allWallpapers[i];
                var b = parsed[i];
                if (!a || !b || a.path !== b.path || !!a.isLive !== !!b.isLive) {
                  same = false;
                  break;
                }
              }
            }
            if (!same) {
              root.allWallpapers = parsed;
            }
            if (root.currentIndex >= parsed.length) {
              root.currentIndex = Math.max(0, parsed.length - 1);
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

  // Trash (gio trash) process — refresh on failure to restore the entry
  Process {
    id: trashProcess
    running: false
    onExited: function(code, status) {
      if (code !== 0)
        root.refresh();
    }
  }
}
