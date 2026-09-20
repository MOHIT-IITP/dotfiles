import Quickshell
import Quickshell.Io
import QtQuick
import "../services"

// Embedded Power Menu subview directly inside ClockPill.
// Supports keyboard navigation (Left/Right/Enter/Space/Esc) and mouse interaction for system actions.
Item {
  id: root

  property int sel: -1 // 0: lock, 1: logout, 2: sleep, 3: reboot, 4: poweroff
  property int hoveredIndex: -1

  implicitWidth: 340
  implicitHeight: 116

  function forceFocus() {
    keyArea.focus = true;
    keyArea.forceActiveFocus();
  }

  Connections {
    target: PowerState
    function onOpenChanged() {
      if (PowerState.open) {
        root.sel = 4; // Default selection on power off
        forceFocus();
        powerFocusTimer.restart();
      } else {
        root.sel = -1;
        root.hoveredIndex = -1;
      }
    }
  }

  Timer {
    id: powerFocusTimer
    interval: 30
    repeat: true
    property int count: 0
    onRunningChanged: {
      if (running) count = 0;
    }
    onTriggered: {
      count++;
      forceFocus();
      if (keyArea.activeFocus || count > 8) {
        running = false;
      }
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
            color: SettingsState.accent
            font.pixelSize: 15
            font.bold: true
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "POWER"
            color: SettingsState.textMain
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
            color: root.activeActionName === "Power Off" ? "#ef5350" : (root.activeActionName === "Restart" ? "#ffd23f" : SettingsState.accent)
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.activeActionName
            color: root.activeActionName === "Power Off" ? "#ef5350" : (root.activeActionName === "Restart" ? "#ffd23f" : SettingsState.accent)
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
        color: SettingsState.borderBase
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
          color: (root.sel === 0 || lockMouse.containsMouse) ? SettingsState.bgActivePill : SettingsState.bgCard
          border.color: (root.sel === 0 || lockMouse.containsMouse) ? SettingsState.borderActive : SettingsState.borderBase
          border.width: 1

          Behavior on color {
            ColorAnimation { duration: 100 }
          }

          CCIcon {
            anchors.centerIn: parent
            width: 20
            height: 20
            kind: "lock"
            glyph: (root.sel === 0 || lockMouse.containsMouse) ? SettingsState.textActive : SettingsState.textSecondary
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
          color: (root.sel === 1 || logoutMouse.containsMouse) ? SettingsState.bgActivePill : SettingsState.bgCard
          border.color: (root.sel === 1 || logoutMouse.containsMouse) ? SettingsState.borderActive : SettingsState.borderBase
          border.width: 1

          Behavior on color {
            ColorAnimation { duration: 100 }
          }

          CCIcon {
            anchors.centerIn: parent
            width: 20
            height: 20
            kind: "logout"
            glyph: (root.sel === 1 || logoutMouse.containsMouse) ? SettingsState.textActive : SettingsState.textSecondary
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
          color: SettingsState.borderBase
        }

        // 3. Sleep / Suspend
        Rectangle {
          width: 48
          height: 48
          radius: 13
          color: (root.sel === 2 || sleepMouse.containsMouse) ? SettingsState.bgActivePill : SettingsState.bgCard
          border.color: (root.sel === 2 || sleepMouse.containsMouse) ? SettingsState.borderActive : SettingsState.borderBase
          border.width: 1

          Behavior on color {
            ColorAnimation { duration: 100 }
          }

          CCIcon {
            anchors.centerIn: parent
            width: 20
            height: 20
            kind: "moon"
            glyph: (root.sel === 2 || sleepMouse.containsMouse) ? SettingsState.textActive : SettingsState.textSecondary
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
          color: (root.sel === 3 || rebootMouse.containsMouse) ? (SettingsState.isDark ? "#2c2a1c" : "#fff8e1") : SettingsState.bgCard
          border.color: (root.sel === 3 || rebootMouse.containsMouse) ? "#ffd23f" : SettingsState.borderBase
          border.width: 1

          Behavior on color {
            ColorAnimation { duration: 100 }
          }

          CCIcon {
            anchors.centerIn: parent
            width: 20
            height: 20
            kind: "reboot"
            glyph: (root.sel === 3 || rebootMouse.containsMouse) ? "#ffd23f" : SettingsState.textSecondary
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
          color: (root.sel === 4 || powerOffMouse.containsMouse) ? (SettingsState.isDark ? "#3a1e1e" : "#ffebee") : SettingsState.bgCard
          border.color: (root.sel === 4 || powerOffMouse.containsMouse) ? "#ef5350" : SettingsState.borderBase
          border.width: 1

          Behavior on color {
            ColorAnimation { duration: 100 }
          }

          CCIcon {
            anchors.centerIn: parent
            width: 20
            height: 20
            kind: "power"
            glyph: (root.sel === 4 || powerOffMouse.containsMouse) ? "#ef5350" : SettingsState.textSecondary
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
