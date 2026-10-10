import QtQuick
import "../services"

// Center-bar countdown timer picker (iOS Dynamic-Island style).
// Top: draggable ruler (numbers every 5 min, uniform-height rounded tick lines every 1 min, edge fades).
// Bottom: Start/Cancel pill (left) + MM:SS readout (right).
Item {
  id: root

  implicitWidth: 360
  implicitHeight: 158
  clip: true

  property bool timerHover: false
  readonly property bool isRunning: TimerState.running || TimerState.paused || TimerState.finished
  readonly property color timerOrange: "#FF9E2C"
  readonly property color tickDim: "#3D2413"
  readonly property color textDim: "#6E4522"

  HoverHandler {
    id: hoverH
    onHoveredChanged: root.timerHover = hovered
  }

  Item {
    id: timerContent
    anchors.fill: parent
    clip: true
    opacity: Math.max(0, Math.min(1, (root.height - 65) / 75.0))

    Column {
      anchors.fill: parent
      anchors.topMargin: 12
      anchors.bottomMargin: 14
      anchors.leftMargin: 18
      anchors.rightMargin: 18
      spacing: 4

      // ================= RULER / SLIDER BAR =================
      Item {
        id: rulerArea
        width: parent.width
        height: 72
        clip: true

      property real tickGap: 9.5
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
              height: 18

              Text {
                anchors.centerIn: parent
                visible: labeled
                text: valid ? minute : ""
                color: active ? root.timerOrange : root.textDim
                opacity: active ? 1.0 : 0.6
                font.pixelSize: 14
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
          anchors.topMargin: 4
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: 0

          Repeater {
            model: rulerArea.window * 2 + 1
            delegate: Item {
              property int minute: TimerState.selectedMinutes + (index - rulerArea.window)
              property bool valid: minute >= 0 && minute <= 120
              property bool active: (index - rulerArea.window) <= 0
              width: rulerArea.tickGap
              height: 28

              Rectangle {
                anchors.centerIn: parent
                width: 2.6
                height: 26
                radius: 1.3
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
        width: 44
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
        width: 44
        z: 2
        gradient: Gradient {
          orientation: Gradient.Horizontal
          GradientStop { position: 0.0; color: "transparent" }
          GradientStop { position: 1.0; color: SettingsState.bgCard }
        }
      }

      // Center marker triangle area (matching screenshot)
      Item {
        id: markerArea
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 16
        height: 14

        Text {
          anchors.centerIn: parent
          text: "\ueab7"
          color: root.timerOrange
          font.pixelSize: 11
          font.family: SettingsState.nerdIconFont
        }
      }

      // Running progress hint (thin bar under marker)
      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
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
      height: 48

      // Left: Start / Cancel (+ pause when running)
      Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Rectangle {
          id: mainBtn
          width: (TimerState.running || TimerState.paused) ? 40 : 124
          height: 40
          radius: 20
          color: startBtnMouse.containsMouse ? Qt.rgba(1.0, 0.62, 0.17, 0.28) : Qt.rgba(1.0, 0.62, 0.17, 0.16)
          border.color: Qt.rgba(1.0, 0.62, 0.17, 0.35)
          border.width: 1

          Behavior on width {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
          }

          Text {
            anchors.centerIn: parent
            visible: !TimerState.running && !TimerState.paused
            text: TimerState.finished ? "Dismiss" : "Start Timer"
            color: root.timerOrange
            font.pixelSize: 15
            font.bold: true
            font.family: SettingsState.fontFamily
          }

          CCIcon {
            anchors.centerIn: parent
            width: 16
            height: 16
            visible: TimerState.running || TimerState.paused
            kind: "close"
            glyph: root.timerOrange
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
          width: 40
          height: 40
          radius: 20
          visible: TimerState.running || TimerState.paused
          color: pauseMouse.containsMouse ? Qt.rgba(1.0, 0.62, 0.17, 0.28) : Qt.rgba(1.0, 0.62, 0.17, 0.16)
          border.color: Qt.rgba(1.0, 0.62, 0.17, 0.35)
          border.width: 1
          Text {
            anchors.centerIn: parent
            text: TimerState.paused ? "▶" : "⏸"
            color: root.timerOrange
            font.pixelSize: 15
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
}
