import QtQuick
import "../services"

// Wi-Fi expanded subview. Extracted from NetworkCircle.qml.
Column {
  id: wifiPage
  required property var circle
  required property bool hovered
  spacing: 12
  opacity: (hovered && circle.activePage === "wifi") ? 1 : 0
  visible: opacity > 0

  Behavior on opacity {
    enabled: circle.opacity > 0.5
    NumberAnimation {
      duration: 220
    }
  }

  // Wi-Fi Header - minimal
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
        color: wifiBackMouse.containsMouse ? SettingsState.bgCardHover : "transparent"
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
          id: wifiBackMouse
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
        width: wifiTitleGroup.implicitWidth + 4
        height: 24

        Row {
          id: wifiTitleGroup
          anchors.verticalCenter: parent.verticalCenter
          spacing: 6

          // Title
          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "WI-FI"
            color: SettingsState.accent
            font.pixelSize: SettingsState.px(14)
            font.family: SettingsState.fontFamily
            font.letterSpacing: 2
            font.weight: Font.DemiBold
          }
        }

        MouseArea {
          id: wifiTitleMouse
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
        text: NetworkState.wifiEnabled ? (circle.wifiUp ? "Connected" : "Available") : "Off"
        color: circle.wifiUp ? (SettingsState.isDark ? "#7ee2a8" : "#2e7d32") : SettingsState.textMuted
        font.pixelSize: SettingsState.px(12)
        font.family: SettingsState.fontFamily
      }

      // Toggle switch - minimal / smaller
      MiniToggle {
        width: 34
        height: 18
        anchors.verticalCenter: parent.verticalCenter
        on: NetworkState.wifiEnabled
        knobOn: SettingsState.isDark ? "#121612" : "#ffffff"
        knobOff: SettingsState.isDark ? SettingsState.textMuted : "#ffffff"
        frameWhenOff: true
        onToggled: NetworkState.toggleWifi()
      }
    }
  }

  // Divider
  Rectangle {
    width: parent.width
    height: 1
    color: SettingsState.borderBase
  }

  // ---- Ethernet / Wired section - minimal ----
  Rectangle {
    width: parent.width
    height: 52
    radius: 10
    color: "transparent"

    Item {
      id: ethIconBox
      anchors.left: parent.left
      anchors.leftMargin: 6
      anchors.verticalCenter: parent.verticalCenter
      width: 28
      height: 28

      CCIcon {
        anchors.centerIn: parent
        width: 18
        height: 18
        kind: "ethernet"
        glyph: SettingsState.textSecondary
      }
    }

    Column {
      anchors.left: ethIconBox.right
      anchors.leftMargin: 8
      anchors.right: ethStateText.left
      anchors.rightMargin: 8
      anchors.verticalCenter: parent.verticalCenter
      spacing: 1

      Text {
        width: parent.width
        text: "Ethernet" + (NetworkState.wiredIface !== "" ? " · " + NetworkState.wiredIface : "")
        color: SettingsState.textMain
        font.pixelSize: SettingsState.px(14)
        font.family: SettingsState.fontFamily
        elide: Text.ElideRight
      }

      Text {
        width: parent.width
        text: circle.wiredUp ? (NetworkState.wiredSummary() === NetworkState.wiredName ? NetworkState.wiredName : NetworkState.wiredName + " · " + NetworkState.wiredSummary()) : "Cable unplugged"
        color: circle.wiredUp ? (SettingsState.isDark ? "#7ee2a8" : "#2e7d32") : SettingsState.textMuted
        font.pixelSize: SettingsState.px(12)
        font.family: SettingsState.fontFamily
        elide: Text.ElideRight
        maximumLineCount: 1
      }
    }

    Text {
      id: ethStateText
      anchors.right: parent.right
      anchors.rightMargin: 10
      anchors.verticalCenter: parent.verticalCenter
      text: circle.wiredUp ? "Connected" : "Off"
      color: circle.wiredUp ? (SettingsState.isDark ? "#7ee2a8" : "#2e7d32") : SettingsState.textMuted
      font.pixelSize: SettingsState.px(12)
      font.family: SettingsState.fontFamily
    }
  }

  // Empty / Off state
  Text {
    visible: !NetworkState.wifiEnabled || circle.wifiNetworksList.length === 0
    text: !NetworkState.wifiEnabled ? "Wi-Fi is turned off" : "No Wi-Fi networks found"
    color: SettingsState.textMuted
    font.pixelSize: SettingsState.px(13)
    font.family: SettingsState.fontFamily
    anchors.horizontalCenter: parent.horizontalCenter
  }

  // Networks List - minimal rows
  ListView {
    id: wifiList
    width: parent.width
    height: !visible ? 0 : Math.min(300, circle.wifiNetworksList.length * 60 - 8)
    spacing: 4
    clip: true
    visible: NetworkState.wifiEnabled && circle.wifiNetworksList.length > 0
    model: circle.wifiNetworksList

    Behavior on height {
      NumberAnimation {
        duration: 250
        easing.type: Easing.OutCubic
      }
    }

    delegate: Rectangle {
      id: wifiRow
      width: ListView.view.width
      height: 52
      radius: 10
      color: wifiRowMouse.containsMouse ? SettingsState.bgCardHover : "transparent"

      readonly property string greenTint: SettingsState.isDark ? "#7ee2a8" : "#2e7d32"

      // Left icon - minimal, no filled box
      Item {
        id: wIconBox
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        width: 28
        height: 28

        CCIcon {
          anchors.centerIn: parent
          width: 18
          height: 18
          kind: "wifi"
          glyph: SettingsState.textSecondary
        }
      }

      // Right action - minimal text button (no pill)
      Item {
        id: wActionBtn
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        height: 24
        width: wBtnText.implicitWidth + 16
        implicitWidth: wBtnText.implicitWidth + 16
        implicitHeight: 24
        z: 5

        Text {
          id: wBtnText
          anchors.centerIn: parent
          text: modelData.connected ? "Disconnect" : "Connect"
          color: modelData.connected ? (SettingsState.isDark ? "#ff8a8a" : "#d32f2f") : (wBtnMouse.containsMouse ? SettingsState.textActive : SettingsState.textMuted)
          font.pixelSize: SettingsState.px(13)
          font.family: SettingsState.fontFamily
        }

        MouseArea {
          id: wBtnMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (modelData.connected) {
              NetworkState.disconnectWifi(modelData);
            } else {
              AuthState.prompt(modelData.name);
            }
          }
        }
      }

      // Center Details
      Column {
        anchors.left: wIconBox.right
        anchors.leftMargin: 8
        anchors.right: wActionBtn.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        Text {
          width: parent.width
          text: modelData.name || "Hidden Network"
          color: SettingsState.textMain
          font.pixelSize: SettingsState.px(14)
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }

        Text {
          width: parent.width
          text: (modelData.connected ? "connected" : "available") + " · " + Math.round((modelData.signalStrength || 0) * 100) + "% signal"
          color: modelData.connected ? wifiRow.greenTint : SettingsState.textMuted
          font.pixelSize: SettingsState.px(12)
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }
      }

      MouseArea {
        id: wifiRowMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: {
          if (!modelData.connected) {
            AuthState.prompt(modelData.name);
          }
        }
      }
    }
  }
}
