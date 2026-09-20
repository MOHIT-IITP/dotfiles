pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Screenshot management singleton for full display, active window, and interactive area captures.
Singleton {
  id: root

  property string mode: "window" // "display" | "window" | "area"
  property string lastPath: "~/Pictures/Screenshots"
  property bool capturing: false

  property string _rawOut: ""

  function capture(targetMode): void {
    var m = targetMode || mode;
    capturing = true;
    _rawOut = "";

    if (captureProc.running) {
      captureProc.running = false;
    }

    captureProc.command = [
      "bash",
      "/home/mohiitp/.config/quickshell/scripts/screenshot.sh",
      m
    ];
    captureProc.running = true;
  }

  function refreshLast(): void {
    _rawOut = "";
    if (lastProc.running) {
      lastProc.running = false;
    }
    lastProc.running = true;
  }

  function openLast(): void {
    if (openProc.running) {
      openProc.running = false;
    }
    openProc.command = [
      "bash",
      "/home/mohiitp/.config/quickshell/scripts/screenshot.sh",
      "open",
      lastPath
    ];
    openProc.running = true;
  }

  function openDir(): void {
    if (openDirProc.running) {
      openDirProc.running = false;
    }
    openDirProc.command = [
      "bash",
      "/home/mohiitp/.config/quickshell/scripts/screenshot.sh",
      "open-dir"
    ];
    openDirProc.running = true;
  }

  Process {
    id: captureProc
    running: false

    stdout: SplitParser {
      onRead: data => {
        root._rawOut += data;
      }
    }

    onExited: function (code, status) {
      root.capturing = false;
      if (root._rawOut && root._rawOut.trim().length > 0) {
        var lines = root._rawOut.trim().split("\n");
        var lastLine = lines[lines.length - 1].trim();
        if (lastLine.length > 0 && lastLine.startsWith("/")) {
          root.lastPath = lastLine;
        }
      }
      root._rawOut = "";
    }
  }

  Process {
    id: lastProc
    command: [
      "bash",
      "/home/mohiitp/.config/quickshell/scripts/screenshot.sh",
      "last"
    ]
    running: true

    stdout: SplitParser {
      onRead: data => {
        root._rawOut += data;
      }
    }

    onExited: function (code, status) {
      if (root._rawOut && root._rawOut.trim().length > 0) {
        var lines = root._rawOut.trim().split("\n");
        var lastLine = lines[lines.length - 1].trim();
        if (lastLine.length > 0 && lastLine.startsWith("/")) {
          root.lastPath = lastLine;
        }
      }
      root._rawOut = "";
    }
  }

  Process {
    id: openProc
    running: false
  }

  Process {
    id: openDirProc
    running: false
  }

  Component.onCompleted: {
    refreshLast();
  }
}
