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

      // Device type detection for the left icon (mouse / headphones / etc.)
      readonly property string devName: (modelData.name || modelData.deviceName || "").toLowerCase()
      readonly property string devIcon: (modelData.icon || "").toLowerCase()
      readonly property string devKind: {
        var n = btRow.devName;
        var ic = btRow.devIcon;
        if (n.indexOf("mouse") !== -1 || ic.indexOf("mouse") !== -1 || n.indexOf("mx master") !== -1) return "mouse";
        if (n.indexOf("keyboard") !== -1 || ic.indexOf("keyboard") !== -1) return "keyboard";
        if (n.indexOf("head") !== -1 || n.indexOf("buds") !== -1 || n.indexOf("ear") !== -1 || n.indexOf("airpod") !== -1 || ic.indexOf("headset") !== -1 || ic.indexOf("headphone") !== -1) return "headphones";
        if (ic.indexOf("audio") !== -1 || n.indexOf("speaker") !== -1 || n.indexOf("soundcore") !== -1 || n.indexOf("jbl") !== -1 || n.indexOf("bose") !== -1) return "speaker";
        if (n.indexOf("controller") !== -1 || n.indexOf("gamepad") !== -1 || n.indexOf("8bitdo") !== -1 || n.indexOf("xbox") !== -1 || n.indexOf("ps4") !== -1 || n.indexOf("ps5") !== -1 || n.indexOf("dualsense") !== -1 || ic.indexOf("gamepad") !== -1) return "gamepad";
        if (n.indexOf("watch") !== -1 || ic.indexOf("watch") !== -1) return "watch";
        if (ic.indexOf("phone") !== -1 || n.indexOf("phone") !== -1 || n.indexOf("oppo") !== -1 || n.indexOf("pixel") !== -1 || n.indexOf("iphone") !== -1 || n.indexOf("galaxy") !== -1 || n.indexOf("oneplus") !== -1 || n.indexOf("redmi") !== -1) return "phone";
        return "bt";
      }

      readonly property bool isPaired: !!(modelData.paired || modelData.bonded)
      readonly property bool hasBattery: modelData.batteryAvailable === true
      readonly property int battPct: btRow.hasBattery ? Math.round(modelData.battery * 100) : -1
      readonly property bool showBattery: modelData.connected && btRow.hasBattery
      readonly property bool showPair: !btRow.isPaired
      readonly property string subLine: {
        var mac = modelData.address || "";
        if (modelData.connected) return mac ? ("connected \u00b7 " + mac) : "connected";
        if (btRow.isPaired) return mac ? ("paired \u00b7 disconnected \u00b7 " + mac) : "paired \u00b7 disconnected";
        return mac ? ("disconnected \u00b7 " + mac) : "disconnected";
      }

      // Left Icon Box (Nerd Font device glyph)
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
          kind: btRow.devKind
          glyph: modelData.connected ? (SettingsState.isDark ? "#121612" : "#ffffff") : SettingsState.textSecondary
        }
      }

      // Right slot: battery readout when connected, compact Pair pill when unpaired,
      // nothing when paired-but-disconnected (row click connects).
      Item {
        id: rightSlot
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: btRow.showBattery ? battRow.implicitWidth : (btRow.showPair ? pairBtn.implicitWidth : 0)
        height: 26
        visible: btRow.showBattery || btRow.showPair

        // Battery: mini level bar + percentage (e.g. mouse / headphones)
        Row {
          id: battRow
          anchors.verticalCenter: parent.verticalCenter
          anchors.right: parent.right
          spacing: 8
          visible: btRow.showBattery

          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 26
            height: 5
            radius: 2.5
            color: SettingsState.borderBase

            Rectangle {
              width: parent.width * Math.max(0, Math.min(1, modelData.battery || 0))
              height: parent.height
              radius: parent.radius
              color: SettingsState.accent
            }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: btRow.battPct + "%"
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(14)
            font.bold: true
            font.family: SettingsState.fontFamily
          }
        }

        // Pair pill (compact padding)
        Rectangle {
          id: pairBtn
          anchors.verticalCenter: parent.verticalCenter
          anchors.right: parent.right
          height: 24
          width: pairText.implicitWidth + 16
          implicitWidth: pairText.implicitWidth + 16
          implicitHeight: 24
          radius: 12
          visible: btRow.showPair
          color: pairMouse.containsMouse ? SettingsState.bgActivePill : SettingsState.bgSurface
          border.color: SettingsState.borderBase
          border.width: 1
          z: 5

          Text {
            id: pairText
            anchors.centerIn: parent
            text: "Pair"
            color: pairMouse.containsMouse ? SettingsState.textActive : SettingsState.textMain
            font.pixelSize: SettingsState.px(12)
            font.bold: true
            font.family: SettingsState.fontFamily
          }

          MouseArea {
            id: pairMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: function(ev) {
              modelData.pair();
              ev.accepted = true;
            }
          }
        }
      }

      // Center Details
      Column {
        anchors.left: iconBox.right
        anchors.leftMargin: 10
        anchors.right: rightSlot.left
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
          text: btRow.subLine
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
          } else if (btRow.isPaired) {
            modelData.connected = true;
          } else {
            modelData.pair();
          }
        }
      }
    }
  }
}
