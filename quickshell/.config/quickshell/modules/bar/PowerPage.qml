import Quickshell
import QtQuick
import "../services"

// Power menu expanded subview. Extracted from NetworkCircle.qml.
Column {
  id: powerPage
  required property var circle
  required property bool hovered
  spacing: 12
  opacity: (hovered && circle.activePage === "power") ? 1 : 0
  visible: opacity > 0

  readonly property string hoveredAction: {
    if (lockBtnMouse.containsMouse) return "Lock";
    if (logoutBtnMouse.containsMouse) return "Logout";
    if (sleepBtnMouse.containsMouse) return "Sleep";
    if (rebootBtnMouse.containsMouse) return "Restart";
    if (powerOffBtnMouse.containsMouse) return "Power Off";
    return "";
  }

  Behavior on opacity {
    NumberAnimation {
      duration: 220
    }
  }

  // Power Header
  Item {
    width: parent.width
    height: 26

    Row {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      spacing: 8

      // Back button
      Rectangle {
        width: 24
        height: 24
        radius: 12
        color: powerBackMouse.containsMouse ? "#252b25" : "transparent"
        anchors.verticalCenter: parent.verticalCenter

        Text {
          anchors.centerIn: parent
          text: "\ueab5"
            font.family: SettingsState.nerdIconFont
          color: "#f2f2f2"
          font.pixelSize: SettingsState.px(20)
          font.bold: true
        }

        MouseArea {
          id: powerBackMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            circle.activePage = "main";
          }
        }
      }

      // Kanji glyph
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "電"
        color: "#f2f2f2"
        font.pixelSize: SettingsState.px(18)
        font.bold: true
      }

      // Title
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "POWER"
        color: "#f2f2f2"
        font.pixelSize: SettingsState.px(16)
        font.bold: true
        font.family: SettingsState.fontFamily
        font.letterSpacing: 1.5
      }
    }

    // Hovered action label on right
    Text {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      text: powerPage.hoveredAction
      color: powerPage.hoveredAction === "Power Off" ? "#ef5350" : (powerPage.hoveredAction === "Restart" ? "#ffd23f" : "#7ee2a8")
      font.pixelSize: SettingsState.px(14)
      font.bold: true
      font.family: SettingsState.fontFamily
      opacity: powerPage.hoveredAction !== "" ? 1 : 0

      Behavior on opacity {
        NumberAnimation { duration: 150 }
      }
    }
  }

  // Divider
  Rectangle {
    width: parent.width
    height: 1
    color: "#252b25"
  }

  // 5 Power Action Buttons Row (Lock, Logout, Suspend, Reboot, Shutdown)
  Row {
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 10

    // 1. Lock
    Rectangle {
      width: 48
      height: 48
      radius: 13
      color: lockBtnMouse.containsMouse ? "#252d25" : "#181c18"
      border.color: lockBtnMouse.containsMouse ? "#3a4a35" : "#283028"
      border.width: 1

      CCIcon {
        anchors.centerIn: parent
        width: 20
        height: 20
        kind: "lock"
        glyph: lockBtnMouse.containsMouse ? "#f2f2f2" : "#a8b3a8"
      }

      MouseArea {
        id: lockBtnMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          circle.execCmd(["hyprlock"]);
        }
      }
    }

    // 2. Logout
    Rectangle {
      width: 48
      height: 48
      radius: 13
      color: logoutBtnMouse.containsMouse ? "#252d25" : "#181c18"
      border.color: logoutBtnMouse.containsMouse ? "#3a4a35" : "#283028"
      border.width: 1

      CCIcon {
        anchors.centerIn: parent
        width: 20
        height: 20
        kind: "logout"
        glyph: logoutBtnMouse.containsMouse ? "#f2f2f2" : "#a8b3a8"
      }

      MouseArea {
        id: logoutBtnMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          circle.execCmd(["hyprctl", "dispatch", "exit"]);
        }
      }
    }

    // 3. Suspend / Sleep
    Rectangle {
      width: 48
      height: 48
      radius: 13
      color: sleepBtnMouse.containsMouse ? "#252d25" : "#181c18"
      border.color: sleepBtnMouse.containsMouse ? "#3a4a35" : "#283028"
      border.width: 1

      CCIcon {
        anchors.centerIn: parent
        width: 20
        height: 20
        kind: "moon"
        glyph: sleepBtnMouse.containsMouse ? "#f2f2f2" : "#a8b3a8"
      }

      MouseArea {
        id: sleepBtnMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          circle.execCmd(["systemctl", "suspend"]);
        }
      }
    }

    // 4. Reboot
    Rectangle {
      width: 48
      height: 48
      radius: 13
      color: rebootBtnMouse.containsMouse ? "#252d25" : "#181c18"
      border.color: rebootBtnMouse.containsMouse ? "#3a4a35" : "#283028"
      border.width: 1

      CCIcon {
        anchors.centerIn: parent
        width: 20
        height: 20
        kind: "reboot"
        glyph: rebootBtnMouse.containsMouse ? "#f2f2f2" : "#a8b3a8"
      }

      MouseArea {
        id: rebootBtnMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          circle.execCmd(["systemctl", "reboot"]);
        }
      }
    }

    // 5. Shutdown
    Rectangle {
      width: 48
      height: 48
      radius: 13
      color: powerOffBtnMouse.containsMouse ? "#3a1e1e" : "#181c18"
      border.color: powerOffBtnMouse.containsMouse ? "#6a2e2e" : "#283028"
      border.width: 1

      CCIcon {
        anchors.centerIn: parent
        width: 20
        height: 20
        kind: "power"
        glyph: powerOffBtnMouse.containsMouse ? "#ef5350" : "#a8b3a8"
      }

      MouseArea {
        id: powerOffBtnMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          circle.execCmd(["systemctl", "poweroff"]);
        }
      }
    }
  }
}
