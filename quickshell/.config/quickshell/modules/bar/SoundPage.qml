import Quickshell
import QtQuick
import "../services"

// Sound output subview. Extracted from NetworkCircle.qml.
Column {
  id: soundPage
  required property var circle
  required property bool hovered
  spacing: 12
  opacity: (hovered && circle.activePage === "sound") ? 1 : 0
  visible: opacity > 0

  Behavior on opacity {
    NumberAnimation { duration: 220 }
  }

  // Sound Header
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
        color: soundBackMouse.containsMouse ? "#252b25" : "transparent"
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
          id: soundBackMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            circle.activePage = "main";
          }
        }
      }

      // Icon
      CCIcon {
        anchors.verticalCenter: parent.verticalCenter
        width: 18
        height: 18
        kind: "sound"
        glyph: SettingsState.accent
      }

      // Title
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "SOUND OUTPUT"
        color: SettingsState.textMain
        font.pixelSize: SettingsState.px(16)
        font.bold: true
        font.family: SettingsState.fontFamily
        font.letterSpacing: 1.2
      }
    }

    Row {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      spacing: 10

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: circle.outMuted ? "Muted" : (Math.round(circle.outVol * 100) + "%")
        color: circle.outMuted ? "#ff8a8a" : SettingsState.textActive
        font.pixelSize: SettingsState.px(14)
        font.bold: true
        font.family: SettingsState.fontFamily
      }

      // Mute toggle switch
      Rectangle {
        width: 40
        height: 22
        radius: 11
        color: !circle.outMuted ? SettingsState.accent : SettingsState.bgCard
        anchors.verticalCenter: parent.verticalCenter

        Behavior on color {
          ColorAnimation { duration: 200 }
        }

        Rectangle {
          width: 16
          height: 16
          radius: 8
          color: !circle.outMuted ? (SettingsState.isDark ? "#ffffff" : "#000000") : SettingsState.textMuted
          anchors.verticalCenter: parent.verticalCenter
          x: !circle.outMuted ? parent.width - width - 3 : 3

          Behavior on x {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
          }
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: AudioState.toggleOutMute()
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

  // Volume Slider
  CCSlider {
    width: parent.width
    label: "Volume"
    icon: "sound"
    value: circle.outVol
    muted: circle.outMuted
    available: AudioState.sink !== null && AudioState.sink !== undefined
    onSeeked: function (v) {
      AudioState.setOutVol(v);
    }
    onIconClicked: AudioState.toggleOutMute()
  }

  // Section title
  Item {
    width: parent.width
    height: 20

    Text {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: "Select Output Device"
      color: SettingsState.textSecondary
      font.pixelSize: SettingsState.px(14)
      font.bold: true
      font.family: SettingsState.fontFamily
    }

    Text {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      text: (AudioState.sinks.length || 0) + " available"
      color: SettingsState.textMuted
      font.pixelSize: SettingsState.px(13)
      font.family: SettingsState.fontFamily
    }
  }

  // Output Device List
  ListView {
    width: parent.width
    height: 260
    spacing: 8
    clip: true
    model: AudioState.sinks

    delegate: Rectangle {
      required property var modelData
      width: ListView.view.width
      height: 52
      radius: 16
      color: modelData.isDefault ? SettingsState.bgActivePill : (sDevMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: modelData.isDefault ? SettingsState.borderActive : (sDevMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
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
            kind: "sound"
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
            text: modelData.description || modelData.name || "Output Device"
            color: modelData.isDefault ? SettingsState.textActive : SettingsState.textMain
            font.pixelSize: SettingsState.px(15)
            font.bold: modelData.isDefault
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            text: modelData.isDefault ? "Active Output Route" : (modelData.name || "Audio Sink")
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
            text: "✓"
              font.family: SettingsState.nerdIconFont
            color: SettingsState.isDark ? "#121612" : "#ffffff"
            font.pixelSize: SettingsState.px(14)
            font.bold: true
          }
        }
      }

      MouseArea {
        id: sDevMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          AudioState.setDefaultSink(modelData);
        }
      }
    }
  }
}
