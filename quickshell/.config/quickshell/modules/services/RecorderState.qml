pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Screen recording service for Quickshell
Singleton {
  id: root

  property bool open: false
  property bool isRecording: false
  property int elapsedSeconds: 0
  property var recentRecordings: []
  property bool loadingRecent: false

  readonly property string currentAudio: {
    var hasMic = !AudioState.inMuted && AudioState.inVol > 0.01;
    var hasDesk = !AudioState.outMuted && AudioState.outVol > 0.01;
    if (hasMic && hasDesk) return "both";
    if (hasMic) return "mic";
    if (hasDesk) return "desktop";
    return "none";
  }

  readonly property string formattedTime: {
    var m = Math.floor(elapsedSeconds / 60);
    var s = elapsedSeconds % 60;
    return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
  }

  function toggle() {
    if (isRecording) {
      stop();
    } else {
      start();
    }
  }

  function start() {
    isRecording = true;
    elapsedSeconds = 0;
    startStdout = "";
    if (startProc.running) {
      startProc.running = false;
    }
    startProc.command = [
      "bash",
      "/home/mohiitp/.config/quickshell/scripts/recorder.sh",
      "start",
      currentAudio
    ];
    startProc.running = true;
  }

  function stop() {
    isRecording = false;
    if (stopProc.running) {
      stopProc.running = false;
    }
    stopProc.command = [
      "bash",
      "/home/mohiitp/.config/quickshell/scripts/recorder.sh",
      "stop"
    ];
    stopProc.running = true;
    refreshTimer.restart();
  }

  function refreshRecent() {
    listStdout = "";
    loadingRecent = true;
    if (listProc.running) {
      listProc.running = false;
    }
    listProc.running = true;
  }

  function openDir() {
    if (openDirProc.running) {
      openDirProc.running = false;
    }
    openDirProc.command = [
      "bash",
      "/home/mohiitp/.config/quickshell/scripts/recorder.sh",
      "open-dir"
    ];
    openDirProc.running = true;
  }

  function play(path) {
    if (!path) return;
    if (playProc.running) {
      playProc.running = false;
    }
    playProc.command = [
      "bash",
      "/home/mohiitp/.config/quickshell/scripts/recorder.sh",
      "play",
      path
    ];
    playProc.running = true;
  }

  function clearAll() {
    if (clearProc.running) {
      clearProc.running = false;
    }
    clearProc.command = [
      "bash",
      "/home/mohiitp/.config/quickshell/scripts/recorder.sh",
      "clear"
    ];
    clearProc.running = true;
    recentRecordings = [];
  }

  function checkStatus() {
    statusStdout = "";
    if (statusProc.running) {
      statusProc.running = false;
    }
    statusProc.running = true;
  }

  Timer {
    id: recordTimer
    interval: 1000
    repeat: true
    running: root.isRecording
    onTriggered: {
      root.elapsedSeconds += 1;
    }
  }

  Timer {
    id: refreshTimer
    interval: 1200
    repeat: false
    running: false
    onTriggered: {
      root.refreshRecent();
    }
  }

  Timer {
    id: pollStatusTimer
    interval: 3000
    repeat: true
    running: true
    onTriggered: {
      root.checkStatus();
    }
  }

  property string listStdout: ""
  property string statusStdout: ""
  property string startStdout: ""

  Process {
    id: listProc
    command: ["bash", "/home/mohiitp/.config/quickshell/scripts/recorder.sh", "list"]
    running: false

    stdout: SplitParser {
      splitMarker: "\n"
      onRead: data => {
        if (data) {
          root.listStdout += data;
        }
      }
    }

    onExited: function(code, status) {
      try {
        if (root.listStdout && root.listStdout.trim() !== "") {
          root.recentRecordings = JSON.parse(root.listStdout.trim());
        } else {
          root.recentRecordings = [];
        }
      } catch (e) {
        root.recentRecordings = [];
      }
      root.loadingRecent = false;
    }
  }

  Process {
    id: statusProc
    command: ["bash", "/home/mohiitp/.config/quickshell/scripts/recorder.sh", "status"]
    running: false

    stdout: SplitParser {
      splitMarker: "\n"
      onRead: data => {
        if (data) {
          root.statusStdout += data;
        }
      }
    }

    onExited: function(code, status) {
      try {
        if (root.statusStdout && root.statusStdout.trim() !== "") {
          var res = JSON.parse(root.statusStdout.trim());
          if (res.isRecording !== undefined) {
            root.isRecording = !!res.isRecording;
          }
        }
      } catch (e) {}
    }
  }

  Process {
    id: startProc
    running: false

    stdout: SplitParser {
      splitMarker: "\n"
      onRead: data => {
        if (data) {
          root.startStdout += data;
        }
      }
    }

    onExited: function(code, status) {
      if (code !== 0 || root.startStdout.indexOf("cancelled") !== -1 || root.startStdout.indexOf("no_recorder") !== -1) {
        root.isRecording = false;
      }
      root.checkStatus();
    }
  }

  Process {
    id: stopProc
    running: false

    onExited: function(code, status) {
      root.checkStatus();
      root.refreshRecent();
    }
  }

  Process {
    id: openDirProc
    running: false
  }

  Process {
    id: playProc
    running: false
  }

  Process {
    id: clearProc
    running: false
  }

  Component.onCompleted: {
    refreshRecent();
    checkStatus();
  }
}
