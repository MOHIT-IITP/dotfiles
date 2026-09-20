pragma Singleton

import Quickshell
import QtQuick

// Shared mixer popup modal state (toggled via IPC or Super+Ctrl+M)
Singleton {
  id: root

  property bool open: false

  function toggle() {
    open = !open;
  }

  function close() {
    open = false;
  }
}
