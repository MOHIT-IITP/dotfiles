import QtQuick
import "../services"

// Shared mixer UI: header (back + 調 MIXER + quick-toggle pill cluster),
// divider, and the 4 vertical faders (Brightness / Display / Volume / Microphone).
// Used by MixerPage (control-center subview, navigates via circle) and
// HardwareMixerContent (center-bar modal, talks via signals).
Column {
  id: root

  property bool showBack: true
  property real outVol: 0
  property bool outMuted: false
  property real inVol: 0
  property bool inMuted: false
  property color waveColor: SettingsState.accent

  signal back()
  signal openSound()
  signal openMic()

  spacing: 12

  // Mixer Header: [‹] [調 MIXER] ---------- quick-toggle pill cluster
  Item {
    width: parent.width
    height: 36

    // Left: Back button + Japanese Kanji + Title
    Row {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      spacing: 8

      // Back button (control-center subview only)
      Rectangle {
        visible: root.showBack
        width: root.showBack ? 26 : 0
        height: 26
        radius: 13
        color: mixerBackMouse.containsMouse ? SettingsState.bgCardHover : "transparent"
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
          id: mixerBackMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.back()
        }
      }

      Item {
        anchors.verticalCenter: parent.verticalCenter
        width: mixerTitleGroup.implicitWidth + 4
        height: 28

        Row {
          id: mixerTitleGroup
          anchors.verticalCenter: parent.verticalCenter
          spacing: 6

          // Title
          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "MIXER"
            color: SettingsState.accent
            font.pixelSize: SettingsState.px(14)
            font.family: SettingsState.fontFamily
            font.letterSpacing: 2
            font.weight: Font.DemiBold
          }
        }

        MouseArea {
          id: mixerTitleMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          enabled: root.showBack
          onClicked: root.back()
        }
      }
    }

    // Right: Pill Cluster of Quick Toggle Buttons
    Rectangle {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      height: 32
      width: toggleRow.implicitWidth + 8
      radius: 16
      color: SettingsState.bgCard
      border.color: SettingsState.borderBase
      border.width: 1

      Row {
        id: toggleRow
        anchors.centerIn: parent
        spacing: 2

        // 1. Sound mute toggle
        Rectangle {
          width: 28
          height: 26
          radius: 13
          color: !root.outMuted ? SettingsState.bgActivePill : (sndBtnMouse.containsMouse ? SettingsState.bgCardHover : "transparent")
          CCIcon {
            anchors.centerIn: parent
            width: 14
            height: 14
            kind: root.outMuted ? "sound-mute" : "sound"
            glyph: !root.outMuted ? SettingsState.textActive : (root.outMuted ? "#ff8a8a" : SettingsState.textSecondary)
          }
          MouseArea {
            id: sndBtnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              AudioState.refreshDevices();
              root.openSound();
            }
          }
        }

        // 2. Mic mute toggle
        Rectangle {
          width: 28
          height: 26
          radius: 13
          color: !root.inMuted ? SettingsState.bgActivePill : (micBtnMouse.containsMouse ? SettingsState.bgCardHover : "transparent")
          CCIcon {
            anchors.centerIn: parent
            width: 14
            height: 14
            kind: root.inMuted ? "mic-mute" : "mic"
            glyph: !root.inMuted ? SettingsState.textActive : (root.inMuted ? "#ff8a8a" : SettingsState.textSecondary)
          }
          MouseArea {
            id: micBtnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              AudioState.refreshDevices();
              root.openMic();
            }
          }
        }

        // 3. Notification DND toggle
        Rectangle {
          width: 28
          height: 26
          radius: 13
          color: NotifCenter.dnd ? SettingsState.bgActivePill : (dndBtnMouse.containsMouse ? SettingsState.bgCardHover : "transparent")
          CCIcon {
            anchors.centerIn: parent
            width: 14
            height: 14
            kind: "moon"
            glyph: NotifCenter.dnd ? SettingsState.textActive : SettingsState.textSecondary
          }
          MouseArea {
            id: dndBtnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: NotifCenter.toggleDnd()
          }
        }

        // 4. Nightlight toggle
        Rectangle {
          width: 28
          height: 26
          radius: 13
          color: NightlightState.active ? SettingsState.bgActivePill : (eyeBtnMouse.containsMouse ? SettingsState.bgCardHover : "transparent")
          CCIcon {
            anchors.centerIn: parent
            width: 14
            height: 14
            kind: "sunset"
            glyph: NightlightState.active ? SettingsState.textActive : SettingsState.textSecondary
          }
          MouseArea {
            id: eyeBtnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: NightlightState.toggle()
          }
        }

        // 5. Brightness toggle
        Rectangle {
          width: 28
          height: 26
          radius: 13
          color: brBtnMouse.containsMouse ? SettingsState.bgCardHover : "transparent"
          CCIcon {
            anchors.centerIn: parent
            width: 14
            height: 14
            kind: "sun"
            glyph: brBtnMouse.containsMouse ? SettingsState.accent : SettingsState.textSecondary
          }
          MouseArea {
            id: brBtnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: BrightnessState.setBrightness(BrightnessState.brightness > 0.4 ? 0.2 : 0.9)
          }
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

  // 4 Vertical Faders Row
  Row {
    width: parent.width
    height: 270
    spacing: Math.max(8, Math.floor((parent.width - (4 * 80)) / 3))

    // 1. Brightness Fader
    VerticalFader {
      width: 80
      height: parent.height
      label: "Brightness"
      icon: "sun"
      value: BrightnessState.brightness
      activeColor: root.waveColor
      onSeeked: function (v) {
        BrightnessState.setBrightness(v);
      }
    }

    // 2. Display / Screen Backlight Fader
    VerticalFader {
      width: 80
      height: parent.height
      label: "Display"
      icon: "display"
      value: BrightnessState.brightness
      activeColor: root.waveColor
      onSeeked: function (v) {
        BrightnessState.setBrightness(v);
      }
    }

    // 3. Master Volume Fader
    VerticalFader {
      width: 80
      height: parent.height
      label: "Volume"
      icon: "sound"
      value: root.outVol
      muted: root.outMuted
      activeColor: root.waveColor
      onSeeked: function (v) {
        AudioState.setOutVol(v);
      }
      onIconClicked: {
        AudioState.refreshDevices();
        root.openSound();
      }
    }

    // 4. Microphone Fader
    VerticalFader {
      width: 80
      height: parent.height
      label: "Microphone"
      icon: "mic"
      value: root.inVol
      muted: root.inMuted
      activeColor: root.waveColor
      onSeeked: function (v) {
        AudioState.setInVol(v);
      }
      onIconClicked: {
        AudioState.refreshDevices();
        root.openMic();
      }
    }
  }
}
