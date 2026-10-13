import QtQuick
import "../services"

// Unified sound-output / microphone-input subview (replaces the
// near-identical SoundPage.qml / MicPage.qml pair).
// direction: "output" (speakers) | "input" (microphone)
Column {
  id: audioPage
  required property var circle
  required property bool hovered
  property string direction: "output"

  readonly property bool isOutput: direction === "output"
  readonly property string pageName: isOutput ? "sound" : "mic"
  readonly property string titleText: isOutput ? "SOUND OUTPUT" : "MICROPHONE INPUT"
  readonly property string iconKind: isOutput ? "sound" : "mic"
  readonly property bool muted: isOutput ? circle.outMuted : circle.inMuted
  readonly property real level: isOutput ? circle.outVol : circle.inVol
  readonly property var devices: isOutput ? AudioState.sinks : AudioState.sources

  spacing: 12
  opacity: (hovered && circle.activePage === pageName) ? 1 : 0
  visible: opacity > 0

  Behavior on opacity {
    NumberAnimation { duration: 220 }
  }

  function toggleMute() {
    if (isOutput) AudioState.toggleOutMute();
    else AudioState.toggleInMute();
  }

  function setLevel(v) {
    if (isOutput) AudioState.setOutVol(v);
    else AudioState.setInVol(v);
  }

  function setDefaultDevice(d) {
    if (isOutput) AudioState.setDefaultSink(d);
    else AudioState.setDefaultSource(d);
  }

  // Audio Header
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
        color: audioBackMouse.containsMouse ? SettingsState.bgCardHover : "transparent"
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
          id: audioBackMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            circle.activePage = "mixer";
          }
        }
      }

      Item {
        anchors.verticalCenter: parent.verticalCenter
        width: audioTitleGroup.implicitWidth + 4
        height: 28

        Row {
          id: audioTitleGroup
          anchors.verticalCenter: parent.verticalCenter
          spacing: 6

          // Title
          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: audioPage.titleText
            color: SettingsState.accent
            font.pixelSize: SettingsState.px(14)
            font.family: SettingsState.fontFamily
            font.letterSpacing: 2
            font.weight: Font.DemiBold
          }
        }

        MouseArea {
          id: audioTitleMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            circle.activePage = "mixer";
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
        text: audioPage.muted ? "Muted" : (Math.round(audioPage.level * 100) + "%")
        color: audioPage.muted ? "#ff8a8a" : SettingsState.textActive
        font.pixelSize: SettingsState.px(14)
        font.bold: true
        font.family: SettingsState.fontFamily
      }

      // Mute toggle switch
      MiniToggle {
        width: 40
        height: 22
        anchors.verticalCenter: parent.verticalCenter
        on: !audioPage.muted
        knobOn: SettingsState.isDark ? "#ffffff" : "#000000"
        onToggled: audioPage.toggleMute()
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
    label: audioPage.isOutput ? "Volume" : "Input Level"
    icon: audioPage.iconKind
    value: audioPage.level
    muted: audioPage.muted
    available: audioPage.isOutput ? (AudioState.sink !== null && AudioState.sink !== undefined) : (AudioState.source !== null && AudioState.source !== undefined)
    onSeeked: function (v) {
      audioPage.setLevel(v);
    }
    onIconClicked: audioPage.toggleMute()
  }

  // Section title
  Item {
    width: parent.width
    height: 20

    Text {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: audioPage.isOutput ? "Select Output Device" : "Select Input Device"
      color: SettingsState.textSecondary
      font.pixelSize: SettingsState.px(14)
      font.bold: true
      font.family: SettingsState.fontFamily
    }

    Text {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      text: ((audioPage.devices ? audioPage.devices.length : 0) || 0) + " available"
      color: SettingsState.textMuted
      font.pixelSize: SettingsState.px(13)
      font.family: SettingsState.fontFamily
    }
  }

  // Device List
  Text {
    visible: ((audioPage.devices ? audioPage.devices.length : 0) || 0) === 0
    text: audioPage.isOutput ? "No output devices found" : "No input devices found"
    color: SettingsState.textMuted
    font.pixelSize: SettingsState.px(14)
    font.family: SettingsState.fontFamily
    anchors.horizontalCenter: parent.horizontalCenter
  }

  ListView {
    width: parent.width
    height: visible ? Math.min(260, ((audioPage.devices ? audioPage.devices.length : 0) || 0) * 60 - 8) : 0
    visible: (((audioPage.devices ? audioPage.devices.length : 0) || 0) > 0)
    spacing: 8
    clip: true
    model: audioPage.devices

    Behavior on height {
      NumberAnimation {
        duration: 250
        easing.type: Easing.OutCubic
      }
    }

    delegate: Rectangle {
      required property var modelData
      width: ListView.view.width
      height: 52
      radius: 16
      color: modelData.isDefault ? SettingsState.bgActivePill : (devMouse.containsMouse ? SettingsState.bgCardHover : SettingsState.bgCard)
      border.color: modelData.isDefault ? SettingsState.borderActive : (devMouse.containsMouse ? SettingsState.borderActive : SettingsState.borderBase)
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
            kind: audioPage.iconKind
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
            text: modelData.description || modelData.name || (audioPage.isOutput ? "Output Device" : "Input Device")
            color: modelData.isDefault ? SettingsState.textActive : SettingsState.textMain
            font.pixelSize: SettingsState.px(15)
            font.bold: modelData.isDefault
            font.family: SettingsState.fontFamily
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            text: modelData.isDefault ? (audioPage.isOutput ? "Active Output Route" : "Active Input Route") : (modelData.name || (audioPage.isOutput ? "Audio Sink" : "Audio Source"))
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
        id: devMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          audioPage.setDefaultDevice(modelData);
        }
      }
    }
  }
}
