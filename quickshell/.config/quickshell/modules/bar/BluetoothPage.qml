import Quickshell
import QtQuick
import "../services"

// Bluetooth expanded subview. Extracted from NetworkCircle.qml.
Column {
  id: btPage
  required property var circle
  required property bool hovered
  spacing: 12
  opacity: (hovered && circle.activePage === "bluetooth") ? 1 : 0
  visible: opacity > 0

  Behavior on opacity {
    NumberAnimation {
      duration: 220
    }
  }

  // Bluetooth Header
  Item {
    width: parent.width
    height: 32

    Row {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      spacing: 10

      // Back button
      Rectangle {
        width: 28
        height: 28
        radius: 14
        color: btBackMouse.containsMouse ? "#252b25" : "transparent"
        anchors.verticalCenter: parent.verticalCenter

        Text {
          anchors.centerIn: parent
          text: "\uf053"
            font.family: SettingsState.nerdIconFont
          color: "#f2f2f2"
          font.pixelSize: SettingsState.px(22)
          font.bold: true
        }

        MouseArea {
          id: btBackMouse
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
        visible: SettingsState.japaneseGlyphs
        text: "歯"
        color: "#f2f2f2"
        font.pixelSize: SettingsState.px(20)
        font.bold: true
      }

      // Title
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "BLUETOOTH"
        color: "#f2f2f2"
        font.pixelSize: SettingsState.px(17)
        font.bold: true
        font.family: SettingsState.fontFamily
      }
    }

    Row {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      spacing: 10

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: BluetoothState.discovering ? "Scanning..." : (BluetoothState.btOn ? "Ready" : "Off")
        color: BluetoothState.discovering ? SettingsState.accent : (BluetoothState.btOn ? SettingsState.textActive : SettingsState.textMuted)
        font.pixelSize: SettingsState.px(14)
        font.family: SettingsState.fontFamily
      }

      // Toggle switch
      Rectangle {
        width: 40
        height: 22
        radius: 11
        color: BluetoothState.btOn ? SettingsState.accent : SettingsState.bgCard
        anchors.verticalCenter: parent.verticalCenter

        Behavior on color {
          ColorAnimation { duration: 200 }
        }

        Rectangle {
          width: 16
          height: 16
          radius: 8
          color: BluetoothState.btOn ? (SettingsState.isDark ? "#ffffff" : "#000000") : SettingsState.textMuted
          anchors.verticalCenter: parent.verticalCenter
          x: BluetoothState.btOn ? parent.width - width - 3 : 3

          Behavior on x {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
          }
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: BluetoothState.toggle()
        }
      }
    }
  }

  // Divider
  Rectangle {
    width: parent.width
    height: 1
    color: SettingsState.borderBase
  }

  // Empty or Off state
  Text {
    visible: !BluetoothState.btOn || circle.btDevicesList.length === 0
    text: !BluetoothState.btOn ? "Bluetooth is turned off" : "No Bluetooth devices found"
    color: SettingsState.textMuted
    font.pixelSize: SettingsState.px(15)
    font.family: SettingsState.fontFamily
    anchors.horizontalCenter: parent.horizontalCenter
  }

  // Devices List
  ListView {
    id: btList
    width: parent.width
    height: !visible ? 0 : Math.min(320, circle.btDevicesList.length * 64 - 8)
    spacing: 8
    clip: true
    visible: BluetoothState.btOn && circle.btDevicesList.length > 0
    model: circle.btDevicesList

    Behavior on height {
      NumberAnimation {
        duration: 250
        easing.type: Easing.OutCubic
      }
    }

    delegate: Rectangle {
      id: btRow
      width: ListView.view.width
      height: 56
      radius: 14
      color: modelData.connected ? SettingsState.bgActivePill : (btRowMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: modelData.connected ? SettingsState.borderActive : (btRowMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
      border.width: 1

      readonly property bool isAudio: {
        var name = (modelData.name || modelData.deviceName || "").toLowerCase();
        var icon = (modelData.icon || "").toLowerCase();
        return name.includes("bud") || name.includes("head") || name.includes("ear") || name.includes("audio") || name.includes("speaker") || name.includes("tv") || icon.includes("audio");
      }

      // Left Icon Box
      Rectangle {
        id: iconBox
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: 36
        height: 36
        radius: 10
        color: modelData.connected ? SettingsState.accent : SettingsState.bgSurface

        CCIcon {
          anchors.centerIn: parent
          width: 20
          height: 20
          kind: btRow.isAudio ? "speaker" : "bt"
          glyph: modelData.connected ? (SettingsState.isDark ? "#121612" : "#ffffff") : SettingsState.textSecondary
        }
      }

      // Right Action Button
      Rectangle {
        id: actionBtn
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        height: 26
        width: btnText.implicitWidth + 18
        radius: 13
        color: btnMouse.containsMouse ? SettingsState.bgActivePill : SettingsState.bgSurface
        border.color: SettingsState.borderBase
        border.width: 1
        z: 5

        Text {
          id: btnText
          anchors.centerIn: parent
          text: modelData.connected ? "Disconnect" : (modelData.paired ? "Connect" : "Pair")
          color: modelData.connected ? "#ff8a8a" : SettingsState.textMain
          font.pixelSize: SettingsState.px(13)
          font.family: SettingsState.fontFamily
        }

        MouseArea {
          id: btnMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (modelData.connected) {
              modelData.connected = false;
            } else if (modelData.paired) {
              modelData.connected = true;
            } else {
              modelData.pair();
            }
          }
        }
      }

      // Center Details
      Column {
        anchors.left: iconBox.right
        anchors.leftMargin: 10
        anchors.right: actionBtn.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
          width: parent.width
          text: modelData.name || modelData.deviceName || modelData.address || "Unknown Device"
          color: "#f2f2f2"
          font.pixelSize: SettingsState.px(15)
          font.bold: true
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }

        Text {
          width: parent.width
          text: (modelData.paired ? "paired" : "unpaired") + " · " + (modelData.connected ? "connected" : "disconnected") + (modelData.address ? (" · " + modelData.address) : "")
          color: modelData.connected ? "#7ee2a8" : "#6e756e"
          font.pixelSize: SettingsState.px(13)
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }
      }

      MouseArea {
        id: btRowMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: {
          if (modelData.connected) {
            modelData.connected = false;
          } else {
            modelData.connected = true;
          }
        }
      }
    }
  }
}
