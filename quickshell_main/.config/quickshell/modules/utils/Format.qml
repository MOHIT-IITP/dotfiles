pragma Singleton

import Quickshell
import QtQuick

// Small formatting helpers.
Singleton {
  function fmtTime(s) {
    if (s === undefined || s === null || !isFinite(s) || s < 0)
      return "0:00";
    var m = Math.floor(s / 60);
    var sec = Math.floor(s % 60);
    return m + ":" + (sec < 10 ? "0" : "") + sec;
  }
}
