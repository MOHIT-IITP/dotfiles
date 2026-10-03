import QtQuick
import "../services"

// Center-bar countdown timer picker (iOS Dynamic-Island style).
// Top: draggable ruler (numbers every 5 min, ticks every 1 min).
// Bottom: Start/Cancel pill (left) + MM:SS readout (right).
Item {
  id: root

  implicitWidth: 360
  implicitHeight: 218

  property bool timerHover: false
  readonly property bool isRunning: TimerState.running || TimerState.paused || TimerState.finished
  readonly property color timerOrange: "#FF9E2C"
  readonly property color tickDim: "#5C4A38"

  HoverHandler {
    id: hoverH
    onHoveredChanged: root.timerHover = hovered
  }

  Column {
    anchors.fill: parent
    anchors.margins: 14
    spacing: 6

    // ================= RULER =================
    Item {
      id: rulerArea
      width: parent.width
      height: 112

      property real tickGap: 14
      property int window: 11 // +/- minutes shown around selection
      property real pressX: 0
      property int pressMin: 22
      property bool dragging: false

      // Labels row (numbers every 5 min)
      Row {
        id: labelRow
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0
        Repeater {
          model: rulerArea.window * 2 + 1
          delegate: Item {
            property int minute: TimerState.selectedMinutes + (index - rulerArea.window)
            property bool valid: minute >= 1 && minute <= 120
            property bool labeled: valid && minute % 5 === 0
            property bool active: (index - rulerArea.window) <= 0
            width: rulerArea.tickGap
            height: 26
            Text {
              anchors.centerIn: parent
              visible: labeled
              text: valid ? minute : ""
              color: active ? root.timerOrange : root.tickDim
              opacity: active ? 1.0 : 0.55
              font.pixelSize: 18
              font.bold: true
              font.family: SettingsState.fontFamily
            }
          }
        }
      }

      // Ticks row
      Row {
        anchors.top: labelRow.bottom
        anchors.topMargin: 4
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0
        Repeater {
          model: rulerArea.window * 2 + 1
          delegate: Item {
            property int minute: TimerState.selectedMinutes + (index - rulerArea.window)
            property bool valid: minute >= 1 && minute <= 120
            property bool major: valid && minute % 5 === 0
            property bool active: (index - rulerArea.window) <= 0
            width: rulerArea.tickGap
            height: 46
            Rectangle {
              anchors.top: parent.top
              anchors.horizontalCenter: parent.horizontalCenter
              width: major ? 3.5 : 2.5
              height: major ? 42 : 26
              radius: 1.5
              visible: valid
              color: active ? root.timerOrange : root.tickDim
              opacity: active ? 1.0 : 0.5
            }
          }
        }
      }

      // Center marker triangle
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        text: "▲"
        color: root.timerOrange
        font.pixelSize: 16
        font.family: SettingsState.fontFamily
      }

      // Running progress hint (thin bar under marker)
      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -2
        width: 120 * TimerState.progress
        height: 2
        radius: 1
        visible: root.isRunning && !TimerState.finished
        color: root.timerOrange
      }

      MouseArea {
        anchors.fill: parent
        enabled: !TimerState.running && !TimerState.paused
        hoverEnabled: false
        cursorShape: Qt.SizeHorCursor
        preventStealing: true
        onPressed: function(ev) {
          rulerArea.pressX = ev.x;
          rulerArea.pressMin = TimerState.selectedMinutes;
          rulerArea.dragging = true;
        }
        onPositionChanged: function(ev) {
          if (!rulerArea.dragging) return;
          var dx = rulerArea.pressX - ev.x; // drag left -> increase
          TimerState.setMinutes(rulerArea.pressMin + dx / rulerArea.tickGap);
        }
        onReleased: { rulerArea.dragging = false; }
        onWheel: function(wheel) {
          var d = 0;
          if (wheel.angleDelta.y > 0 || wheel.angleDelta.x > 0) d = 1;
          else if (wheel.angleDelta.y < 0 || wheel.angleDelta.x < 0) d = -1;
          if (d !== 0) TimerState.adjust(d);
        }
      }
    }

    // ================= BOTTOM ROW =================
    Item {
      width: parent.width
      height: 66

      // Left: Start / Cancel (+ pause when running)
      Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Rectangle {
          id: mainBtn
          width: (TimerState.running || TimerState.paused) ? 52 : 160
          height: 52
          radius: 26
          color: Qt.rgba(1.0, 0.62, 0.17, 0.16)

          Behavior on width {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
          }

          Text {
            anchors.centerIn: parent
            text: TimerState.finished ? "Dismiss" : (TimerState.running || TimerState.paused ? "×" : "Start Timer")
            color: root.timerOrange
            font.pixelSize: (TimerState.running || TimerState.paused) ? 24 : 18
            font.bold: true
            font.family: SettingsState.fontFamily
          }

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (TimerState.finished) TimerState.dismissDone();
              else if (TimerState.running || TimerState.paused) TimerState.cancel();
              else TimerState.start();
            }
          }
        }

        // Pause / resume circle (only while running)
        Rectangle {
          width: 52
          height: 52
          radius: 26
          visible: TimerState.running || TimerState.paused
          color: pauseMouse.containsMouse ? Qt.rgba(1.0, 0.62, 0.17, 0.28) : Qt.rgba(1.0, 0.62, 0.17, 0.16)
          border.color: Qt.rgba(1.0, 0.62, 0.17, 0.35)
          border.width: 1
          Text {
            anchors.centerIn: parent
            text: TimerState.paused ? "▶" : "⏸"
            color: root.timerOrange
            font.pixelSize: 17
            font.family: SettingsState.fontFamily
          }
          MouseArea {
            id: pauseMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (TimerState.paused) TimerState.resume();
              else TimerState.pause();
            }
          }
        }
      }

      // Right: MM:SS readout
      Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: TimerState.finished ? "00:00" : (TimerState.running || TimerState.paused ? TimerState.formatted : TimerState.selectedLabel)
        color: root.timerOrange
        font.pixelSize: 42
        font.bold: true
        font.family: SettingsState.fontFamily

        // Gentle pulse when time is up
        SequentialAnimation on opacity {
          running: TimerState.finished
          loops: Animation.Infinite
          NumberAnimation { from: 1.0; to: 0.4; duration: 600; easing.type: Easing.InOutSine }
          NumberAnimation { from: 0.4; to: 1.0; duration: 600; easing.type: Easing.InOutSine }
        }
      }
    }
  }
}
