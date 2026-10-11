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

  // Bluetooth Header - minimal
  Item {
    width: parent.width
    height: 28

    Row {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      spacing: 6

      // Back button
      Rectangle {
        width: 24
        height: 24
        radius: 12
        color: btBackMouse.containsMouse ? SettingsState.bgCardHover : "transparent"
        anchors.verticalCenter: parent.verticalCenter

        Text {
          anchors.centerIn: parent
          text: "\ueab5"
            font.family: SettingsState.nerdIconFont
          color: SettingsState.textMain
          font.pixelSize: SettingsState.px(16)
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

      Item {
        anchors.verticalCenter: parent.verticalCenter
        width: btTitleGroup.implicitWidth + 4
        height: 24

        Row {
          id: btTitleGroup
          anchors.verticalCenter: parent.verticalCenter
          spacing: 6

          // Kanji glyph
          Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: SettingsState.japaneseGlyphs
            text: "歯"
            color: btTitleMouse.containsMouse ? SettingsState.accent : SettingsState.textMain
            font.pixelSize: SettingsState.px(15)
            font.bold: true
          }

          // Title
          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "BLUETOOTH"
            color: btTitleMouse.containsMouse ? SettingsState.accent : SettingsState.textMain
            font.pixelSize: SettingsState.px(13)
            font.bold: true
            font.family: SettingsState.fontFamily
            font.letterSpacing: 0.5
          }
        }

        MouseArea {
          id: btTitleMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            circle.activePage = "main";
          }
        }
      }
    }

    Row {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      spacing: 8

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: BluetoothState.discovering ? "Scanning..." : (BluetoothState.btOn ? "Ready" : "Off")
        color: BluetoothState.discovering ? SettingsState.accent : (BluetoothState.btOn ? SettingsState.textActive : SettingsState.textMuted)
        font.pixelSize: SettingsState.px(12)
        font.family: SettingsState.fontFamily
      }

      // Toggle switch - minimal / smaller
      Rectangle {
        width: 34
        height: 18
        radius: 9
        color: BluetoothState.btOn ? SettingsState.accent : SettingsState.bgCard
        border.color: SettingsState.borderBase
        border.width: BluetoothState.btOn ? 0 : 1
        anchors.verticalCenter: parent.verticalCenter

        Behavior on color {
          ColorAnimation { duration: 200 }
        }

        Rectangle {
          width: 12
          height: 12
          radius: 6
          color: BluetoothState.btOn ? "#ffffff" : SettingsState.textMuted
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
    font.pixelSize: SettingsState.px(13)
    font.family: SettingsState.fontFamily
    anchors.horizontalCenter: parent.horizontalCenter
  }

  // Devices List - minimal rows
  ListView {
    id: btList
    width: parent.width
    height: !visible ? 0 : Math.min(300, circle.btDevicesList.length * 60 - 8)
    spacing: 4
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
      height: 52
      radius: 10
      color: btRowMouse.containsMouse ? SettingsState.bgCardHover : "transparent"

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
      readonly property int battPct: btRow.hasBattery ? Math.round((Number(modelData.battery) <= 1.01 ? Number(modelData.battery) * 100 : Number(modelData.battery))) : -1
      readonly property bool showBattery: modelData.connected && btRow.hasBattery && btRow.battPct >= 0
      readonly property bool showPair: !btRow.isPaired
      readonly property string greenTint: SettingsState.isDark ? "#7ee2a8" : "#2e7d32"
      readonly property string subLine: {
        var batt = (btRow.hasBattery && btRow.battPct >= 0) ? (btRow.battPct + "%") : "";
        if (modelData.connected) {
          return batt !== "" ? ("connected · " + batt) : "connected";
        }
        if (btRow.isPaired) {
          return "paired · disconnected";
        }
        return "disconnected";
      }

      // Left icon - minimal, no filled box
      Item {
        id: iconBox
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        width: 28
        height: 28

        CCIcon {
          anchors.centerIn: parent
          width: 18
          height: 18
          kind: btRow.devKind
          glyph: SettingsState.textSecondary
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

        // Battery: mini level bar + percentage in green tint
        Row {
          id: battRow
          anchors.verticalCenter: parent.verticalCenter
          anchors.right: parent.right
          spacing: 6
          visible: btRow.showBattery

          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 22
            height: 4
            radius: 2
            color: SettingsState.borderBase

            Rectangle {
              width: parent.width * Math.max(0, Math.min(1, (Number(modelData.battery) <= 1.01 ? Number(modelData.battery) : Number(modelData.battery) / 100) || 0))
              height: parent.height
              radius: parent.radius
              color: btRow.greenTint
            }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: btRow.battPct + "%"
            color: btRow.greenTint
            font.pixelSize: SettingsState.px(12)
            font.family: SettingsState.fontFamily
          }
        }

        // Pair - minimal text button (no pill)
        Item {
          id: pairBtn
          anchors.verticalCenter: parent.verticalCenter
          anchors.right: parent.right
          height: 24
          width: pairText.implicitWidth + 4
          implicitWidth: pairText.implicitWidth + 4
          implicitHeight: 24
          visible: btRow.showPair

          Text {
            id: pairText
            anchors.centerIn: parent
            text: "Pair"
            color: pairMouse.containsMouse ? SettingsState.textActive : SettingsState.textMuted
            font.pixelSize: SettingsState.px(13)
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
        anchors.leftMargin: 8
        anchors.right: rightSlot.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        Text {
          width: parent.width
          text: modelData.name || modelData.deviceName || modelData.address || "Unknown Device"
          color: SettingsState.textMain
          font.pixelSize: SettingsState.px(14)
          font.bold: false
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }

        Text {
          width: parent.width
          text: btRow.subLine
          color: modelData.connected ? btRow.greenTint : SettingsState.textMuted
          font.pixelSize: SettingsState.px(12)
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

  // ---- Mouse & accessories battery (UPower: Logitech hidpp, headsets, etc.) ----
  // Covers wireless mice/dongles that never appear as Bluetooth battery
  // devices, e.g. MX Master 2S at 55% via upower.
  Column {
    width: parent.width
    spacing: 4
    visible: DeviceBatteryState.hasAccessories

    Text {
      text: "MOUSE & ACCESSORIES"
      color: SettingsState.textMuted
      font.pixelSize: SettingsState.px(11)
      font.family: SettingsState.fontFamily
      font.letterSpacing: 0.5
    }

    Repeater {
      model: DeviceBatteryState.accessories
      delegate: Rectangle {
        id: accRow
        width: parent.width
        height: 52
        radius: 10
        color: "transparent"

        readonly property int accPct: DeviceBatteryState.pct100(modelData)
        readonly property string accKind: DeviceBatteryState.iconKindFor(modelData)
        readonly property string accLabel: DeviceBatteryState.labelFor(modelData)
        readonly property string accState: DeviceBatteryState.stateText(modelData)
        readonly property string greenTint: SettingsState.isDark ? "#7ee2a8" : "#2e7d32"

        Item {
          id: accIconBox
          anchors.left: parent.left
          anchors.leftMargin: 6
          anchors.verticalCenter: parent.verticalCenter
          width: 28
          height: 28

          CCIcon {
            anchors.centerIn: parent
            width: 18
            height: 18
            kind: accRow.accKind
            glyph: SettingsState.textSecondary
          }
        }

        Item {
          id: accRight
          anchors.right: parent.right
          anchors.rightMargin: 10
          anchors.verticalCenter: parent.verticalCenter
          width: accBattRow.implicitWidth
          height: 26

          Row {
            id: accBattRow
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            spacing: 6

            Rectangle {
              anchors.verticalCenter: parent.verticalCenter
              width: 22
              height: 4
              radius: 2
              color: SettingsState.borderBase

              Rectangle {
                width: parent.width * Math.max(0, Math.min(1, accRow.accPct / 100))
                height: parent.height
                radius: parent.radius
                color: accRow.greenTint
              }
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: accRow.accPct >= 0 ? accRow.accPct + "%" : "--"
              color: accRow.greenTint
              font.pixelSize: SettingsState.px(12)
              font.family: SettingsState.fontFamily
            }
          }
        }

        Column {
          anchors.left: accIconBox.right
          anchors.leftMargin: 8
          anchors.right: accRight.left
          anchors.rightMargin: 8
          anchors.verticalCenter: parent.verticalCenter
          spacing: 1

          Text {
            width: parent.width
            text: accRow.accLabel
            color: SettingsState.textMain
            font.pixelSize: SettingsState.px(14)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            text: accRow.accState !== "" ? accRow.accState : "upower"
            color: SettingsState.textMuted
            font.pixelSize: SettingsState.px(12)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }
        }
      }
    }
  }
}
