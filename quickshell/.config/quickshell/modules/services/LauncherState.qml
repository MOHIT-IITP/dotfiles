pragma Singleton

import Quickshell
import QtQuick

// App launcher open/close state (toggled via IPC: `qs ipc call mohiitp launcher`).
Singleton {
  property bool open: false

  function toggle() {
    open = !open;
  }
  function close() {
    open = false;
  }
}
