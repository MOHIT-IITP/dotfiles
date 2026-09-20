pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Clipboard history service (toggled via IPC: `qs ipc call mohiitp clipboard` or Super+Ctrl+V).
Singleton {
  id: root

  property bool open: false
  property var history: []
  property bool loading: false

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
    rawLines = [];
    loading = true;
    if (listProc.running) {
      listProc.running = false;
    }
    listProc.running = true;
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

  property var rawLines: []

  // Background watcher daemon process that records every clipboard copy
  Process {
    id: watchProc
    command: ["bash", "/home/mohiitp/.config/quickshell/scripts/cliphist.sh", "watch"]
    running: true
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
          var display = (tabIdx >= 0) ? clean.substring(tabIdx + 1).trim() : clean;
          root.rawLines.push({
            raw: data,
            text: display
          });
        }
      }
    }

    onExited: function(code, status) {
      root.history = root.rawLines;
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
