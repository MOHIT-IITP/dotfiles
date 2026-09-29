pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Temporary file shelf / drop zone.
// Drop files onto the center bar -> they are staged here.
// Drag a staged file out to any app (Nautilus, browser, Discord, ...).
// Files persist across restarts in ~/.cache/quickshell/filetray.json.
Singleton {
  id: root

  property bool open: false
  property bool dndHover: false
  property var files: []
  property bool loading: false

  readonly property int count: files.length
  readonly property string storePath: (Quickshell.env("HOME") || "/home/mohiitp") + "/.cache/quickshell/filetray.json"

  function toggle() {
    open = !open;
  }
  function openTray() {
    open = true;
  }
  function close() {
    open = false;
    dndHover = false;
  }

  function baseName(path) {
    if (!path) return "";
    var p = path.toString();
    // strip trailing slashes
    while (p.length > 1 && p.endsWith("/")) p = p.substring(0, p.length - 1);
    var i = Math.max(p.lastIndexOf("/"), p.lastIndexOf("\\"));
    return i >= 0 ? p.substring(i + 1) : p;
  }

  function isImageName(name) {
    var n = (name || "").toLowerCase();
    return n.endsWith(".png") || n.endsWith(".jpg") || n.endsWith(".jpeg")
        || n.endsWith(".gif") || n.endsWith(".bmp") || n.endsWith(".webp")
        || n.endsWith(".svg") || n.endsWith(".avif");
  }

  function urlForPath(path) {
    if (!path) return "";
    var p = path.toString();
    if (p.indexOf("file://") === 0) return p;
    // minimal percent-encoding for spaces etc.; keep '/' intact
    var enc = encodeURI(p);
    return "file://" + enc;
  }

  function pathForUrl(u) {
    var s = u.toString();
    if (s.indexOf("file://") === 0) {
      s = s.substring("file://".length);
      try {
        s = decodeURI(s);
      } catch (e) {}
      // file:///home/... -> /home/...
      return s;
    }
    return s;
  }

  function addUrls(urls) {
    if (!urls || urls.length === 0) return;
    var paths = [];
    for (var i = 0; i < urls.length; ++i) {
      var p = pathForUrl(urls[i]);
      if (p && p !== "") paths.push(p);
    }
    addPaths(paths);
  }

  function addPaths(paths) {
    if (!paths || paths.length === 0) return;
    var arr = files.slice(0);
    var changed = false;
    for (var i = 0; i < paths.length; ++i) {
      var p = (paths[i] || "").toString().trim();
      if (p === "") continue;
      // de-dupe
      var dup = false;
      for (var j = 0; j < arr.length; ++j) {
        if (arr[j] && arr[j].path === p) { dup = true; break; }
      }
      if (dup) continue;
      // skip directories that don't exist? keep anyway, check on open
      var name = baseName(p);
      arr.push({
        path: p,
        name: name || p,
        url: urlForPath(p),
        isImage: isImageName(name)
      });
      changed = true;
    }
    if (changed) {
      // cap at 24 items to keep the pill usable
      while (arr.length > 24) arr.shift();
      files = arr;
      save();
    }
  }

  function removeAt(idx) {
    var arr = files.slice(0);
    if (idx < 0 || idx >= arr.length) return;
    arr.splice(idx, 1);
    files = arr;
    save();
  }

  function clear() {
    if (files.length === 0) return;
    files = [];
    save();
  }

  function moveUp(idx) {
    if (idx <= 0 || idx >= files.length) return;
    var arr = files.slice(0);
    var t = arr[idx - 1]; arr[idx - 1] = arr[idx]; arr[idx] = t;
    files = arr;
    save();
  }

  function moveDown(idx) {
    if (idx < 0 || idx >= files.length - 1) return;
    var arr = files.slice(0);
    var t = arr[idx + 1]; arr[idx + 1] = arr[idx]; arr[idx] = t;
    files = arr;
    save();
  }

  function openFile(idx) {
    if (idx < 0 || idx >= files.length) return;
    var p = files[idx].path;
    if (!p) return;
    Quickshell.execDetached(["xdg-open", p]);
  }

  function revealFile(idx) {
    if (idx < 0 || idx >= files.length) return;
    var p = files[idx].path;
    if (!p) return;
    // open parent folder, best-effort select not supported everywhere
    var dir = p.substring(0, Math.max(p.lastIndexOf("/"), 1));
    if (dir === "") dir = "/";
    Quickshell.execDetached(["xdg-open", dir]);
  }

  function copyPath(idx) {
    if (idx < 0 || idx >= files.length) return;
    Quickshell.execDetached(["bash", "-c", "printf %s " + "'" + files[idx].path.replace(/'/g, "'\\''") + "' | wl-copy"]);
  }

  // ---- persistence ----
  function save() {
    var jsonStr = JSON.stringify(files);
    saveProc.command = ["bash", "-c", "mkdir -p ~/.cache/quickshell && cat << 'FILETRAY_EOF' > ~/.cache/quickshell/filetray.json\n" + jsonStr + "\nFILETRAY_EOF"];
    saveProc.running = true;
  }

  function reload() {
    if (loadProc.running) return;
    loadProc.running = true;
  }

  Component.onCompleted: reload()

  Process {
    id: saveProc
    running: false
  }

  Process {
    id: loadProc
    command: ["bash", "-c", "cat ~/.cache/quickshell/filetray.json 2>/dev/null || echo '[]'"]
    running: false
    stdout: SplitParser {
      onRead: data => {
        try {
          var parsed = JSON.parse(data);
          if (Array.isArray(parsed)) {
            var out = [];
            for (var i = 0; i < parsed.length && i < 24; ++i) {
              var e = parsed[i];
              if (!e) continue;
              var p = (e.path || "").toString();
              if (p === "") continue;
              var name = e.name || root.baseName(p);
              out.push({
                path: p,
                name: name,
                url: e.url || root.urlForPath(p),
                isImage: (e.isImage !== undefined) ? e.isImage : root.isImageName(name)
              });
            }
            root.files = out;
          }
        } catch (e) {}
      }
    }
  }
}
