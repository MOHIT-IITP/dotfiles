pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Clipboard history service (toggled via IPC: `qs ipc call mohiitp clipboard` or Super+Ctrl+V).
// Manages background watchers (text + images), thumbnail caching, and history synchronization.
Singleton {
  id: root

  property bool open: false
  property var history: []
  property bool loading: false

  readonly property string thumbDir: (Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")) + "/quickshell/cliphist-thumbs/"

  property var _buffer: []

  Component.onCompleted: {
    refresh();
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

  function openMenu() {
    open = true;
    refresh();
  }

  function refresh() {
    _buffer = [];
    loading = true;
    if (thumbProc.running) {
      thumbProc.running = false;
    }
    if (listProc.running) {
      listProc.running = false;
    }
    thumbProc.running = true;
  }

  function copyItem(raw) {
    if (!raw) return;
    copyProc.command = ["bash", "/home/mohiitp/.config/quickshell/scripts/cliphist.sh", "copy", raw];
    copyProc.running = true;
    close();
  }

  function deleteItem(raw) {
    if (!raw) return;
    deleteProc.command = ["bash", "/home/mohiitp/.config/quickshell/scripts/cliphist.sh", "delete", raw];
    deleteProc.running = true;

    // Optimistically remove from local array
    var arr = [];
    for (var i = 0; i < history.length; ++i) {
      if (history[i].raw !== raw) {
        arr.push(history[i]);
      }
    }
    history = arr;
  }

  function clearAll() {
    wipeProc.command = ["bash", "/home/mohiitp/.config/quickshell/scripts/cliphist.sh", "wipe"];
    wipeProc.running = true;
    history = [];
  }

  // Background watcher processes for text and binary/image clipboard entries
  Process {
    id: watchTextProc
    command: ["bash", "/home/mohiitp/.config/quickshell/scripts/cliphist.sh", "watch-text"]
    running: true
    onExited: respawnTextTimer.restart()
  }

  Timer {
    id: respawnTextTimer
    interval: 2000
    onTriggered: watchTextProc.running = true
  }

  Process {
    id: watchImageProc
    command: ["bash", "/home/mohiitp/.config/quickshell/scripts/cliphist.sh", "watch-image"]
    running: true
    onExited: respawnImageTimer.restart()
  }

  Timer {
    id: respawnImageTimer
    interval: 2000
    onTriggered: watchImageProc.running = true
  }

  // Thumbnail generator process
  Process {
    id: thumbProc
    command: ["bash", "/home/mohiitp/.config/quickshell/scripts/cliphist.sh", "thumbs"]
    running: false
    onExited: {
      listProc.running = true;
    }
  }

  Process {
    id: listProc
    command: ["bash", "/home/mohiitp/.config/quickshell/scripts/cliphist.sh", "list"]
    running: false

    stdout: SplitParser {
      splitMarker: "\n"
      onRead: data => {
        if (data && data.trim() !== "") {
          var clean = data.trim();
          var tabIdx = clean.indexOf("\t");
          var id = (tabIdx >= 0) ? clean.substring(0, tabIdx).trim() : "";
          var preview = (tabIdx >= 0) ? clean.substring(tabIdx + 1).trim() : clean;

          var metaRe = /^\[\[ binary data (.*) \]\]$/;
          var imgRe = /\b(png|jpg|jpeg|gif|bmp|webp)\b/i;
          var splitRe = /^(\S+ \S+) (\w+) (\d+)x(\d+)$/;

          var m = metaRe.exec(preview);
          var isImage = m !== null && imgRe.test(m[1]);
          var label = "";
          var sizeLabel = "";

          if (isImage) {
            var p = splitRe.exec(m[1]);
            label = p ? p[2].toUpperCase() + " " + p[3] + "×" + p[4] : m[1];
            sizeLabel = p ? p[1] : "";
          }

          root._buffer.push({
            id: id,
            raw: data,
            text: preview,
            isImage: isImage,
            label: label,
            sizeLabel: sizeLabel,
            thumb: isImage ? root.thumbDir + id + ".png" : ""
          });
        }
      }
    }

    onExited: function(code, status) {
      root.history = root._buffer.slice(0);
      root._buffer = [];
      root.loading = false;
    }
  }

  Process {
    id: copyProc
    running: false
  }

  Process {
    id: deleteProc
    running: false
  }

  Process {
    id: wipeProc
    running: false
  }
}
