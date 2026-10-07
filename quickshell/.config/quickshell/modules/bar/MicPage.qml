import Quickshell
import QtQuick
import "../services"

// Microphone input subview. Extracted from NetworkCircle.qml.
Column {
  id: micPage
  required property var circle
  required property bool hovered
  spacing: 12
  opacity: (hovered && circle.activePage === "mic") ? 1 : 0
  visible: opacity > 0

  Behavior on opacity {
    NumberAnimation { duration: 220 }
  }

  // Mic Header
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
        color: micBackMouse.containsMouse ? SettingsState.bgCardHover : "transparent"
        anchors.verticalCenter: parent.verticalCenter

        Text {
          anchors.centerIn: parent
          text: "\ueab5"
            font.family: SettingsState.nerdIconFont
          color: SettingsState.textMain
          font.pixelSize: SettingsState.px(22)
          font.bold: true
        }

        MouseArea {
          id: micBackMouse
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
        width: micTitleGroup.implicitWidth + 4
        height: 28

        Row {
          id: micTitleGroup
          anchors.verticalCenter: parent.verticalCenter
          spacing: 6

          // Icon
          CCIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 18
            height: 18
            kind: "mic"
            glyph: SettingsState.accent
          }

          // Title
          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "MICROPHONE INPUT"
            color: micTitleMouse.containsMouse ? SettingsState.accent : SettingsState.textMain
            font.pixelSize: SettingsState.px(16)
            font.bold: true
            font.family: SettingsState.fontFamily
            font.letterSpacing: 1.2
          }
        }

        MouseArea {
          id: micTitleMouse
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
      spacing: 10

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: circle.inMuted ? "Muted" : (Math.round(circle.inVol * 100) + "%")
        color: circle.inMuted ? "#ff8a8a" : SettingsState.textActive
        font.pixelSize: SettingsState.px(14)
        font.bold: true
        font.family: SettingsState.fontFamily
      }

      // Mute toggle switch
      Rectangle {
        width: 40
        height: 22
        radius: 11
        color: !circle.inMuted ? SettingsState.accent : SettingsState.bgCard
        anchors.verticalCenter: parent.verticalCenter

        Behavior on color {
          ColorAnimation { duration: 200 }
        }

        Rectangle {
          width: 16
          height: 16
          radius: 8
          color: !circle.inMuted ? (SettingsState.isDark ? "#ffffff" : "#000000") : SettingsState.textMuted
          anchors.verticalCenter: parent.verticalCenter
          x: !circle.inMuted ? parent.width - width - 3 : 3

          Behavior on x {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
          }
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: AudioState.toggleInMute()
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

  // Input Volume Slider
  CCSlider {
    width: parent.width
    label: "Input Level"
    icon: "mic"
    value: circle.inVol
    muted: circle.inMuted
    available: AudioState.source !== null && AudioState.source !== undefined
    onSeeked: function (v) {
      AudioState.setInVol(v);
    }
    onIconClicked: AudioState.toggleInMute()
  }

  // Section title
  Item {
    width: parent.width
    height: 20

    Text {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: "Select Input Device"
      color: SettingsState.textSecondary
      font.pixelSize: SettingsState.px(14)
      font.bold: true
      font.family: SettingsState.fontFamily
    }

    Text {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      text: (AudioState.sources.length || 0) + " available"
      color: SettingsState.textMuted
      font.pixelSize: SettingsState.px(13)
      font.family: SettingsState.fontFamily
    }
  }

  // Input Device List
  ListView {
    width: parent.width
    height: 260
    spacing: 8
    clip: true
    model: AudioState.sources

    delegate: Rectangle {
      required property var modelData
      width: ListView.view.width
      height: 52
      radius: 16
      color: modelData.isDefault ? SettingsState.bgActivePill : (mDevMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: modelData.isDefault ? SettingsState.borderActive : (mDevMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
      border.width: 1

      Behavior on color {
        ColorAnimation { duration: 120 }
      }

      Row {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 12

        // Icon Avatar
        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 32
          height: 32
          radius: 16
          color: modelData.isDefault ? SettingsState.accent : SettingsState.bgSurface

          CCIcon {
            anchors.centerIn: parent
            width: 16
            height: 16
            kind: "mic"
            glyph: modelData.isDefault ? (SettingsState.isDark ? "#121612" : "#ffffff") : SettingsState.textSecondary
          }
        }

        // Device Info
        Column {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 86
          spacing: 2

          Text {
            width: parent.width
            text: modelData.description || modelData.name || "Input Device"
            color: modelData.isDefault ? SettingsState.textActive : SettingsState.textMain
            font.pixelSize: SettingsState.px(15)
            font.bold: modelData.isDefault
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            text: modelData.isDefault ? "Active Input Route" : (modelData.name || "Audio Source")
            color: modelData.isDefault ? SettingsState.textActive : SettingsState.textSecondary
            font.pixelSize: SettingsState.px(13)
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }
        }

        // Active indicator checkmark badge
        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 22
          height: 22
          radius: 11
          color: modelData.isDefault ? SettingsState.accent : "transparent"
          border.color: modelData.isDefault ? SettingsState.accent : SettingsState.borderBase
          border.width: 1

          Text {
            anchors.centerIn: parent
            visible: modelData.isDefault
            text: "\ueab2"
              font.family: SettingsState.nerdIconFont
            color: SettingsState.isDark ? "#121612" : "#ffffff"
            font.pixelSize: SettingsState.px(14)
            font.bold: true
          }
        }
      }

      MouseArea {
        id: mDevMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          AudioState.setDefaultSource(modelData);
        }
      }
    }
  }
}
