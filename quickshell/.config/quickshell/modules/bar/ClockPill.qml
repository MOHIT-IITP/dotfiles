import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects
import "../services"

// Center Date & Time pill.
// Normal state: configurable time format (24h/12h, seconds, font) + Cava visualizer.
// Workspace switch: temporarily reveals workspace dots + active bar.
// Hovered: big clock + 7-day strip.
// Right swipe on hover: seamlessly morphs the center bar itself into the Weather & Calendar dual-pane widget!
Rectangle {
  id: root

  required property var date

  // Track workspace changes
  readonly property int currentWsId: Hyprland.focusedWorkspace?.id ?? 1
  property bool showWorkspaces: false
  property bool isWeatherView: false

  onCurrentWsIdChanged: {
    showWorkspaces = true;
    wsTimer.restart();
  }

  Timer {
    id: wsTimer
    interval: 1800
    repeat: false
    onTriggered: {
      root.showWorkspaces = false;
    }
  }

  // Determine highest workspace number to display
  readonly property int maxWs: {
    var m = 3;
    if (currentWsId > m) {
      m = currentWsId;
    }
    var list = Hyprland.workspaces?.values ?? [];
    for (var i = 0; i < list.length; ++i) {
      var ws = list[i];
      if (ws && ws.id > m && ws.id <= 10) {
        m = ws.id;
      }
    }
    return Math.min(Math.max(m, 3), 10);
  }

  function isOccupied(wsId) {
    var list = Hyprland.workspaces?.values ?? [];
    for (var i = 0; i < list.length; ++i) {
      if (list[i] && list[i].id === wsId) {
        return true;
      }
    }
    return false;
  }

  readonly property bool showLauncher: LauncherState.open
  readonly property bool showWallpaper: WallpaperState.open && !showLauncher
  readonly property bool showPower: PowerState.open && !showLauncher && !showWallpaper
  readonly property bool showClipboard: ClipboardState.open && !showLauncher && !showWallpaper && !showPower
  readonly property bool showMixer: MixerState.open && !showLauncher && !showWallpaper && !showPower && !showClipboard
  readonly property bool showAuth: AuthState.open && !showLauncher && !showWallpaper && !showPower && !showClipboard && !showMixer
  readonly property bool showNotif: NotifCenter.showNotificationPill && !showLauncher && !showWallpaper && !showPower && !showClipboard && !showMixer && !showAuth
  readonly property bool showWeather: (isWeatherView || CalendarState.open) && !showLauncher && !showWallpaper && !showPower && !showClipboard && !showMixer && !showAuth && !showNotif
  // Hover inside the calendar view (over day/chevron buttons which sit above
  // the gesture MouseArea) must also keep the pill expanded.
  readonly property bool calHovering: wxView.visible && wxView.calHover
  readonly property bool isExpanded: mouse.containsMouse || calHovering || root.isWeatherView || CalendarState.open || LauncherState.open || WallpaperState.open || PowerState.open || ClipboardState.open || MixerState.open || AuthState.open || showNotif
  // Screenshot area/window capture indicator takes over the collapsed center bar
  readonly property bool showCapture: ScreenshotState.capturing && (ScreenshotState.activeMode === "area" || ScreenshotState.activeMode === "window") && !isExpanded

  implicitHeight: isExpanded ? (showLauncher ? (launcherContent.implicitHeight + 28) : (showWallpaper ? 260 : (showPower ? 116 : (showClipboard ? 420 : (showMixer ? 360 : (showAuth ? 210 : (showNotif ? 118 : (showWeather ? 265 : 168)))))))) : 34
  implicitWidth: isExpanded ? (showLauncher ? 400 : (showWallpaper ? 720 : (showPower ? 340 : (showClipboard ? 460 : (showMixer ? 440 : (showAuth ? 460 : (showNotif ? 340 : (showWeather ? 520 : 300)))))))) : (showCapture ? Math.max(captureRow.implicitWidth + 36, 80) : (showWorkspaces ? Math.max(wsRow.implicitWidth + 36, 80) : collapsedRow.implicitWidth + 36))

  radius: isExpanded ? (showLauncher ? 24 : (showWallpaper ? 26 : (showPower ? 22 : (showClipboard ? 22 : (showMixer ? 26 : (showAuth ? 24 : (showNotif ? 28 : (showWeather ? 20 : 28)))))))) : implicitHeight / 2
  color: isExpanded ? SettingsState.bgCard : SettingsState.bgSurface
  border.color: SettingsState.borderBase
  border.width: 1
  clip: true

  function forceFocusLauncher() {
    if (launcherContent) {
      launcherContent.forceFocus();
    }
  }

  function forceFocusWallpaper() {
    if (wallpaperContent) {
      wallpaperContent.forceFocus();
    }
  }

  function forceFocusPower() {
    if (powerMenuContent) {
      powerMenuContent.forceFocus();
    }
  }

  function forceFocusClipboard() {
    if (clipboardContent) {
      clipboardContent.forceFocus();
    }
  }

  function forceFocusMixer() {
    if (hardwareMixerContent) {
      hardwareMixerContent.forceFocus();
    }
  }

  function forceFocusAuth() {
    if (authContent) {
      authContent.forceFocus();
    }
  }

  Behavior on implicitWidth {
    NumberAnimation {
      duration: 280
      easing.type: Easing.OutCubic
    }
  }
  Behavior on implicitHeight {
    NumberAnimation {
      duration: 300
      easing.type: Easing.OutCubic
    }
  }
  Behavior on radius {
    NumberAnimation {
      duration: 300
      easing.type: Easing.OutCubic
    }
  }
  Behavior on color {
    ColorAnimation {
      duration: 180
    }
  }

  // Handle IPC and keybind toggle
  Connections {
    target: CalendarState
    function onOpenChanged() {
      if (CalendarState.open) {
        root.isWeatherView = true;
        CalendarState.refreshWeather();
      } else if (!mouse.containsMouse && !LauncherState.open && !WallpaperState.open && !PowerState.open && !ClipboardState.open && !MixerState.open && !AuthState.open) {
        root.isWeatherView = false;
      }
    }
  }

  Connections {
    target: LauncherState
    function onOpenChanged() {
      if (LauncherState.open) {
        root.isWeatherView = false;
        forceFocusLauncher();
      } else if (!mouse.containsMouse && !CalendarState.open && !WallpaperState.open && !PowerState.open && !ClipboardState.open && !MixerState.open && !AuthState.open) {
        root.isWeatherView = false;
      }
    }
  }

  Connections {
    target: WallpaperState
    function onOpenChanged() {
      if (WallpaperState.open) {
        root.isWeatherView = false;
        forceFocusWallpaper();
      } else if (!mouse.containsMouse && !CalendarState.open && !LauncherState.open && !PowerState.open && !ClipboardState.open && !MixerState.open && !AuthState.open) {
        root.isWeatherView = false;
      }
    }
  }

  Connections {
    target: PowerState
    function onOpenChanged() {
      if (PowerState.open) {
        root.isWeatherView = false;
        forceFocusPower();
      } else if (!mouse.containsMouse && !CalendarState.open && !LauncherState.open && !WallpaperState.open && !ClipboardState.open && !MixerState.open && !AuthState.open) {
        root.isWeatherView = false;
      }
    }
  }

  Connections {
    target: ClipboardState
    function onOpenChanged() {
      if (ClipboardState.open) {
        root.isWeatherView = false;
        forceFocusClipboard();
      } else if (!mouse.containsMouse && !CalendarState.open && !LauncherState.open && !WallpaperState.open && !PowerState.open && !MixerState.open && !AuthState.open) {
        root.isWeatherView = false;
      }
    }
  }

  Connections {
    target: MixerState
    function onOpenChanged() {
      if (MixerState.open) {
        root.isWeatherView = false;
        forceFocusMixer();
      } else if (!mouse.containsMouse && !CalendarState.open && !LauncherState.open && !WallpaperState.open && !PowerState.open && !ClipboardState.open && !AuthState.open) {
        root.isWeatherView = false;
      }
    }
  }

  Connections {
    target: AuthState
    function onOpenChanged() {
      if (AuthState.open) {
        root.isWeatherView = false;
        forceFocusAuth();
      } else if (!mouse.containsMouse && !CalendarState.open && !LauncherState.open && !WallpaperState.open && !PowerState.open && !ClipboardState.open && !MixerState.open) {
        root.isWeatherView = false;
      }
    }
  }

  // Reset to default clock view shortly after the mouse leaves
  Connections {
    target: mouse
    function onContainsMouseChanged() {
      root.pokeLeaveTimer();
    }
  }

  // Live cava levels (0..100) mapped to bar pixel heights.
  // CavaState captures the default-sink monitor, so music and videos
  // drive this accurately; silence rests flat at 3px.
  readonly property var barHeights: {
    var vals = CavaState.values;
    var out = [];
    for (var i = 0; i < 5; ++i) {
      var v = (vals && vals.length > i) ? vals[i] : 0;
      out.push(3 + (Math.max(0, Math.min(100, v)) / 100) * 14);
    }
    return out;
  }

  // ========================================================
  // 1. COLLAPSED VIEW: Cava Visualizer + Time Pill
  // ========================================================
  Row {
    id: collapsedRow
    anchors.centerIn: parent
    spacing: RecorderState.isRecording ? 14 : 7
    opacity: (!root.isExpanded && !root.showWorkspaces && !root.showCapture) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 160 }
    }

    // Cava visualizer bars on the left of time
    // Recording indicator: red dot that smoothly blinks while screen recording
    Rectangle {
      id: recDot
      anchors.verticalCenter: parent.verticalCenter
      width: 8
      height: 8
      radius: 4
      color: "#ff453a"
      visible: RecorderState.isRecording

      SequentialAnimation on opacity {
        running: RecorderState.isRecording
        loops: Animation.Infinite
        NumberAnimation {
          from: 1.0
          to: 0.2
          duration: 900
          easing.type: Easing.InOutSine
        }
        NumberAnimation {
          from: 0.2
          to: 1.0
          duration: 900
          easing.type: Easing.InOutSine
        }
      }
    }

    Row {
      id: visualizerRow
      anchors.verticalCenter: parent.verticalCenter
      spacing: 2
      visible: SettingsState.musicVisualizer

      Repeater {
        model: 5

        delegate: Rectangle {
          width: 2.8
          height: root.barHeights[index] || 3
          radius: 1.4
          color: SettingsState.accent
          anchors.verticalCenter: parent.verticalCenter

          Behavior on height {
            NumberAnimation {
              duration: 50
              easing.type: Easing.OutQuad
            }
          }
        }
      }
    }

    Text {
      id: timeText
      anchors.verticalCenter: parent.verticalCenter
      visible: !RecorderState.isRecording
      text: {
        var fmt = "";
        if (SettingsState.timeFormat === "24h") {
          fmt = SettingsState.clockSeconds ? "HH:mm:ss" : "HH:mm";
        } else {
          fmt = SettingsState.clockSeconds ? "hh:mm:ss AP" : "hh:mm AP";
        }
        return Qt.formatDateTime(root.date, fmt);
      }
      color: SettingsState.accent
      font.pixelSize: 17
      font.bold: true
      font.family: SettingsState.fontFamily
    }

    // Spacer between time and mute indicators so the mic icon never hugs the text
    // Privacy indicators: solid yellow = camera in use, solid green = mic in use (never blink)
    // Spacer so the dots never hug the time text
    Item {
      width: 6
      height: 1
      visible: PrivacyState.cameraActive || PrivacyState.micActive
    }

    Row {
      anchors.verticalCenter: parent.verticalCenter
      spacing: 5
      visible: PrivacyState.cameraActive || PrivacyState.micActive

      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 8
        height: 8
        radius: 4
        color: "#ffd60a"
        visible: PrivacyState.cameraActive
      }

      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 8
        height: 8
        radius: 4
        color: "#30d158"
        visible: PrivacyState.micActive
      }
    }

    Item {
      width: 6
      height: 1
      visible: AudioState.inMuted || AudioState.outMuted
    }

    // Mic mute indicator: right side inside center bar, only when mic is muted
    CCIcon {
      id: micMuteIcon
      anchors.verticalCenter: parent.verticalCenter
      width: 16
      height: 16
      kind: "mic-mute"
      glyph: "#ff8a8a"
      visible: AudioState.inMuted
    }

    // Sound mute indicator: right side inside center bar, only when output is muted
    CCIcon {
      id: soundMuteIcon
      anchors.verticalCenter: parent.verticalCenter
      width: 16
      height: 16
      kind: "sound-mute"
      glyph: "#ff8a8a"
      visible: AudioState.outMuted
    }

    // DND indicator: yellow bell-slash, only when Do Not Disturb is on
    CCIcon {
      anchors.verticalCenter: parent.verticalCenter
      width: 16
      height: 16
      kind: "dnd"
      glyph: "#ffd60a"
      visible: NotifCenter.dnd
    }

    // Recording elapsed time: right side, only while screen recording
    Text {
      id: recTimeText
      anchors.verticalCenter: parent.verticalCenter
      visible: RecorderState.isRecording
      text: RecorderState.formattedTime
      color: "#ff8a8a"
      font.pixelSize: 14
      font.bold: true
      font.family: SettingsState.fontFamily
    }
  }

  // ========================================================
  // 2. WORKSPACE SWITCHER INDICATORS
  // ========================================================
  Row {
    id: wsRow
    anchors.centerIn: parent
    spacing: 8
    opacity: (!root.isExpanded && root.showWorkspaces && !root.showCapture) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 160 }
    }

    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: 8
      height: 8
      radius: 4
      color: "#ff453a"
      visible: RecorderState.isRecording

      SequentialAnimation on opacity {
        running: RecorderState.isRecording && !root.isExpanded && root.showWorkspaces
        loops: Animation.Infinite
        NumberAnimation {
          from: 1.0
          to: 0.2
          duration: 900
          easing.type: Easing.InOutSine
        }
        NumberAnimation {
          from: 0.2
          to: 1.0
          duration: 900
          easing.type: Easing.InOutSine
        }
      }
    }

    Repeater {
      model: root.maxWs

      delegate: Item {
        id: wsItem
        property int wsId: index + 1
        property bool isCurrent: root.currentWsId === wsId
        property bool occupied: root.isOccupied(wsId)

        width: isCurrent ? 26 : 7
        height: 7
        anchors.verticalCenter: parent.verticalCenter

        Behavior on width {
          NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
          }
        }

        Rectangle {
          anchors.fill: parent
          radius: height / 2
          color: wsItem.isCurrent ? SettingsState.accent : (wsItem.occupied ? SettingsState.textSecondary : SettingsState.borderBase)

          Behavior on color {
            ColorAnimation { duration: 200 }
          }
        }

        MouseArea {
          anchors.fill: parent
          anchors.margins: -6
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            Hyprland.dispatch("workspace " + wsItem.wsId);
            root.showWorkspaces = true;
            wsTimer.restart();
          }
        }
      }
    }

    // Privacy indicators: solid yellow = camera in use, solid green = mic in use (never blink)
    // Spacer so the dots never hug the time text
    Item {
      width: 6
      height: 1
      visible: PrivacyState.cameraActive || PrivacyState.micActive
    }

    Row {
      anchors.verticalCenter: parent.verticalCenter
      spacing: 5
      visible: PrivacyState.cameraActive || PrivacyState.micActive

      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 8
        height: 8
        radius: 4
        color: "#ffd60a"
        visible: PrivacyState.cameraActive
      }

      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 8
        height: 8
        radius: 4
        color: "#30d158"
        visible: PrivacyState.micActive
      }
    }

    Item {
      width: 6
      height: 1
      visible: AudioState.inMuted || AudioState.outMuted
    }

    CCIcon {
      anchors.verticalCenter: parent.verticalCenter
      width: 16
      height: 16
      kind: "mic-mute"
      glyph: "#ff8a8a"
      visible: AudioState.inMuted
    }

    CCIcon {
      anchors.verticalCenter: parent.verticalCenter
      width: 16
      height: 16
      kind: "sound-mute"
      glyph: "#ff8a8a"
      visible: AudioState.outMuted
    }

    // DND indicator: yellow bell-slash, only when Do Not Disturb is on
    CCIcon {
      anchors.verticalCenter: parent.verticalCenter
      width: 16
      height: 16
      kind: "dnd"
      glyph: "#ffd60a"
      visible: NotifCenter.dnd
    }
  }

  // ========================================================
  // 2b. SCREENSHOT CAPTURE INDICATOR (area / window mode)
  // ========================================================
  Row {
    id: captureRow
    anchors.centerIn: parent
    spacing: 7
    opacity: root.showCapture ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 160 }
    }

    CCIcon {
      anchors.verticalCenter: parent.verticalCenter
      width: 16
      height: 16
      kind: "camera"
      glyph: SettingsState.accent
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: "Capture"
      color: SettingsState.accent
      font.pixelSize: 17
      font.bold: true
      font.family: SettingsState.fontFamily

      SequentialAnimation on opacity {
        running: root.showCapture
        loops: Animation.Infinite
        NumberAnimation {
          from: 1.0
          to: 0.45
          duration: 700
          easing.type: Easing.InOutSine
        }
        NumberAnimation {
          from: 0.45
          to: 1.0
          duration: 700
          easing.type: Easing.InOutSine
        }
      }
    }
  }

  // ========================================================
  // 3. EXPANDED HOVER VIEW: Big Time + 7-Day Strip + Swipe Hint
  // ========================================================
  Item {
    anchors.fill: parent
    opacity: (root.isExpanded && !root.showWeather && !root.showLauncher && !root.showWallpaper && !root.showPower && !root.showClipboard && !root.showMixer && !root.showAuth && !root.showNotif) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 200 }
    }

    Column {
      anchors.centerIn: parent
      spacing: 12

      // Big 12hr time
      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 10
          height: 10
          radius: 5
          color: "#ff453a"
          visible: RecorderState.isRecording

          SequentialAnimation on opacity {
            running: RecorderState.isRecording
            loops: Animation.Infinite
            NumberAnimation {
              from: 1.0
              to: 0.2
              duration: 900
              easing.type: Easing.InOutSine
            }
            NumberAnimation {
              from: 0.2
              to: 1.0
              duration: 900
              easing.type: Easing.InOutSine
            }
          }
        }

        Text {
          id: bigTimeText
          text: {
            var h = root.date.getHours();
            var m = root.date.getMinutes();
            var s = root.date.getSeconds();
            function pad(n) {
              return (n < 10 ? "0" : "") + n;
            }
            if (SettingsState.timeFormat === "24h") {
              return pad(h) + ":" + pad(m) + (SettingsState.clockSeconds ? ":" + pad(s) : "");
            }
            // NOTE: Qt's "hh" only yields 1-12 when the format string also
            // contains an AP marker, so compute 12-hour digits explicitly.
            var h12 = h % 12;
            if (h12 === 0) {
              h12 = 12;
            }
            return pad(h12) + ":" + pad(m) + (SettingsState.clockSeconds ? ":" + pad(s) : "");
          }
          color: SettingsState.accent
          font.pixelSize: 34
          font.bold: true
          font.family: SettingsState.fontFamily
        }
        Text {
          anchors.baseline: bigTimeText.baseline
          visible: SettingsState.timeFormat !== "24h"
          text: Qt.formatDateTime(root.date, "AP")
          color: SettingsState.accent
          opacity: 0.8
          font.pixelSize: 15
          font.bold: true
          font.family: SettingsState.fontFamily
        }
      }

      // 7-day strip centered on today (today-3 .. today+3)
      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 14

        Repeater {
          model: 7

          delegate: Column {
            spacing: 4

            property var dayDate: {
              var d = new Date(root.date);
              d.setDate(d.getDate() + (index - 3));
              return d;
            }
            property bool isToday: index === 3
            property bool isSunday: dayDate.getDay() === 0

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: isToday ? Qt.formatDateTime(dayDate, "ddd").toUpperCase() : Qt.formatDateTime(dayDate, "ddd").substring(0, 1).toUpperCase()
              color: isToday ? SettingsState.accent : (isSunday ? "#e86a65" : SettingsState.textMuted)
              font.pixelSize: isToday ? 13 : 12
              font.bold: isToday || isSunday
              font.family: SettingsState.fontFamily
            }
            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: Qt.formatDateTime(dayDate, "d")
              color: isToday ? SettingsState.accent : (isSunday ? "#e86a65" : SettingsState.textSecondary)
              font.pixelSize: isToday ? 18 : 15
              font.bold: isToday
              font.family: SettingsState.fontFamily
            }
          }
        }
      }
    }
  }

  // ========================================================
  // 4. WEATHER & CALENDAR VIEW (Directly inside Center Bar)
  // ========================================================
  WeatherCalendarView {
    id: wxView
    anchors.fill: parent
    opacity: (root.isExpanded && root.showWeather && !root.showLauncher && !root.showWallpaper && !root.showPower && !root.showClipboard && !root.showMixer && !root.showAuth && !root.showNotif) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 220 }
    }
  }

  // ========================================================
  // 5. EMBEDDED APP LAUNCHER VIEW (Directly inside Center Bar)
  // ========================================================
  LauncherContent {
    id: launcherContent
    anchors.fill: parent
    opacity: (root.isExpanded && root.showLauncher) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 180 }
    }
  }

  // ========================================================
  // 6. EMBEDDED WALLPAPER SELECTOR VIEW (Directly inside Center Bar)
  // ========================================================
  WallpaperContent {
    id: wallpaperContent
    anchors.fill: parent
    opacity: (root.isExpanded && root.showWallpaper) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 180 }
    }
  }

  // ========================================================
  // 7. EMBEDDED POWER MENU VIEW (Directly inside Center Bar)
  // ========================================================
  PowerMenuContent {
    id: powerMenuContent
    anchors.fill: parent
    opacity: (root.isExpanded && root.showPower) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 180 }
    }
  }

  // ========================================================
  // 8. EMBEDDED CLIPBOARD HISTORY VIEW (Directly inside Center Bar)
  // ========================================================
  ClipboardContent {
    id: clipboardContent
    anchors.fill: parent
    opacity: (root.isExpanded && root.showClipboard) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 180 }
    }
  }

  // ========================================================
  // 9. EMBEDDED HARDWARE MIXER VIEW (Directly inside Center Bar)
  // ========================================================
  HardwareMixerContent {
    id: hardwareMixerContent
    anchors.fill: parent
    opacity: (root.isExpanded && root.showMixer) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 180 }
    }
  }

  // ========================================================
  // 10. EMBEDDED SYSTEM & WI-FI AUTHENTICATION VIEW (Directly inside Center Bar)
  // ========================================================
  AuthContent {
    id: authContent
    anchors.fill: parent
    opacity: (root.isExpanded && root.showAuth) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 180 }
    }
  }

  // ========================================================
  // 11. EMBEDDED NOTIFICATION VIEW (Directly inside Center Bar)
  // ========================================================
  NotificationContent {
    id: notificationContent
    anchors.fill: parent
    opacity: (root.isExpanded && root.showNotif) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 180 }
    }
  }

  // Close the calendar shortly after the pointer fully leaves the pill
  // (both the gesture layer and the calendar buttons). The delay avoids
  // flicker when moving between the background and the day/chevron buttons.
  Timer {
    id: leaveTimer
    interval: 350
    repeat: false
    onTriggered: {
      if (!mouse.containsMouse && !root.calHovering) {
        root.isWeatherView = false;
        CalendarState.close();
      }
    }
  }

  function pokeLeaveTimer(): void {
    if (mouse.containsMouse || root.calHovering) {
      leaveTimer.stop();
    } else {
      leaveTimer.restart();
    }
  }

  onCalHoveringChanged: pokeLeaveTimer()

  // GESTURE & INTERACTION HANDLER
  // ========================================================
  property real _pressX: 0
  property real _pressY: 0
  property bool _swiped: false

  MouseArea {
    id: mouse
    anchors.fill: parent
    z: -1
    enabled: !root.showLauncher && !root.showWallpaper && !root.showPower && !root.showClipboard && !root.showMixer && !root.showAuth && !root.showNotif
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onPressed: function(ev) {
      root._pressX = ev.x;
      root._pressY = ev.y;
      root._swiped = false;
    }

    onPositionChanged: function(ev) {
      // Swipe = press + drag. Ignore pure hover moves, otherwise merely
      // moving the mouse across the pill would open/close the calendar.
      if (!mouse.pressed || root._swiped) {
        return;
      }
      var dx = ev.x - root._pressX;
      var dy = Math.abs(ev.y - root._pressY);

      // Left swipe -> open Weather & Calendar inside center bar
      if (dx < -18 && dy < 45) {
        root._swiped = true;
        root.isWeatherView = true;
        CalendarState.refreshWeather();
      }
      // Right swipe -> return to clock view
      else if (dx > 18 && dy < 45) {
        root._swiped = true;
        root.isWeatherView = false;
      }
    }

    onWheel: wheel => {
      // Touchpad horizontal swipe left -> Open Weather & Calendar inside center bar
      if (wheel.angleDelta.x < 0 || wheel.pixelDelta.x < 0) {
        root.isWeatherView = true;
        CalendarState.refreshWeather();
      }
      // Touchpad horizontal swipe right -> Return to clock view
      else if (wheel.angleDelta.x > 0 || wheel.pixelDelta.x > 0) {
        root.isWeatherView = false;
      }
      // Vertical scroll -> Workspace switch
      else if (wheel.angleDelta.y > 0) {
        Hyprland.dispatch("workspace e-1");
      } else if (wheel.angleDelta.y < 0) {
        Hyprland.dispatch("workspace e+1");
      }
    }
  }
}
