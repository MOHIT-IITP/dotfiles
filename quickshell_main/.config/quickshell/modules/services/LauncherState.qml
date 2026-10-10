pragma Singleton

import Quickshell
import QtQuick

// App + file launcher open/close state.
// `qs ipc call mohiitp launcher` -> apps mode, `qs ipc call mohiitp files` -> files mode.
Singleton {
  property bool open: false
  property string mode: "apps" // "apps" | "files"

  function toggle() {
    open = !open;
  }
  function openApps() {
    mode = "apps";
    open = true;
  }
  function openFiles() {
    mode = "files";
    open = true;
  }
  function toggleFiles() {
    if (open && mode === "files") close();
    else openFiles();
  }
  function toggleMode() {
    mode = (mode === "apps") ? "files" : "apps";
  }
  function close() {
    open = false;
  }
}
