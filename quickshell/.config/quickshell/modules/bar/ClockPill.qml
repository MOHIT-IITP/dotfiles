import Quickshell
import Quickshell.Hyprland
import QtQuick
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

  readonly property bool isExpanded: mouse.containsMouse || CalendarState.open
  readonly property bool showWeather: isWeatherView || CalendarState.open

  implicitHeight: isExpanded ? (showWeather ? 265 : 168) : 34
  implicitWidth: isExpanded ? (showWeather ? 520 : 300) : (showWorkspaces ? Math.max(wsRow.implicitWidth + 36, 80) : collapsedRow.implicitWidth + 36)

  radius: isExpanded ? (showWeather ? 20 : 28) : implicitHeight / 2
  color: isExpanded ? SettingsState.bgCard : SettingsState.bgSurface
  border.color: SettingsState.borderBase
  border.width: 1
  clip: true

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
      } else if (!mouse.containsMouse) {
        root.isWeatherView = false;
      }
    }
  }

  // Reset to default clock view when mouse leaves
  Connections {
    target: mouse
    function onContainsMouseChanged() {
      if (!mouse.containsMouse && !CalendarState.open) {
        root.isWeatherView = false;
      }
    }
  }

  // Cava style dynamic visualizer heights
  property var barHeights: [3, 3, 3, 3, 3]
  property real vizPhase: 0

  Timer {
    id: vizTimer
    interval: 60
    running: SettingsState.musicVisualizer && MediaState.isPlaying
    repeat: true
    onTriggered: {
      root.vizPhase += 0.35;
      var p = root.vizPhase;
      var b0 = 3 + Math.abs(Math.sin(p * 1.3)) * 11;
      var b1 = 4 + Math.abs(Math.sin(p * 2.1 + 0.8)) * 12;
      var b2 = 5 + Math.abs(Math.cos(p * 1.7 + 1.2)) * 14;
      var b3 = 4 + Math.abs(Math.sin(p * 2.4 + 2.0)) * 12;
      var b4 = 3 + Math.abs(Math.cos(p * 1.5 + 0.5)) * 10;
      root.barHeights = [b0, b1, b2, b3, b4];
    }
  }

  Connections {
    target: MediaState
    function onIsPlayingChanged() {
      if (!MediaState.isPlaying) {
        root.barHeights = [3, 3, 3, 3, 3];
      }
    }
  }

  // ========================================================
  // 1. COLLAPSED VIEW: Cava Visualizer + Time Pill
  // ========================================================
  Row {
    id: collapsedRow
    anchors.centerIn: parent
    spacing: 7
    opacity: (!mouse.containsMouse && !root.showWorkspaces) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 160 }
    }

    // Cava visualizer bars on the left of time
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
              duration: 70
              easing.type: Easing.OutQuad
            }
          }
        }
      }
    }

    Text {
      id: timeText
      anchors.verticalCenter: parent.verticalCenter
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
  }

  // ========================================================
  // 2. WORKSPACE SWITCHER INDICATORS
  // ========================================================
  Row {
    id: wsRow
    anchors.centerIn: parent
    spacing: 8
    opacity: (!mouse.containsMouse && root.showWorkspaces) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 160 }
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
  }

  // ========================================================
  // 3. EXPANDED HOVER VIEW: Big Time + 7-Day Strip + Swipe Hint
  // ========================================================
  Item {
    anchors.fill: parent
    opacity: (root.isExpanded && !root.showWeather) ? 1 : 0
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
        spacing: 6

        Text {
          text: Qt.formatDateTime(root.date, "hh:mm")
          color: SettingsState.accent
          font.pixelSize: 34
          font.bold: true
          font.family: SettingsState.fontFamily
        }
        Text {
          anchors.baseline: parent.children[0].baseline
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

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: isToday ? Qt.formatDateTime(dayDate, "ddd").toUpperCase() : Qt.formatDateTime(dayDate, "ddd").substring(0, 1).toUpperCase()
              color: isToday ? SettingsState.accent : SettingsState.textMuted
              font.pixelSize: isToday ? 13 : 12
              font.bold: isToday
              font.family: SettingsState.fontFamily
            }
            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: Qt.formatDateTime(dayDate, "d")
              color: isToday ? SettingsState.accent : SettingsState.textSecondary
              font.pixelSize: isToday ? 18 : 15
              font.bold: isToday
              font.family: SettingsState.fontFamily
            }
          }
        }
      }
    }

    // Right Swipe Navigation Hint Button
    Rectangle {
      anchors.right: parent.right
      anchors.rightMargin: 8
      anchors.verticalCenter: parent.verticalCenter
      width: 24
      height: 36
      radius: 12
      color: rightArrowMouse.containsMouse ? SettingsState.bgCardHover : "transparent"

      Text {
        anchors.centerIn: parent
        text: "›"
        color: rightArrowMouse.containsMouse ? SettingsState.textActive : SettingsState.textMuted
        font.pixelSize: 18
        font.bold: true
      }

      MouseArea {
        id: rightArrowMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          root.isWeatherView = true;
          CalendarState.refreshWeather();
        }
      }
    }
  }

  // ========================================================
  // 4. WEATHER & CALENDAR VIEW (Directly inside Center Bar)
  // ========================================================
  WeatherCalendarView {
    anchors.fill: parent
    opacity: (root.isExpanded && root.showWeather) ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation { duration: 220 }
    }
  }

  // ========================================================
  // GESTURE & INTERACTION HANDLER
  // ========================================================
  property real _pressX: 0
  property real _pressY: 0
  property bool _swiped: false

  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onPressed: function(ev) {
      root._pressX = ev.x;
      root._pressY = ev.y;
      root._swiped = false;
    }

    onPositionChanged: function(ev) {
      if (!root._swiped) {
        var dx = ev.x - root._pressX;
        var dy = Math.abs(ev.y - root._pressY);

        // Right swipe while hovered -> Open Weather & Calendar inside center bar
        if (dx > 18 && dy < 45) {
          root._swiped = true;
          root.isWeatherView = true;
          CalendarState.refreshWeather();
        }
        // Left swipe while hovered -> Return to clock view
        else if (dx < -18 && dy < 45) {
          root._swiped = true;
          root.isWeatherView = false;
        }
      }
    }

    onWheel: wheel => {
      // Touchpad horizontal swipe right -> Open Weather & Calendar inside center bar
      if (wheel.angleDelta.x > 0 || wheel.pixelDelta.x > 0) {
        root.isWeatherView = true;
        CalendarState.refreshWeather();
      }
      // Touchpad horizontal swipe left -> Return to clock view
      else if (wheel.angleDelta.x < 0 || wheel.pixelDelta.x < 0) {
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
