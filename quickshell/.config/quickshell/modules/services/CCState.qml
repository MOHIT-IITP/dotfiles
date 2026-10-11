pragma Singleton

import Quickshell

// Control-center visibility state for the center bar.
// Toggled via IPC `qs ipc call mohiitp cc` (Super+S).
// ClockPill mirrors TimerState: opening sets isControlCenterView,
// closing the view (Esc / click-outside / swipe) clears it back.
Singleton {
  id: root

  property bool open: false
  function toggle(): void {
    open = !open;
  }
  function openView(): void {
    open = true;
  }
  function closeView(): void {
    open = false;
  }
}
