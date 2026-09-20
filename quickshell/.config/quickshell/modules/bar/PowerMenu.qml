import Quickshell
import Quickshell.Io
import QtQuick
import "../services"

// Power menu modal dropping down below the clock pill.
// Supports mouse click and keyboard navigation (Left/Right/Enter/Esc).
Rectangle {
  id: root

  readonly property bool open: PowerState.open
  property int sel: -1 // 0: lock, 1: logout, 2: sleep, 3: reboot, 4: poweroff

  implicitWidth: 330
  implicitHeight: open ? 116 : 0
  radius: 22
  clip: true

  color: "#101210"
  border.color: "#2e362e"
  border.width: 1

  opacity: open ? 1 : 0
  visible: open || opacity > 0

  Behavior on implicitHeight {
    NumberAnimation {
      duration: 250
      easing.type: Easing.OutCubic
    }
  }

  Behavior on opacity {
    NumberAnimation {
      duration: 180
    }
  }

  onOpenChanged: {
    if (open) {
      sel = 4; // Default selection on shutdown or none
      keyArea.focus = true;
      powerFocusTimer.restart();
    } else {
      sel = -1;
    }
  }

  Timer {
    id: powerFocusTimer
    interval: 30
    repeat: false
    onTriggered: {
      keyArea.forceActiveFocus();
    }
  }

  Process {
    id: proc
  }

  function execAction(idx) {
    PowerState.close();
    if (idx === 0) {
      proc.command = ["hyprlock"];
      proc.running = true;
    } else if (idx === 1) {
      proc.command = ["hyprctl", "dispatch", "exit"];
      proc.running = true;
    } else if (idx === 2) {
      proc.command = ["systemctl", "suspend"];
      proc.running = true;
    } else if (idx === 3) {
      proc.command = ["systemctl", "reboot"];
      proc.running = true;
    } else if (idx === 4) {
      proc.command = ["systemctl", "poweroff"];
      proc.running = true;
    }
  }

  readonly property string activeActionName: {
    var s = (hoveredIndex >= 0) ? hoveredIndex : sel;
    if (s === 0) return "Lock";
    if (s === 1) return "Logout";
    if (s === 2) return "Sleep";
    if (s === 3) return "Restart";
    if (s === 4) return "Power Off";
    return "";
  }

  property int hoveredIndex: -1

  Item {
    id: keyArea
    anchors.fill: parent
    focus: true

    Keys.onLeftPressed: function(ev) {
      if (sel < 0) sel = 0;
      else sel = (sel - 1 + 5) % 5;
      ev.accepted = true;
    }

    Keys.onRightPressed: function(ev) {
      if (sel < 0) sel = 0;
      else sel = (sel + 1) % 5;
      ev.accepted = true;
    }

    Keys.onReturnPressed: function(ev) {
      if (sel >= 0 && sel < 5) {
        execAction(sel);
      }
      ev.accepted = true;
    }

    Keys.onEnterPressed: function(ev) {
      if (sel >= 0 && sel < 5) {
        execAction(sel);
      }
      ev.accepted = true;
    }

    Keys.onSpacePressed: function(ev) {
      if (sel >= 0 && sel < 5) {
        execAction(sel);
      }
      ev.accepted = true;
    }

    Keys.onEscapePressed: function(ev) {
      PowerState.close();
      ev.accepted = true;
    }

    Column {
      anchors.fill: parent
      anchors.margins: 14
      spacing: 10

      // Header row: "電 POWER" on left, dynamic action title on right
      Item {
        width: parent.width
        height: 22

        Row {
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          spacing: 8

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "電"
            color: "#f2f2f2"
            font.pixelSize: 15
            font.bold: true
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "POWER"
            color: "#f2f2f2"
            font.pixelSize: 13
            font.bold: true
            font.family: SettingsState.fontFamily
            font.letterSpacing: 1.5
          }
        }

        // Action label on right
        Row {
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: 6
          opacity: root.activeActionName !== "" ? 1 : 0

          Behavior on opacity {
            NumberAnimation { duration: 150 }
          }

          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 6
            height: 6
            radius: 3
            color: root.activeActionName === "Power Off" ? "#ef5350" : (root.activeActionName === "Restart" ? "#ffd23f" : "#7ee2a8")
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.activeActionName
            color: root.activeActionName === "Power Off" ? "#ef5350" : (root.activeActionName === "Restart" ? "#ffd23f" : "#7ee2a8")
            font.pixelSize: 12
            font.bold: true
            font.family: SettingsState.fontFamily
          }
        }
      }

      // Divider line
      Rectangle {
        width: parent.width
        height: 1
        color: "#252b25"
      }

      // 5 Action buttons row
      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8

        // 1. Lock
        Rectangle {
          width: 48
          height: 48
          radius: 13
          color: (root.sel === 0 || lockMouse.containsMouse) ? "#252d25" : "#181c18"
          border.color: (root.sel === 0 || lockMouse.containsMouse) ? "#7ee2a8" : "#283028"
          border.width: (root.sel === 0 || lockMouse.containsMouse) ? 1.5 : 1

          CCIcon {
            anchors.centerIn: parent
            width: 20
            height: 20
            kind: "lock"
            glyph: (root.sel === 0 || lockMouse.containsMouse) ? "#f2f2f2" : "#a8b3a8"
          }

          MouseArea {
            id: lockMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.hoveredIndex = 0
            onExited: {
              if (root.hoveredIndex === 0) root.hoveredIndex = -1;
            }
            onClicked: root.execAction(0)
          }
        }

        // 2. Logout
        Rectangle {
          width: 48
          height: 48
          radius: 13
          color: (root.sel === 1 || logoutMouse.containsMouse) ? "#252d25" : "#181c18"
          border.color: (root.sel === 1 || logoutMouse.containsMouse) ? "#7ee2a8" : "#283028"
          border.width: (root.sel === 1 || logoutMouse.containsMouse) ? 1.5 : 1

          CCIcon {
            anchors.centerIn: parent
            width: 20
            height: 20
            kind: "logout"
            glyph: (root.sel === 1 || logoutMouse.containsMouse) ? "#f2f2f2" : "#a8b3a8"
          }

          MouseArea {
            id: logoutMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.hoveredIndex = 1
            onExited: {
              if (root.hoveredIndex === 1) root.hoveredIndex = -1;
            }
            onClicked: root.execAction(1)
          }
        }

        // Subtle vertical separator
        Rectangle {
          width: 1
          height: 32
          anchors.verticalCenter: parent.verticalCenter
          color: "#252b25"
        }

        // 3. Sleep / Suspend
        Rectangle {
          width: 48
          height: 48
          radius: 13
          color: (root.sel === 2 || sleepMouse.containsMouse) ? "#252d25" : "#181c18"
          border.color: (root.sel === 2 || sleepMouse.containsMouse) ? "#7ee2a8" : "#283028"
          border.width: (root.sel === 2 || sleepMouse.containsMouse) ? 1.5 : 1

          CCIcon {
            anchors.centerIn: parent
            width: 20
            height: 20
            kind: "moon"
            glyph: (root.sel === 2 || sleepMouse.containsMouse) ? "#f2f2f2" : "#a8b3a8"
          }

          MouseArea {
            id: sleepMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.hoveredIndex = 2
            onExited: {
              if (root.hoveredIndex === 2) root.hoveredIndex = -1;
            }
            onClicked: root.execAction(2)
          }
        }

        // 4. Reboot
        Rectangle {
          width: 48
          height: 48
          radius: 13
          color: (root.sel === 3 || rebootMouse.containsMouse) ? "#2c2a1c" : "#181c18"
          border.color: (root.sel === 3 || rebootMouse.containsMouse) ? "#ffd23f" : "#283028"
          border.width: (root.sel === 3 || rebootMouse.containsMouse) ? 1.5 : 1

          CCIcon {
            anchors.centerIn: parent
            width: 20
            height: 20
            kind: "reboot"
            glyph: (root.sel === 3 || rebootMouse.containsMouse) ? "#ffd23f" : "#a8b3a8"
          }

          MouseArea {
            id: rebootMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.hoveredIndex = 3
            onExited: {
              if (root.hoveredIndex === 3) root.hoveredIndex = -1;
            }
            onClicked: root.execAction(3)
          }
        }

        // 5. Power off
        Rectangle {
          width: 48
          height: 48
          radius: 13
          color: (root.sel === 4 || powerOffMouse.containsMouse) ? "#3a1e1e" : "#181c18"
          border.color: (root.sel === 4 || powerOffMouse.containsMouse) ? "#ef5350" : "#283028"
          border.width: (root.sel === 4 || powerOffMouse.containsMouse) ? 1.5 : 1

          CCIcon {
            anchors.centerIn: parent
            width: 20
            height: 20
            kind: "power"
            glyph: (root.sel === 4 || powerOffMouse.containsMouse) ? "#ef5350" : "#a8b3a8"
          }

          MouseArea {
            id: powerOffMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.hoveredIndex = 4
            onExited: {
              if (root.hoveredIndex === 4) root.hoveredIndex = -1;
            }
            onClicked: root.execAction(4)
          }
        }
      }
    }
  }
}
