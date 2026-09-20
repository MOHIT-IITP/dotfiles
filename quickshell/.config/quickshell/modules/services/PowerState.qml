pragma Singleton

import Quickshell
import QtQuick

// Power menu state (toggled via IPC: `qs ipc call mohiitp power` or Super+Ctrl+P).
Singleton {
  property bool open: false

  function toggle() {
    open = !open;
  }

  function close() {
    open = false;
  }

  function openMenu() {
    open = true;
  }
}
