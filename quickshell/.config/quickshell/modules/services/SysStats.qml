pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// System stats polled from scripts/sysstats.sh (RAM, swap, CPU, disk, temp).
// CPU load is diffed between consecutive snapshots in QML.
Singleton {
  id: root

  property real cpuPct: 0
  property int cpuTemp: -1 // -1 = unknown
  property real ramUsedGB: 0
  property real ramTotalGB: 1
  property real ramPct: 0
  property real swapUsedGB: 0
  property real swapTotalGB: 1
  property real swapPct: 0
  property real diskUsedGB: 0
  property real diskTotalGB: 1
  property real diskPct: 0
  property bool ready: false

  property double _prevTotal: 0
  property double _prevIdle: 0
  property string _stdout: ""

  readonly property string ramText: ramUsedGB.toFixed(1) + " GB / " + ramTotalGB.toFixed(1) + " GB"
  readonly property string swapText: swapUsedGB.toFixed(1) + " GB / " + swapTotalGB.toFixed(1) + " GB"
  readonly property string diskText: diskUsedGB.toFixed(1) + " GB / " + diskTotalGB.toFixed(1) + " GB"
  readonly property string tempText: cpuTemp < 0 ? "--" : cpuTemp + "°C"

  function fetch() {
    _stdout = "";
    if (statProc.running)
      statProc.running = false;
    statProc.running = true;
  }

  Timer {
    interval: 2500
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.fetch()
  }

  Process {
    id: statProc
    command: ["bash", "/home/mohiitp/.config/quickshell/scripts/sysstats.sh"]
    running: false

    stdout: SplitParser {
      splitMarker: "\n"
      onRead: data => {
        if (data)
          root._stdout += data;
      }
    }

    onExited: function (code, status) {
      try {
        var txt = (root._stdout || "").trim();
        if (txt === "")
          return;
        var s = JSON.parse(txt);

        var total = Number(s.cpuTotal) || 0;
        var idle = Number(s.cpuIdle) || 0;
        if (root.ready && total > root._prevTotal) {
          var dT = total - root._prevTotal;
          var dI = idle - root._prevIdle;
          if (dT > 0)
            root.cpuPct = Math.max(0, Math.min(100, (1 - dI / dT) * 100));
        }
        root._prevTotal = total;
        root._prevIdle = idle;

        var mT = (Number(s.memTotalKB) || 0) / 1048576;
        var mA = (Number(s.memAvailKB) || 0) / 1048576;
        if (mT > 0) {
          root.ramTotalGB = mT;
          root.ramUsedGB = Math.max(0, mT - mA);
          root.ramPct = Math.max(0, Math.min(100, root.ramUsedGB / mT * 100));
        }

        var sT = (Number(s.swapTotalKB) || 0) / 1048576;
        var sF = (Number(s.swapFreeKB) || 0) / 1048576;
        if (sT > 0) {
          root.swapTotalGB = sT;
          root.swapUsedGB = Math.max(0, sT - sF);
          root.swapPct = Math.max(0, Math.min(100, root.swapUsedGB / sT * 100));
        } else {
          root.swapTotalGB = 0;
          root.swapUsedGB = 0;
          root.swapPct = 0;
        }

        var dT2 = Number(s.diskTotalB) || 0;
        var dU = Number(s.diskUsedB) || 0;
        if (dT2 > 0) {
          root.diskTotalGB = dT2 / 1073741824;
          root.diskUsedGB = Math.max(0, dU / 1073741824);
          root.diskPct = Math.max(0, Math.min(100, root.diskUsedGB / root.diskTotalGB * 100));
        }

        var t = Math.round(Number(s.cpuTemp));
        root.cpuTemp = isNaN(t) ? -1 : t;
        root.ready = true;
      } catch (e) {}
    }
  }
}
