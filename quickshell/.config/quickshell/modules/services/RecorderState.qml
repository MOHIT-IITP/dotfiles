pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Screen recording service for Quickshell
Singleton {
  id: root

  property bool open: false // expanded recorder card in the center bar (Super+Ctrl+R)
  property bool isRecording: false
  property int elapsedSeconds: 0
  property var recentRecordings: []
  property bool loadingRecent: false

  // Capture target: "fullscreen" | "area"
  property string mode: "fullscreen"
  property string areaGeometry: "" // slurp raw: "X,Y WxH"
  property string areaRegion: "" // gpu-screen-recorder form: "WxH+X+Y"
  property bool selectingArea: false

  // Capture settings (dropdown in RecorderPage)
  property int fps: 120 // 30 | 60 | 120 | 144
  property string quality: "high" // "medium" | "high" | "very_high" | "ultra" (shown Med/High/Ultra/Loss)
  property bool captureCursor: true
  property int countdown: 5 // 0 | 3 | 5 | 10 (seconds)
  property bool settingsExpanded: false
  // After tapping Start: show Screen | Window/Region target picker
  property bool choosingTarget: false
  // Countdown in progress before the recorder spawns
  property bool starting: false
  property int countdownLeft: 0

  readonly property var fpsOptions: [30, 60, 120, 144]
  readonly property var qualityOptions: ["medium", "high", "very_high", "ultra"]
  readonly property var countdownOptions: [0, 3, 5, 10]

  function qualityLabel(q) {
    if (q === "medium") return "Med";
    if (q === "high") return "High";
    if (q === "very_high") return "Ultra";
    if (q === "ultra") return "Loss";
    return "High";
  }

  readonly property string qualityDisplay: qualityLabel(quality)

  readonly property string summaryText: fps + " fps · " + qualityDisplay

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
    } else if (starting) {
      cancelPending();
    } else {
      beginCountdown();
    }
  }

  // Expanded card view in the center bar (Super+Ctrl+R). Mirrors
  // ScreenshotState.open: ClockPill shows CenterCC on the recorder page
  // while this is true. Separate from toggle() which starts/stops recording.
  function toggleCard(): void {
    open = !open;
    if (open) {
      refreshRecent();
      checkStatus();
    }
  }

  function openCard(): void {
    open = true;
    refreshRecent();
    checkStatus();
  }

  function closeCard(): void {
    open = false;
  }

  function close(): void {
    open = false;
  }

  function requestStart() {
    if (isRecording || selectingArea || starting) return;
    choosingTarget = true;
  }

  function startScreen() {
    if (isRecording || selectingArea || starting) return;
    mode = "fullscreen";
    beginCountdown();
  }

  function startAreaFlow() {
    if (isRecording || selectingArea || starting) return;
    mode = "area";
    if (areaGeometry === "") {
      selectArea(true);
      return;
    }
    beginCountdown();
  }

  function beginCountdown() {
    if (isRecording || selectingArea || starting) return;
    if (countdown <= 0) {
      doStart();
      return;
    }
    starting = true;
    countdownLeft = countdown;
    countdownTimer.restart();
  }

  function cancelPending() {
    countdownTimer.stop();
    starting = false;
    countdownLeft = 0;
    choosingTarget = false;
  }

  function start() {
    // Legacy entry point (keybind): honour countdown, keep current mode.
    choosingTarget = false;
    beginCountdown();
  }

  function doStart() {
    // Starting a recording dismisses the card so the bar collapses
    // (avoids capturing the expanded bar, shows the REC indicator).
    open = false;
    choosingTarget = false;
    starting = false;
    // Area mode without a selection: run slurp first, then start.
    if (mode === "area" && areaGeometry === "") {
      selectArea(true);
      return;
    }
    isRecording = true;
    elapsedSeconds = 0;
    startStdout = "";
    if (startProc.running) {
      startProc.running = false;
    }
    var cmd = [
      "bash",
      "/home/mohiitp/.config/quickshell/scripts/recorder.sh",
      "start",
      currentAudio,
      mode,
      String(fps),
      quality,
      captureCursor ? "yes" : "no"
    ];
    if (mode === "area" && areaGeometry !== "") {
      cmd.push(areaGeometry);
    }
    startProc.command = cmd;
    startProc.running = true;
  }

  function selectArea(autoStart) {
    if (selectingArea || isRecording) return;
    selectingArea = true;
    selectStdout = "";
    _selectAutoStart = !!autoStart;
    if (selectProc.running) {
      selectProc.running = false;
    }
    selectProc.command = [
      "bash",
      "/home/mohiitp/.config/quickshell/scripts/recorder.sh",
      "select-area"
    ];
    selectProc.running = true;
  }

  function clearArea() {
    areaGeometry = "";
    areaRegion = "";
  }

  function stop() {
    countdownTimer.stop();
    starting = false;
    choosingTarget = false;
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
    id: countdownTimer
    interval: 1000
    repeat: true
    running: false
    onTriggered: {
      root.countdownLeft -= 1;
      if (root.countdownLeft <= 0) {
        stop();
        root.doStart();
      }
    }
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
  property string selectStdout: ""
  property bool _selectAutoStart: false

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
    id: selectProc
    running: false

    stdout: SplitParser {
      splitMarker: "\n"
      onRead: data => {
        if (data) {
          root.selectStdout += data;
        }
      }
    }

    onExited: function(code, status) {
      root.selectingArea = false;
      try {
        var txt = (root.selectStdout || "").trim();
        if (txt !== "") {
          var res = JSON.parse(txt);
          if (res.status === "selected" && res.geometry) {
            root.areaGeometry = res.geometry;
            root.areaRegion = res.region || "";
            root.mode = "area";
            if (root._selectAutoStart) {
              root._selectAutoStart = false;
              root.beginCountdown();
              return;
            }
          }
        }
      } catch (e) {}
      root._selectAutoStart = false;
      root.checkStatus();
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
      if (code !== 0 || root.startStdout.indexOf("cancelled") !== -1 || root.startStdout.indexOf("failed") !== -1 || root.startStdout.indexOf("no_recorder") !== -1 || root.startStdout.indexOf("no_slurp") !== -1) {
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
