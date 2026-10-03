import QtQuick
import "../services"

// Center-bar countdown timer picker (iOS Dynamic-Island style).
// Top: draggable ruler (numbers every 5 min, uniform-height rounded tick lines every 1 min, edge fades).
// Bottom: Start/Cancel pill (left) + MM:SS readout (right).
Item {
  id: root

  implicitWidth: 360
  implicitHeight: 218

  property bool timerHover: false
  readonly property bool isRunning: TimerState.running || TimerState.paused || TimerState.finished
  readonly property color timerOrange: "#FF9E2C"
  readonly property color tickDim: "#3D2413"
  readonly property color textDim: "#6E4522"

  HoverHandler {
    id: hoverH
    onHoveredChanged: root.timerHover = hovered
  }

  Column {
    anchors.fill: parent
    anchors.margins: 16
    spacing: 8

    // ================= RULER / SLIDER BAR =================
    Item {
      id: rulerArea
      width: parent.width
      height: 110

      property real tickGap: 10
      property int window: 16 // +/- 16 minutes shown around selection
      property real pressX: 0
      property int pressMin: 15
      property bool dragging: false

      // Ruler content (Labels + uniform tick lines)
      Item {
        anchors.top: parent.top
        anchors.bottom: markerArea.top
        anchors.left: parent.left
        anchors.right: parent.right

        // Labels row (numbers every 5 min: 0, 5, 10, 15, 20, 25, 30...)
        Row {
          id: labelRow
          anchors.top: parent.top
          anchors.topMargin: 2
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: 0

          Repeater {
            model: rulerArea.window * 2 + 1
            delegate: Item {
              property int minute: TimerState.selectedMinutes + (index - rulerArea.window)
              property bool valid: minute >= 0 && minute <= 120
              property bool labeled: valid && minute % 5 === 0
              property bool active: (index - rulerArea.window) <= 0
              width: rulerArea.tickGap
              height: 22

              Text {
                anchors.centerIn: parent
                visible: labeled
                text: valid ? minute : ""
                color: active ? root.timerOrange : root.textDim
                opacity: active ? 1.0 : 0.6
                font.pixelSize: 15
                font.bold: true
                font.family: SettingsState.fontFamily
              }
            }
          }
        }

        // Ticks row (vertical rounded capsule lines of identical height)
        Row {
          id: ticksRow
          anchors.top: labelRow.bottom
          anchors.topMargin: 6
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: 0

          Repeater {
            model: rulerArea.window * 2 + 1
            delegate: Item {
              property int minute: TimerState.selectedMinutes + (index - rulerArea.window)
              property bool valid: minute >= 0 && minute <= 120
              property bool active: (index - rulerArea.window) <= 0
              width: rulerArea.tickGap
              height: 34

              Rectangle {
                anchors.centerIn: parent
                width: 2.8
                height: 32
                radius: 1.4
                visible: valid
                color: active ? root.timerOrange : root.tickDim
                opacity: active ? 1.0 : 0.65
              }
            }
          }
        }
      }

      // Left edge fade overlay
      Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: markerArea.top
        width: 48
        z: 2
        gradient: Gradient {
          orientation: Gradient.Horizontal
          GradientStop { position: 0.0; color: SettingsState.bgCard }
          GradientStop { position: 1.0; color: "transparent" }
        }
      }

      // Right edge fade overlay
      Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: markerArea.top
        width: 48
        z: 2
        gradient: Gradient {
          orientation: Gradient.Horizontal
          GradientStop { position: 0.0; color: "transparent" }
          GradientStop { position: 1.0; color: SettingsState.bgCard }
        }
      }

      // Center marker triangle area
      Item {
        id: markerArea
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 24
        height: 18

        Text {
          anchors.centerIn: parent
          text: "▲"
          color: root.timerOrange
          font.pixelSize: 13
          font.family: SettingsState.fontFamily
        }
      }

      // Running progress hint (thin bar under marker)
      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        width: 120 * TimerState.progress
        height: 2
        radius: 1
        visible: root.isRunning && !TimerState.finished
        color: root.timerOrange
      }

      // Mouse drag & scroll handling for the ruler
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
      height: 60

      // Left: Start / Cancel (+ pause when running)
      Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Rectangle {
          id: mainBtn
          width: (TimerState.running || TimerState.paused) ? 50 : 136
          height: 48
          radius: 24
          color: Qt.rgba(1.0, 0.62, 0.17, 0.16)

          Behavior on width {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
          }

          Text {
            anchors.centerIn: parent
            text: TimerState.finished ? "Dismiss" : (TimerState.running || TimerState.paused ? "×" : "Start Timer")
            color: root.timerOrange
            font.pixelSize: (TimerState.running || TimerState.paused) ? 22 : 16
            font.bold: true
            font.family: SettingsState.fontFamily
          }

          MouseArea {
            id: startBtnMouse
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
          width: 48
          height: 48
          radius: 24
          visible: TimerState.running || TimerState.paused
          color: pauseMouse.containsMouse ? Qt.rgba(1.0, 0.62, 0.17, 0.28) : Qt.rgba(1.0, 0.62, 0.17, 0.16)
          border.color: Qt.rgba(1.0, 0.62, 0.17, 0.35)
          border.width: 1
          Text {
            anchors.centerIn: parent
            text: TimerState.paused ? "▶" : "⏸"
            color: root.timerOrange
            font.pixelSize: 16
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
        font.pixelSize: 44
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
