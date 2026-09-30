import Quickshell
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
    NumberAnimation {
      duration: 220
    }
  }

  // Wi-Fi Header
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
        color: wifiBackMouse.containsMouse ? "#252b25" : "transparent"
        anchors.verticalCenter: parent.verticalCenter

        Text {
          anchors.centerIn: parent
          text: "\uf053"
            font.family: SettingsState.nerdIconFont
          color: "#f2f2f2"
          font.pixelSize: 22
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

      // Kanji glyph
      Text {
        anchors.verticalCenter: parent.verticalCenter
        visible: SettingsState.japaneseGlyphs
        text: "波"
        color: "#f2f2f2"
        font.pixelSize: 20
        font.bold: true
      }

      // Title
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "WI-FI"
        color: "#f2f2f2"
        font.pixelSize: 17
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
        text: NetworkState.wifiEnabled ? (circle.wifiUp ? "Connected" : "Available") : "Off"
        color: circle.wifiUp ? "#7ee2a8" : "#6e756e"
        font.pixelSize: 14
        font.family: SettingsState.fontFamily
      }

      // Toggle switch
      Rectangle {
        width: 40
        height: 22
        radius: 11
        color: NetworkState.wifiEnabled ? "#e05f65" : "#252b25"
        anchors.verticalCenter: parent.verticalCenter

        Behavior on color {
          ColorAnimation { duration: 200 }
        }

        Rectangle {
          width: 16
          height: 16
          radius: 8
          color: "#ffffff"
          anchors.verticalCenter: parent.verticalCenter
          x: NetworkState.wifiEnabled ? parent.width - width - 3 : 3

          Behavior on x {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
          }
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: NetworkState.toggleWifi()
        }
      }
    }
  }

  // Divider
  Rectangle {
    width: parent.width
    height: 1
    color: "#252b25"
  }

  // Empty / Off state
  Text {
    visible: !NetworkState.wifiEnabled || circle.wifiNetworksList.length === 0
    text: !NetworkState.wifiEnabled ? "Wi-Fi is turned off" : "No Wi-Fi networks found"
    color: "#6e756e"
    font.pixelSize: 15
    font.family: SettingsState.fontFamily
    anchors.horizontalCenter: parent.horizontalCenter
  }

  // Networks List
  ListView {
    id: wifiList
    width: parent.width
    height: !visible ? 0 : Math.min(320, circle.wifiNetworksList.length * 64 - 8)
    spacing: 8
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
      height: 56
      radius: 14
      color: modelData.connected ? SettingsState.bgActivePill : (wifiRowMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: modelData.connected ? SettingsState.borderActive : (wifiRowMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
      border.width: 1

      // Left Icon Box
      Rectangle {
        id: wIconBox
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
          kind: "wifi"
          glyph: modelData.connected ? (SettingsState.isDark ? "#121612" : "#ffffff") : SettingsState.textSecondary
        }
      }

      // Right Action Button
      Rectangle {
        id: wActionBtn
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        height: 26
        width: wBtnText.implicitWidth + 18
        radius: 13
        color: wBtnMouse.containsMouse ? SettingsState.bgActivePill : SettingsState.bgSurface
        border.color: SettingsState.borderBase
        border.width: 1
        z: 5

        Text {
          id: wBtnText
          anchors.centerIn: parent
          text: modelData.connected ? "Disconnect" : "Connect"
          color: modelData.connected ? "#ff8a8a" : SettingsState.textMain
          font.pixelSize: 13
          font.family: SettingsState.fontFamily
        }

        MouseArea {
          id: wBtnMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (modelData.connected) {
              // disconnect
            } else {
              AuthState.prompt(modelData.name);
            }
          }
        }
      }

      // Center Details
      Column {
        anchors.left: wIconBox.right
        anchors.leftMargin: 10
        anchors.right: wActionBtn.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
          width: parent.width
          text: modelData.name || "Hidden Network"
          color: SettingsState.textMain
          font.pixelSize: 15
          font.bold: true
          font.family: SettingsState.fontFamily
          elide: Text.ElideRight
        }

        Text {
          width: parent.width
          text: (modelData.connected ? "connected" : "available") + " · " + Math.round((modelData.signalStrength || 0) * 100) + "% signal"
          color: modelData.connected ? SettingsState.textActive : SettingsState.textMuted
          font.pixelSize: 13
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
